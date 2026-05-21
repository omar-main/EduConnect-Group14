<%@ Page Title="EduConnect - Quiz Attempt" Language="C#" MasterPageFile="~/Site.Master"
         AutoEventWireup="true" CodeBehind="QuizAttempt.aspx.cs" Inherits="EduConnect.QuizAttempt" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===== QUIZ ATTEMPT SECTION ===== --%>
    <div class="attempt-section">

        <%-- Quiz title + timer bar --%>
        <div class="quiz-header-bar">
            <div>
                <h2><asp:Literal ID="litQuizTitle" runat="server" /></h2>
                <div class="topic-label">
                    Topic: <asp:Literal ID="litTopic" runat="server" />
                </div>
            </div>
            <%-- Countdown Timer --%>
            <div id="timerBox" class="timer-display">
                <asp:HiddenField ID="hfTimer" runat="server" />
                <span id="timerText">--:--</span>
            </div>
        </div>

        <%-- Progress bar --%>
        <div class="progress-outer">
            <div class="progress-inner" id="progressBar" style="width:0%;"></div>
        </div>
        <div class="progress-text">
            <span id="progressLabel">
                0 of <asp:Literal ID="litTotalQ" runat="server" /> answered
            </span>
        </div>

        <%-- Server-side error (shown if validation fails on postback) --%>
        <asp:Label ID="lblError" runat="server" Visible="false" CssClass="msg-error" />

        <%-- ===== QUESTION REPEATER =====
             Each item renders one multiple-choice question
             with a RadioButtonList for options A-D.
        --%>
        <asp:Repeater ID="rptQuestions" runat="server"
            OnItemDataBound="rptQuestions_ItemDataBound">
            <ItemTemplate>
                <div class="question-card" id='<%# "qcard" + (Container.ItemIndex + 1) %>'>

                    <div class="q-number">
                        Question <%# Container.ItemIndex + 1 %>
                        of <%# Eval("TotalQ") %>
                    </div>

                    <div class="q-text"><%# Eval("QuestionText") %></div>

                    <%-- Radio buttons for options A, B, C, D --%>
                    <%-- Items are added in code-behind via ItemDataBound --%>
                    <asp:RadioButtonList
                        ID="rblOptions"
                        runat="server"
                        RepeatDirection="Vertical"
                        CssClass="rbl-options"
                        DataValueField="Value"
                        DataTextField="Text" />

                    <%-- Hidden field carries QuestionID to code-behind on postback --%>
                    <asp:HiddenField ID="hfQID"
                        runat="server"
                        Value='<%# Eval("QuestionID") %>' />

                    <%-- Validation hint (shown by JavaScript) --%>
                    <div class="val-hint"
                         id='<%# "vh" + (Container.ItemIndex + 1) %>'>
                        Please select an answer.
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <%-- ===== SUBMIT BUTTON BOX ===== --%>
        <div class="submit-box">
            <p>Ensure all questions are answered before submitting.</p>
            <asp:Button ID="btnSubmit"
                runat="server"
                Text="Submit Quiz"
                CssClass="btn-submit"
                OnClick="btnSubmit_Click"
                OnClientClick="return handleSubmitClick();" />
        </div>

    </div><%-- end .attempt-section --%>

    <%-- ===== CONFIRMATION OVERLAY ===== --%>
    <div class="confirm-overlay" id="confirmOverlay">
        <div class="confirm-box">
            <h3>Submit Quiz?</h3>
            <p>Are you sure? You cannot change your answers after submitting.</p>
            <div class="btn-row">
                <button type="button" class="btn-action" onclick="proceedSubmit()">
                    Yes, Submit
                </button>
                <button type="button" class="btn-action-grey" onclick="cancelSubmit()">
                    Cancel
                </button>
            </div>
        </div>
    </div>

    <%-- ===================================================
         JAVASCRIPT
         1. Countdown Timer (client-side, auto-submits when done)
         2. Progress Bar (tracks how many questions are answered)
         3. Form Validation (all must be answered before submit)
         4. Confirmation Dialog (prevents accidental submissions)
    ==================================================== --%>
    <script type="text/javascript">

        // ==== 1. COUNTDOWN TIMER ====
        var seconds = parseInt(document.getElementById('<%= hfTimer.ClientID %>').value) || 600;
        var timerInterval;

        function padTwo(n) { return n < 10 ? '0' + n : '' + n; }

        function startTimer() {
            timerInterval = setInterval(function () {
                seconds--;
                var m = Math.floor(seconds / 60);
                var s = seconds % 60;
                document.getElementById('timerText').textContent = padTwo(m) + ':' + padTwo(s);

                if (seconds <= 60) {
                    document.getElementById('timerBox').classList.add('time-warning');
                }
                if (seconds <= 0) {
                    clearInterval(timerInterval);
                    autoSubmit();
                }
            }, 1000);
        }

        function autoSubmit() {
            readyToSubmit = true;
            document.getElementById('<%= btnSubmit.ClientID %>').click();
        }

        window.onload = function () { startTimer(); };


        // ==== 2. PROGRESS BAR ====
        var totalQ = parseInt('<%= rptQuestions.Items.Count %>') || 0;

        function updateProgress() {
            var cards = document.querySelectorAll('.question-card');
            var count = 0;
            cards.forEach(function (card) {
                var radios = card.querySelectorAll('input[type="radio"]');
                if (Array.from(radios).some(function (r) { return r.checked; })) {
                    count++;
                    card.classList.add('answered-card');
                }
            });
            var pct = totalQ > 0 ? (count / totalQ) * 100 : 0;
            document.getElementById('progressBar').style.width = pct + '%';
            document.getElementById('progressLabel').textContent =
                count + ' of ' + totalQ + ' answered';
        }

        document.addEventListener('change', function (e) {
            if (e.target && e.target.type === 'radio') { updateProgress(); }
        });


        // ==== 3. CLIENT-SIDE FORM VALIDATION ====
        function validateAnswers() {
            var cards = document.querySelectorAll('.question-card');
            var valid = true;
            var firstBad = null;

            for (var i = 0; i < cards.length; i++) {
                var card = cards[i];
                var radios = card.querySelectorAll('input[type="radio"]');
                var answered = Array.from(radios).some(function (r) { return r.checked; });
                var hint = document.getElementById('vh' + (i + 1));

                if (!answered) {
                    valid = false;
                    card.classList.add('error-card');
                    if (hint) hint.classList.add('show');
                    if (!firstBad) firstBad = card;
                } else {
                    card.classList.remove('error-card');
                    if (hint) hint.classList.remove('show');
                }
            }

            if (!valid && firstBad) {
                firstBad.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
            return valid;
        }


        // ==== 4. CONFIRMATION DIALOG ====
        var readyToSubmit = false;

        function handleSubmitClick() {
            if (readyToSubmit) return true;
            if (!validateAnswers()) return false;

            document.getElementById('confirmOverlay').classList.add('show');
            return false;
        }

        function proceedSubmit() {
            readyToSubmit = true;
            clearInterval(timerInterval);
            document.getElementById('confirmOverlay').classList.remove('show');
            document.getElementById('<%= btnSubmit.ClientID %>').click();
        }

        function cancelSubmit() {
            document.getElementById('confirmOverlay').classList.remove('show');
        }

    </script>

</asp:Content>
