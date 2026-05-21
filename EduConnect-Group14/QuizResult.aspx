<%@ Page Title="EduConnect - Quiz Result" Language="C#" MasterPageFile="~/Site.Master"
         AutoEventWireup="true" CodeBehind="QuizResult.aspx.cs" Inherits="EduConnect.QuizResult" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===== RESULT SECTION ===== --%>
    <div class="result-section">

        <%-- Error fallback --%>
        <asp:Label ID="lblError" runat="server" Visible="false" CssClass="msg-error" />

        <%-- Score Card Panel --%>
        <asp:Panel ID="pnlResult" runat="server" Visible="false">

            <%-- Score card (dark blue banner) --%>
            <div class="scorecard">
                <h2><asp:Literal ID="litQuizTitle" runat="server" /></h2>
                <span class="quiz-topic-small">
                    Topic: <asp:Literal ID="litTopic" runat="server" />
                </span>

                <%-- Big percentage number --%>
                <div class="score-big">
                    <asp:Literal ID="litPercentage" runat="server" />%
                </div>
                <span class="score-label">Score</span>

                <%-- Correct / Total row --%>
                <div class="score-stats-row">
                    <div class="stat-block">
                        <div class="val"><asp:Literal ID="litScore" runat="server" /></div>
                        <div class="lbl">Correct</div>
                    </div>
                    <div class="stat-block">
                        <div class="val"><asp:Literal ID="litTotal" runat="server" /></div>
                        <div class="lbl">Total</div>
                    </div>
                    <div class="stat-block">
                        <div class="val"><asp:Literal ID="litWrong" runat="server" /></div>
                        <div class="lbl">Wrong</div>
                    </div>
                </div>

                <%-- Pass / Fail badge --%>
                <asp:Label ID="lblPassFail" runat="server" CssClass="pass-label" />

                <%-- Action buttons --%>
                <div class="result-btn-row">
                    <asp:HyperLink ID="lnkTryAgain" runat="server" Text="Try Again" />
                    <a href="QuizList.aspx">Back to Quizzes</a>
                </div>
            </div>

            <%-- ===== PER-QUESTION REVIEW ===== --%>
            <h3 class="review-heading">Question Review</h3>

            <asp:Repeater ID="rptReview" runat="server">
                <ItemTemplate>
                    <div class='<%# (bool)Eval("IsCorrect") ? "review-card correct-card" : "review-card wrong-card" %>'>

                        <div class="review-q-num">
                            Question <%# Container.ItemIndex + 1 %>
                        </div>

                        <div class="review-q-text">
                            <%# Eval("QuestionText") %>
                        </div>

                        <span class='<%# (bool)Eval("IsCorrect") ? "pill pill-correct" : "pill pill-wrong" %>'>
                            Your Answer: <%# Eval("SelectedLabel") %>
                        </span>

                        <%# (bool)Eval("IsCorrect") ? ""
                            : "<span class=\"pill pill-correct\">Correct Answer: " + Eval("CorrectLabel") + "</span>" %>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

        </asp:Panel><%-- end pnlResult --%>

    </div><%-- end .result-section --%>

</asp:Content>
