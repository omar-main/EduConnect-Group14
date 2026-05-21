// ============================================================
// EduConnect - QuizAttempt.aspx.cs
// CT050-3-2-WAPP Group Assignment
//
// Loads all questions for a given quiz, renders them on the
// page, and on submission: validates, calculates the score,
// saves the attempt + individual answers to the database,
// then redirects to QuizResult.aspx.
//
// Session variables expected:
//   Session["UserID"]   = int
//   Session["FullName"] = string
// ============================================================
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EduConnect
{
    public partial class QuizAttempt : Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["EduConnectDB"].ConnectionString;

        // ----------------------------------------------------------
        // Page_Load
        // ----------------------------------------------------------
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect if not logged in
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Validate QuizID query string
            int quizId;
            if (!int.TryParse(Request.QueryString["QuizID"], out quizId) || quizId <= 0)
            {
                Response.Redirect("QuizList.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadQuiz(quizId);
            }
        }

        // ----------------------------------------------------------
        // LoadQuiz
        // Fetches quiz info and all questions, binds to Repeater
        // ----------------------------------------------------------
        private void LoadQuiz(int quizId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // ---- 1. Load quiz title and topic ----
                    string quizSql = "SELECT Title, Topic, TotalQuestions FROM Quiz WHERE QuizID = @QID";
                    using (SqlCommand qCmd = new SqlCommand(quizSql, conn))
                    {
                        qCmd.Parameters.AddWithValue("@QID", quizId);
                        using (SqlDataReader dr = qCmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                litQuizTitle.Text = dr["Title"].ToString();
                                litTopic.Text     = dr["Topic"].ToString();
                                int totalQ = Convert.ToInt32(dr["TotalQuestions"]);
                                litTotalQ.Text    = totalQ.ToString();

                                // Timer = 2 minutes per question (in seconds)
                                hfTimer.Value = (totalQ * 2 * 60).ToString();
                            }
                            else
                            {
                                // Quiz not found
                                Response.Redirect("QuizList.aspx");
                                return;
                            }
                        }
                    }

                    // ---- 2. Load all questions for this quiz ----
                    string qstSql = @"
                        SELECT
                            QuestionID,
                            QuestionText,
                            OptionA, OptionB, OptionC, OptionD,
                            CorrectAnswer,
                            (SELECT TotalQuestions FROM Quiz WHERE QuizID = @QID2) AS TotalQ
                        FROM QuizQuestion
                        WHERE QuizID = @QID3
                        ORDER BY QuestionID ASC";

                    using (SqlCommand qstCmd = new SqlCommand(qstSql, conn))
                    {
                        qstCmd.Parameters.AddWithValue("@QID2", quizId);
                        qstCmd.Parameters.AddWithValue("@QID3", quizId);

                        SqlDataAdapter da = new SqlDataAdapter(qstCmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count == 0)
                        {
                            lblError.Text    = "No questions found for this quiz. Please contact your administrator.";
                            lblError.Visible = true;
                            btnSubmit.Visible = false;
                            return;
                        }

                        // Store QuizID in ViewState so it's available on postback
                        ViewState["QuizID"] = quizId;

                        rptQuestions.DataSource = dt;
                        rptQuestions.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                lblError.Text    = "Error loading quiz: " + ex.Message;
                lblError.Visible = true;
            }
        }

        // ----------------------------------------------------------
        // rptQuestions_ItemDataBound
        // Populates the RadioButtonList with options A–D for each question
        // ----------------------------------------------------------
        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem)
                return;

            var rbl = (RadioButtonList)e.Item.FindControl("rblOptions");
            DataRowView row = (DataRowView)e.Item.DataItem;

            rbl.Items.Add(new ListItem(Server.HtmlEncode(row["OptionA"].ToString()), "A"));
            rbl.Items.Add(new ListItem(Server.HtmlEncode(row["OptionB"].ToString()), "B"));
            rbl.Items.Add(new ListItem(Server.HtmlEncode(row["OptionC"].ToString()), "C"));
            rbl.Items.Add(new ListItem(Server.HtmlEncode(row["OptionD"].ToString()), "D"));
        }

        // ----------------------------------------------------------
        // btnSubmit_Click
        // Processes answers, calculates score, saves to DB
        // ----------------------------------------------------------
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            // Retrieve QuizID stored from initial page load
            if (ViewState["QuizID"] == null)
            {
                Response.Redirect("QuizList.aspx");
                return;
            }

            int quizId = Convert.ToInt32(ViewState["QuizID"]);
            int userId = Convert.ToInt32(Session["UserID"]);

            int score          = 0;
            int totalQuestions = rptQuestions.Items.Count;

            // ---- SERVER-SIDE VALIDATION ----
            // Check that every question has a selected answer
            bool allAnswered = true;
            foreach (RepeaterItem item in rptQuestions.Items)
            {
                var rbl = (RadioButtonList)item.FindControl("rblOptions");
                if (rbl != null && string.IsNullOrEmpty(rbl.SelectedValue))
                {
                    allAnswered = false;
                    break;
                }
            }

            if (!allAnswered)
            {
                lblError.Text    = "Please answer all questions before submitting. Scroll up to find any unanswered questions.";
                lblError.Visible = true;
                return;
            }

            // ---- LOAD ALL CORRECT ANSWERS IN ONE QUERY ----
            // Fetch all correct answers for this quiz upfront to avoid
            // N individual round-trips to the database.
            var correctAnswers = new System.Collections.Generic.Dictionary<int, string>();
            try
            {
                using (SqlConnection caConn = new SqlConnection(connStr))
                using (SqlCommand caCmd = new SqlCommand(
                    "SELECT QuestionID, CorrectAnswer FROM QuizQuestion WHERE QuizID = @QID", caConn))
                {
                    caCmd.Parameters.AddWithValue("@QID", quizId);
                    caConn.Open();
                    using (SqlDataReader caReader = caCmd.ExecuteReader())
                    {
                        while (caReader.Read())
                            correctAnswers[Convert.ToInt32(caReader["QuestionID"])] =
                                caReader["CorrectAnswer"].ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                lblError.Text    = "Error loading answer key: " + ex.Message;
                lblError.Visible = true;
                return;
            }

            // ---- COLLECT ANSWERS + CALCULATE SCORE ----
            var answers = new System.Collections.Generic.List<(int qid, string selected, bool correct)>();

            foreach (RepeaterItem item in rptQuestions.Items)
            {
                var rbl   = (RadioButtonList)item.FindControl("rblOptions");
                var hfQID = (HiddenField)item.FindControl("hfQID");

                int    questionId     = Convert.ToInt32(hfQID.Value);
                string selectedAnswer = rbl?.SelectedValue ?? "";

                string correctAnswer;
                correctAnswers.TryGetValue(questionId, out correctAnswer);
                bool isCorrect = (selectedAnswer == correctAnswer);

                if (isCorrect) score++;

                answers.Add((questionId, selectedAnswer, isCorrect));
            }

            decimal percentage = totalQuestions > 0
                ? Math.Round((decimal)score / totalQuestions * 100, 2)
                : 0;

            // ---- SAVE TO DATABASE ----
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // INSERT QuizAttempt record, get new AttemptID
                    string attemptSql = @"
                        INSERT INTO QuizAttempt
                            (UserID, QuizID, Score, TotalQuestions, Percentage, AttemptDate)
                        VALUES
                            (@UserID, @QuizID, @Score, @TotalQ, @Pct, GETDATE());
                        SELECT SCOPE_IDENTITY();";

                    int attemptId;
                    using (SqlCommand aCmd = new SqlCommand(attemptSql, conn))
                    {
                        aCmd.Parameters.AddWithValue("@UserID", userId);
                        aCmd.Parameters.AddWithValue("@QuizID", quizId);
                        aCmd.Parameters.AddWithValue("@Score",  score);
                        aCmd.Parameters.AddWithValue("@TotalQ", totalQuestions);
                        aCmd.Parameters.AddWithValue("@Pct",    percentage);
                        attemptId = Convert.ToInt32(aCmd.ExecuteScalar());
                    }

                    // INSERT one QuizAnswer row per question
                    string answerSql = @"
                        INSERT INTO QuizAnswer
                            (AttemptID, QuestionID, SelectedAnswer, IsCorrect)
                        VALUES
                            (@AttemptID, @QID, @Selected, @IsCorrect)";

                    foreach (var ans in answers)
                    {
                        using (SqlCommand ansCmd = new SqlCommand(answerSql, conn))
                        {
                            ansCmd.Parameters.AddWithValue("@AttemptID", attemptId);
                            ansCmd.Parameters.AddWithValue("@QID",       ans.qid);
                            ansCmd.Parameters.AddWithValue("@Selected",
                                string.IsNullOrEmpty(ans.selected) ? (object)DBNull.Value : ans.selected);
                            ansCmd.Parameters.AddWithValue("@IsCorrect", ans.correct ? 1 : 0);
                            ansCmd.ExecuteNonQuery();
                        }
                    }

                    // Pass AttemptID to result page via Session
                    Session["LastAttemptID"] = attemptId;
                    Response.Redirect("QuizResult.aspx");
                }
            }
            catch (Exception ex)
            {
                lblError.Text    = "Error saving your attempt: " + ex.Message;
                lblError.Visible = true;
            }
        }

    }
}
