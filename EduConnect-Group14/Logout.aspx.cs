// ============================================================
// EduConnect - Logout.aspx.cs
// CT050-3-2-WAPP Group Assignment
//
// Clears the user's session on Page_Load, then the ASPX page
// shows a brief confirmation message before auto-redirecting.
// ============================================================
using System;
using System.Web.UI;

namespace EduConnect
{
    public partial class Logout : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Clear all session data (UserID, FullName, Role, etc.)
            Session.Clear();

            // Completely abandon the session on the server
            Session.Abandon();

            // Expire the session cookie in the browser
            if (Request.Cookies["ASP.NET_SessionId"] != null)
            {
                Response.Cookies["ASP.NET_SessionId"].Expires =
                    DateTime.Now.AddDays(-1);
            }

            // Page then displays the logout confirmation UI
            // The JavaScript countdown handles the final redirect
        }
    }
}
