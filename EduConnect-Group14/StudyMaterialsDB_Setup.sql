-- ============================================================
-- EduConnect - Study Materials Database Setup Script
-- CT050-3-2-WAPP Group Assignment
-- Member 3: Database Admin & Study Materials
--
-- Run this in SQL Server Management Studio OR Visual Studio
-- Server Explorer against your EduConnect.mdf database.
-- Run AFTER the Users table has already been created
-- (by Member 1's login/register script).
-- ============================================================

-- -------------------------------------------------------
-- ROLE COLUMN (for Admin access to Admin.aspx)
-- The Users table is created by Member 1.
-- If the Role column does not yet exist, run the line below:
--   ALTER TABLE Users ADD Role NVARCHAR(50) NOT NULL DEFAULT 'Student';
--
-- To make a user an Admin, run:
--   UPDATE Users SET Role = 'Admin' WHERE Email = 'your@email.com';
-- -------------------------------------------------------

-- -------------------------------------------------------
-- TABLE: StudyMaterial
-- Stores each study article shown on StudyMaterials.aspx
-- -------------------------------------------------------
CREATE TABLE StudyMaterial (
    MaterialID   INT            PRIMARY KEY IDENTITY(1,1),
    Title        NVARCHAR(200)  NOT NULL,
    Topic        NVARCHAR(100)  NOT NULL,       -- 'HTML' or 'CSS'
    Summary      NVARCHAR(500)  NULL,           -- Short blurb shown on card
    ContentText  NVARCHAR(MAX)  NOT NULL,       -- Full article body
    SortOrder    INT            NOT NULL DEFAULT 0,  -- Controls display order
    CreatedDate  DATETIME       NOT NULL DEFAULT GETDATE(),
    UpdatedDate  DATETIME       NULL            -- Set on UPDATE via Admin.aspx
);

-- ============================================================
-- SAMPLE DATA — HTML Materials (4 articles)
-- ============================================================
INSERT INTO StudyMaterial (Title, Topic, Summary, ContentText, SortOrder) VALUES
(
    'Introduction to HTML',
    'HTML',
    'Learn what HTML is, how it works, and the structure of a basic web page.',
    'WHAT IS HTML?
HTML (HyperText Markup Language) is the standard language used to build web pages. It uses tags to define elements that a browser renders as visible content.

BASIC DOCUMENT STRUCTURE
Every HTML document follows this skeleton:

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Page</title>
</head>
<body>
    <h1>Hello, World!</h1>
    <p>This is a paragraph.</p>
</body>
</html>

KEY POINTS
- Tags are written in angle brackets: <tagname>
- Most tags come in pairs: opening <p> and closing </p>
- The DOCTYPE declaration tells the browser which version of HTML is used
- The <head> holds metadata (invisible to users)
- The <body> holds everything the user sees on screen

HEADINGS
HTML provides six levels of headings, from <h1> (most important) to <h6> (least important).
Use <h1> for the main page title, and lower levels for sub-sections.',
    1
),
(
    'HTML5 Semantic Tags',
    'HTML',
    'Discover semantic elements that give clear meaning to your page structure and improve accessibility.',
    'WHAT ARE SEMANTIC TAGS?
Semantic HTML tags describe their purpose clearly, both to the browser and to developers. Instead of using <div> for everything, HTML5 introduced tags with built-in meaning.

COMMON SEMANTIC TAGS
<header>  — The header section of a page or article
<nav>     — A block of navigation links
<main>    — The main content area of the page
<article> — A self-contained piece of content (e.g. a blog post)
<section> — A thematic grouping of related content
<aside>   — Side content, such as a sidebar or related links
<footer>  — The footer of a page or section

EXAMPLE STRUCTURE
<body>
    <header>
        <h1>EduConnect</h1>
        <nav>
            <ul>
                <li><a href="index.html">Home</a></li>
                <li><a href="StudyMaterials.aspx">Study Materials</a></li>
            </ul>
        </nav>
    </header>

    <main>
        <article>
            <h2>HTML Basics</h2>
            <p>HTML is the foundation of every web page...</p>
        </article>

        <aside>
            <h3>Quick Links</h3>
        </aside>
    </main>

    <footer>
        <p>&copy; 2026 EduConnect. All rights reserved.</p>
    </footer>
</body>

WHY USE SEMANTIC TAGS?
1. Accessibility — Screen readers use them to help visually impaired users.
2. SEO — Search engines rank pages better when they understand the structure.
3. Readability — Other developers can understand your code more easily.',
    2
),
(
    'HTML Forms and Input Elements',
    'HTML',
    'Understand how to build interactive forms using the form element, input types, labels, and validation.',
    'THE <form> ELEMENT
The <form> element wraps all form controls. Its two key attributes are:
- action — The URL where form data is sent on submit
- method — "GET" (data visible in URL) or "POST" (data in request body)

COMMON INPUT TYPES
<input type="text">      — Single-line text field
<input type="password">  — Password field (characters hidden)
<input type="email">     — Email address with basic format check
<input type="checkbox">  — A tick-box option
<input type="radio">     — Radio button (select one from a group)
<input type="submit">    — Button that submits the form
<textarea>               — Multi-line text area
<select>                 — Drop-down selection list

THE <label> ELEMENT
Labels link visible text to a form control. The for attribute must match the input id.

EXAMPLE REGISTRATION FORM
<form action="Register.aspx" method="post">

    <label for="name">Full Name:</label>
    <input type="text" id="name" name="name" placeholder="Your name">

    <label for="email">Email Address:</label>
    <input type="email" id="email" name="email" placeholder="you@example.com">

    <label for="pass">Password:</label>
    <input type="password" id="pass" name="pass">

    <input type="submit" value="Register">

</form>

BEST PRACTICES
- Always use <label> for accessibility
- Use the correct input type (e.g. type="email" gives mobile keyboards an @ key)
- Use the required attribute for mandatory fields: <input type="text" required>',
    3
),
(
    'HTML Lists and Tables',
    'HTML',
    'Learn how to organise information using ordered lists, unordered lists, and HTML data tables.',
    'UNORDERED LISTS (<ul>)
Use when the order of items does not matter. Each item uses <li>.

<ul>
    <li>HTML</li>
    <li>CSS</li>
    <li>JavaScript</li>
</ul>
Renders as a bulleted list.

ORDERED LISTS (<ol>)
Use when sequence matters. Items are numbered automatically.

<ol>
    <li>Open your code editor</li>
    <li>Create a new file named index.html</li>
    <li>Write your HTML structure</li>
    <li>Open it in a browser</li>
</ol>

HTML TABLES (<table>)
Tables display data in rows and columns.

KEY TABLE ELEMENTS
<table>  — The table container
<thead>  — Groups the header rows
<tbody>  — Groups the body rows
<tr>     — A table row
<th>     — A header cell (bold and centred by default)
<td>     — A data cell

EXAMPLE TABLE
<table border="1">
    <thead>
        <tr>
            <th>Student</th>
            <th>Score</th>
            <th>Grade</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Alice</td>
            <td>92%</td>
            <td>A</td>
        </tr>
        <tr>
            <td>Bob</td>
            <td>74%</td>
            <td>C</td>
        </tr>
    </tbody>
</table>

TIP: Use CSS to style tables rather than the old border attribute.',
    4
);

-- ============================================================
-- SAMPLE DATA — CSS Materials (4 articles)
-- ============================================================
INSERT INTO StudyMaterial (Title, Topic, Summary, ContentText, SortOrder) VALUES
(
    'Introduction to CSS',
    'CSS',
    'Learn what CSS is, how it is applied to HTML, and the three ways to add styles to a web page.',
    'WHAT IS CSS?
CSS (Cascading Style Sheets) controls the visual presentation of HTML elements — colours, fonts, spacing, and layout. Without CSS, all web pages would look like plain text documents.

HOW A CSS RULE WORKS
selector {
    property: value;
}

Example:
p {
    color: #333333;
    font-size: 14px;
}

This targets every <p> element and sets its text colour and size.

THREE WAYS TO ADD CSS

1. INLINE CSS — applied directly to a single element via the style attribute:
   <p style="color: red; font-weight: bold;">Warning text</p>
   Use sparingly — hard to maintain.

2. INTERNAL CSS — written inside a <style> block in the <head> section:
   <style>
       h1 { color: #003366; }
       p  { font-size: 14px; }
   </style>
   Useful for single-page styles.

3. EXTERNAL CSS (best practice) — a separate .css file linked with <link>:
   <link rel="stylesheet" href="style.css">
   One file can style the entire site; changes apply everywhere instantly.

COMMON CSS PROPERTIES
color              — Text colour
background-color   — Background colour
font-size          — Text size (e.g. 14px, 1em)
font-family        — Typeface (e.g. Arial, sans-serif)
margin             — Space outside the element
padding            — Space inside the element
border             — Line drawn around the element
width / height     — Element dimensions',
    1
),
(
    'CSS Selectors',
    'CSS',
    'Master CSS selectors — element, class, ID, grouping, descendant, and pseudo-class — to target HTML with precision.',
    'WHAT IS A CSS SELECTOR?
A selector tells the browser which HTML element(s) to style.

ELEMENT SELECTOR
Targets every element of that type.
p { color: #333333; }

CLASS SELECTOR (.)
Targets all elements sharing a class. Add class="name" to your HTML.
.highlight { background-color: #fffacd; }
<p class="highlight">This text is highlighted.</p>

ID SELECTOR (#)
Targets one unique element. Add id="name" to your HTML.
#main-header { background-color: #003366; color: #ffffff; }
<header id="main-header">...</header>

GROUPING SELECTOR
Apply the same style to multiple selectors separated by commas.
h1, h2, h3 { color: #003366; font-family: Arial, sans-serif; }

DESCENDANT SELECTOR
Targets elements nested inside another element.
nav ul li { display: inline-block; }
This selects <li> elements that are inside a <ul> inside a <nav>.

HOVER PSEUDO-CLASS (:hover)
Applies a style when the user moves the mouse over an element.
a:hover { color: #0055aa; text-decoration: underline; }

SPECIFICITY — WHO WINS?
When multiple rules target the same element, CSS uses specificity to decide:
1. Inline styles        — highest priority
2. ID selectors (#)
3. Class selectors (.)
4. Element selectors    — lowest priority

PRACTICAL EXAMPLE
CSS:
nav ul li a { color: #ffffff; text-decoration: none; }
nav ul li a:hover { background-color: #0066cc; }

HTML:
<nav><ul><li><a href="index.html">Home</a></li></ul></nav>',
    2
),
(
    'CSS Box Model',
    'CSS',
    'Understand the four-layer CSS box model — content, padding, border, margin — that controls every element on the page.',
    'THE CSS BOX MODEL
Every HTML element is treated as a rectangular box in CSS. The box has four layers, from inside to outside:

1. CONTENT  — The actual text or image inside the element
2. PADDING  — Clear space between the content and the border
3. BORDER   — A line drawn around the padding
4. MARGIN   — Clear space outside the border, separating elements

VISUALISING THE BOX
+-------------------------------+
|           MARGIN              |
|   +-----------------------+   |
|   |        BORDER         |   |
|   |   +---------------+   |   |
|   |   |    PADDING    |   |   |
|   |   |  +---------+  |   |   |
|   |   |  | CONTENT |  |   |   |
|   |   |  +---------+  |   |   |
|   |   +---------------+   |   |
|   +-----------------------+   |
+-------------------------------+

CSS EXAMPLE
div {
    margin: 20px;                  /* Space outside */
    border: 2px solid #003366;     /* Border line */
    padding: 15px;                 /* Space inside */
    width: 300px;                  /* Content width */
    background-color: #ffffff;
}

BOX-SIZING: BORDER-BOX (Recommended)
By default, width only sets the content area, so padding and border add to the total size.
Use box-sizing: border-box so the width includes padding and border — much easier to predict.

* {
    box-sizing: border-box;
}

SHORTHAND NOTATION
Margin and padding accept 1–4 values:
margin: 10px;              /* all four sides = 10px */
margin: 10px 20px;         /* top/bottom=10px, left/right=20px */
margin: 10px 20px 15px;    /* top=10, left/right=20, bottom=15 */
margin: 5px 10px 15px 20px; /* top right bottom left (clockwise) */',
    3
),
(
    'CSS Layout Basics',
    'CSS',
    'Learn how to control page layout using the display property, float, clear, and element positioning.',
    'THE display PROPERTY
Controls how an element participates in the page layout.

display: block      — Full width, starts on a new line (default for <div>, <p>, <h1>)
display: inline     — Sits in the text flow, no width/height (default for <span>, <a>)
display: inline-block — Like inline but respects width and height settings
display: none       — Hides the element completely (takes no space)

FLOAT LAYOUT
float moves an element to the left or right, letting content wrap around it.
This technique powers the two-column layout used on this site.

article {
    width: 65%;
    float: left;
}

aside {
    width: 30%;
    float: right;
}

The clear Property
Prevents the next element from wrapping around floated elements.
footer {
    clear: both;   /* Pushes footer below both floated columns */
}

CENTERING AN ELEMENT
To horizontally centre a block element, give it a fixed width and auto margins:
.container {
    width: 800px;
    margin: 0 auto;   /* 0 top/bottom, auto left/right */
}

CSS POSITIONING
position: static    — Default. Element follows normal document flow.
position: relative  — Offset from its normal position using top/left/right/bottom.
position: absolute  — Removed from document flow, positioned relative to nearest
                      positioned ancestor element.
position: fixed     — Stays in the same place even when the user scrolls.

EXAMPLE — STICKY HEADER
header {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    background-color: #003366;
    z-index: 100;   /* Ensures header appears above other content */
}',
    4
);
