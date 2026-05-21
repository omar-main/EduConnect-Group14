// ============================================================
// EduConnect - QuizList.aspx.cs
// CT050-3-2-WAPP Group Assignment
//
// Displays all quizzes with each logged-in user's attempt
// count and best percentage score per quiz.
//
// Session variables expected (set by Login.aspx):
//   Session["UserID"]   = int   (e.g. 1)
//   Session["FullName"] = string (e.g. "Tarunan")
//   Session["Role"]     = string ("Member" or "Admin")
// ============================================================
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EduConnect
{
    public partial class QuizList : Page
    {
        // Connection string name from Web.config (same as Register.aspx.cs)
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["EduConnectDB"].ConnectionString;

        // ----------------------------------------------------------
        // Page_Load
        // ----------------------------------------------------------
        protected void Page_Load(object sender, EventArgs e)
        {
            // Security check: redirect to login if no active session
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Show the logged-in user's name in the welcome sub-heading
            string name = Session["FullName"]?.ToString() ?? "Student";
            litWelcome.Text = name;

            if (!IsPostBack)
            {
                LoadQuizzes();
            }
        }

        // ----------------------------------------------------------
        // LoadQuizzes
        // SQL SELECT: all quizzes + attempt stats for current user
        // ----------------------------------------------------------
        private void LoadQuizzes()
        {
            int userId = Convert.ToInt32(Session["UserID"]);

            // Parameterized query – joins Quiz table with QuizAttempt
            // aggregates (attempt count + best score) for this user only
            string sql = @"
                SELECT
                    q.QuizID,
                    q.Title,
                    q.Topic,
                    q.Description,
                    q.TotalQuestions,
                    COUNT(a.AttemptID)   AS AttemptCount,
                    MAX(a.Percentage)    AS BestScore
                FROM  Quiz q
                LEFT  JOIN QuizAttempt a
                      ON q.QuizID = a.QuizID
                      AND a.UserID = @UserID
                GROUP BY q.QuizID, q.Title, q.Topic,
                         q.Description, q.TotalQuestions
                ORDER BY q.QuizID ASC";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd  = new SqlCommand(sql, conn))
                {
                    // Parameterized – prevents SQL injection
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    conn.Open();

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptQuizzes.DataSource = dt;
                        rptQuizzes.DataBind();
                        lblNoQuiz.Visible = false;
                    }
                    else
                    {
                        rptQuizzes.Visible = false;
                        lblNoQuiz.Visible  = true;
                    }
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text      = "Error loading quizzes. Details: " + ex.Message;
                lblMessage.CssClass  = "msg-error";
                lblMessage.Visible   = true;
            }
        }

        // ----------------------------------------------------------
        // rptQuizzes_ItemCommand
        // Fires when user clicks "Start Quiz" on any quiz card
        // ----------------------------------------------------------
        protected void rptQuizzes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "StartQuiz")
            {
                // Pass the QuizID to the attempt page via query string
                Response.Redirect("QuizAttempt.aspx?QuizID=" + e.CommandArgument.ToString());
            }
        }
    }
}
