-- ============================================================
-- EduConnect - Quiz System Database Setup Script
-- CT050-3-2-WAPP Group Assignment
-- Run this in SQL Server Management Studio OR Visual Studio
-- Server Explorer against your EduConnect.mdf database
-- ============================================================

-- -------------------------------------------------------
-- TABLE: Quiz
-- Stores each quiz (topic-based)
-- -------------------------------------------------------
CREATE TABLE Quiz (
    QuizID          INT           PRIMARY KEY IDENTITY(1,1),
    Title           NVARCHAR(200) NOT NULL,
    Topic           NVARCHAR(100) NOT NULL,
    Description     NVARCHAR(500) NULL,
    TotalQuestions  INT           NOT NULL DEFAULT 0,
    CreatedDate     DATETIME      NOT NULL DEFAULT GETDATE()
);

-- -------------------------------------------------------
-- TABLE: QuizQuestion
-- Stores MCQ questions linked to a Quiz
-- -------------------------------------------------------
CREATE TABLE QuizQuestion (
    QuestionID      INT           PRIMARY KEY IDENTITY(1,1),
    QuizID          INT           NOT NULL,
    QuestionText    NVARCHAR(500) NOT NULL,
    OptionA         NVARCHAR(200) NOT NULL,
    OptionB         NVARCHAR(200) NOT NULL,
    OptionC         NVARCHAR(200) NOT NULL,
    OptionD         NVARCHAR(200) NOT NULL,
    CorrectAnswer   CHAR(1)       NOT NULL CHECK (CorrectAnswer IN ('A','B','C','D')),
    CONSTRAINT FK_Question_Quiz FOREIGN KEY (QuizID)
        REFERENCES Quiz(QuizID) ON DELETE CASCADE
);

-- -------------------------------------------------------
-- TABLE: QuizAttempt
-- Records each time a user attempts a quiz
-- -------------------------------------------------------
CREATE TABLE QuizAttempt (
    AttemptID       INT             PRIMARY KEY IDENTITY(1,1),
    UserID          INT             NOT NULL,
    QuizID          INT             NOT NULL,
    Score           INT             NOT NULL,
    TotalQuestions  INT             NOT NULL,
    Percentage      DECIMAL(5,2)    NOT NULL,
    AttemptDate     DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Attempt_Quiz FOREIGN KEY (QuizID)
        REFERENCES Quiz(QuizID)
);

-- -------------------------------------------------------
-- TABLE: QuizAnswer
-- Stores each individual answer within an attempt
-- -------------------------------------------------------
CREATE TABLE QuizAnswer (
    AnswerID        INT    PRIMARY KEY IDENTITY(1,1),
    AttemptID       INT    NOT NULL,
    QuestionID      INT    NOT NULL,
    SelectedAnswer  CHAR(1) NULL,   -- NULL if question was skipped
    IsCorrect       BIT    NOT NULL DEFAULT 0,
    CONSTRAINT FK_Answer_Attempt FOREIGN KEY (AttemptID)
        REFERENCES QuizAttempt(AttemptID) ON DELETE CASCADE,
    CONSTRAINT FK_Answer_Question FOREIGN KEY (QuestionID)
        REFERENCES QuizQuestion(QuestionID)
);

-- ============================================================
-- SAMPLE DATA - Quizzes
-- ============================================================
INSERT INTO Quiz (Title, Topic, Description) VALUES
('HTML Fundamentals',   'HTML', 'Test your knowledge on basic HTML elements, tags, and document structure.'),
('CSS Styling Basics',  'CSS',  'Test your knowledge on CSS selectors, properties, and styling techniques.'),
('HTML Forms & Inputs', 'HTML', 'Test your understanding of HTML form elements, input types, and attributes.');

-- ============================================================
-- SAMPLE DATA - Quiz 1: HTML Fundamentals (5 Questions)
-- ============================================================
INSERT INTO QuizQuestion (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer) VALUES
(1, 'What does HTML stand for?',
 'Hyper Text Markup Language',
 'High Tech Modern Language',
 'Hyper Transfer Markup Language',
 'Home Tool Markup Language', 'A'),

(1, 'Which HTML tag is used for the largest heading?',
 '<h6>', '<heading>', '<h1>', '<head>', 'C'),

(1, 'Which HTML tag is used to create a hyperlink?',
 '<link>', '<a>', '<href>', '<url>', 'B'),

(1, 'What is the correct HTML element for inserting a line break?',
 '<break>', '<lb>', '<br>', '<newline>', 'C'),

(1, 'Which HTML attribute specifies an alternate text for an image, if the image cannot be displayed?',
 'src', 'title', 'href', 'alt', 'D');

UPDATE Quiz SET TotalQuestions = 5 WHERE QuizID = 1;

-- ============================================================
-- SAMPLE DATA - Quiz 2: CSS Styling Basics (5 Questions)
-- ============================================================
INSERT INTO QuizQuestion (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer) VALUES
(2, 'What does CSS stand for?',
 'Computer Style Sheets',
 'Cascading Style Sheets',
 'Creative Style System',
 'Colorful Styling Syntax', 'B'),

(2, 'Which CSS property is used to change the text color of an element?',
 'font-color', 'text-color', 'color', 'text-style', 'C'),

(2, 'Which CSS property controls the size of text?',
 'font-style', 'text-size', 'font-size', 'text-height', 'C'),

(2, 'How do you select an element with the id "header" in CSS?',
 '.header', '#header', '*header', 'header', 'B'),

(2, 'Which CSS property is used to set the background color of an element?',
 'color', 'bgcolor', 'background-color', 'bg-color', 'C');

UPDATE Quiz SET TotalQuestions = 5 WHERE QuizID = 2;

-- ============================================================
-- SAMPLE DATA - Quiz 3: HTML Forms & Inputs (5 Questions)
-- ============================================================
INSERT INTO QuizQuestion (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer) VALUES
(3, 'Which HTML element is used to create an input form?',
 '<input>', '<form>', '<field>', '<data>', 'B'),

(3, 'Which input type creates a password field that hides characters?',
 'type="text"', 'type="hidden"', 'type="password"', 'type="secure"', 'C'),

(3, 'Which attribute specifies where to send the form data when a form is submitted?',
 'method', 'action', 'submit', 'href', 'B'),

(3, 'Which input type creates a checkbox?',
 'type="check"', 'type="tick"', 'type="select"', 'type="checkbox"', 'D'),

(3, 'What is the default HTTP method for HTML form submission?',
 'POST', 'GET', 'PUT', 'SEND', 'B');

UPDATE Quiz SET TotalQuestions = 5 WHERE QuizID = 3;
