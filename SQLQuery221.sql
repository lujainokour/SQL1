CREATE DATABASE TechWorldHRDB;

CREATE TABLE TemporaryStaff (
    StaffID INT,
    StaffName VARCHAR(50),
    HireDate DATE
);

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentNam VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Salary DECIMAL(10,2),
    DepartmentID INT
);

ALTER TABLE Employees
ADD PhoneNumber VARCHAR(20);

DROP TABLE TemporaryStaff;

INSERT INTO Departments (DepartmentID, DepartmentNam)
VALUES (1, 'IT');

INSERT INTO Departments (DepartmentID, DepartmentNam)
VALUES (2, 'HR');

INSERT INTO Departments (DepartmentID, DepartmentNam)
VALUES (3, 'Finance');

INSERT INTO Employees
(EmployeeID, FullName, Email, Salary, DepartmentID, PhoneNumber)
VALUES
(1, 'Ahmad Ali', 'ahmad@techworld.com', 1200.00, 1, '0791111111'),
(2, 'Sara Hassan', 'sara@techworld.com', 950.00, 2, '0792222222'),
(3, 'Zaid Omar', 'zaid@techworld.com', 1500.00, 1, '0793333333'),
(4, 'Mona Khaled', 'mona@techworld.com', 800.00, 3, '0794444444');

SELECT * FROM Employees;

--3.3--
UPDATE Employees
SET Salary = 1350.00
WHERE EmployeeID = 1;

DELETE FROM Employees
WHERE EmployeeID = 4;

SELECT * FROM Employees;

SELECT FullName, Salary
FROM Employees;

SELECT SUM(Salary) AS TotalSalaries
FROM Employees;

SELECT AVG(Salary) AS AverageSalary
FROM Employees;

SELECT
    MAX(Salary) AS HighestSalary,
    MIN(Salary) AS LowestSalary
FROM Employees;

SELECT COUNT(*) AS TotalEmployees
FROM Employees;