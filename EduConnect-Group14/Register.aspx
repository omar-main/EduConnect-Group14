<%@ Page Title="EduConnect - User Registration" Language="C#" MasterPageFile="~/Site.Master"
         AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="EduConnect.Register" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===== INTRO SECTION ===== --%>
    <section id="intro">
        <h1>Welcome to EduConnect</h1>
        <p>EduConnect is an online revision system specifically designed to help students learn and revise basic web development concepts, particularly HTML and CSS.</p>
    </section>

    <%-- ===== TWO COLUMN LAYOUT ===== --%>
    <div id="main-area">

        <article>
            <h2>About This Platform</h2>
            <p>EduConnect is a web-based platform that provides beginner students aged 16-25 with structured study materials and interactive quizzes to support their learning of HTML and CSS.</p>
            <p>Use the navigation bar above to explore the different sections of the site.</p>

            <h3>What You Can Learn Here</h3>
            <ul>
                <li>HTML5 Semantic Tags</li>
                <li>CSS Selectors and Styling</li>
                <li>Forms and Input Elements</li>
                <li>Basic Page Layout</li>
            </ul>
        </article>

        <aside>
            <h3>Quick Links</h3>
            <ul>
                <li><a href="StudyMaterials.aspx?topic=HTML">HTML Basics</a></li>
                <li><a href="StudyMaterials.aspx?topic=CSS">CSS Selectors</a></li>
                <li><a href="QuizList.aspx">Take a Quiz</a></li>
            </ul>

            <h3>Study Tip</h3>
            <p>Try to practice by writing code every day, even if it is just a small example.</p>
        </aside>

    </div>

    <%-- ===== REGISTRATION FORM SECTION ===== --%>
    <section id="register">
        <h2>User Registration</h2>
        <p>Create an account to access all study materials and quizzes.</p>

        <div class="form-box">

            <p class="field-note">
                Fields marked <span class="required">*</span> are required.
            </p>

            <%-- Full Name --%>
            <label for="txtFullName">Full Name: <span class="required">*</span></label>
            <asp:TextBox
                ID="txtFullName"
                runat="server"
                CssClass="register-input"
                placeholder="Enter your full name"
                MaxLength="100" />
            <asp:RequiredFieldValidator
                ID="rfvFullName"
                runat="server"
                ControlToValidate="txtFullName"
                ErrorMessage="Full Name is required."
                CssClass="val-msg"
                Display="Dynamic" />

            <%-- Email Address --%>
            <label for="txtEmail">Email Address: <span class="required">*</span></label>
            <asp:TextBox
                ID="txtEmail"
                runat="server"
                CssClass="register-input"
                placeholder="Enter your email address"
                MaxLength="150" />
            <asp:RequiredFieldValidator
                ID="rfvEmail"
                runat="server"
                ControlToValidate="txtEmail"
                ErrorMessage="Email Address is required."
                CssClass="val-msg"
                Display="Dynamic" />
            <asp:RegularExpressionValidator
                ID="revEmail"
                runat="server"
                ControlToValidate="txtEmail"
                ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                ErrorMessage="Please enter a valid email address."
                CssClass="val-msg"
                Display="Dynamic" />

            <%-- Password --%>
            <label for="txtPassword">Password: <span class="required">*</span></label>
            <asp:TextBox
                ID="txtPassword"
                runat="server"
                TextMode="Password"
                CssClass="register-input"
                placeholder="Enter a password"
                MaxLength="50" />
            <asp:RequiredFieldValidator
                ID="rfvPassword"
                runat="server"
                ControlToValidate="txtPassword"
                ErrorMessage="Password is required."
                CssClass="val-msg"
                Display="Dynamic" />

            <%-- Confirm Password --%>
            <label for="txtConfirmPassword">Confirm Password: <span class="required">*</span></label>
            <asp:TextBox
                ID="txtConfirmPassword"
                runat="server"
                TextMode="Password"
                CssClass="register-input"
                placeholder="Re-enter your password"
                MaxLength="50" />
            <asp:RequiredFieldValidator
                ID="rfvConfirmPassword"
                runat="server"
                ControlToValidate="txtConfirmPassword"
                ErrorMessage="Please confirm your password."
                CssClass="val-msg"
                Display="Dynamic" />

            <%-- CompareValidator: password must match confirm password --%>
            <asp:CompareValidator
                ID="cvPasswordMatch"
                runat="server"
                ControlToValidate="txtConfirmPassword"
                ControlToCompare="txtPassword"
                ErrorMessage="Passwords do not match."
                CssClass="val-msg"
                Display="Dynamic" />

            <%-- Register + Clear buttons side by side --%>
            <div class="register-btn-row">
                <asp:Button
                    ID="btnRegister"
                    runat="server"
                    Text="Register"
                    CssClass="btn-register"
                    OnClick="btnRegister_Click" />

                <input type="reset" value="Clear" class="btn-clear" />
            </div>

            <%-- Success or error message --%>
            <asp:Label
                ID="lblMessage"
                runat="server"
                Text=""
                CssClass="register-msg" />

            <p class="login-prompt">
                Already have an account?
                <a href="Login.aspx">Login here</a>
            </p>

        </div><%-- end .form-box --%>

    </section>

</asp:Content>
