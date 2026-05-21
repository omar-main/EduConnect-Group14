<%@ Page Title="EduConnect - Manage Quizzes" Language="C#" MasterPageFile="~/Site.Master"
         AutoEventWireup="true" CodeBehind="ManageQuiz.aspx.cs" Inherits="EduConnect.ManageQuiz"
         ValidateRequest="false" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===== INTRO ===== --%>
    <section id="intro">
        <h1>Manage Quizzes</h1>
        <p>Add, edit, and delete quiz questions for all topics. All changes take immediate effect for students.</p>
    </section>

    <%-- ===== ADMIN CONTENT AREA ===== --%>
    <div class="admin-section">

        <%-- Success / Error message --%>
        <asp:Label ID="lblMessage" runat="server" Visible="false" />

        <%-- ================================================
             PANEL 1: ADD / EDIT QUESTION FORM
        ================================================= --%>
        <div class="admin-panel">
            <h2>
                <asp:Literal ID="litFormTitle" runat="server" Text="Add New Question" />
            </h2>

            <%-- Hidden field: stores QuestionID when editing (0 = new) --%>
            <asp:HiddenField ID="hfEditID" runat="server" Value="0" />

            <%-- Quiz Selection Dropdown --%>
            <div class="form-group">
                <label for="ddlQuiz">
                    Select Quiz: <span class="required">*</span>
                </label>
                <asp:DropDownList ID="ddlQuiz" runat="server" CssClass="form-input" />
                <asp:RequiredFieldValidator
                    ID="rfvQuiz"
                    runat="server"
                    ControlToValidate="ddlQuiz"
                    InitialValue="0"
                    ErrorMessage="Please select a quiz."
                    CssClass="val-err"
                    Display="Dynamic" />
            </div>

            <%-- Question Text --%>
            <div class="form-group">
                <label for="txtQuestion">
                    Question Text: <span class="required">*</span>
                </label>
                <asp:TextBox ID="txtQuestion" runat="server"
                    TextMode="MultiLine"
                    CssClass="form-input"
                    Rows="3"
                    placeholder="Enter the question..." />
                <asp:RequiredFieldValidator
                    ID="rfvQuestion"
                    runat="server"
                    ControlToValidate="txtQuestion"
                    ErrorMessage="Question text is required."
                    CssClass="val-err"
                    Display="Dynamic" />
            </div>

            <%-- Options A and B (side by side) --%>
            <div class="form-two-col">
                <div class="form-group">
                    <label for="txtOptA">Option A: <span class="required">*</span></label>
                    <asp:TextBox ID="txtOptA" runat="server"
                        CssClass="form-input"
                        placeholder="Option A text" />
                    <asp:RequiredFieldValidator
                        ID="rfvOptA" runat="server"
                        ControlToValidate="txtOptA"
                        ErrorMessage="Option A is required."
                        CssClass="val-err" Display="Dynamic" />
                </div>
                <div class="form-group">
                    <label for="txtOptB">Option B: <span class="required">*</span></label>
                    <asp:TextBox ID="txtOptB" runat="server"
                        CssClass="form-input"
                        placeholder="Option B text" />
                    <asp:RequiredFieldValidator
                        ID="rfvOptB" runat="server"
                        ControlToValidate="txtOptB"
                        ErrorMessage="Option B is required."
                        CssClass="val-err" Display="Dynamic" />
                </div>
            </div>

            <%-- Options C and D (side by side) --%>
            <div class="form-two-col">
                <div class="form-group">
                    <label for="txtOptC">Option C: <span class="required">*</span></label>
                    <asp:TextBox ID="txtOptC" runat="server"
                        CssClass="form-input"
                        placeholder="Option C text" />
                    <asp:RequiredFieldValidator
                        ID="rfvOptC" runat="server"
                        ControlToValidate="txtOptC"
                        ErrorMessage="Option C is required."
                        CssClass="val-err" Display="Dynamic" />
                </div>
                <div class="form-group">
                    <label for="txtOptD">Option D: <span class="required">*</span></label>
                    <asp:TextBox ID="txtOptD" runat="server"
                        CssClass="form-input"
                        placeholder="Option D text" />
                    <asp:RequiredFieldValidator
                        ID="rfvOptD" runat="server"
                        ControlToValidate="txtOptD"
                        ErrorMessage="Option D is required."
                        CssClass="val-err" Display="Dynamic" />
                </div>
            </div>

            <%-- Correct Answer (A/B/C/D) as styled radio buttons --%>
            <div class="form-group">
                <label>Correct Answer: <span class="required">*</span></label>
                <div class="answer-choice-group">
                    <label class="answer-choice-lbl">
                        <asp:RadioButton ID="rbA" runat="server" GroupName="CorrectAns" Text="A" />
                    </label>
                    <label class="answer-choice-lbl">
                        <asp:RadioButton ID="rbB" runat="server" GroupName="CorrectAns" Text="B" />
                    </label>
                    <label class="answer-choice-lbl">
                        <asp:RadioButton ID="rbC" runat="server" GroupName="CorrectAns" Text="C" />
                    </label>
                    <label class="answer-choice-lbl">
                        <asp:RadioButton ID="rbD" runat="server" GroupName="CorrectAns" Text="D" />
                    </label>
                </div>
                <asp:CustomValidator
                    ID="cvCorrectAns"
                    runat="server"
                    ErrorMessage="Please select the correct answer (A, B, C, or D)."
                    CssClass="val-err"
                    Display="Dynamic"
                    OnServerValidate="cvCorrectAns_ServerValidate" />
            </div>

            <%-- Buttons: Save + Cancel/Clear --%>
            <div class="form-btn-row">
                <asp:Button ID="btnSave" runat="server"
                    Text="Save Question"
                    CssClass="btn-action"
                    OnClick="btnSave_Click" />

                <asp:Button ID="btnCancel" runat="server"
                    Text="Clear / Cancel"
                    CssClass="btn-action-grey"
                    CausesValidation="false"
                    OnClick="btnCancel_Click" />
            </div>

        </div><%-- end admin-panel (form) --%>

        <%-- ================================================
             PANEL 2: QUESTIONS TABLE (GridView)
        ================================================= --%>
        <div class="admin-panel">
            <h2>All Quiz Questions</h2>

            <asp:GridView ID="gvQuestions"
                runat="server"
                AutoGenerateColumns="false"
                CssClass="data-table"
                DataKeyNames="QuestionID"
                OnRowCommand="gvQuestions_RowCommand"
                EmptyDataText="No questions found. Add one using the form above.">

                <Columns>
                    <asp:BoundField DataField="QuestionID"
                        HeaderText="ID"
                        ItemStyle-Width="50px" />

                    <asp:BoundField DataField="QuizTitle"
                        HeaderText="Quiz"
                        ItemStyle-Width="160px" />

                    <asp:BoundField DataField="QuestionText"
                        HeaderText="Question"
                        ItemStyle-Width="300px" />

                    <asp:BoundField DataField="CorrectAnswer"
                        HeaderText="Answer"
                        ItemStyle-Width="70px"
                        ItemStyle-HorizontalAlign="Center" />

                    <asp:TemplateField HeaderText="Edit" ItemStyle-Width="70px" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:Button ID="btnEdit" runat="server"
                                Text="Edit"
                                CssClass="btn-edit"
                                CommandName="EditQ"
                                CausesValidation="false"
                                CommandArgument='<%# Eval("QuestionID") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Delete" ItemStyle-Width="80px" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:Button ID="btnDelete" runat="server"
                                Text="Delete"
                                CssClass="btn-danger"
                                CommandName="DeleteQ"
                                CausesValidation="false"
                                CommandArgument='<%# Eval("QuestionID") %>'
                                OnClientClick="return confirm('Delete this question? This action cannot be undone.');" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>

        </div><%-- end admin-panel (grid) --%>

    </div><%-- end .admin-section --%>

</asp:Content>
