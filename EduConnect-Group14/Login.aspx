<%@ Page Title="EduConnect - Login" Language="C#" MasterPageFile="~/Site.Master"
         AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="EduConnect.Login" %>

<%-- HeadContent: page-specific styles injected into the master's <head> --%>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>

        /* ---- Login page intro section ---- */
        #login-intro {
            background-color: #ffffff;
            padding: 28px 25px;
            border-bottom: 2px solid #003366;
        }

        #login-intro h1 {
            color: #003366;
            margin: 0 0 10px 0;
            font-size: 24px;
        }

        #login-intro p {
            font-size: 15px;
            line-height: 1.7;
            color: #333333;
            max-width: 600px;
        }

        /* ---- Outer wrapper (grey page background) ---- */
        #login-section {
            background-color: #f5f5f5;
            padding: 40px 25px;
            clear: both;
        }

        /* ---- Centred white login card ---- */
        .login-box {
            width: 400px;
            margin: 0 auto;
            background-color: #ffffff;
            border: 1px solid #cccccc;
            border-top: 4px solid #003366;
            padding: 30px 32px 24px;
        }

        .login-box h2 {
            color: #003366;
            font-size: 18px;
            margin: 0 0 20px 0;
            padding-bottom: 10px;
            border-bottom: 1px solid #dddddd;
        }

        /* ---- Individual field rows ---- */
        .field-row {
            margin-bottom: 16px;
        }

        .field-row label {
            display: block;
            font-weight: bold;
            font-size: 14px;
            margin-bottom: 5px;
            color: #333333;
        }

        /* ---- Text / password inputs ---- */
        .login-input {
            display: block;
            width: 100%;
            padding: 9px 10px;
            font-size: 14px;
            border: 1px solid #999999;
            background-color: #fafafa;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        .login-input:focus {
            outline: none;
            border-color: #003366;
            background-color: #ffffff;
        }

        /* ---- Inline validation error text ---- */
        .val-msg {
            display: block;
            color: #cc0000;
            font-size: 12px;
            font-weight: bold;
            margin-top: 4px;
        }

        /* ---- Login submit button ---- */
        .login-btn {
            display: block;
            width: 100%;
            padding: 11px;
            margin-top: 22px;
            background-color: #003366;
            color: #ffffff;
            border: none;
            font-size: 15px;
            font-weight: bold;
            cursor: pointer;
            font-family: Arial, sans-serif;
        }

        .login-btn:hover { background-color: #0055aa; }

        /* ---- Register prompt below the button ---- */
        .register-prompt {
            text-align: center;
            margin-top: 16px;
            font-size: 13px;
            color: #555555;
            border-top: 1px solid #eeeeee;
            padding-top: 14px;
        }

        .register-prompt a {
            color: #003366;
            font-weight: bold;
            text-decoration: none;
        }

        .register-prompt a:hover { text-decoration: underline; }

    </style>
</asp:Content>

<%-- MainContent: everything between the nav bar and the footer --%>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===== INTRO SECTION ===== --%>
    <section id="login-intro">
        <h1>Login to EduConnect</h1>
        <p>
            Enter your email address and password below to access your study materials and quizzes.
            New here? <a href="Register.aspx" style="color:#003366; font-weight:bold;">Create a free account.</a>
        </p>
    </section>

    <%-- ===== LOGIN CARD ===== --%>
    <section id="login-section">

        <div class="login-box">

            <h2>Member Login</h2>

            <%-- =====================================================
                 Error banner
                 Shown (Visible="true") by Login.aspx.cs when the
                 email/password combination does not match any record.
                 Hidden by default until a failed login attempt.
            ====================================================== --%>
            <asp:Label ID="lblError" runat="server"
                Visible="false"
                CssClass="msg-error"
                style="display:block; margin-bottom:18px;" />

            <%-- ---- Email Address field ---- --%>
            <div class="field-row">
                <label for="txtEmail">
                    Email Address: <span class="required">*</span>
                </label>
                <asp:TextBox ID="txtEmail" runat="server"
                    CssClass="login-input"
                    MaxLength="150"
                    placeholder="Enter your email address" />
                <asp:RequiredFieldValidator
                    ID="rfvEmail" runat="server"
                    ControlToValidate="txtEmail"
                    ErrorMessage="Email address is required."
                    CssClass="val-msg" Display="Dynamic" />
                <asp:RegularExpressionValidator
                    ID="revEmail" runat="server"
                    ControlToValidate="txtEmail"
                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                    ErrorMessage="Please enter a valid email address."
                    CssClass="val-msg" Display="Dynamic" />
            </div>

            <%-- ---- Password field ---- --%>
            <div class="field-row">
                <label for="txtPassword">
                    Password: <span class="required">*</span>
                </label>
                <asp:TextBox ID="txtPassword" runat="server"
                    TextMode="Password"
                    CssClass="login-input"
                    MaxLength="50"
                    placeholder="Enter your password" />
                <asp:RequiredFieldValidator
                    ID="rfvPassword" runat="server"
                    ControlToValidate="txtPassword"
                    ErrorMessage="Password is required."
                    CssClass="val-msg" Display="Dynamic" />
            </div>

            <%-- ---- Login button ---- --%>
            <asp:Button ID="btnLogin" runat="server"
                Text="Login"
                CssClass="login-btn"
                OnClick="btnLogin_Click" />

            <%-- ---- Register prompt ---- --%>
            <p class="register-prompt">
                Don't have an account?
                <a href="Register.aspx">Register here</a>
            </p>

        </div><%-- end .login-box --%>

    </section>

</asp:Content>
