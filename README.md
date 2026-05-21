# EduConnect — Web-Based Learning System

A web-based learning system built with ASP.NET WebForms (.NET Framework 4.8) and SQL Server LocalDB, developed as a group assignment for **CT050-3-2 Web Applications (WAPP)**.

The platform allows students to browse HTML and CSS study materials, take multiple-choice quizzes, and track their results. Administrators can manage study materials and quiz questions through a dedicated dashboard.

---

## Features

- **User Authentication** — Registration, login, and logout with SHA-256 password hashing
- **Role-Based Access** — Student and Admin roles with separate navigation and page guards
- **Study Materials** — Browse and filter HTML/CSS articles by topic; admins can add, edit, and delete
- **Quiz System** — Multiple-choice quizzes with a countdown timer, live progress bar, and per-question review on results
- **Admin Dashboard** — Full CRUD management for both study materials and quiz questions
- **Form Validation** — ASP.NET validators (Required, Compare, Range, RegularExpression, Custom) with client-side and server-side enforcement

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | ASP.NET WebForms (.NET Framework 4.8) |
| Language | C# |
| Database | SQL Server (LocalDB / SQL Server Express) |
| Data Access | ADO.NET (SqlConnection, SqlCommand, SqlDataReader) |
| Frontend | HTML5, CSS3, JavaScript |
| IDE | Visual Studio 2022 |

---

## Getting Started

### Prerequisites

- [Visual Studio 2022](https://visualstudio.microsoft.com/) with the **ASP.NET and web development** workload
- SQL Server LocalDB (included with Visual Studio) **or** SQL Server Express

### 1. Clone the repository

```bash
git clone https://github.com/omar-main/EduConnect-Group14.git
```

### 2. Set up the database

Open **SQL Server Management Studio** or Visual Studio's **Server Explorer** and run the three setup scripts in this order:

```
EduConnect-Group14/UserDB_Setup.sql
EduConnect-Group14/StudyMaterialsDB_Setup.sql
EduConnect-Group14/QuizDB_Setup.sql
```

### 3. Open and run the project

1. Double-click `EduConnect-Group14.sln` to open in Visual Studio
2. Press **Ctrl+F5** to build and launch in your browser

---

## Default Accounts

| Role | Email | Password |
|---|---|---|
| Admin | admin@educonnect.com | admin123 |
| Student | student@educonnect.com | student123 |

> Passwords are stored as SHA-256 hashes in the database.

---

## Project Structure

```
EduConnect-Group14/
├── Site.Master              # Shared layout (header, nav, footer)
├── index.aspx               # Home page with tutorial videos
├── Login.aspx               # Member login
├── Register.aspx            # New user registration
├── StudyMaterials.aspx      # Browse and read study articles
├── QuizList.aspx            # Quiz catalogue
├── QuizAttempt.aspx         # Take a quiz (timer + progress bar)
├── QuizResult.aspx          # Score and per-question review
├── Admin.aspx               # Admin: manage study materials
├── ManageQuiz.aspx          # Admin: manage quiz questions
├── Logout.aspx              # Session clear and redirect
├── style.css                # Global stylesheet
├── quiz.css                 # Quiz module stylesheet
├── UserDB_Setup.sql         # Users table + seed data
├── StudyMaterialsDB_Setup.sql
└── QuizDB_Setup.sql
```
