// ============================================================
// EduConnect - Admin.aspx.cs
// CT050-3-2-WAPP Group Assignment
// Member 3: Database Admin & Study Materials
//
// Admin dashboard for managing study materials.
// Implements all four CRUD operations using ADO.NET:
//
//   CREATE (INSERT) — Add a new study material via the form
//   READ   (SELECT) — Display all materials in a GridView
//   UPDATE          — Edit an existing material: load → modify → save
//   DELETE          — Remove a material after JS confirmation
//
// Access control: Session["Role"] must equal "Admin".
// Redirects to Login.aspx if the user is not authenticated.
// This matches the same security pattern used in ManageQuiz.aspx.cs.
// ============================================================

using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EduConnect
{
    public partial class Admin : Page
    {
        // -------------------------------------------------------
        // Connection string from web.config
        // Name "EduConnectDB" is used consistently across the project
        // -------------------------------------------------------
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["EduConnectDB"].ConnectionString;

        // ===========================================================
        // PAGE_LOAD
        // ===========================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            // --- Security check ---
            // Only users with Role = "Admin" may access this page.
            // Session["UserID"] and Session["Role"] are set by Login.aspx (Member 1).
            if (Session["UserID"] == null || Session["Role"]?.ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Display the logged-in admin's name in the intro banner
            litAdminName.Text = Session["FullName"]?.ToString() ?? "Administrator";

            if (!IsPostBack)
            {
                LoadMaterialsGrid();
                ResetForm();
            }
        }

        // ===========================================================
        // READ (SELECT) — LoadMaterialsGrid
        // Retrieves all study materials and binds them to the GridView.
        // Uses COALESCE to display UpdatedDate if set, else CreatedDate.
        // ===========================================================
        private void LoadMaterialsGrid()
        {
            string sql = @"
                SELECT
                    MaterialID,
                    Title,
                    Topic,
                    -- Truncate long summaries in the grid view
                    CASE
                        WHEN LEN(Summary) > 80
                        THEN LEFT(Summary, 77) + '...'
                        ELSE Summary
                    END AS Summary,
                    -- Show UpdatedDate if available; otherwise CreatedDate
                    COALESCE(UpdatedDate, CreatedDate) AS DisplayDate
                FROM  StudyMaterial
                ORDER BY Topic ASC, SortOrder ASC, MaterialID ASC";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvMaterials.DataSource = dt;
                    gvMaterials.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading materials: " + ex.Message, false);
            }
        }

        // ===========================================================
        // CREATE (INSERT) + UPDATE — btnSave_Click
        // Determines whether to INSERT or UPDATE based on hfEditID.
        // ===========================================================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ASP.NET validation controls check required fields first
            if (!Page.IsValid) return;

            // Collect form values
            string title     = txtTitle.Text.Trim();
            string topic     = ddlTopic.SelectedValue;
            string summary   = txtSummary.Text.Trim();
            string content   = txtContent.Text.Trim();
            int    editId    = Convert.ToInt32(hfEditID.Value);

            // SortOrder defaults to 0 if left blank or invalid
            int sortOrder = 0;
            if (!string.IsNullOrWhiteSpace(txtSortOrder.Text))
                int.TryParse(txtSortOrder.Text.Trim(), out sortOrder);

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    if (editId == 0)
                    {
                        // ------------------------------------------------
                        // CREATE — INSERT a brand-new study material
                        // All column values come from the form inputs.
                        // Parameterized query prevents SQL Injection.
                        // ------------------------------------------------
                        string sql = @"
                            INSERT INTO StudyMaterial
                                (Title, Topic, Summary, ContentText, SortOrder)
                            VALUES
                                (@Title, @Topic, @Summary, @Content, @Sort)";

                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@Title",   title);
                            cmd.Parameters.AddWithValue("@Topic",   topic);
                            cmd.Parameters.AddWithValue("@Summary", summary);
                            cmd.Parameters.AddWithValue("@Content", content);
                            cmd.Parameters.AddWithValue("@Sort",    sortOrder);
                            cmd.ExecuteNonQuery();
                        }

                        ShowMessage("Study material added successfully.", true);
                    }
                    else
                    {
                        // ------------------------------------------------
                        // UPDATE — Modify an existing study material.
                        // UpdatedDate is stamped with the current server time.
                        // ------------------------------------------------
                        string sql = @"
                            UPDATE StudyMaterial SET
                                Title       = @Title,
                                Topic       = @Topic,
                                Summary     = @Summary,
                                ContentText = @Content,
                                SortOrder   = @Sort,
                                UpdatedDate = GETDATE()
                            WHERE MaterialID = @EditID";

                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@Title",   title);
                            cmd.Parameters.AddWithValue("@Topic",   topic);
                            cmd.Parameters.AddWithValue("@Summary", summary);
                            cmd.Parameters.AddWithValue("@Content", content);
                            cmd.Parameters.AddWithValue("@Sort",    sortOrder);
                            cmd.Parameters.AddWithValue("@EditID",  editId);
                            cmd.ExecuteNonQuery();
                        }

                        ShowMessage("Study material updated successfully.", true);
                    }
                }

                // Refresh the grid and reset the form to "Add new" mode
                ResetForm();
                LoadMaterialsGrid();
            }
            catch (SqlException sqlEx)
            {
                ShowMessage("Database error: " + sqlEx.Message, false);
            }
            catch (Exception ex)
            {
                ShowMessage("An unexpected error occurred: " + ex.Message, false);
            }
        }

        // ===========================================================
        // btnCancel_Click
        // Resets the form without saving anything
        // ===========================================================
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        // ===========================================================
        // gvMaterials_RowCommand
        // Dispatches GridView button clicks to Edit or Delete handlers
        // ===========================================================
        protected void gvMaterials_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int materialId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditMat")
            {
                LoadMaterialForEdit(materialId);
            }
            else if (e.CommandName == "DeleteMat")
            {
                DeleteMaterial(materialId);
            }
        }

        // ===========================================================
        // READ + UPDATE prep — LoadMaterialForEdit
        // SQL SELECT: fetches one record and pre-fills the form inputs.
        // The user can then modify fields and click Save to UPDATE.
        // ===========================================================
        private void LoadMaterialForEdit(int materialId)
        {
            string sql = @"
                SELECT Title, Topic, Summary, ContentText, SortOrder
                FROM   StudyMaterial
                WHERE  MaterialID = @ID";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", materialId);
                    conn.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            // Store the ID so btnSave_Click knows to UPDATE, not INSERT
                            hfEditID.Value    = materialId.ToString();
                            litFormTitle.Text = "Edit Study Material (ID: " + materialId + ")";

                            // Pre-fill all form fields with the existing record's values
                            txtTitle.Text         = dr["Title"].ToString();
                            ddlTopic.SelectedValue = dr["Topic"].ToString();
                            txtSummary.Text       = dr["Summary"].ToString();
                            txtContent.Text       = dr["ContentText"].ToString();
                            txtSortOrder.Text     = dr["SortOrder"].ToString();

                            // Change the Save button label to make intent clear
                            btnSave.Text = "Update Material";
                        }
                    }
                }

                // Scroll the page back to the top so the user can see the form
                ScriptManager.RegisterStartupScript(this, GetType(), "scrollTop",
                    "window.scrollTo({ top: 0, behavior: 'smooth' });", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading material for editing: " + ex.Message, false);
            }
        }

        // ===========================================================
        // DELETE — DeleteMaterial
        // SQL DELETE: permanently removes a study material by its ID.
        // The JavaScript confirm() on the button provides a safety check.
        // ===========================================================
        private void DeleteMaterial(int materialId)
        {
            string sql = "DELETE FROM StudyMaterial WHERE MaterialID = @ID";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", materialId);
                    conn.Open();
                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                        ShowMessage("Study material deleted successfully.", true);
                    else
                        ShowMessage("Material not found — it may have already been deleted.", false);
                }

                // Refresh the grid to reflect the deletion
                LoadMaterialsGrid();
            }
            catch (SqlException sqlEx)
            {
                ShowMessage("Database error during deletion: " + sqlEx.Message, false);
            }
            catch (Exception ex)
            {
                ShowMessage("An unexpected error occurred: " + ex.Message, false);
            }
        }

        // ===========================================================
        // HELPERS
        // ===========================================================

        // ResetForm — clears all inputs and returns to "Add new" mode
        private void ResetForm()
        {
            hfEditID.Value    = "0";
            litFormTitle.Text = "Add New Study Material";
            btnSave.Text      = "Save Material";

            txtTitle.Text      = "";
            ddlTopic.SelectedIndex = 0;   // "-- Select Topic --"
            txtSummary.Text    = "";
            txtContent.Text    = "";
            txtSortOrder.Text  = "0";
        }

        // ShowMessage — displays a green (success) or red (error) banner
        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text     = msg;
            lblMessage.CssClass = success ? "msg-success" : "msg-error";
            lblMessage.Visible  = true;
        }
    }
}
