// ============================================================
// EduConnect - StudyMaterials.aspx.cs
// CT050-3-2-WAPP Group Assignment
// Member 3: Database Admin & Study Materials
//
// This page serves two views depending on the query string:
//
//   StudyMaterials.aspx            → card grid (all materials)
//   StudyMaterials.aspx?topic=HTML → card grid (HTML only)
//   StudyMaterials.aspx?topic=CSS  → card grid (CSS only)
//   StudyMaterials.aspx?id=3       → full article detail for MaterialID 3
//
// ADO.NET operations: SELECT (list) and SELECT by primary key (detail)
// No login required — this is a public page.
// ============================================================

using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace EduConnect
{
    public partial class StudyMaterials : System.Web.UI.Page
    {
        // -------------------------------------------------------
        // Connection string from web.config
        // Matches the name used by all other members: "EduConnectDB"
        // -------------------------------------------------------
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["EduConnectDB"].ConnectionString;

        // -------------------------------------------------------
        // Properties used by the filter anchor tags in the ASPX
        // (Data binding sets the "active" CSS class)
        // -------------------------------------------------------
        public string FilterAllCss  { get; private set; } = "";
        public string FilterHtmlCss { get; private set; } = "";
        public string FilterCssCss  { get; private set; } = "";

        // -------------------------------------------------------
        // Page_Load
        // Decides which view to show based on query string
        // -------------------------------------------------------
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string idParam    = Request.QueryString["id"];
                string topicParam = Request.QueryString["topic"];

                if (!string.IsNullOrEmpty(idParam) && int.TryParse(idParam, out int materialId))
                {
                    // ---- Show detail view for a specific material ----
                    ShowDetail(materialId);
                }
                else
                {
                    // ---- Show card grid, optionally filtered by topic ----
                    ShowList(topicParam);
                }

                // Trigger data binding so the filter anchor tag classes resolve
                Page.DataBind();
            }
        }

        // -------------------------------------------------------
        // ShowList
        // SQL SELECT: loads materials into the Repeater card grid.
        // Filters by topic when a valid topic is supplied.
        // -------------------------------------------------------
        private void ShowList(string topic)
        {
            // Show the list panel, hide the detail panel
            pnlList.Visible   = true;
            pnlDetail.Visible = false;

            // Mark the correct filter button as active
            if (topic == "HTML")
            {
                FilterHtmlCss      = "active";
                litListHeading.Text = "HTML Study Materials";
            }
            else if (topic == "CSS")
            {
                FilterCssCss       = "active";
                litListHeading.Text = "CSS Study Materials";
            }
            else
            {
                FilterAllCss       = "active";
                litListHeading.Text = "All Study Materials";
                topic = null;   // Treat everything else as "no filter"
            }

            // Build the SELECT query; add WHERE clause only when filtering
            string sql = @"
                SELECT MaterialID, Title, Topic, Summary
                FROM   StudyMaterial";

            if (!string.IsNullOrEmpty(topic))
                sql += " WHERE Topic = @Topic";

            sql += " ORDER BY Topic ASC, SortOrder ASC, MaterialID ASC";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    // Bind the topic parameter only when filtering
                    if (!string.IsNullOrEmpty(topic))
                        cmd.Parameters.AddWithValue("@Topic", topic);

                    conn.Open();

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        // No rows returned — show the "no data" message
                        rptMaterials.Visible = false;
                        lblNoData.Visible    = true;
                    }
                    else
                    {
                        // Bind the DataTable to the Repeater
                        rptMaterials.DataSource = dt;
                        rptMaterials.DataBind();
                        rptMaterials.Visible = true;
                        lblNoData.Visible    = false;
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                // Show a friendly database error message
                lblListError.Text    = "Database error loading materials: " + sqlEx.Message;
                lblListError.Visible = true;
            }
            catch (Exception ex)
            {
                lblListError.Text    = "An unexpected error occurred: " + ex.Message;
                lblListError.Visible = true;
            }
        }

        // -------------------------------------------------------
        // ShowDetail
        // SQL SELECT by primary key: loads one material for display.
        // -------------------------------------------------------
        private void ShowDetail(int materialId)
        {
            // Hide the list panel, show the detail panel
            pnlList.Visible   = false;
            pnlDetail.Visible = true;

            // No filter button is "active" on the detail view
            FilterAllCss = FilterHtmlCss = FilterCssCss = "";

            // Set the "Back" link to preserve any topic filter the user had
            string referrer = Request.UrlReferrer?.AbsolutePath ?? "";
            lnkBack.NavigateUrl = referrer.Contains("StudyMaterials")
                ? Request.UrlReferrer.PathAndQuery
                : "StudyMaterials.aspx";

            string sql = @"
                SELECT Title, Topic, ContentText, CreatedDate, UpdatedDate
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
                            // Populate the detail Literal controls
                            litDetailTopic.Text = dr["Topic"].ToString();
                            litDetailTitle.Text = HttpUtility.HtmlEncode(dr["Title"].ToString());

                            // Use UpdatedDate if set, otherwise fall back to CreatedDate
                            DateTime displayDate = dr["UpdatedDate"] != DBNull.Value
                                ? Convert.ToDateTime(dr["UpdatedDate"])
                                : Convert.ToDateTime(dr["CreatedDate"]);
                            litDetailDate.Text = displayDate.ToString("dd MMM yyyy");

                            // HtmlEncode protects against XSS.
                            // white-space: pre-wrap in CSS preserves the newlines from the DB.
                            litDetailContent.Text = HttpUtility.HtmlEncode(
                                dr["ContentText"].ToString());
                        }
                        else
                        {
                            // MaterialID not found — show a polite error
                            litDetailTitle.Text   = "Material Not Found";
                            litDetailTopic.Text   = "-";
                            litDetailDate.Text    = "-";
                            litDetailContent.Text =
                                "The requested study material could not be found.\n" +
                                "It may have been removed by an administrator.\n\n" +
                                "Please return to the Study Materials list and choose another article.";
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                litDetailTitle.Text   = "Database Error";
                litDetailContent.Text = "Could not load this material: " + sqlEx.Message;
            }
            catch (Exception ex)
            {
                litDetailTitle.Text   = "Error";
                litDetailContent.Text = "An unexpected error occurred: " + ex.Message;
            }
        }
    }
}
