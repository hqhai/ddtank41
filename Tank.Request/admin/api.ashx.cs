using Bussiness;
using Bussiness.CenterService;
using Bussiness.Managers;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using SqlDataProvider.Data;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.SessionState;

namespace Tank.Request.Admin
{
    /// <summary>
    /// JSON API behind the admin panel (/admin/). Every action needs a logged-in admin session except
    /// "login"; the password is the AdminPassword app setting (ADMIN_PASSWORD in server.env), and the
    /// panel is disabled while it is empty. Requests must carry X-Requested-With, which a cross-site
    /// form post cannot set.
    /// </summary>
    public class AdminApi : IHttpHandler, IRequiresSessionState
    {
        private const string SessionKey = "ddt_admin";
        private const int MaxStrengthen = 15;

        // failed logins per client IP: (count, time of the last failure)
        private static readonly ConcurrentDictionary<string, Tuple<int, DateTime>> failures =
            new ConcurrentDictionary<string, Tuple<int, DateTime>>();

        public bool IsReusable => false;

        private static string PlayerDb => ConfigurationManager.AppSettings["conString"];
        private static string GameDb => ConfigurationManager.AppSettings["crosszoneString"];
        private static string Password => ConfigurationManager.AppSettings["AdminPassword"] ?? "";

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            try
            {
                if (string.IsNullOrEmpty(Password))
                {
                    Fail(context, 503, "Trang quản trị đang tắt: đặt ADMIN_PASSWORD trong cấu hình server rồi khởi động lại.");
                    return;
                }
                if (string.IsNullOrEmpty(context.Request.Headers["X-Requested-With"]))
                {
                    Fail(context, 400, "Bad request");
                    return;
                }
                string action = context.Request["action"] ?? "";
                JObject body = ReadBody(context);
                if (action == "login")
                {
                    Login(context, body);
                    return;
                }
                if (!(context.Session[SessionKey] is bool ok && ok))
                {
                    Fail(context, 401, "Chưa đăng nhập");
                    return;
                }
                switch (action)
                {
                    case "logout": context.Session.Abandon(); Ok(context, new { }); break;
                    case "me": Ok(context, new { admin = true }); break;
                    case "stats": Stats(context); break;
                    case "players": Players(context); break;
                    case "categories": Categories(context); break;
                    case "items": Items(context); break;
                    case "send": Send(context, body); break;
                    case "level": SetLevel(context, body); break;
                    case "ban": Ban(context, body, true); break;
                    case "unban": Ban(context, body, false); break;
                    case "kick": Kick(context, body); break;
                    case "notice": Notice(context, body); break;
                    default: Fail(context, 404, "Unknown action"); break;
                }
            }
            catch (Exception ex)
            {
                Fail(context, 500, ex.Message);
            }
        }

        // ---------------------------------------------------------------- auth

        private static void Login(HttpContext context, JObject body)
        {
            string ip = context.Request.UserHostAddress ?? "";
            if (failures.TryGetValue(ip, out var f) && f.Item1 >= 5 && DateTime.Now - f.Item2 < TimeSpan.FromMinutes(10))
            {
                Fail(context, 429, "Sai mật khẩu quá nhiều lần, thử lại sau 10 phút.");
                return;
            }
            string given = (string)body?["password"] ?? "";
            if (!SlowEquals(given, Password))
            {
                failures.AddOrUpdate(ip, Tuple.Create(1, DateTime.Now),
                    (_, old) => Tuple.Create(DateTime.Now - old.Item2 < TimeSpan.FromMinutes(10) ? old.Item1 + 1 : 1, DateTime.Now));
                Fail(context, 401, "Sai mật khẩu");
                return;
            }
            failures.TryRemove(ip, out _);
            context.Session[SessionKey] = true;
            Ok(context, new { admin = true });
        }

        private static bool SlowEquals(string a, string b)
        {
            using (var sha = SHA256.Create())
            {
                byte[] x = sha.ComputeHash(Encoding.UTF8.GetBytes(a));
                byte[] y = sha.ComputeHash(Encoding.UTF8.GetBytes(b));
                int diff = 0;
                for (int i = 0; i < x.Length; i++) diff |= x[i] ^ y[i];
                return diff == 0;
            }
        }

        // ---------------------------------------------------------------- read

        private static void Stats(HttpContext context)
        {
            using (var cn = Open(PlayerDb))
            using (var cmd = new SqlCommand(
                "SELECT COUNT(*), SUM(CASE WHEN [State] <> 0 THEN 1 ELSE 0 END), " +
                "SUM(CASE WHEN ForbidDate > GETDATE() THEN 1 ELSE 0 END), " +
                "SUM(CASE WHEN [Date] > DATEADD(day, -1, GETDATE()) THEN 1 ELSE 0 END) " +
                "FROM Sys_Users_Detail WHERE NickName <> ''", cn))
            using (var r = cmd.ExecuteReader())
            {
                r.Read();
                Ok(context, new
                {
                    players = r.IsDBNull(0) ? 0 : r.GetInt32(0),
                    online = r.IsDBNull(1) ? 0 : r.GetInt32(1),
                    banned = r.IsDBNull(2) ? 0 : r.GetInt32(2),
                    newToday = r.IsDBNull(3) ? 0 : r.GetInt32(3)
                });
            }
        }

        private static void Players(HttpContext context)
        {
            string q = (context.Request["q"] ?? "").Trim();
            int page = Math.Max(1, ToInt(context.Request["page"], 1));
            const int size = 20;
            var list = new List<object>();
            int total;
            using (var cn = Open(PlayerDb))
            {
                const string where = "WHERE NickName <> '' AND (@q = '' OR UserName LIKE @like OR NickName LIKE @like OR CAST(UserID AS nvarchar(20)) = @q)";
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Sys_Users_Detail " + where, cn))
                {
                    cmd.Parameters.AddWithValue("@q", q);
                    cmd.Parameters.AddWithValue("@like", "%" + q + "%");
                    total = (int)cmd.ExecuteScalar();
                }
                using (var cmd = new SqlCommand(
                    "SELECT UserID, UserName, NickName, Grade, Money, Gold, GiftToken, [State], ForbidDate, LastDate, FightPower, Sex " +
                    "FROM Sys_Users_Detail " + where +
                    " ORDER BY [State] DESC, LastDate DESC OFFSET @skip ROWS FETCH NEXT @size ROWS ONLY", cn))
                {
                    cmd.Parameters.AddWithValue("@q", q);
                    cmd.Parameters.AddWithValue("@like", "%" + q + "%");
                    cmd.Parameters.AddWithValue("@skip", (page - 1) * size);
                    cmd.Parameters.AddWithValue("@size", size);
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            DateTime forbid = r.IsDBNull(8) ? DateTime.MinValue : r.GetDateTime(8);
                            list.Add(new
                            {
                                id = r.GetInt32(0),
                                user = Str(r, 1),
                                nick = Str(r, 2),
                                grade = r.GetInt32(3),
                                money = r.GetInt32(4),
                                gold = r.GetInt32(5),
                                giftToken = r.GetInt32(6),
                                online = !r.IsDBNull(7) && Convert.ToInt32(r.GetValue(7)) != 0,
                                bannedUntil = forbid > DateTime.Now ? forbid.ToString("yyyy-MM-dd HH:mm") : null,
                                lastSeen = r.IsDBNull(9) ? null : r.GetDateTime(9).ToString("yyyy-MM-dd HH:mm"),
                                fightPower = r.IsDBNull(10) ? 0 : Convert.ToInt32(r.GetValue(10)),
                                male = !r.IsDBNull(11) && r.GetBoolean(11)
                            });
                        }
                    }
                }
            }
            Ok(context, new { total, page, size, players = list });
        }

        private static void Categories(HttpContext context)
        {
            var list = new List<object>();
            using (var cn = Open(GameDb))
            using (var cmd = new SqlCommand(
                "SELECT c.ID, c.Name, COUNT(g.TemplateID) FROM Shop_Goods_Categorys c " +
                "JOIN Shop_Goods g ON g.CategoryID = c.ID GROUP BY c.ID, c.Name ORDER BY c.ID", cn))
            using (var r = cmd.ExecuteReader())
            {
                while (r.Read()) list.Add(new { id = r.GetInt32(0), name = r.GetString(1), count = r.GetInt32(2) });
            }
            Ok(context, list);
        }

        private static void Items(HttpContext context)
        {
            string q = (context.Request["q"] ?? "").Trim();
            int cat = ToInt(context.Request["cat"], 0);
            int page = Math.Max(1, ToInt(context.Request["page"], 1));
            const int size = 40;
            var list = new List<object>();
            int total;
            using (var cn = Open(GameDb))
            {
                const string where = "WHERE (@cat = 0 OR CategoryID = @cat) AND (@q = '' OR Name LIKE @like OR CAST(TemplateID AS nvarchar(20)) = @q)";
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Shop_Goods " + where, cn))
                {
                    cmd.Parameters.AddWithValue("@cat", cat);
                    cmd.Parameters.AddWithValue("@q", q);
                    cmd.Parameters.AddWithValue("@like", "%" + q + "%");
                    total = (int)cmd.ExecuteScalar();
                }
                using (var cmd = new SqlCommand(
                    "SELECT TemplateID, Name, CategoryID, NeedSex, Pic, MaxCount, Attack, Defence, Agility, Luck, NeedLevel " +
                    "FROM Shop_Goods " + where + " ORDER BY TemplateID OFFSET @skip ROWS FETCH NEXT @size ROWS ONLY", cn))
                {
                    cmd.Parameters.AddWithValue("@cat", cat);
                    cmd.Parameters.AddWithValue("@q", q);
                    cmd.Parameters.AddWithValue("@like", "%" + q + "%");
                    cmd.Parameters.AddWithValue("@skip", (page - 1) * size);
                    cmd.Parameters.AddWithValue("@size", size);
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            int category = r.GetInt32(2);
                            list.Add(new
                            {
                                id = r.GetInt32(0),
                                name = r.GetString(1),
                                cat = category,
                                icon = IconPath(category, r.GetInt32(3), r.IsDBNull(4) ? "" : r.GetString(4)),
                                maxCount = r.GetInt32(5),
                                attack = r.GetInt32(6),
                                defence = r.GetInt32(7),
                                agility = r.GetInt32(8),
                                luck = r.GetInt32(9),
                                level = r.GetInt32(10)
                            });
                        }
                    }
                }
            }
            Ok(context, new { total, page, size, items = list });
        }

        /// <summary>Icon of an item under /resource/ (same layout the client uses).</summary>
        private static string IconPath(int category, int needSex, string pic)
        {
            if (string.IsNullOrEmpty(pic) || pic == "default") return null;
            string sex = needSex == 1 ? "m" : "f";
            switch (category)
            {
                case 1: return "image/equip/" + sex + "/head/" + pic + "/icon_1.png";
                case 2: return "image/equip/" + sex + "/glass/" + pic + "/icon_1.png";
                case 3: return "image/equip/" + sex + "/hair/" + pic + "/icon_1.png";
                case 4: return "image/equip/" + sex + "/eff/" + pic + "/icon_1.png";
                case 5: return "image/equip/" + sex + "/cloth/" + pic + "/icon_1.png";
                case 6: return "image/equip/" + sex + "/face/" + pic + "/icon_1.png";
                case 7: case 27: return "image/arm/" + pic + "/00.png";
                case 8: return "image/equip/armlet/" + pic + "/icon.png";
                case 9: return "image/equip/ring/" + pic + "/icon.png";
                case 10: case 11: case 30: case 34: case 35: case 36: case 40: case 60:
                    return "image/unfrightprop/" + pic + "/icon.png";
                case 12: return "image/task/" + pic + "/icon.png";
                case 13: return "image/equip/" + sex + "/suits/" + pic + "/icon_1.png";
                case 14: return "image/equip/necklace/" + pic + "/icon.png";
                case 15: return "image/equip/wing/" + pic + "/icon.png";
                case 16: return "image/specialprop/chatBall/" + pic + "/icon.png";
                case 17: case 31: return "image/equip/offhand/" + pic + "/icon.png";
                case 18: return "image/cardbox/" + pic + "/icon.png";
                case 19: case 20: case 23: case 28: case 29: return "image/prop/" + pic + "/icon.png";
                case 25: return "image/gift/" + pic + "/icon.png";
                case 26: return "image/card/" + pic + "/icon.jpg";
                case 50: return "image/petequip/arm/" + pic + "/icon.png";
                case 51: return "image/petequip/hat/" + pic + "/icon.png";
                case 52: return "image/petequip/cloth/" + pic + "/icon.png";
                default: return null;
            }
        }

        // ---------------------------------------------------------------- write

        /// <summary>Mail money and/or items to a player; works while they are online.</summary>
        private static void Send(HttpContext context, JObject body)
        {
            var target = FindPlayer((string)body?["user"]);
            if (target == null) { Fail(context, 404, "Không tìm thấy nhân vật"); return; }
            string title = Limit((string)body["title"], 100, "Quà từ Ban Quản Trị");
            string content = Limit((string)body["content"], 500, "Chúc bạn chơi game vui vẻ!");
            int money = Math.Max(0, ToInt((string)body["money"], 0));
            int gold = Math.Max(0, ToInt((string)body["gold"], 0));
            int giftToken = Math.Max(0, ToInt((string)body["giftToken"], 0));

            var items = new List<ItemInfo>();
            var lines = new List<string>();
            if (body["items"] is JArray arr)
            {
                using (var produce = new ProduceBussiness())
                {
                    foreach (JToken it in arr)
                    {
                        ItemTemplateInfo temp = produce.GetSingleGoods((int)it["id"]);
                        if (temp == null) continue;
                        ItemInfo item = ItemInfo.CreateFromTemplate(temp, 1, 105);
                        item.Count = Math.Max(1, Math.Min(ToInt((string)it["count"], 1), Math.Max(1, temp.MaxCount) * 99));
                        item.ValidDate = Math.Max(0, ToInt((string)it["valid"], 0));
                        item.StrengthenLevel = Math.Max(0, Math.Min(ToInt((string)it["strengthen"], 0), MaxStrengthen));
                        item.IsBinds = it["bind"] == null || (bool)it["bind"];
                        items.Add(item);
                        lines.Add(temp.Name + " x" + item.Count);
                    }
                }
            }
            if (items.Count == 0 && money == 0 && gold == 0 && giftToken == 0)
            {
                Fail(context, 400, "Chưa chọn quà nào để gửi");
                return;
            }

            if (money > 0 || gold > 0 || giftToken > 0)
            {
                using (var pb = new PlayerBussiness())
                {
                    pb.SendMail(new MailInfo
                    {
                        Title = title,
                        Content = content + "\n" + string.Format("Nhận: {0:N0} xu, {1:N0} vàng, {2:N0} lễ kim.", money, gold, giftToken),
                        ReceiverID = target.Item1,
                        Receiver = target.Item3,
                        Sender = "Ban Quản Trị",
                        SenderID = 0,
                        Money = money,
                        Gold = gold,
                        GiftToken = giftToken,
                        IsExist = true,
                        Type = 9
                    });
                }
            }
            if (items.Count > 0)
            {
                WorldEventMgr.SendItemsToMail(items, target.Item1, target.Item3, title, content);
            }
            TryCenter(c => c.MailNotice(target.Item1));
            Ok(context, new { sent = true, to = target.Item3, items = lines, money, gold, giftToken });
        }

        /// <summary>Change level; only while offline, the game server would overwrite it on save.</summary>
        private static void SetLevel(HttpContext context, JObject body)
        {
            var target = FindPlayer((string)body?["user"]);
            if (target == null) { Fail(context, 404, "Không tìm thấy nhân vật"); return; }
            if (target.Item4) { Fail(context, 409, "Nhân vật đang online – hãy đá (kick) ra trước rồi đổi cấp."); return; }
            int grade = ToInt((string)body["grade"], 0);
            using (var cn = Open(PlayerDb))
            using (var cmd = new SqlCommand(
                "DECLARE @gp int = (SELECT GP FROM " + GameDbName() + "..LevelInfo WHERE Grade = @g); " +
                "IF @gp IS NULL BEGIN SELECT -1; RETURN; END " +
                "UPDATE Sys_Users_Detail SET Grade = @g, GP = @gp WHERE UserID = @id AND [State] = 0; SELECT @@ROWCOUNT;", cn))
            {
                cmd.Parameters.AddWithValue("@g", grade);
                cmd.Parameters.AddWithValue("@id", target.Item1);
                int n = Convert.ToInt32(cmd.ExecuteScalar());
                if (n < 0) { Fail(context, 400, "Cấp không hợp lệ"); return; }
                if (n == 0) { Fail(context, 409, "Nhân vật vừa vào game – thử lại sau khi họ thoát."); return; }
            }
            Ok(context, new { user = target.Item2, grade });
        }

        private static void Ban(HttpContext context, JObject body, bool ban)
        {
            var target = FindPlayer((string)body?["user"]);
            if (target == null) { Fail(context, 404, "Không tìm thấy nhân vật"); return; }
            int days = Math.Max(1, ToInt((string)body["days"], 3650));
            DateTime until = ban ? DateTime.Now.AddDays(days) : DateTime.Now.AddMinutes(-1);
            using (var cn = Open(PlayerDb))
            using (var cmd = new SqlCommand("UPDATE Sys_Users_Detail SET ForbidDate = @d WHERE UserID = @id", cn))
            {
                cmd.Parameters.AddWithValue("@d", until);
                cmd.Parameters.AddWithValue("@id", target.Item1);
                cmd.ExecuteNonQuery();
            }
            if (ban) TryCenter(c => c.KitoffUser(target.Item1, "Tài khoản của bạn đã bị khoá."));
            Ok(context, new { user = target.Item2, bannedUntil = ban ? until.ToString("yyyy-MM-dd HH:mm") : null });
        }

        private static void Kick(HttpContext context, JObject body)
        {
            var target = FindPlayer((string)body?["user"]);
            if (target == null) { Fail(context, 404, "Không tìm thấy nhân vật"); return; }
            bool done = TryCenter(c => c.KitoffUser(target.Item1, Limit((string)body["reason"], 200, "Bạn đã bị Ban Quản Trị mời ra khỏi game.")));
            if (!done) { Fail(context, 502, "Không gửi được lệnh tới Center server"); return; }
            Ok(context, new { user = target.Item2 });
        }

        private static void Notice(HttpContext context, JObject body)
        {
            string msg = ((string)body?["message"] ?? "").Trim();
            if (msg.Length == 0 || msg.Length > 200) { Fail(context, 400, "Nội dung thông báo phải từ 1 đến 200 ký tự"); return; }
            if (!TryCenter(c => c.SystemNotice(msg))) { Fail(context, 502, "Không gửi được lệnh tới Center server"); return; }
            Ok(context, new { sent = true });
        }

        // ---------------------------------------------------------------- helpers

        /// <summary>(UserID, UserName, NickName, online) by user name, nickname or id.</summary>
        private static Tuple<int, string, string, bool> FindPlayer(string key)
        {
            key = (key ?? "").Trim();
            if (key.Length == 0) return null;
            using (var cn = Open(PlayerDb))
            using (var cmd = new SqlCommand(
                "SELECT TOP 1 UserID, UserName, NickName, [State] FROM Sys_Users_Detail " +
                "WHERE UserName = @k OR NickName = @k OR CAST(UserID AS nvarchar(20)) = @k ORDER BY CASE WHEN UserName = @k THEN 0 ELSE 1 END", cn))
            {
                cmd.Parameters.AddWithValue("@k", key);
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return null;
                    return Tuple.Create(r.GetInt32(0), Str(r, 1), Str(r, 2), !r.IsDBNull(3) && Convert.ToInt32(r.GetValue(3)) != 0);
                }
            }
        }

        private static string GameDbName()
        {
            var b = new SqlConnectionStringBuilder(GameDb);
            return "[" + b.InitialCatalog.Replace("]", "]]") + "]";
        }

        private static bool TryCenter(Func<CenterServiceClient, bool> call)
        {
            try
            {
                using (var c = new CenterServiceClient()) return call(c);
            }
            catch
            {
                return false;
            }
        }

        private static SqlConnection Open(string cs)
        {
            var cn = new SqlConnection(cs);
            cn.Open();
            return cn;
        }

        private static JObject ReadBody(HttpContext context)
        {
            if (context.Request.HttpMethod != "POST") return new JObject();
            using (var sr = new StreamReader(context.Request.InputStream, Encoding.UTF8))
            {
                string s = sr.ReadToEnd();
                return string.IsNullOrWhiteSpace(s) ? new JObject() : JObject.Parse(s);
            }
        }

        private static string Str(SqlDataReader r, int i) => r.IsDBNull(i) ? "" : r.GetString(i);

        private static int ToInt(string s, int def) => int.TryParse(s, out int v) ? v : def;

        private static string Limit(string s, int max, string def)
        {
            s = (s ?? "").Trim();
            if (s.Length == 0) return def;
            return s.Length > max ? s.Substring(0, max) : s;
        }

        private static void Ok(HttpContext context, object data)
        {
            context.Response.Write(JsonConvert.SerializeObject(new { ok = true, data }));
        }

        private static void Fail(HttpContext context, int status, string message)
        {
            context.Response.StatusCode = status;
            context.Response.TrySkipIisCustomErrors = true;
            context.Response.Write(JsonConvert.SerializeObject(new { ok = false, error = message }));
        }
    }
}
