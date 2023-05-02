DROP TABLE employees
USE shop;
CREATE TABLE employees (
  name VARCHAR(50) NOT NULL,
  department VARCHAR(50) NOT NULL,
  salary VARCHAR(50) NOT NULL,
);



INSERT INTO employees (name, department, salary) VALUES 
('John Doe', 'Marketing', 50000.00),
('Jane Smith', 'Human Resources', 60000.00),
('Bob Johnson', 'Accounting', 75000.00),
('Sarah Lee', 'Sales', 80000.00),
('Mike Brown', 'Engineering', 90000.00);


CREATE OR ALTER PROCEDURE insert_employee @employee_name VARCHAR(50), @employee_salary VARCHAR(50), @employee_department VARCHAR(50)
AS
BEGIN

  SET NOCOUNT ON;
  INSERT INTO employees(name, salary, department)
  VALUES(@employee_name, @employee_salary, @employee_department);
  
  -- IF @@ROWCOUNT > 0
    -- SET @error = 1;

  SELECT 'insert Success' AS message FOR XML RAW, ROOT('Response');
  return 0;
END

EXEC insert_employee 'Jhon', 1324.21, 'depa'

USE shop;
SELECT * FROM employees