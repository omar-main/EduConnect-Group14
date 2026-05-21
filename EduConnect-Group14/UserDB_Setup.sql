-- ============================================================
-- EduConnect - User Authentication Database Setup Script
-- CT050-3-2-WAPP Group Assignment
-- Member 2: Authentication & User System
--
-- Run this script FIRST, before StudyMaterialsDB_Setup.sql
-- and QuizDB_Setup.sql, because those tables reference Users.
--
-- Run in SQL Server Management Studio OR Visual Studio
-- Server Explorer against your EduConnect.mdf database.
-- ============================================================

-- -------------------------------------------------------
-- TABLE: Users
-- Stores every registered account.
--
-- Columns:
--   UserID   — auto-generated primary key
--   FullName — the user's display name (used in the nav greeting)
--   Email    — login username; must be unique across all accounts
--   Password — SHA-256 hash (lowercase hex, UTF-8 bytes) of the password
--   Role     — 'Student' (default) or 'Admin'
-- -------------------------------------------------------
CREATE TABLE Users (
    UserID   INT           PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    Email    NVARCHAR(150) NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    Role     NVARCHAR(50)  NOT NULL DEFAULT 'Student',
    CONSTRAINT UQ_Users_Email UNIQUE (Email)
);

-- -------------------------------------------------------
-- SAMPLE DATA
-- Two test accounts. Passwords are SHA-256 hashed.
--
-- Admin account  : admin@educonnect.com   / admin123
-- Student account: student@educonnect.com / student123
--
-- The hash is computed with T-SQL HASHBYTES('SHA2_256', ...)
-- over the ASCII/UTF-8 byte sequence, matching what
-- C#'s Encoding.UTF8.GetBytes() + SHA256.ComputeHash() produces.
--
-- To promote any registered user to Admin, run:
--   UPDATE Users SET Role = 'Admin' WHERE Email = 'their@email.com';
-- -------------------------------------------------------
INSERT INTO Users (FullName, Email, Password, Role) VALUES
(
    'Administrator',
    'admin@educonnect.com',
    LOWER(CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST('admin123' AS VARBINARY(MAX))), 2)),
    'Admin'
),
(
    'Student User',
    'student@educonnect.com',
    LOWER(CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST('student123' AS VARBINARY(MAX))), 2)),
    'Student'
);
