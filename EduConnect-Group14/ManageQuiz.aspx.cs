// ============================================================
// EduConnect - ManageQuiz.aspx.cs
// CT050-3-2-WAPP Group Assignment
//
// Admin page: full CRUD operations for quiz questions.
//   INSERT  – Add a new question via the form
//   SELECT  – Display all questions in a GridView
//   UPDATE  – Load a question into the form for editing, then save
//   DELETE  – Remove a question with confirmation
//
// Access restricted to Session["Role"] == "Admin"
// ============================================================
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EduConnect
{
    public partial class ManageQuiz : Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["EduConnectDB"].ConnectionString;

        // ----------------------------------------------------------
        // Page_Load
        // ----------------------------------------------------------
        protected void Page_Load(object sender, EventArgs e)
        {
            // Security: only Admin role may access this page
            if (Session["UserID"] == null || Session["Role"]?.ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadQuizDropdown();
                LoadQuestionsGrid();
                ResetForm();
            }
        }

        // ----------------------------------------------------------
        // LoadQuizDropdown
        // Populates the Quiz dropdown used when adding/editing
        // ----------------------------------------------------------
        private void LoadQuizDropdown()
        {
            string sql = "SELECT QuizID, Title FROM Quiz ORDER BY QuizID ASC";
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlQuiz.DataSource    = dt;
                    ddlQuiz.DataTextField  = "Title";
                    ddlQuiz.DataValueField = "QuizID";
                    ddlQuiz.DataBind();

                    // Blank "please select" item at the top
                    ddlQuiz.Items.Insert(0, new ListItem("-- Select Quiz --", "0"));
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading quizzes: " + ex.Message, false);
            }
        }

        // ----------------------------------------------------------
        // LoadQuestionsGrid
        // SQL SELECT: all questions joined with their quiz title
        // ----------------------------------------------------------
        private void LoadQuestionsGrid()
        {
            string sql = @"
                SELECT
                    qq.QuestionID,
                    q.Title         AS QuizTitle,
                    qq.QuestionText,
                    qq.CorrectAnswer
                FROM QuizQuestion qq
                INNER JOIN Quiz q ON qq.QuizID = q.QuizID
                ORDER BY q.QuizID ASC, qq.QuestionID ASC";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvQuestions.DataSource = dt;
                    gvQuestions.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading questions: " + ex.Message, false);
            }
        }

        // ----------------------------------------------------------
        // btnSave_Click
        // INSERT new question OR UPDATE existing one
        // ----------------------------------------------------------
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return; // ASP.NET validators failed

            // Determine correct answer from radio buttons
            string correctAns = "";
            if (rbA.Checked) correctAns = "A";
            else if (rbB.Checked) correctAns = "B";
            else if (rbC.Checked) correctAns = "C";
            else if (rbD.Checked) correctAns = "D";

            // Extra server-side check (in case JS is disabled)
            if (string.IsNullOrEmpty(correctAns))
            {
                ShowMessage("Please select the correct answer (A, B, C or D).", false);
                return;
            }

            int quizId  = Convert.ToInt32(ddlQuiz.SelectedValue);
            int editId  = Convert.ToInt32(hfEditID.Value);
            string qText = txtQuestion.Text.Trim();
            string optA  = txtOptA.Text.Trim();
            string optB  = txtOptB.Text.Trim();
            string optC  = txtOptC.Text.Trim();
            string optD  = txtOptD.Text.Trim();

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    if (editId == 0)
                    {
                        // ---- INSERT new question ----
                        string sql = @"
                            INSERT INTO QuizQuestion
                                (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer)
                            VALUES
                                (@QID, @QText, @OptA, @OptB, @OptC, @OptD, @Correct);

                            -- Keep TotalQuestions count in sync
                            UPDATE Quiz
                            SET TotalQuestions = (
                                SELECT COUNT(*) FROM QuizQuestion WHERE QuizID = @QID2
                            )
                            WHERE QuizID = @QID3;";

                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@QID",     quizId);
                            cmd.Parameters.AddWithValue("@QText",   qText);
                            cmd.Parameters.AddWithValue("@OptA",    optA);
                            cmd.Parameters.AddWithValue("@OptB",    optB);
                            cmd.Parameters.AddWithValue("@OptC",    optC);
                            cmd.Parameters.AddWithValue("@OptD",    optD);
                            cmd.Parameters.AddWithValue("@Correct", correctAns);
                            cmd.Parameters.AddWithValue("@QID2",    quizId);
                            cmd.Parameters.AddWithValue("@QID3",    quizId);
                            cmd.ExecuteNonQuery();
                        }

                        ShowMessage("Question added successfully.", true);
                    }
                    else
                    {
                        // ---- UPDATE existing question ----
                        string sql = @"
                            UPDATE QuizQuestion SET
                                QuizID        = @QID,
                                QuestionText  = @QText,
                                OptionA       = @OptA,
                                OptionB       = @OptB,
                                OptionC       = @OptC,
                                OptionD       = @OptD,
                                CorrectAnswer = @Correct
                            WHERE QuestionID = @EditID";

                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@QID",     quizId);
                            cmd.Parameters.AddWithValue("@QText",   qText);
                            cmd.Parameters.AddWithValue("@OptA",    optA);
                            cmd.Parameters.AddWithValue("@OptB",    optB);
                            cmd.Parameters.AddWithValue("@OptC",    optC);
                            cmd.Parameters.AddWithValue("@OptD",    optD);
                            cmd.Parameters.AddWithValue("@Correct", correctAns);
                            cmd.Parameters.AddWithValue("@EditID",  editId);
                            cmd.ExecuteNonQuery();
                        }

                        ShowMessage("Question updated successfully.", true);
                    }
                }

                ResetForm();
                LoadQuizDropdown();
                LoadQuestionsGrid();
            }
            catch (Exception ex)
            {
                ShowMessage("Error saving question: " + ex.Message, false);
            }
        }

        // ----------------------------------------------------------
        // btnCancel_Click
        // Clears the form and resets to "Add" mode
        // ----------------------------------------------------------
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        // ----------------------------------------------------------
        // gvQuestions_RowCommand
        // Handles Edit and Delete button clicks in the GridView
        // ----------------------------------------------------------
        protected void gvQuestions_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int questionId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditQ")
            {
                LoadQuestionForEdit(questionId);
            }
            else if (e.CommandName == "DeleteQ")
            {
                DeleteQuestion(questionId);
            }
        }

        // ----------------------------------------------------------
        // LoadQuestionForEdit
        // SQL SELECT: fetch one question and pre-fill the form
        // ----------------------------------------------------------
        private void LoadQuestionForEdit(int questionId)
        {
            string sql = @"
                SELECT QuizID, QuestionText,
                       OptionA, OptionB, OptionC, OptionD, CorrectAnswer
                FROM QuizQuestion
                WHERE QuestionID = @QID";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@QID", questionId);
                    conn.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            hfEditID.Value = questionId.ToString();
                            litFormTitle.Text = "Edit Question (ID: " + questionId + ")";

                            // Set dropdown
                            ddlQuiz.SelectedValue = dr["QuizID"].ToString();

                            // Set text fields
                            txtQuestion.Text = dr["QuestionText"].ToString();
                            txtOptA.Text     = dr["OptionA"].ToString();
                            txtOptB.Text     = dr["OptionB"].ToString();
                            txtOptC.Text     = dr["OptionC"].ToString();
                            txtOptD.Text     = dr["OptionD"].ToString();

                            // Set correct answer radio
                            rbA.Checked = rbB.Checked = rbC.Checked = rbD.Checked = false;
                            switch (dr["CorrectAnswer"].ToString())
                            {
                                case "A": rbA.Checked = true; break;
                                case "B": rbB.Checked = true; break;
                                case "C": rbC.Checked = true; break;
                                case "D": rbD.Checked = true; break;
                            }

                            // Change button text
                            btnSave.Text = "Update Question";
                        }
                    }
                }

                // Scroll to the form
                ScriptManager.RegisterStartupScript(this, GetType(), "scroll",
                    "window.scrollTo({top:0, behavior:'smooth'});", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading question: " + ex.Message, false);
            }
        }

        // ----------------------------------------------------------
        // DeleteQuestion
        // SQL DELETE: removes a question + resyncs TotalQuestions
        // ----------------------------------------------------------
        private void DeleteQuestion(int questionId)
        {
            string sql = @"
                DECLARE @QID INT;
                SELECT @QID = QuizID FROM QuizQuestion WHERE QuestionID = @QQID;

                DELETE FROM QuizQuestion WHERE QuestionID = @QQID2;

                -- Keep TotalQuestions count accurate
                UPDATE Quiz
                SET TotalQuestions = (
                    SELECT COUNT(*) FROM QuizQuestion WHERE QuizID = @QID
                )
                WHERE QuizID = @QID;";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@QQID",  questionId);
                    cmd.Parameters.AddWithValue("@QQID2", questionId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Question deleted successfully.", true);
                LoadQuestionsGrid();
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting question: " + ex.Message, false);
            }
        }

        // ----------------------------------------------------------
        // cvCorrectAns_ServerValidate
        // Custom server-side validation: at least one radio checked
        // ----------------------------------------------------------
        protected void cvCorrectAns_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = (rbA.Checked || rbB.Checked || rbC.Checked || rbD.Checked);
        }

        // ----------------------------------------------------------
        // ResetForm  –  clear all inputs, reset to "Add" mode
        // ----------------------------------------------------------
        private void ResetForm()
        {
            hfEditID.Value    = "0";
            litFormTitle.Text = "Add New Question";
            btnSave.Text      = "Save Question";

            // Re-load the dropdown in case it lost state
            if (ddlQuiz.Items.Count == 0) LoadQuizDropdown();
            if (ddlQuiz.Items.Count > 0)  ddlQuiz.SelectedIndex = 0;

            txtQuestion.Text = "";
            txtOptA.Text     = "";
            txtOptB.Text     = "";
            txtOptC.Text     = "";
            txtOptD.Text     = "";
            rbA.Checked = rbB.Checked = rbC.Checked = rbD.Checked = false;
        }

        // ----------------------------------------------------------
        // ShowMessage  –  display success (green) or error (red)
        // ----------------------------------------------------------
        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text      = msg;
            lblMessage.CssClass  = success ? "msg-success" : "msg-error";
            lblMessage.Visible   = true;
        }
    }
}
