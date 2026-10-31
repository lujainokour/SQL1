
USE TechWorldHRDB;
GO

-- =====================================
-- FIX DEPARTMENT COLUMN NAME
-- =====================================

IF COL_LENGTH('dbo.Departments', 'DepartmentName') IS NULL
AND COL_LENGTH('dbo.Departments', 'DepartmentNam') IS NOT NULL
BEGIN
    EXEC sp_rename
        'dbo.Departments.DepartmentNam',
        'DepartmentName',
        'COLUMN';
END;
GO

-- =====================================
-- PHASE 5: DATABASE RELATIONS
-- =====================================

-- TASK 5.1: ACCESS CARDS (1:1)

IF OBJECT_ID('dbo.AccessCards', 'U') IS NULL
BEGIN
    CREATE TABLE AccessCards (
        CardID INT PRIMARY KEY,
        CardNumber VARCHAR(50) NOT NULL UNIQUE,
        EmployeeID INT UNIQUE,
        FOREIGN KEY (EmployeeID)
            REFERENCES Employees(EmployeeID)
    );
END;
GO

-- TASK 5.2: PROJECTS (M:N)

IF OBJECT_ID('dbo.Projects', 'U') IS NULL
BEGIN
    CREATE TABLE Projects (
        ProjectID INT PRIMARY KEY,
        ProjectName VARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID('dbo.EmployeeProjects', 'U') IS NULL
BEGIN
    CREATE TABLE EmployeeProjects (
        EmployeeID INT,
        ProjectID INT,
        AssignedDate DATE,

        PRIMARY KEY (EmployeeID, ProjectID),

        FOREIGN KEY (EmployeeID)
            REFERENCES Employees(EmployeeID),

        FOREIGN KEY (ProjectID)
            REFERENCES Projects(ProjectID)
    );
END;
GO

-- =====================================
-- TASK 5.3: INSERT SAMPLE DATA
-- =====================================

-- ACCESS CARDS

INSERT INTO AccessCards
(CardID, CardNumber, EmployeeID)
SELECT 101, 'CARD101', 1
WHERE EXISTS (
    SELECT 1 FROM Employees WHERE EmployeeID = 1
)
AND NOT EXISTS (
    SELECT 1 FROM AccessCards
    WHERE CardID = 101 OR EmployeeID = 1
);

INSERT INTO AccessCards
(CardID, CardNumber, EmployeeID)
SELECT 102, 'CARD102', 2
WHERE EXISTS (
    SELECT 1 FROM Employees WHERE EmployeeID = 2
)
AND NOT EXISTS (
    SELECT 1 FROM AccessCards
    WHERE CardID = 102 OR EmployeeID = 2
);

INSERT INTO AccessCards
(CardID, CardNumber, EmployeeID)
SELECT 103, 'CARD103', 3
WHERE EXISTS (
    SELECT 1 FROM Employees WHERE EmployeeID = 3
)
AND NOT EXISTS (
    SELECT 1 FROM AccessCards
    WHERE CardID = 103 OR EmployeeID = 3
);

-- PROJECTS

IF NOT EXISTS (
    SELECT 1 FROM Projects WHERE ProjectID = 1
)
INSERT INTO Projects
(ProjectID, ProjectName)
VALUES (1, 'AI & Security Training');

IF NOT EXISTS (
    SELECT 1 FROM Projects WHERE ProjectID = 2
)
INSERT INTO Projects
(ProjectID, ProjectName)
VALUES (2, 'Cloud Migration');

-- EMPLOYEE PROJECTS

INSERT INTO EmployeeProjects
(EmployeeID, ProjectID, AssignedDate)
SELECT 1, 1, '2026-10-01'
WHERE EXISTS (
    SELECT 1 FROM Employees WHERE EmployeeID = 1
)
AND EXISTS (
    SELECT 1 FROM Projects WHERE ProjectID = 1
)
AND NOT EXISTS (
    SELECT 1 FROM EmployeeProjects
    WHERE EmployeeID = 1 AND ProjectID = 1
);

INSERT INTO EmployeeProjects
(EmployeeID, ProjectID, AssignedDate)
SELECT 1, 2, '2026-10-02'
WHERE EXISTS (
    SELECT 1 FROM Employees WHERE EmployeeID = 1
)
AND EXISTS (
    SELECT 1 FROM Projects WHERE ProjectID = 2
)
AND NOT EXISTS (
    SELECT 1 FROM EmployeeProjects
    WHERE EmployeeID = 1 AND ProjectID = 2
);

INSERT INTO EmployeeProjects
(EmployeeID, ProjectID, AssignedDate)
SELECT 2, 1, '2026-10-03'
WHERE EXISTS (
    SELECT 1 FROM Employees WHERE EmployeeID = 2
)
AND EXISTS (
    SELECT 1 FROM Projects WHERE ProjectID = 1
)
AND NOT EXISTS (
    SELECT 1 FROM EmployeeProjects
    WHERE EmployeeID = 2 AND ProjectID = 1
);

INSERT INTO EmployeeProjects
(EmployeeID, ProjectID, AssignedDate)
SELECT 3, 2, '2026-10-04'
WHERE EXISTS (
    SELECT 1 FROM Employees WHERE EmployeeID = 3
)
AND EXISTS (
    SELECT 1 FROM Projects WHERE ProjectID = 2
)
AND NOT EXISTS (
    SELECT 1 FROM EmployeeProjects
    WHERE EmployeeID = 3 AND ProjectID = 2
);
GO

-- =====================================
-- PHASE 6: DATABASE JOINS
-- =====================================

-- TASK 6.1: INNER JOIN (1:N)

SELECT
    E.FullName,
    E.Salary,
    D.DepartmentName
FROM Employees E
INNER JOIN Departments D
    ON E.DepartmentID = D.DepartmentID;

-- TASK 6.2: LEFT JOIN (1:N)

SELECT
    D.DepartmentName,
    E.FullName
FROM Departments D
LEFT JOIN Employees E
    ON D.DepartmentID = E.DepartmentID;

-- TASK 6.3: INNER JOIN (1:1)

SELECT
    E.FullName,
    A.CardNumber
FROM Employees E
INNER JOIN AccessCards A
    ON E.EmployeeID = A.EmployeeID;

-- TASK 6.4: MULTI-TABLE JOIN (M:N)

SELECT
    E.FullName,
    P.ProjectName,
    EP.AssignedDate
FROM Employees E
INNER JOIN EmployeeProjects EP
    ON E.EmployeeID = EP.EmployeeID
INNER JOIN Projects P
    ON EP.ProjectID = P.ProjectID;

-- =====================================
-- PHASE 7: ADVANCED SQL
-- =====================================

-- TASK 7.1: GROUP BY

SELECT
    DepartmentID,
    SUM(Salary) AS TotalSalary,
    COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY DepartmentID;

-- TASK 7.2: HAVING

SELECT
    DepartmentID,
    AVG(Salary) AS AvgSalary
FROM Employees
GROUP BY DepartmentID
HAVING AVG(Salary) > 1000.00;

-- TASK 7.3: SUBQUERY

SELECT *
FROM Employees
WHERE Salary > (
    SELECT AVG(Salary)
    FROM Employees
);
GO

-- =====================================
-- TASK 7.4: VIEW
-- =====================================

CREATE OR ALTER VIEW vw_EmployeeDetails
AS
SELECT
    E.EmployeeID,
    E.FullName,
    E.Email,
    D.DepartmentName
FROM Employees E
INNER JOIN Departments D
    ON E.DepartmentID = D.DepartmentID;
GO

SELECT * FROM vw_EmployeeDetails;
GO

-- =====================================
-- TASK 7.5: STORED PROCEDURE
-- =====================================

CREATE OR ALTER PROCEDURE sp_GetEmployeesByDepartment
    @DeptID INT
AS
BEGIN
    SELECT *
    FROM Employees
    WHERE DepartmentID = @DeptID;
END;
GO

-- TEST PROCEDURE

EXEC sp_GetEmployeesByDepartment @DeptID = 1;
GO

-- =====================================
-- TASK 7.6: AUDIT TABLE
-- =====================================

IF OBJECT_ID('dbo.EmployeeAudit', 'U') IS NULL
BEGIN
    CREATE TABLE EmployeeAudit (
        AuditID INT PRIMARY KEY IDENTITY(1,1),
        EmployeeID INT,
        [Action] VARCHAR(50),
        ActionDate DATETIME
    );
END;
GO

-- =====================================
-- DELETE TRIGGER
-- =====================================

CREATE OR ALTER TRIGGER trg_EmployeeDelete
ON Employees
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO EmployeeAudit
        (EmployeeID, [Action], ActionDate)
    SELECT
        EmployeeID,
        'DELETE',
        GETDATE()
    FROM deleted;
END;
GO

-- =====================================
-- FINAL VERIFICATION
-- =====================================

SELECT * FROM Departments;
SELECT * FROM Employees;
SELECT * FROM AccessCards;
SELECT * FROM Projects;
SELECT * FROM EmployeeProjects;
SELECT * FROM vw_EmployeeDetails;
SELECT * FROM EmployeeAudit;

PRINT 'HR TASK 2 SCRIPT COMPLETED';
GO
