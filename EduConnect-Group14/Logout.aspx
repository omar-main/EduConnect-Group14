<%@ Page Title="EduConnect - Logging Out" Language="C#" MasterPageFile="~/Site.Master"
         AutoEventWireup="true" CodeBehind="Logout.aspx.cs" Inherits="EduConnect.Logout" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .logout-wrapper {
            max-width: 420px;
            margin: 60px auto;
            background-color: #ffffff;
            border: 1px solid #cccccc;
            border-top: 4px solid #003366;
            padding: 40px 35px;
            text-align: center;
        }

        .logout-wrapper h2 {
            color: #003366;
            font-size: 20px;
            margin: 0 0 10px 0;
        }

        .logout-wrapper p {
            font-size: 14px;
            color: #555555;
            line-height: 1.6;
            margin-bottom: 22px;
        }

        .redirect-note {
            font-size: 12px;
            color: #888888;
            margin-top: 18px;
        }

        .btn-login-again {
            display: inline-block;
            padding: 10px 30px;
            background-color: #003366;
            color: #ffffff;
            text-decoration: none;
            font-size: 14px;
            font-weight: bold;
            border: none;
            cursor: pointer;
        }

        .btn-login-again:hover {
            background-color: #0055aa;
        }

        .countdown-bar-outer {
            height: 5px;
            background-color: #e0e0e0;
            margin-top: 20px;
            overflow: hidden;
        }

        .countdown-bar-inner {
            height: 100%;
            background-color: #003366;
            width: 100%;
            transition: width linear;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===== LOGOUT CARD ===== --%>
    <div id="main-area" style="background-color:#f5f5f5; padding:30px 25px; clear:both;">
        <div class="logout-wrapper">

            <h2>You have been logged out</h2>

            <p>
                Your session has been cleared successfully.<br />
                Thank you for using <strong>EduConnect</strong>.
            </p>

            <a href="Login.aspx" class="btn-login-again">Log In Again</a>

            <p class="redirect-note">
                Redirecting to the home page in
                <strong><span id="countNum">5</span></strong> seconds...
            </p>

            <div class="countdown-bar-outer">
                <div class="countdown-bar-inner" id="cBar"></div>
            </div>

        </div>
    </div>

    <%-- Countdown + redirect script --%>
    <script type="text/javascript">
        var count = 5;
        var bar = document.getElementById('cBar');
        var numSpan = document.getElementById('countNum');

        bar.style.transition = 'width ' + count + 's linear';
        setTimeout(function () { bar.style.width = '0%'; }, 50);

        var timer = setInterval(function () {
            count--;
            numSpan.textContent = count;
            if (count <= 0) {
                clearInterval(timer);
                window.location.href = 'index.html';
            }
        }, 1000);
    </script>

</asp:Content>
