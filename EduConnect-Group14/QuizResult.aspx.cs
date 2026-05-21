// ============================================================
// EduConnect - QuizResult.aspx.cs
// CT050-3-2-WAPP Group Assignment
//
// Reads the AttemptID from Session["LastAttemptID"], loads
// the attempt summary + per-question answers, and displays:
//   - Score, percentage, pass/fail status
//   - Question-by-question review with correct/wrong indicators
// ============================================================
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace EduConnect
{
    public partial class QuizResult : Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["EduConnectDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect if not logged in
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Retrieve AttemptID set by QuizAttempt.aspx.cs
            if (Session["LastAttemptID"] == null)
            {
                Response.Redirect("QuizList.aspx");
                return;
            }

            if (!IsPostBack)
            {
                int attemptId = Convert.ToInt32(Session["LastAttemptID"]);
                LoadResult(attemptId);
            }
        }

        // ----------------------------------------------------------
        // LoadResult
        // Fetches attempt summary + all answers, populates the UI
        // ----------------------------------------------------------
        private void LoadResult(int attemptId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // ---- 1. Load attempt summary ----
                    string summSql = @"
                        SELECT
                            a.Score, a.TotalQuestions, a.Percentage,
                            q.Title, q.Topic, q.QuizID
                        FROM  QuizAttempt a
                        INNER JOIN Quiz q ON a.QuizID = q.QuizID
                        WHERE a.AttemptID = @AID AND a.UserID = @UID";

                    using (SqlCommand cmd = new SqlCommand(summSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@AID", attemptId);
                        cmd.Parameters.AddWithValue("@UID", Convert.ToInt32(Session["UserID"]));

                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (!dr.Read())
                            {
                                lblError.Text    = "Result not found. Please attempt a quiz first.";
                                lblError.Visible = true;
                                return;
                            }

                            int     score      = Convert.ToInt32(dr["Score"]);
                            int     totalQ     = Convert.ToInt32(dr["TotalQuestions"]);
                            decimal percentage = Convert.ToDecimal(dr["Percentage"]);
                            string  title      = dr["Title"].ToString();
                            string  topic      = dr["Topic"].ToString();
                            int     quizId     = Convert.ToInt32(dr["QuizID"]);

                            // Populate scorecard
                            litQuizTitle.Text  = title;
                            litTopic.Text      = topic;
                            litPercentage.Text = percentage.ToString("0.0");
                            litScore.Text      = score.ToString();
                            litTotal.Text      = totalQ.ToString();
                            litWrong.Text      = (totalQ - score).ToString();

                            // Pass / Fail: pass = 60% or above
                            bool passed = (percentage >= 60);
                            lblPassFail.Text     = passed ? "PASS" : "FAIL";
                            lblPassFail.CssClass = passed ? "pass-label pass" : "pass-label fail";

                            // "Try Again" link
                            lnkTryAgain.NavigateUrl = "QuizAttempt.aspx?QuizID=" + quizId;
                        }
                    }

                    // ---- 2. Load per-question review ----
                    // Joins QuizAnswer with QuizQuestion to get text + options
                    string reviewSql = @"
                        SELECT
                            qq.QuestionText,
                            qq.OptionA, qq.OptionB, qq.OptionC, qq.OptionD,
                            qq.CorrectAnswer,
                            ans.SelectedAnswer,
                            ans.IsCorrect
                        FROM  QuizAnswer ans
                        INNER JOIN QuizQuestion qq ON ans.QuestionID = qq.QuestionID
                        WHERE ans.AttemptID = @AID
                        ORDER BY qq.QuestionID ASC";

                    using (SqlCommand rCmd = new SqlCommand(reviewSql, conn))
                    {
                        rCmd.Parameters.AddWithValue("@AID", attemptId);

                        SqlDataAdapter da = new SqlDataAdapter(rCmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        // Add computed columns for display labels
                        dt.Columns.Add("SelectedLabel", typeof(string));
                        dt.Columns.Add("CorrectLabel",  typeof(string));

                        foreach (DataRow row in dt.Rows)
                        {
                            row["SelectedLabel"] = GetOptionText(row, row["SelectedAnswer"].ToString());
                            row["CorrectLabel"]  = GetOptionText(row, row["CorrectAnswer"].ToString());
                        }

                        rptReview.DataSource = dt;
                        rptReview.DataBind();
                    }
                }

                pnlResult.Visible = true;

                // Clear session so user can't refresh to re-access
                Session.Remove("LastAttemptID");
            }
            catch (Exception ex)
            {
                lblError.Text    = "Error loading result: " + ex.Message;
                lblError.Visible = true;
            }
        }

        // ----------------------------------------------------------
        // GetOptionText
        // Returns the full option text for a given answer letter
        // e.g. "B" → the text of OptionB
        // ----------------------------------------------------------
        private string GetOptionText(DataRow row, string letter)
        {
            if (string.IsNullOrEmpty(letter)) return "(Not answered)";
            switch (letter.ToUpper())
            {
                case "A": return "A. " + Server.HtmlEncode(row["OptionA"].ToString());
                case "B": return "B. " + Server.HtmlEncode(row["OptionB"].ToString());
                case "C": return "C. " + Server.HtmlEncode(row["OptionC"].ToString());
                case "D": return "D. " + Server.HtmlEncode(row["OptionD"].ToString());
                default:  return letter;
            }
        }
    }
}
