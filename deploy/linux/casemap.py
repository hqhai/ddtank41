#!/usr/bin/env python3
"""Write a "lower-case URL -> real URL" table for nginx (see nginx.conf.template).

The Flash client and its web handlers were written for Windows/IIS, whose file system is
case-insensitive: the client asks for e.g. "firstTainer.swf" or "serverlist.ashx" while the files
are "firsttainer.swf" / "ServerList.ashx". On Linux nginx rewrites such requests to the real name.

usage: casemap.py OUT_DIR MAP_FILE
"""
import os
import sys

# URL prefix -> directory (relative to OUT_DIR)
ROOTS = {
    "/": "web/Tank.Flash",
    "/request/": "web/Tank.Request",
    "/flash/": "site/flash",
    "/resource/": "site/resource",
}


def main(out, map_file):
    entries = {}
    for prefix, rel in ROOTS.items():
        base = os.path.join(out, rel)
        for dirpath, dirnames, filenames in os.walk(base):
            dirnames[:] = [d for d in dirnames if d not in ("bin", "obj", "logs")]
            for name in dirnames + filenames:
                url = prefix + os.path.relpath(os.path.join(dirpath, name), base).replace(os.sep, "/")
                entries.setdefault(url.lower(), url)
    with open(map_file, "w", encoding="utf-8") as f:
        for k, v in sorted(entries.items()):
            f.write(f"{k}\t{v}\n")
    print(f"case map: {len(entries)} entries -> {map_file}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
