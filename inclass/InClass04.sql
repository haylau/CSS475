\qecho Mohammad Zahid, Hayden Lauritzen, Abhimanyu Kumar

ALTER SEQUENCE Employee_id_seq  RESTART WITH 101;
ALTER SEQUENCE phone_id_seq RESTART WITH 101;
BEGIN;

\qecho
\qecho #1 
\qecho

INSERT INTO employee (id, employeenum, name, departmentid, email)
VALUES ( employee_id_seq ,'Z000000001', 'Zeke', 3, 'zman@bigco.com')
;

\qecho check #1
SELECT COUNT (*) FROM Employee;
SELECT * FROM Employee
WHERE Employee.employeenum LIKE 'Z%';

\qecho
\qecho #2
\qecho

INSERT INTO phone
(
    phone_id_seq.last_value, "321-4590"
)
;
SET phone.phonetypeid = 'W',
    phone.number = "321-4590"
WHERE phone.id = phone_id_seq.last_value,
    employeeid = (SELECT employe.id FROM employee WHERE employee.employeenum = 'Z000000001')

\qecho Check #2
SELECT phonetypeid, phone.number
FROM Phone
    JOIN Employee ON ( phone.employeeid = employee.id)
WHERE employee.employeenum = 'Z000000001';

ROLLBACK;
