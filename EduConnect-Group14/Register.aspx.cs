// Register.aspx.cs
// Code-behind for the User Registration page
// EduConnect Web Application - University Assignment

using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;

namespace EduConnect
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Navigation visibility is managed by Site.Master
        }

        // Runs when the user clicks the Register button
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string email    = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();

            string connectionString = ConfigurationManager
                                        .ConnectionStrings["EduConnectDB"]
                                        .ConnectionString;

            // Hash the password with SHA-256 before storing
            string hashedPassword = HashPassword(password);

            // Parameterized INSERT — prevents SQL Injection
            string sql = "INSERT INTO Users (FullName, Email, Password) " +
                         "VALUES (@FullName, @Email, @Password)";

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@FullName", fullName);
                    cmd.Parameters.AddWithValue("@Email",    email);
                    cmd.Parameters.AddWithValue("@Password", hashedPassword);

                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        lblMessage.Text      = "Registration successful! You can now log in.";
                        lblMessage.CssClass  = "msg-success";
                        lblMessage.Visible   = true;

                        txtFullName.Text        = "";
                        txtEmail.Text           = "";
                        txtPassword.Text        = "";
                        txtConfirmPassword.Text = "";
                    }
                    else
                    {
                        lblMessage.Text      = "Registration failed. Please try again.";
                        lblMessage.CssClass  = "msg-error";
                        lblMessage.Visible   = true;
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                lblMessage.Text      = "Database error: " + sqlEx.Message;
                lblMessage.CssClass  = "msg-error";
                lblMessage.Visible   = true;
            }
            catch (Exception ex)
            {
                lblMessage.Text      = "An error occurred: " + ex.Message;
                lblMessage.CssClass  = "msg-error";
                lblMessage.Visible   = true;
            }
        }

        // Returns the lowercase SHA-256 hex digest of the password (UTF-8 encoding).
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
