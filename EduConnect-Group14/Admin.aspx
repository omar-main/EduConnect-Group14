<%@ Page Title="EduConnect - Admin: Manage Study Materials" Language="C#"
         MasterPageFile="~/Site.Master" AutoEventWireup="true"
         CodeBehind="Admin.aspx.cs" Inherits="EduConnect.Admin"
         ValidateRequest="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* Extra column widths for the study materials GridView */
        .col-topic   { width: 80px;  }
        .col-summary { width: 300px; }
        .col-date    { width: 110px; }
        .col-action  { width: 80px; text-align: center; }

        /* Larger content textarea */
        .content-textarea {
            min-height: 160px;
            resize: vertical;
        }

        /* Admin page banner note */
        #intro p.admin-note {
            color: #c17d00;
            font-weight: bold;
            font-size: 13px;
            margin-top: 6px;
        }

        /* Flex row for form action buttons */
        .form-btn-row {
            display: flex;
            gap: 12px;
            margin-top: 20px;
        }

        /* Narrow wrapper for sort order field */
        .sort-order-group {
            max-width: 200px;
        }

        /* Helper text within labels */
        .label-hint {
            font-weight: normal;
            font-size: 12px;
            color: #666666;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===== INTRO ===== --%>
    <section id="intro">
        <h1>Manage Study Materials</h1>
        <p>Add, edit, and delete study articles available to students on the Study Materials page. All changes are applied immediately.</p>
        <p class="admin-note">Admin access only. You are logged in as:
            <asp:Literal ID="litAdminName" runat="server" />
        </p>
    </section>

    <%-- ===== ADMIN CONTENT AREA ===== --%>
    <div class="admin-section">

        <%-- Success / Error banner --%>
        <asp:Label ID="lblMessage" runat="server" Visible="false" />

        <%-- =====================================================
             PANEL 1: ADD / EDIT STUDY MATERIAL FORM
        ====================================================== --%>
        <div class="admin-panel">

            <h2>
                <asp:Literal ID="litFormTitle" runat="server" Text="Add New Study Material" />
            </h2>

            <%-- Hidden field stores MaterialID when editing (0 = new record) --%>
            <asp:HiddenField ID="hfEditID" runat="server" Value="0" />

            <%-- Title and Topic side by side --%>
            <div class="form-two-col">

                <%-- Title --%>
                <div class="form-group">
                    <label for="txtTitle">
                        Title: <span class="required">*</span>
                    </label>
                    <asp:TextBox ID="txtTitle" runat="server"
                        CssClass="form-input"
                        MaxLength="200"
                        placeholder="e.g. Introduction to HTML" />
                    <asp:RequiredFieldValidator
                        ID="rfvTitle" runat="server"
                        ControlToValidate="txtTitle"
                        ErrorMessage="Title is required."
                        CssClass="val-err" Display="Dynamic" />
                </div>

                <%-- Topic dropdown: HTML or CSS --%>
                <div class="form-group">
                    <label for="ddlTopic">
                        Topic: <span class="required">*</span>
                    </label>
                    <asp:DropDownList ID="ddlTopic" runat="server" CssClass="form-input">
                        <asp:ListItem Value="0" Text="-- Select Topic --" />
                        <asp:ListItem Value="HTML" Text="HTML" />
                        <asp:ListItem Value="CSS"  Text="CSS"  />
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator
                        ID="rfvTopic" runat="server"
                        ControlToValidate="ddlTopic"
                        InitialValue="0"
                        ErrorMessage="Please select a topic."
                        CssClass="val-err" Display="Dynamic" />
                </div>

            </div><%-- end form-two-col (title/topic) --%>

            <%-- Summary --%>
            <div class="form-group">
                <label for="txtSummary">
                    Summary: <span class="required">*</span>
                    <span class="label-hint">(1-2 sentences shown on the card)</span>
                </label>
                <asp:TextBox ID="txtSummary" runat="server"
                    TextMode="MultiLine"
                    CssClass="form-input"
                    Rows="2"
                    MaxLength="500"
                    placeholder="A short description that appears on the study material card..." />
                <asp:RequiredFieldValidator
                    ID="rfvSummary" runat="server"
                    ControlToValidate="txtSummary"
                    ErrorMessage="Summary is required."
                    CssClass="val-err" Display="Dynamic" />
            </div>

            <%-- Full Content --%>
            <div class="form-group">
                <label for="txtContent">
                    Full Content: <span class="required">*</span>
                    <span class="label-hint">(Plain text; line breaks are preserved)</span>
                </label>
                <asp:TextBox ID="txtContent" runat="server"
                    TextMode="MultiLine"
                    CssClass="form-input content-textarea"
                    placeholder="Write the full study material content here. Use plain text; line breaks are shown to students as-is." />
                <asp:RequiredFieldValidator
                    ID="rfvContent" runat="server"
                    ControlToValidate="txtContent"
                    ErrorMessage="Content is required."
                    CssClass="val-err" Display="Dynamic" />
            </div>

            <%-- Sort Order --%>
            <div class="form-group sort-order-group">
                <label for="txtSortOrder">
                    Sort Order:
                    <span class="label-hint">(lower = shown first)</span>
                </label>
                <asp:TextBox ID="txtSortOrder" runat="server"
                    CssClass="form-input"
                    MaxLength="5"
                    placeholder="0" />
                <asp:RangeValidator
                    ID="rvSortOrder" runat="server"
                    ControlToValidate="txtSortOrder"
                    MinimumValue="0"
                    MaximumValue="9999"
                    Type="Integer"
                    ErrorMessage="Sort Order must be a whole number between 0 and 9999."
                    CssClass="val-err" Display="Dynamic" />
            </div>

            <%-- Action buttons --%>
            <div class="form-btn-row">
                <asp:Button ID="btnSave" runat="server"
                    Text="Save Material"
                    CssClass="btn-action"
                    OnClick="btnSave_Click" />

                <asp:Button ID="btnCancel" runat="server"
                    Text="Clear / Cancel"
                    CssClass="btn-action-grey"
                    CausesValidation="false"
                    OnClick="btnCancel_Click" />
            </div>

        </div><%-- end admin-panel (form) --%>

        <%-- =====================================================
             PANEL 2: ALL STUDY MATERIALS TABLE (GridView)
        ====================================================== --%>
        <div class="admin-panel">

            <h2>All Study Materials</h2>

            <asp:GridView ID="gvMaterials"
                runat="server"
                AutoGenerateColumns="false"
                CssClass="data-table"
                DataKeyNames="MaterialID"
                OnRowCommand="gvMaterials_RowCommand"
                EmptyDataText="No study materials found. Add one using the form above.">

                <Columns>

                    <asp:BoundField DataField="MaterialID"
                        HeaderText="ID"
                        ItemStyle-Width="45px" />

                    <asp:BoundField DataField="Topic"
                        HeaderText="Topic"
                        ItemStyle-Width="70px"
                        ItemStyle-HorizontalAlign="Center" />

                    <asp:BoundField DataField="Title"
                        HeaderText="Title"
                        ItemStyle-Width="200px" />

                    <asp:BoundField DataField="Summary"
                        HeaderText="Summary"
                        ItemStyle-Width="280px" />

                    <asp:BoundField DataField="DisplayDate"
                        HeaderText="Last Updated"
                        ItemStyle-Width="110px"
                        ItemStyle-HorizontalAlign="Center"
                        DataFormatString="{0:dd MMM yyyy}" />

                    <asp:TemplateField HeaderText="Edit"
                        ItemStyle-Width="65px"
                        ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:Button ID="btnEdit" runat="server"
                                Text="Edit"
                                CssClass="btn-edit"
                                CommandName="EditMat"
                                CausesValidation="false"
                                CommandArgument='<%# Eval("MaterialID") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Delete"
                        ItemStyle-Width="75px"
                        ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:Button ID="btnDelete" runat="server"
                                Text="Delete"
                                CssClass="btn-danger"
                                CommandName="DeleteMat"
                                CausesValidation="false"
                                CommandArgument='<%# Eval("MaterialID") %>'
                                OnClientClick="return confirm('Delete this study material? This cannot be undone.');" />
                        </ItemTemplate>
                    </asp:TemplateField>

                </Columns>
            </asp:GridView>

        </div><%-- end admin-panel (GridView) --%>

    </div><%-- end .admin-section --%>

</asp:Content>
