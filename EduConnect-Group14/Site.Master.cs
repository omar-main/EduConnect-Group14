// ============================================================
// EduConnect - Site.Master.cs
// CT050-3-2-WAPP Group Assignment
// Member 2: Authentication & User System
//
// Master Page code-behind.
// This runs before every page that uses Site.Master as its
// MasterPageFile. Its only job is to update the navigation
// bar to match the current login state and user role.
//
// Session variables set by Login.aspx.cs:
//   Session["UserID"]   — the logged-in user's primary key
//   Session["FullName"] — used for the "Hi, [name]" greeting
//   Session["Role"]     — "Student" or "Admin"
// ============================================================

using System;
using System.Web.UI;

namespace EduConnect
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            UpdateNavigation();
        }

        // ===========================================================
        // UpdateNavigation
        // Shows or hides navigation <li> items based on login state.
        //
        // Guests (not logged in):
        //   Visible  — Register, Login
        //   Hidden   — Welcome greeting, Logout, Admin, Manage Quizzes
        //
        // Students (logged in, Role = "Student"):
        //   Visible  — Welcome greeting, Logout
        //   Hidden   — Register, Login, Admin, Manage Quizzes
        //
        // Admins (logged in, Role = "Admin"):
        //   Visible  — Welcome greeting, Logout, Admin, Manage Quizzes
        //   Hidden   — Register, Login
        // ===========================================================
        private void UpdateNavigation()
        {
            bool loggedIn = (Session["UserID"] != null);
            bool isAdmin  = loggedIn && Session["Role"]?.ToString() == "Admin";

            // Guest-only links
            liRegister.Visible = !loggedIn;
            liLogin.Visible    = !loggedIn;

            // Logged-in links
            liWelcome.Visible = loggedIn;
            liLogout.Visible  = loggedIn;

            // Admin-only links
            liAdmin.Visible      = isAdmin;
            liManageQuiz.Visible = isAdmin;

            // Show the logged-in user's first name in the nav greeting
            if (loggedIn)
            {
                string name = Session["FullName"]?.ToString() ?? "";
                litWelcome.Text = "Hi, " + Server.HtmlEncode(name);
            }
        }
    }
}
