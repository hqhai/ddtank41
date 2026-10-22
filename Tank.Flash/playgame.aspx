<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="playgame.aspx.cs" Inherits="Tank.Flash.playgame" %>

<html>

<head id="Head1" runat="server">
<title>DDTank</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@700;800&display=swap" />
    <link rel="stylesheet" href="theme/site.css" />
    <script type="text/javascript" src="/site-config.js"></script>
    <script type="text/javascript" src="script/jquery-1.7.2.min.js"></script>
    <script type="text/javascript" src="script/dandantang.js"></script>
    <script type="text/javascript" src="script/rightClick.js"></script>
    <script type="text/javascript" src="script/swfobject.js"></script>
    <script type="text/javascript" src="script/isSafeFlash.js"></script>
    <!-- Ruffle: runs the Flash client in modern browsers (no Flash Player plugin needed) -->
    <script type="text/javascript" src="/ruffle-config.js"></script>
    <script type="text/javascript" src="/ruffle/ruffle.js"></script>
<style type="text/css">
        .game-frame { display: flex; align-items: center; justify-content: center; overflow: auto; }
        .game-frame table { margin: auto; }
    </style>
   
</head>
<body scroll="no" class="game-body">
<div class="game-bar">
    <a class="logo" href="index.htm"><span class="tag">PVP</span><span class="name" data-site="name">DDTank</span></a>
    <div class="actions">
        <button class="pill-btn" id="fullscreen">&#x26F6; Toàn màn hình</button>
        <a class="pill-btn" href="index.htm">Thoát</a>
    </div>
</div>
<div class="game-frame" id="frame">
<table border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td valign="middle">
                <table border="0" align="center" cellpadding="0" cellspacing="0">
                    <tr>
                        <td align="center">
                            <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" id="7road-ddt-game"
                                codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0"
                                name="Main" width="1000" height="600" align="middle" id="Main">
                                <param name="allowScriptAccess" value="always" />
                                <param name="movie" value="<%=Flash %>Loading.swf?<%=Content %>&config=<%=Config %>" />
                                <param name="quality" value="high" />
                                <param name="menu" value="false">
                                <param name="bgcolor" value="#000000" />
                                <param name="FlashVars" value="<%=AutoParam %>" />
                                <param name="allowScriptAccess" value="always" />
                                <embed flashvars="<%=AutoParam %>" src="<%=Flash %>Loading.swf?<%=Content %>&config=<%=Config %>"
                                    width="1000" height="600" align="middle" quality="high" name="Main" allowscriptaccess="always"
                                    type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" wmode="direct"/>
                            </object>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</div>
<script type="text/javascript">
    (function () {
        var name = (window.SITE_CONFIG || {}).name || "DDTank";
        document.title = name;
        var els = document.querySelectorAll('[data-site="name"]');
        for (var i = 0; i < els.length; i++) els[i].textContent = name;
        var frame = document.getElementById("frame");
        document.getElementById("fullscreen").onclick = function () {
            if (document.fullscreenElement) document.exitFullscreen();
            else if (frame.requestFullscreen) frame.requestFullscreen();
        };
        window.onbeforeunload = function () { return "Bạn có chắc là muốn thoát không?"; };
    })();
</script>
</body>
</html>
