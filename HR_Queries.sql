--Count of Male and Female Employees
SELECT COUNT(`EMPID`),`Gender` from `Employee`
GROUP BY Gender

-- Count of Gender Manager Wise
SELECT E.`Manager_ID`, `M`.`First_Name`,E.`Gender`,COUNT(E.`EMPID`) from `Employee` as E JOIN `Managers` as M ON E.`Manager_ID`=M.`EMPID`
GROUP BY E.Gender,E.Manager_ID,M.`First_Name`

--Genderwise rating :

SELECT E.`Gender`,E.`RATING`,COUNT(1) from `Employee` E
GROUP BY E.`Gender`,E.`RATING`
ORDER BY E.`RATING`

-- Basic Salary Distribution Male and Female Wise

SELECT `Gender`,ROUND(AVG(`BASIC_SAL`),0) as Basic_salary  FROM `Employee`
GROUP BY `Gender`

-- Highest Salary Under Manager
SELECT max(`BASIC_SAL`) as Max_Salary, `Manager_ID` FROM `Employee`
GROUP BY `Manager_ID`

-- Leave Balance per employee 
SELECT CONCAT(`First_Name`,' ',`Last_Name`) as Employee_Name,`CL_BAl`,`SL_Bal`,`PL_Bal` FROM `Employee` JOIN `LEAVES_BALANCE` ON `Employee`.`EMPID`=`LEAVES_BALANCE`.`EMPID`

--Average tennure of employees against manager ID

SELECT `Manager_ID`, ROUND((AVG((EXTRACT(YEAR_MONTH FROM SYSDATE())-(EXTRACT(YEAR_MONTH FROM `DOJ`)))))/100,2) AS AVG_TENNURE FROM `Employee`
GROUP BY `Manager_ID`
ORDER BY AVG_TENNURE DESC

--PROCEDURE TO APPLY CASUAL LEAVE

DELIMITER $$

CREATE PROCEDURE CL_LEAVE_APPLY(p_emp_id BIGINT, p_date DATE)
BEGIN
    DECLARE emp_id_chk INT DEFAULT 0;
    DECLARE cl_bal_chk INT DEFAULT 0;
    
    -- Check if the employee exists in LEAVES_RUNNING
    SELECT count(1) INTO emp_id_chk 
    FROM LEAVES_RUNNING 
    WHERE EMPID = p_emp_id;
    
    IF emp_id_chk > 0 THEN
        -- Check the current leave balance
        SELECT CL_BAl INTO cl_bal_chk  
        FROM LEAVES_BALANCE 
        WHERE EMPID = p_emp_id;
        
        IF cl_bal_chk > 1 THEN
            -- Update the leave balance
            UPDATE LEAVES_BALANCE
            SET CL_BAl = CL_BAl - 1
            WHERE EMPID = p_emp_id;
            
            -- Insert a record into LEAVES_RUNNING
            INSERT INTO LEAVES_RUNNING (`Date_Lv`, `TYPE_Lv`, `SL_No`, `EMPID`)
            VALUES (p_date, 'CL', ROUND(RAND(32)*100+100,2), p_emp_id);
        ELSE 
            SELECT 'ERROR: Insufficient leave balance' AS Message;
        END IF;
    ELSE 
        SELECT 'ERROR: Employee not found' AS Message;
    END IF;
END
$$

DELIMITER ;

-- A procedure to view heirarchy from a particular manager

SELECT * from `Managers`

DELIMITER ^^

CREATE PROCEDURE Heirarchy(p_EMPID BIGINT)
BEGIN

DECLARE count_emp INT;
SELECT count(1)  INTO count_emp from `Managers` WHERE `EMPID`=p_EMPID;

IF count_emp>0 THEN

    WITH RECURSIVE HRCHY AS (
        SELECT `Managers`.`EMPID`,`Managers`.`First_Name`,`Managers`.`Designation`,`Managers`.`Manager_ID` from `Managers` WHERE `EMPID`=p_EMPID
        UNION ALL
        SELECT `Managers`.`EMPID`,`Managers`.`First_Name`, `Managers`.`Designation`,`Managers`.`Manager_ID` from `Managers` JOIN HRCHY ON `HRCHY`.`Manager_ID`=`Managers`.`EMPID`
    ) SELECT * from `HRCHY` ;

ELSE
    SELECT 'Error:: EMPID invalid' as MESSAGE_TEXT;

END IF;

END;
^^

CALL `Heirarchy`(3151245)

-- Divide Employees into 4 Quartiles based on their basic salary

SELECT `EMPID`, CONCAT(`First_Name`,' ',`Last_Name`), `BASIC_SAL`, NTILE(4) OVER(ORDER BY `BASIC_SAL`) AS Quartile FROM `Employee`