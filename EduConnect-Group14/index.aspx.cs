// ============================================================
// EduConnect - index.aspx.cs
// Home page code-behind.
// Hides the guest CTA banner when the user is already logged in.
// ============================================================

using System;
using System.Web.UI;

namespace EduConnect
{
    public partial class Index : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Hide the "Register / Login" CTA for users who are already logged in
            pnlGuestCTA.Visible = (Session["UserID"] == null);
        }
    }
}
