#!/usr/bin/env python3
"""Apply deploy/server.env to every configuration file of the assembled deployment.

Edits (in OUT_DIR, default deploy/out):
  server/{Center,Fighting,Road}.Service/*.exe.config   DB connection strings, bind IPs, login key, paths
  web/Tank.Request/Web.config, web/Tank.Flash/Web.config DB connection strings, login key, URLs
  site/flash/config.xml                                 Flash client URLs (FLASHSITE, SITE, REQUEST_PATH, ...)
  site/ruffle-config.js                                 Ruffle (browser Flash emulator) socket proxy
  sql/90_configure.sql                                  Server_List row (game server address shown to players)

usage: configure.py [ENV_FILE] [OUT_DIR]
"""
import os
import re
import sys
import xml.etree.ElementTree as ET

HERE = os.path.dirname(os.path.abspath(__file__))


def load_env(path):
    env = {}
    defaults = os.path.join(HERE, "server.env.example")
    for p in (defaults, path):
        if p and os.path.exists(p):
            for line in open(p, encoding="utf-8"):
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    env[k.strip()] = v.strip()
    # environment variables override the file (handy for docker)
    for k in list(env):
        if k in os.environ:
            env[k] = os.environ[k]
    return env


def conn(env, db):
    return (f"Data Source={env['DB_HOST']};Initial Catalog={db};Persist Security Info=True;"
            f"User ID={env['DB_USER']};Password={env['DB_PASSWORD']};Enlist=false")


def set_app_settings(path, values):
    """Set <appSettings><add key=.. value=..> entries, preserving the rest of the file."""
    text = open(path, encoding="utf-8-sig").read()
    for key, value in values.items():
        esc = (value.replace("&", "&amp;").replace('"', "&quot;").replace("<", "&lt;").replace(">", "&gt;"))
        pat = re.compile(r'(<add\s+key="' + re.escape(key) + r'"\s+value=")[^"]*(")')
        if pat.search(text):
            text = pat.sub(lambda m: m.group(1) + esc + m.group(2), text)
        else:
            text = text.replace("<appSettings>", f'<appSettings>\n\t\t<add key="{key}" value="{esc}" />', 1)
    open(path, "w", encoding="utf-8").write(text)


def env_on(env, key, default):
    value = env.get(key, "")
    return default if value == "" else value.lower() in ("1", "true", "yes", "on")


def newbie_guide_sql(skip):
    """IsOldPlayer=1 makes the client treat every newbie-guide step as done: no tutorial,
    every building (game room, shop, ...) open from level 1. Applies to new characters via
    the column default; when skipping, existing characters are switched too."""
    value = 1 if skip else 0
    sql = f"""DECLARE @c sysname = (SELECT d.name FROM sys.default_constraints d
    WHERE d.parent_object_id = OBJECT_ID('dbo.Sys_Users_Detail')
      AND COL_NAME(d.parent_object_id, d.parent_column_id) = 'IsOldPlayer');
IF @c IS NOT NULL EXEC('ALTER TABLE dbo.Sys_Users_Detail DROP CONSTRAINT [' + @c + ']');
ALTER TABLE dbo.Sys_Users_Detail ADD DEFAULT ({value}) FOR IsOldPlayer;
"""
    if skip:
        sql += "UPDATE dbo.Sys_Users_Detail SET IsOldPlayer = 1 WHERE IsOldPlayer = 0;\n"
    return sql + "GO"


def main():
    env_file = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "server.env")
    out = sys.argv[2] if len(sys.argv) > 2 else os.path.join(HERE, "out")
    env = load_env(env_file)

    host = env["PUBLIC_HOST"]
    port = env.get("WEB_PORT", "80")
    # port players type in the browser (differs from WEB_PORT when docker maps e.g. 8080 -> 80)
    public_port = env.get("PUBLIC_WEB_PORT") or port
    web = f"http://{host}" + ("" if public_port == "80" else f":{public_port}")
    internal_web = env.get("INTERNAL_WEB_URL", f"http://127.0.0.1:{port}")
    player, game, member = env["DB_PLAYER"], env["DB_GAME"], env["DB_MEMBERSHIP"]
    key = env["LOGIN_KEY"]

    common = {
        "conString": conn(env, player),
        "crosszoneString": conn(env, game),
        "LanguagePath": "Languages/Language-vn.txt",
        "LoginKey": key,
    }
    services = {
        "Center.Service": {"IP": "127.0.0.1", "SystemNoticePath": "Languages/SystemNotice.xml"},
        "Fighting.Service": {"IP": "127.0.0.1",
                             "PvpAutoBot": "true" if env_on(env, "PVP_AUTO_BOT", False) else "false"},
        "Road.Service": {"IP": "0.0.0.0", "Port": env.get("GAME_PORT", "9500"),
                         "LoginServerIp": "127.0.0.1", "FightServerIp": "127.0.0.1",
                         "ScriptCompilationTarget": "./GameServerScripts.dll"},
    }
    for svc, extra in services.items():
        cfg = os.path.join(out, "server", svc, f"{svc}.exe.config")
        if os.path.exists(cfg):
            set_app_settings(cfg, {**common, **extra})
            print("configured", cfg)

    req = os.path.join(out, "web", "Tank.Request", "Web.config")
    if os.path.exists(req):
        set_app_settings(req, {
            **common,
            "LanguagePath": "bin/Languages/Language-vn.txt",
            "LoginKey_a": key,
            "membershipDb": conn(env, member),
            "LogPath": "logs",
            "ReqPath": "./",
            "LoginIP": "",
            # xu / vàng every new character starts with
            "DefaultMoney": env.get("STARTING_MONEY") or "1000000",
            "DefaultGold": env.get("STARTING_GOLD") or "1000000",
        })
        print("configured", req)

    portal = os.path.join(out, "web", "Tank.Flash", "Web.config")
    if os.path.exists(portal):
        set_app_settings(portal, {
            "LoginKey": key,
            "LoginKey_a": key,
            "LoginUrl": f"{internal_web}/request/CreateLogin.aspx",
            "LoginOnUrl": "/index.htm?open=self",
            "FlashUrl": "/playgame.aspx",
            "FlashConfig": f"{web}/flash/config.xml",
            "FlashSite": f"{web}/flash/",
            "membershipDb": conn(env, member),
            "conString": conn(env, player),
            "crosszoneString": conn(env, game),
        })
        print("configured", portal)

    flash_cfg = os.path.join(out, "site", "flash", "config.xml")
    if os.path.exists(flash_cfg):
        text = open(flash_cfg, encoding="utf-8-sig").read()
        urls = {
            "FLASHSITE": f"{web}/flash/",
            "BACKUP_FLASHSITE": f"{web}/flash/",
            "SITE": f"{web}/resource/",
            "FIRSTPAGE": f"{web}/",
            "REGISTER": f"{web}/",
            "REQUEST_PATH": f"{web}/request/",
            "LOGIN_PATH": f"{web}/index.htm",
            "FILL_PATH": f"{web}/",
            "WEEKLYSITE": f"{web}/flash/",
        }
        for tag, value in urls.items():
            text = re.sub(r'(<' + tag + r'\s+value=")[^"]*(")', lambda m: m.group(1) + value + m.group(2), text)
        text = re.sub(r'(<POLICY_FILES>\s*<file value=")[^"]*(")',
                      lambda m: m.group(1) + f"{web}/flash/crossdomain.xml" + m.group(2), text)
        open(flash_cfg, "w", encoding="utf-8").write(text)
        print("configured", flash_cfg)

    ruffle_cfg = os.path.join(out, "site", "ruffle-config.js")
    os.makedirs(os.path.dirname(ruffle_cfg), exist_ok=True)
    ws_port = env.get("WS_PORT", "9501")
    game_port = env.get("GAME_PORT", "9500")
    with open(ruffle_cfg, "w", encoding="utf-8") as f:
        f.write(f"""// generated by deploy/configure.py
window.RufflePlayer = window.RufflePlayer || {{}};
window.RufflePlayer.config = {{
  autoplay: "on",
  unmuteOverlay: "hidden",
  letterbox: "on",
  allowScriptAccess: true,
  openUrlMode: "allow",
  logLevel: "{env.get('RUFFLE_LOG_LEVEL', 'error')}",
  // the client renders Vietnamese text with device fonts (Arial/Tahoma); Ruffle needs real font files
  fontSources: ["/fonts/DejaVuSans.ttf", "/fonts/DejaVuSans-Bold.ttf", "/fonts/DejaVuSerif.ttf", "/fonts/DejaVuSansMono.ttf"],
  defaultFonts: {{ sans: ["DejaVu Sans"], serif: ["DejaVu Serif"], typewriter: ["DejaVu Sans Mono"] }},
  // the Flash client talks raw TCP to the game server; browsers can only do WebSockets,
  // so the connection is bridged by websockify (WS_PORT -> GAME_PORT)
  socketProxy: [
    {{ host: "{host}", port: {game_port}, proxyUrl: "ws://" + location.hostname + ":{ws_port}" }},
    {{ host: "127.0.0.1", port: {game_port}, proxyUrl: "ws://" + location.hostname + ":{ws_port}" }},
    {{ host: "localhost", port: {game_port}, proxyUrl: "ws://" + location.hostname + ":{ws_port}" }}
  ]
}};
""")
    print("configured", ruffle_cfg)

    sql = os.path.join(out, "sql", "90_configure.sql")
    os.makedirs(os.path.dirname(sql), exist_ok=True)
    with open(sql, "w", encoding="utf-8") as f:
        f.write(f"""-- generated by deploy/configure.py: address of the game server shown in the server list
USE [{player}];
UPDATE Server_List SET IP = N'{host}', Port = {game_port}, State = 1;
GO
{newbie_guide_sql(env_on(env, "SKIP_NEWBIE_GUIDE", True))}
""")
    print("configured", sql)


if __name__ == "__main__":
    main()
