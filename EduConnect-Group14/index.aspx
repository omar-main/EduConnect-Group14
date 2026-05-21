<%@ Page Title="EduConnect - Home" Language="C#" MasterPageFile="~/Site.Master"
         AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="EduConnect.Index" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* ---- CTA banner at the bottom of the home page ---- */
        #cta-section {
            background-color: #003366;
            color: #ffffff;
            text-align: center;
            padding: 38px 25px;
            clear: both;
        }

        #cta-section h2 {
            color: #ffffff;
            font-size: 20px;
            margin: 0 0 8px 0;
        }

        #cta-section p {
            font-size: 14px;
            color: #cce0ff;
            margin-bottom: 20px;
        }

        .cta-btn {
            display: inline-block;
            padding: 11px 32px;
            background-color: #ffffff;
            color: #003366;
            font-size: 15px;
            font-weight: bold;
            text-decoration: none;
            margin: 0 6px;
        }

        .cta-btn:hover {
            background-color: #cce0ff;
        }

        .cta-btn.secondary {
            background-color: transparent;
            color: #ffffff;
            border: 2px solid #ffffff;
        }

        .cta-btn.secondary:hover {
            background-color: rgba(255,255,255,0.15);
        }

        /* ---- Featured Videos section ---- */
        #video-section {
            padding: 30px 25px;
            background-color: #ffffff;
            border-top: 2px solid #003366;
            clear: both;
        }

        #video-section h2 {
            color: #003366;
            font-size: 20px;
            margin: 0 0 8px 0;
        }

        #video-section > p {
            font-size: 14px;
            color: #444444;
            margin-bottom: 20px;
        }

        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 24px;
        }

        .video-card {
            background-color: #f9f9f9;
            border: 1px solid #cccccc;
            border-top: 4px solid #004080;
            padding: 16px;
        }

        .video-card h3 {
            color: #003366;
            font-size: 15px;
            margin: 0 0 10px 0;
        }

        .video-card p {
            font-size: 13px;
            color: #555555;
            margin-top: 10px;
        }

        .video-wrapper {
            position: relative;
            overflow: hidden;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===== INTRO ===== --%>
    <section id="intro">
        <h1>Welcome to EduConnect</h1>
        <p>EduConnect is an online revision system specifically designed to help students learn and revise basic web development concepts, particularly HTML and CSS.</p>
    </section>

    <%-- ===== TWO-COLUMN LAYOUT ===== --%>
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

    <%-- ===== MULTIMEDIA: Featured Tutorial Videos ===== --%>
    <section id="video-section">
        <h2>Featured Tutorial Videos</h2>
        <p>Watch these short video introductions to HTML and CSS before diving into the study materials.</p>

        <div class="video-grid">

            <div class="video-card">
                <h3>HTML Crash Course for Beginners</h3>
                <div class="video-wrapper">
                    <iframe
                        width="100%"
                        height="215"
                        src="https://www.youtube.com/embed/qz0aGYrrlhU"
                        title="HTML Crash Course for Beginners"
                        frameborder="0"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        allowfullscreen>
                    </iframe>
                </div>
                <p>A quick introduction to HTML5 structure, tags, and semantic elements.</p>
            </div>

            <div class="video-card">
                <h3>CSS Tutorial - Zero to Hero</h3>
                <div class="video-wrapper">
                    <iframe
                        width="100%"
                        height="215"
                        src="https://www.youtube.com/embed/1Rs2ND1ryYc"
                        title="CSS Tutorial for Beginners"
                        frameborder="0"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        allowfullscreen>
                    </iframe>
                </div>
                <p>Learn how to style web pages with CSS selectors, colours, and layouts.</p>
            </div>

        </div>
    </section>

    <%-- ===== CALL TO ACTION =====
         Shown to guests; logged-in users see the nav buttons instead.
    --%>
    <asp:Panel ID="pnlGuestCTA" runat="server">
        <section id="cta-section">
            <h2>Ready to Start Learning?</h2>
            <p>Create a free account to access all study materials and interactive quizzes.</p>
            <a href="Register.aspx" class="cta-btn">Register Free</a>
            <a href="Login.aspx" class="cta-btn secondary">Login</a>
        </section>
    </asp:Panel>

</asp:Content>
