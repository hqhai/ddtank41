using System;
using System.Collections.Generic;
using System.Linq;
using System.Configuration;
using Bussiness;
using System.Web.Security;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.SessionState;
using System.Data.SqlClient;

namespace Tank.Flash
{
    /// <summary>
    /// Summary description for checkuser
    /// </summary>
    public class checkuser : IHttpHandler, IRequiresSessionState
    {
        public string SiteTitle
        {
            get
            {
                return ((ConfigurationManager.AppSettings["SiteTitle"] == null) ? "DanDanTang" : ConfigurationManager.AppSettings["SiteTitle"]);
            }
        }
        public void ProcessRequest(HttpContext context)
        {
            string username = context.Request["username"];
            string password = context.Request["password"];
            using (MemberShipBussiness db = new MemberShipBussiness())
            {                
                if (!string.IsNullOrEmpty(username) && !string.IsNullOrEmpty(password) && db.CheckUsername(username, password))
                {
                    DateTime bannedUntil = BannedUntil(username);
                    if (bannedUntil > DateTime.Now)
                    {
                        context.Response.Write("Tài khoản đã bị khoá đến " + bannedUntil.ToString("HH:mm dd/MM/yyyy") + ".");
                        return;
                    }
                    context.Session["username"] = username;
                    context.Session["password"] = password;
                    LoadingManager.Add(username, password, db.CheckAdmin(username));
                    context.Response.Write("ok");
                }
                else
                {
                    context.Response.Write("Tài khoản hoặc mật khẩu không đúng!");
                }
            }
        }

        /// <summary>Ban set by the admin panel (Sys_Users_Detail.ForbidDate); MinValue when there is no character yet.</summary>
        private static DateTime BannedUntil(string username)
        {
            try
            {
                using (var cn = new SqlConnection(ConfigurationManager.AppSettings["conString"]))
                using (var cmd = new SqlCommand("SELECT MAX(ForbidDate) FROM Sys_Users_Detail WHERE UserName = @u", cn))
                {
                    cmd.Parameters.AddWithValue("@u", username);
                    cn.Open();
                    object v = cmd.ExecuteScalar();
                    return v is DateTime d ? d : DateTime.MinValue;
                }
            }
            catch
            {
                return DateTime.MinValue;
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}