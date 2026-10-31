CREATE DATABASE CourseHubDB;
GO

USE CourseHubDB;
GO

-- STAGE 1
CREATE TABLE TempInstructors (
    TempID INT,
    TempName VARCHAR(50),
    JoinedDate DATE
);

-- STAGE 2
-- TASK 2.1
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL UNIQUE
);

-- TASK 2.2
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    GPA DECIMAL(3,2),
    DepartmentID INT,
    FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
);

-- TASK 2.3
CREATE TABLE StudentProfiles (
    ProfileID INT PRIMARY KEY,
    StudentID INT UNIQUE,
    Address VARCHAR(200),
    EmergencyPhone VARCHAR(20),
    FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
);

-- TASK 2.4
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    Credits INT,
    DepartmentID INT,
    FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
);

-- TASK 2.5
CREATE TABLE StudentCourses (
    StudentID INT,
    CourseID INT,
    EnrollmentDate DATE DEFAULT GETDATE(),
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID)
        REFERENCES Courses(CourseID)
);

-- TASK 2.6
ALTER TABLE Students
ADD Age INT;

DROP TABLE TempInstructors;

-- STAGE 3
-- TASK 3.1
INSERT INTO Departments VALUES
(1, 'Computer Science'),
(2, 'Software Engineering'),
(3, 'Business Administration');

-- TASK 3.2
INSERT INTO Students
(StudentID, FullName, Email, GPA, DepartmentID, Age)
VALUES
(101, 'Ali Smadi', 'ali@coursehub.com', 3.80, 1, 22),
(102, 'Omar Ahmad', 'omar@coursehub.com', 2.90, 1, 21),
(103, 'Laila Hassan', 'laila@coursehub.com', 3.50, 2, 23),
(104, 'Tariq Zaid', 'tariq@coursehub.com', 2.10, 3, 20);

-- TASK 3.3
INSERT INTO StudentProfiles VALUES
(1, 101, 'Amman, Jordan', '0791111111'),
(2, 102, 'Irbid, Jordan', '0792222222'),
(3, 103, 'Zarqa, Jordan', '0793333333');

-- TASK 3.4
INSERT INTO Courses VALUES
(201, 'Database Systems', 3, 1),
(202, 'Web Development', 3, 1),
(203, 'Software Architecture', 3, 2);

-- TASK 3.5
INSERT INTO StudentCourses (StudentID, CourseID)
VALUES
(101, 201),
(101, 202),
(102, 201),
(103, 203);

-- TASK 3.6
UPDATE Students
SET GPA = 2.50
WHERE StudentID = 104;

DELETE FROM Students
WHERE StudentID = 104;

-- STAGE 4
-- TASK 4.1 INNER JOIN
SELECT S.FullName, S.GPA, D.DepartmentName
FROM Students S
INNER JOIN Departments D
ON S.DepartmentID = D.DepartmentID;

-- TASK 4.2 LEFT JOIN
SELECT D.DepartmentName, S.FullName
FROM Departments D
LEFT JOIN Students S
ON D.DepartmentID = S.DepartmentID;

-- TASK 4.3 INNER JOIN 1:1
SELECT S.FullName, P.Address, P.EmergencyPhone
FROM Students S
INNER JOIN StudentProfiles P
ON S.StudentID = P.StudentID;

-- TASK 4.4 M:N JOIN
SELECT S.FullName, C.CourseName, SC.EnrollmentDate
FROM Students S
INNER JOIN StudentCourses SC
ON S.StudentID = SC.StudentID
INNER JOIN Courses C
ON SC.CourseID = C.CourseID;

-- STAGE 5
-- TASK 5.1
SELECT
    COUNT(*) AS TotalStudents,
    AVG(GPA) AS AverageGPA,
    MAX(GPA) AS HighestGPA,
    MIN(GPA) AS LowestGPA
FROM Students;

-- TASK 5.2
SELECT DepartmentID,
       AVG(GPA) AS AverageGPA,
       COUNT(*) AS TotalStudents
FROM Students
GROUP BY DepartmentID;

-- TASK 5.3
SELECT DepartmentID,
       AVG(GPA) AS AverageGPA
FROM Students
GROUP BY DepartmentID
HAVING AVG(GPA) > 3.00;

-- TASK 5.4
SELECT DepartmentID,
       COUNT(*) AS TotalStudents
FROM Students
WHERE GPA >= 2.50
GROUP BY DepartmentID
HAVING COUNT(*) > 1;

-- STAGE 6
-- TASK 6.1
-- StudentID has a Clustered Index by default
-- because it is the Primary Key.

-- TASK 6.2
CREATE NONCLUSTERED INDEX IX_Students_Email
ON Students(Email);

-- STAGE 7
-- TASK 7.1 SUBQUERY
SELECT *
FROM Students
WHERE GPA > (
    SELECT AVG(GPA)
    FROM Students
);
GO

-- TASK 7.2 VIEW
CREATE VIEW vw_StudentAcademicDetails AS
SELECT S.StudentID,
       S.FullName,
       S.GPA,
       D.DepartmentName
FROM Students S
INNER JOIN Departments D
ON S.DepartmentID = D.DepartmentID;
GO

SELECT * FROM vw_StudentAcademicDetails;
GO

-- TASK 7.3 STORED PROCEDURE
CREATE PROCEDURE sp_GetStudentsByDepartment
    @DeptID INT
AS
BEGIN
    SELECT *
    FROM Students
    WHERE DepartmentID = @DeptID;
END;
GO

EXEC sp_GetStudentsByDepartment @DeptID = 1;
GO