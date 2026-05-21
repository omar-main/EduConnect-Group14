<%@ Page Title="EduConnect - Practice Quizzes" Language="C#" MasterPageFile="~/Site.Master"
         AutoEventWireup="true" CodeBehind="QuizList.aspx.cs" Inherits="EduConnect.QuizList" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===== INTRO SECTION ===== --%>
    <section id="intro">
        <h1>Practice Quizzes</h1>
        <p>Test your understanding of HTML and CSS with our interactive topic-based quizzes. Select a quiz below to get started.</p>
    </section>

    <%-- ===== QUIZ CARDS SECTION ===== --%>
    <div class="quiz-section">

        <%-- Message label (success / error) --%>
        <asp:Label ID="lblMessage" runat="server" Visible="false" />

        <%-- Sub-heading --%>
        <h2>Available Quizzes</h2>
        <p class="subtitle">
            Logged in as: <strong><asp:Literal ID="litWelcome" runat="server" /></strong>
        </p>

        <%-- Quiz Cards Repeater --%>
        <asp:Repeater ID="rptQuizzes" runat="server" OnItemCommand="rptQuizzes_ItemCommand">
            <HeaderTemplate>
                <div class="quiz-grid">
            </HeaderTemplate>

            <ItemTemplate>
                <div class="quiz-card">
                    <div class="quiz-topic-tag"><%# Eval("Topic") %></div>
                    <h3><%# Eval("Title") %></h3>
                    <p><%# Eval("Description") %></p>

                    <div class="quiz-meta-info">
                        <%# Eval("TotalQuestions") %> Questions &nbsp;&nbsp;
                        ~<%# Convert.ToInt32(Eval("TotalQuestions")) * 2 %> mins
                    </div>

                    <div class="quiz-attempts-bar">
                        <span>Your Attempts: <strong><%# Eval("AttemptCount") %></strong></span>
                        <span>Best Score:
                            <strong>
                                <%# (Eval("BestScore") != DBNull.Value) ? Eval("BestScore") + "%" : "N/A" %>
                            </strong>
                        </span>
                    </div>

                    <asp:Button ID="btnStart" runat="server"
                        Text="Start Quiz"
                        CssClass="btn-quiz"
                        CommandName="StartQuiz"
                        CommandArgument='<%# Eval("QuizID") %>' />
                </div>
            </ItemTemplate>

            <FooterTemplate>
                </div>
            </FooterTemplate>
        </asp:Repeater>

        <%-- Shown if no quizzes are in the database --%>
        <asp:Label ID="lblNoQuiz" runat="server" Visible="false"
            Text="No quizzes are available at the moment. Please check back later."
            CssClass="no-data" />

    </div><%-- end .quiz-section --%>

</asp:Content>
