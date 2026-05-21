// ============================================================
// EduConnect - Login.aspx.cs
// CT050-3-2-WAPP Group Assignment
// Member 2: Authentication & User System
//
// Handles user authentication using ADO.NET and ASP.NET Sessions.
//
//   SQL SELECT — verifies email and password against the Users table
//   Session    — stores UserID, FullName, and Role after a successful login
//   Redirect   — sends Admins to Admin.aspx, Students to StudyMaterials.aspx
//
// Security: Passwords are hashed with SHA-256 (Encoding.UTF8) before
//   comparison. The DB stores only the hash, never the plaintext.
//   SQL Injection is prevented through parameterised queries.
// ============================================================

using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace EduConnect
{
    public partial class Login : Page
    {
        // Connection string from Web.config — name "EduConnectDB"
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["EduConnectDB"].ConnectionString;

        // ===========================================================
        // PAGE_LOAD
        // Runs on every request to this page.
        // If the user already has an active session they are redirected
        // away so they cannot see the login form again.
        // ===========================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Session["UserID"] != null)
            {
                // Already logged in — send them to the right place
                string role = Session["Role"]?.ToString();
                Response.Redirect(role == "Admin" ? "Admin.aspx" : "StudyMaterials.aspx");
            }
        }

        // ===========================================================
        // btnLogin_Click
        // Fires when the user clicks the Login button.
        //
        // Flow:
        //   1. ASP.NET validators check for empty fields (client-side
        //      and server-side).
        //   2. A parameterised SQL SELECT looks for a Users row where
        //      BOTH the email AND the password match.
        //   3a. Match found  → session variables are set, redirect.
        //   3b. No match     → error banner is shown.
        //   3c. DB exception → error banner shows the message.
        // ===========================================================
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // Server-side validation guard (client-side already ran)
            if (!Page.IsValid) return;

            string email    = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();

            // -----------------------------------------------------------
            // SQL SELECT — credential check
            //
            // Returns the account row only when BOTH email AND password
            // match. Using @Email and @Password parameters (not string
            // concatenation) prevents SQL Injection attacks.
            // -----------------------------------------------------------
            string sql = @"
                SELECT UserID, FullName, Role
                FROM   Users
                WHERE  Email    = @Email
                AND    Password = @Password";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    // Bind inputs to SQL parameters — password is compared as SHA-256 hash
                    cmd.Parameters.AddWithValue("@Email",    email);
                    cmd.Parameters.AddWithValue("@Password", HashPassword(password));

                    conn.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            // -------------------------------------------
                            // LOGIN SUCCESSFUL
                            //
                            // Store the user's identity in ASP.NET Session.
                            // Session data is kept on the server and linked
                            // to the user's browser via a cookie. It expires
                            // after 30 minutes of inactivity (set in Web.config).
                            //
                            // All other pages read these values to:
                            //   - Check if the user is logged in (Session["UserID"] != null)
                            //   - Display the user's name (Session["FullName"])
                            //   - Restrict admin pages (Session["Role"] == "Admin")
                            // -------------------------------------------
                            Session["UserID"]   = dr["UserID"].ToString();
                            Session["FullName"] = dr["FullName"].ToString();
                            Session["Role"]     = dr["Role"].ToString();

                            // Redirect based on role:
                            //   Admin   → Admin dashboard
                            //   Student → Study Materials listing
                            string role = dr["Role"].ToString();
                            Response.Redirect(role == "Admin" ? "Admin.aspx" : "StudyMaterials.aspx");
                        }
                        else
                        {
                            // -------------------------------------------
                            // LOGIN FAILED
                            //
                            // The SELECT returned no rows, meaning the
                            // email/password combination was not found.
                            //
                            // The error message is deliberately vague —
                            // it does not reveal whether the email exists
                            // in the database, which would help an attacker
                            // enumerate valid accounts.
                            // -------------------------------------------
                            ShowError("Incorrect email address or password. Please try again.");
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                ShowError("Database error: " + sqlEx.Message);
            }
            catch (Exception ex)
            {
                ShowError("An unexpected error occurred: " + ex.Message);
            }
        }

        // ===========================================================
        // ShowError
        // Makes the red error Label visible with the given message.
        // ===========================================================
        private void ShowError(string message)
        {
            lblError.Text    = message;
            lblError.Visible = true;
        }

        // ===========================================================
        // HashPassword
        // Returns the lowercase SHA-256 hex digest of the password.
        // Uses UTF-8 encoding to match Register.aspx.cs.
        // ===========================================================
        private static string HashPassword(string password)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
                var sb = new StringBuilder();
                foreach (byte b in bytes)
                    sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }
    }
}
