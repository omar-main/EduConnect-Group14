<%@ Page Title="EduConnect - Study Materials" Language="C#" MasterPageFile="~/Site.Master"
         AutoEventWireup="true" CodeBehind="StudyMaterials.aspx.cs" Inherits="EduConnect.StudyMaterials" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* ---- Filter bar (topic buttons) ---- */
        .filter-bar {
            padding: 16px 25px 0 25px;
            background-color: #f5f5f5;
        }

        .filter-bar span {
            font-size: 13px;
            font-weight: bold;
            color: #333333;
            margin-right: 10px;
        }

        .filter-btn {
            display: inline-block;
            padding: 7px 18px;
            margin-right: 6px;
            font-size: 13px;
            font-weight: bold;
            text-decoration: none;
            border: 2px solid #003366;
            color: #003366;
            background-color: #ffffff;
            cursor: pointer;
            transition: background-color 0.15s, color 0.15s;
        }

        .filter-btn:hover,
        .filter-btn.active {
            background-color: #003366;
            color: #ffffff;
        }

        /* ---- Materials list section ---- */
        .materials-section {
            padding: 20px 25px 30px 25px;
            background-color: #f5f5f5;
            clear: both;
        }

        .materials-section h2 {
            color: #003366;
            font-size: 20px;
            margin: 0 0 6px 0;
            border-bottom: 2px solid #003366;
            padding-bottom: 8px;
        }

        .materials-section p.subtitle {
            font-size: 14px;
            color: #444444;
            margin-bottom: 20px;
        }

        /* ---- Material cards grid ---- */
        .material-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(290px, 1fr));
            gap: 20px;
            margin-top: 10px;
        }

        .material-card {
            background-color: #ffffff;
            border: 1px solid #cccccc;
            border-top: 4px solid #003366;
            padding: 20px;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
        }

        .material-card:hover {
            border-top-color: #0066cc;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
        }

        .material-card h3 {
            color: #003366;
            font-size: 15px;
            margin: 8px 0 10px 0;
        }

        .material-card p {
            font-size: 13px;
            color: #555555;
            line-height: 1.6;
            flex-grow: 1;
            margin-bottom: 14px;
        }

        /* ---- Detail view ---- */
        .detail-section {
            padding: 20px 25px 30px 25px;
            background-color: #f5f5f5;
            clear: both;
        }

        .detail-back-link {
            display: inline-block;
            margin-bottom: 16px;
            font-size: 13px;
            color: #004080;
            text-decoration: none;
            font-weight: bold;
        }

        .detail-back-link:hover { text-decoration: underline; }

        .detail-card {
            background-color: #ffffff;
            border: 1px solid #cccccc;
            border-top: 5px solid #003366;
            padding: 28px 30px;
        }

        .detail-card h2 {
            color: #003366;
            font-size: 20px;
            margin: 10px 0 6px 0;
        }

        .detail-meta {
            font-size: 12px;
            color: #888888;
            margin-bottom: 20px;
            border-bottom: 1px solid #eeeeee;
            padding-bottom: 14px;
        }

        .detail-content {
            font-size: 14px;
            color: #333333;
            line-height: 1.8;
            white-space: pre-wrap;
            font-family: Arial, sans-serif;
        }

        .detail-footer-btns {
            margin-top: 26px;
            padding-top: 16px;
            border-top: 1px solid #eeeeee;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .no-data-msg {
            font-size: 14px;
            color: #888888;
            padding: 30px 0;
            text-align: center;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===== INTRO SECTION ===== --%>
    <section id="intro">
        <h1>Study Materials</h1>
        <p>Browse articles on HTML and CSS fundamentals. Select a topic below to filter, then click any card to read the full material.</p>
    </section>

    <%-- ===== TOPIC FILTER BUTTONS ===== --%>
    <div class="filter-bar">
        <span>Filter by topic:</span>

        <a href="StudyMaterials.aspx"
           class='<%# "filter-btn " + FilterAllCss %>'
           id="btnAll" runat="server">All</a>

        <a href="StudyMaterials.aspx?topic=HTML"
           class='<%# "filter-btn " + FilterHtmlCss %>'
           id="btnHtml" runat="server">HTML</a>

        <a href="StudyMaterials.aspx?topic=CSS"
           class='<%# "filter-btn " + FilterCssCss %>'
           id="btnCss" runat="server">CSS</a>
    </div>

    <%-- ===================================================
         PANEL 1: MATERIALS LIST
    ==================================================== --%>
    <asp:Panel ID="pnlList" runat="server">
        <div class="materials-section">

            <h2>
                <asp:Literal ID="litListHeading" runat="server" Text="All Study Materials" />
            </h2>
            <p class="subtitle">Click "Read Material" on any card to open the full article.</p>

            <asp:Label ID="lblListError" runat="server" Visible="false"
                CssClass="msg-error" />

            <div class="material-grid">
                <asp:Repeater ID="rptMaterials" runat="server">
                    <ItemTemplate>
                        <div class="material-card">
                            <span class="quiz-topic-tag"><%# Eval("Topic") %></span>
                            <h3><%# Eval("Title") %></h3>
                            <p><%# Eval("Summary") %></p>
                            <a href='<%# "StudyMaterials.aspx?id=" + Eval("MaterialID") %>'
                               class="btn-quiz">Read Material</a>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <asp:Label ID="lblNoData" runat="server" Visible="false"
                CssClass="no-data-msg"
                Text="No study materials found for this topic. Check back soon!" />

        </div>
    </asp:Panel>

    <%-- ===================================================
         PANEL 2: MATERIAL DETAIL VIEW
    ==================================================== --%>
    <asp:Panel ID="pnlDetail" runat="server" Visible="false">
        <div class="detail-section">

            <asp:HyperLink ID="lnkBack" runat="server"
                Text="Back to Study Materials"
                CssClass="detail-back-link"
                NavigateUrl="StudyMaterials.aspx" />

            <div class="detail-card">

                <span class="quiz-topic-tag">
                    <asp:Literal ID="litDetailTopic" runat="server" />
                </span>

                <h2><asp:Literal ID="litDetailTitle" runat="server" /></h2>

                <p class="detail-meta">
                    Last updated: <asp:Literal ID="litDetailDate" runat="server" />
                </p>

                <div class="detail-content">
                    <asp:Literal ID="litDetailContent" runat="server" />
                </div>

                <div class="detail-footer-btns">
                    <a href="StudyMaterials.aspx" class="btn-action" style="text-decoration:none;">All Materials</a>
                    <a href="QuizList.aspx" class="btn-action" style="text-decoration:none;">Take a Quiz</a>
                </div>

            </div>

        </div>
    </asp:Panel>

</asp:Content>
