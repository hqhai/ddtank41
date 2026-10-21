# Hướng dẫn dựng & chơi DDTank 4.1 (Gunny)

Tài liệu này mô tả cách chạy bộ source này thành một game chơi được trên **trình duyệt hiện đại**
(Chrome/Edge/Firefox — không cần Adobe Flash Player) nhờ [Ruffle](https://ruffle.rs).

## Kiến trúc

```
Trình duyệt (Ruffle chạy client Flash)
   │  HTTP :80  ── nginx ── /            Tank.Flash   (trang đăng ký / đăng nhập / vào game)
   │                     ├─ /request/   Tank.Request (API XML cho client: login, template, shop…)
   │                     ├─ /flash/     client Flash (Source Flash/FlashSV1)
   │                     └─ /resource/  ảnh trang bị, bản đồ, bom, âm thanh…
   │  WebSocket :9501 ── websockify ──► Road.Service :9500 (game server)
   │                                         ├─ Center.Service :9202 (+WCF :2008/2009)
   │                                         └─ Fighting.Service :9208 (trận đấu)
   └──────────────────────────────────── SQL Server: Db_Membership, Project_Player34, Project_Game34
```

## Cách 1 — Docker (khuyến nghị, chạy được trên Windows/Linux/macOS)

Yêu cầu: [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/macOS) hoặc Docker Engine (Linux), ~8 GB dung lượng trống.

```bash
cd deploy/docker
cp .env.example .env        # sửa PUBLIC_HOST nếu cho người khác vào chơi (IP LAN / IP public / domain)
docker compose up -d --build
```

Lần đầu sẽ mất 10–20 phút (build server, tải ~650 MB resource từ GitHub, restore database).
Xem tiến trình: `docker compose logs -f game`. Khi thấy `Game ready` thì mở:

**http://127.0.0.1/** → *Đăng ký nhanh* → đăng nhập → chọn nhân vật → chơi.

Mở cổng tường lửa nếu cho người khác chơi: `WEB_PORT` (80), `WS_PORT` (9501) và `GAME_PORT` (9500).

Dừng: `docker compose down` (dữ liệu nằm trong volume `sqldata`, không mất).
Xoá sạch dữ liệu để làm lại từ đầu: `docker compose down -v`.

## Cách 2 — Chạy trực tiếp trên Linux (Ubuntu 24.04)

```bash
sudo apt install dotnet-sdk-8.0 mono-complete mono-fastcgi-server4 nginx libnginx-mod-http-perl \
                 websockify tmux python3 git curl
# SQL Server: dùng docker (hoặc cài mssql-server)
docker run -d --name ddt-sql -e ACCEPT_EULA=Y -e 'MSSQL_SA_PASSWORD=Ddtank@2024' -p 1433:1433 \
       -v "$PWD/Database:/backup:ro" mcr.microsoft.com/mssql/server:2022-latest
# restore 3 database + áp các bản vá SQL (xem deploy/docker/init-db.sh để biết lệnh), rồi:
cp deploy/server.env.example deploy/server.env   # sửa DB_PASSWORD, PUBLIC_HOST, ...
deploy/setup.sh                                   # build + tải resource + cấu hình (deploy/out/)
for f in deploy/out/sql/*.sql; do docker exec -i ddt-sql /opt/mssql-tools18/bin/sqlcmd \
     -S localhost -U sa -P 'Ddtank@2024' -C -b < "$f"; done
deploy/linux/start.sh                             # chạy tất cả (tmux)
deploy/linux/stop.sh                              # dừng (lưu dữ liệu người chơi)
```

Console từng server: `tmux attach -t ddt-road` (thoát giữ server chạy: `Ctrl-b` rồi `d`).
Đổi IP/cổng/mật khẩu: sửa `deploy/server.env` → `deploy/setup.sh configure` → stop/start.

## Cách 3 — Windows thuần (IIS + .NET Framework 4.8)

Code vẫn chạy trên Windows như bản gốc (các sửa đổi đều tương thích):

1. Cài SQL Server (hoặc dùng container như trên), restore `Database/*.bak` thành
   `Db_Membership`, `Project_Game34`, `Project_Player34`, rồi chạy lần lượt `deploy/sql/*.sql`.
2. Mở `DDTank 3.0.sln` bằng Visual Studio 2022, build Center/Fighting/Road.Service và
   `GameServerScripts`, chép `GameServerScripts.dll` vào thư mục chạy của Road.Service và
   Fighting.Service (cạnh file .exe); build `Tank.Request` và `Tank.Flash` (Request.sln / Tank.Flash.Single.sln).
3. Dùng Git Bash: `deploy/setup.sh` để tải resource + Ruffle và sinh cấu hình vào `deploy/out/`
   (hoặc sửa tay `App.config`/`Web.config`: chuỗi kết nối, `LoginKey` giống nhau ở cả 2 web).
4. IIS: site gốc trỏ `Tank.Flash`, application `/request` trỏ `Tank.Request`, virtual directory
   `/flash` → `deploy/out/site/flash`, `/resource` → `deploy/out/site/resource`,
   `/ruffle` → `deploy/out/site/ruffle`, `/fonts` → `deploy/out/site/fonts`, file `ruffle-config.js`.
5. Chạy websockify (Python: `pip install websockify` → `websockify 9501 127.0.0.1:9500`)
   để trình duyệt kết nối được game server. (Nếu dùng Flash Player projector/launcher cũ thì không cần.)
6. Chạy Center.Service → Fighting.Service → Road.Service.

## Tài khoản

- Đăng ký trên trang chủ (có mã xác nhận). Lần đầu vào game sẽ chọn giới tính + tên nhân vật.
- Đánh PvP: người vào **cùng một phòng là đồng đội**. Mỗi đội bấm **Bắt đầu** (trong Phòng game)
  để tạo một phòng "Thi đấu", mời đồng đội bằng nút **Mời**, rồi chủ phòng bấm **Bắt đầu** → hệ thống
  ghép với một phòng khác **có cùng số người** (1v1, 2v2, 3v3, 4v4). ("Tổ đội" là tìm phòng có sẵn
  để vào nhanh.)
- Nâng cấp/cộng xu cho tài khoản (GM) bằng SQL, ví dụ:
  `UPDATE Project_Player34..Sys_Users_Detail SET Grade=20, GP=200000, Money=1000000 WHERE UserName='ten_dang_nhap'`
  (làm khi người chơi đang offline).

## Tuỳ chọn cho server PvP

Đặt trong `deploy/docker/.env` (Docker) hoặc `deploy/server.env` (chạy trực tiếp), rồi khởi động lại
(`docker compose up -d`):

| Biến | Mặc định | Ý nghĩa |
|---|---|---|
| `SKIP_NEWBIE_GUIDE` | `true` | Bỏ màn hướng dẫn tân thủ: nhân vật mới (cấp 1) vào thẳng sảnh, mọi khu (Phòng game, Shop…) mở sẵn, không còn mũi tên/bảng chỉ dẫn. Bật thì áp dụng cả cho nhân vật cũ. |
| `PVP_AUTO_BOT` | `false` | `false`: chỉ ghép phòng người với phòng người, không có bot; mọi phòng cùng số người đều ghép được với nhau (không giới hạn thời gian chờ hay chênh lệch lực chiến). `true`: như game gốc, chờ ~20 giây không có ai thì đánh với bot. |
| `STARTING_MONEY` / `STARTING_GOLD` | `1000000` | Xu / vàng tặng sẵn cho **nhân vật mới tạo** để mua vũ khí, đạo cụ chiến đấu trong Shop. |

## Những gì đã được phục dựng / bù vào

| Hạng mục | Tình trạng ban đầu | Đã làm |
|---|---|---|
| Thư mục resource (ảnh đồ, map, bom, âm thanh…) | Thiếu hoàn toàn (CDN gunny.vcdn.vn đã chết) | Tải & ghép từ 2 repo GitHub công khai (`deploy/fetch-resources.sh`) |
| `bombs/*.swf`, `Catharine.swf` của client | Thiếu | Lấy từ dk-khoado/Gunny-3.0 |
| Stored procedure `Check_User`, `Mem_UserInfo_Addmin`, … | Thiếu → không đăng nhập web được | Viết bù (`deploy/sql/10..30`) |
| Proc lưu người chơi lệch tham số với code | Không lưu được dữ liệu | Đồng bộ (`deploy/sql/40`) |
| Tank.Flash gửi sai định dạng login cho Tank.Request, `LoginKey` 2 bên khác nhau | Không vào được game | Sửa định dạng, cấu hình chung 1 key |
| Flash Player đã bị khai tử | Không chạy được trên trình duyệt | Nhúng Ruffle + websockify + font tiếng Việt |
| Chạy trên Linux/Docker | Chỉ Windows | Sửa đường dẫn, IniReader, console, log, phân biệt hoa/thường… |
| Script AI phó bản (PvE) | Bị tác giả xoá (không biên dịch được) | Khôi phục từ lịch sử git + DLL cũ, bổ sung API engine → project `GameServerScripts` (598/757 script DB tham chiếu chạy được) |
| Tạo nhân vật lần đầu | Client gọi đăng ký trước khi tài khoản game tồn tại → kẹt | Tạo tài khoản trước trong `VisualizeRegister` |
| Nhận nhiều nhiệm vụ cùng lúc (vd. GM nâng nhiều cấp) | Client gửi hàng nghìn gói nhận nhiệm vụ trùng, sảnh kẹt, không tạo được phòng | Vá client (`Source Flash/FlashSV1/2.png`), xem `deploy/client-patches/` |

Đã kiểm thử bằng trình duyệt tự động: đăng ký → tạo nhân vật → vào sảnh → mua đồ trong Shop →
tạo phòng PvP → ghép trận với bot → bắn, phá địa hình, trừ máu; 2 người chơi mời nhau vào
phòng phó bản "Huyệt Ma Kiến" → vào trận với quái AI.

## Hạn chế còn lại

- **Ruffle** chưa giả lập 100% Flash: một số hiệu ứng/khung có thể hiển thị chưa chuẩn. Nếu cần
  chính xác tuyệt đối có thể dùng Flash Player projector cũ trỏ vào
  `http://HOST/flash/Loading.swf?user=...&key=...&config=http://HOST/flash/config.xml`.
- Lần đầu vào game có hộp thoại "lưu trữ Adobe Flash Player": bấm **Đồng ý** rồi **X** (trình duyệt sẽ nhớ cho lần sau).
- Vũ khí dòng 124xx–126xx thiếu cả hình dạng nổ phía server (`bomb/*.bomb`) lẫn ảnh hố phía client
  (`image/bomb/crater/12401…`) → đạn của chúng không đục địa hình (7 file khác đã được bù từ đạn cùng loại hố).
- Ảnh "báo tuần" (weekly) không có.
- Phó bản: 134 script AI không tìm được mã nguồn ở đâu (vd. bản Ác mộng của Huyệt Ma Kiến / Gà Chạy,
  `EvilTribeSimpleGame`, vài NPC) → các màn đó dùng AI mặc định hoặc không bắt đầu được; vài màn tiếp theo
  thiếu dòng trong `Mission_Info` (1073, 1083, 1176…). Các chế độ sự kiện (World Cup, Mê cung, Boss guild,
  Camp battle…) chưa được engine hỗ trợ.
- Nhiều phó bản yêu cầu tối thiểu 2 người (mời bạn bằng nút **Mời** trong phòng).
- GameAdmin (trang quản trị) chưa được đưa vào bản triển khai.
