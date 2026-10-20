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

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}