
# End-to-end Dabase of a contact center(Call Center)
This Call Center Database project aims to create a comprehensive database for managing various aspects of call center operations, including employee details, skills, leave balances, production data, and QA audits. The database structure ensures efficient data management and retrieval, aiding HR, operations, and quality assurance teams in their respective functions.









## Key Objectives

**Employee Management**: Store and manage detailed employee information, including personal details, job information, and ratings.

**Skill Management**: Track and manage skills and targets, ensuring employees are trained and meeting performance metrics.

**Leave Management**: Maintain accurate leave balances and track leave requests to ensure proper leave management.

**Operational Data Management**: Capture and analyze daily operational data to monitor performance and productivity.

**Quality Assurance**: Record and review QA audits to maintain high service quality and address any issues promptly.

**Management Oversight**: Maintain records of management staff for better organizational structure and reporting.




## Data Definitions 
SQL Queries Link : https://github.com/npallab/Call_center_end_to_end_Database/blob/main/Call%20Center%20Project_DDL.sql
<a href="https://ibb.co/q70cBwN"><img src="https://i.ibb.co/WGDMn1k/Untitled.png" alt="Untitled" border="0"></a>


## Operations Queries


1. View each employee and their Average Handling Times (AHTs) across different work types.

```bash

SELECT P.`EMPID`,CONCAT(E.`First_Name`,' ',E.`Last_Name`) AS Emp_Name,ROUND(ROUND(AVG(P.`RESOLVE_TIME`- P.`ASSIGN_TIME`),0)/100,2) AS AHT, `P`.`SKILL`,P.`Date_login` FROM `PRODUCTION_SHEET` P JOIN `Employee` E 
ON P.`EMPID`=E.`EMPID`
GROUP BY `EMPID`,`SKILL`,`Date_login`



```

2. Assess each team against various work types, including manager names.


```bash

WITH OPS_MANAGER(`Manager_ID`,Team_Span,SKILL,AHT) AS
(
SELECT E.`Manager_ID`, COUNT(P_D.`EMPID`) as Team_Span,`P_D`.`SKILL`, AVG(`P_D`.`RESOLVE_TIME`- P_D.`ASSIGN_TIME`) FROM `PRODUCTION_SHEET` P_D JOIN `Employee` E ON `E`.`EMPID`=`P_D`.`EMPID`
GROUP BY `E`.`Manager_ID`,`P_D`.`SKILL`
)
SELECT CONCAT(M.`First_Name`,' ',M.`Last_Name`) as Manager_Name, OM.* FROM `Managers` M JOIN OPS_MANAGER OM ON OM.`Manager_ID`=M.`EMPID`



```

3. Determine if targets are met and the percentage of achievement if targets are met


```bash

-- Creating a View to fetch Managers and Their team Span along with skills and AHT
CREATE OR REPLACE VIEW OPS_AHT_VS_TARGET AS (
SELECT OPS.*,SK.`AHT` as AHT_target FROM 
(WITH OPS_MANAGER(`Manager_ID`,Team_Span,SKILL,AHT) AS
(
SELECT E.`Manager_ID`, COUNT(P_D.`EMPID`) as Team_Span,`P_D`.`SKILL`, ROUND(ROUND(AVG(`P_D`.`RESOLVE_TIME`- P_D.`ASSIGN_TIME`),0)/100,2) FROM `PRODUCTION_SHEET` P_D JOIN `Employee` E ON `E`.`EMPID`=`P_D`.`EMPID`
GROUP BY `E`.`Manager_ID`,`P_D`.`SKILL`
)
SELECT CONCAT(M.`First_Name`,' ',M.`Last_Name`) as Manager_Name, OM.* FROM `Managers` M JOIN OPS_MANAGER OM ON OM.`Manager_ID`=M.`EMPID`
) AS OPS JOIN `SKILLS` SK ON OPS.SKILL=SK.`Skill_name`
ORDER BY OPS.Manager_Name
)

--Getting Data from that view to display met percentage
SELECT *, CASE 
    WHEN AHT<AHT_Target THEN  'Met'
    ELSE  'Not Met'
END AS AHT_Status,ROUND((AHT_Target/AHT)*100,2) as Met_Percentage
FROM `OPS_AHT_VS_TARGET`



```
4. Analyze shrinkage patterns over days, grouped by managers and their names.


```bash

SELECT CONCAT(MG.`First_Name`,' ',`MG`.`Last_Name`) AS Manager_name, MG.`Designation`, M.* from (WITH LEAVES_PERDAY(EMP_No,`Date_Lv`,`Manager_ID`) AS
(
SELECT COUNT(L.`SL_No`),L.`Date_Lv`, E.`Manager_ID` FROM `LEAVES_RUNNING` L JOIN `Employee` E ON L.`EMPID`=E.`EMPID`
GROUP BY `Manager_ID`,Date_Lv
)
SELECT LP.Manager_ID,COUNT(EM.`EMPID`) as Total_HC, LP.EMP_No as 'HC_on_leave', `Date_Lv`  as Date_of_leave, ROUND((LP.EMP_No/COUNT(EM.`EMPID`))*100,2) as Shrinkage FROM `Employee` EM JOIN LEAVES_PERDAY LP ON EM.`Manager_ID`=LP.`Manager_ID`
GROUP BY EM.Manager_ID,`Date_Lv`) as M JOIN `Managers` as MG ON M.`Manager_ID`=`MG`.`EMPID`



```
5.Track the customer rating trend across all agents.



```bash

WITH Manager_trend(Manager_ID,Avg_rating) AS 
(
SELECT E.Manager_ID,ROUND(AVG(P.`CX_RATING`),2) as "Avg Rating" from `PRODUCTION_SHEET` P JOIN `Employee` E ON `P`.`EMPID`=E.`EMPID`
GROUP BY `Manager_ID`
)
SELECT CONCAT(`Mg`.`First_Name`,' ',`Mg`.`Last_Name`) AS Manager_Name,`Mt`.Avg_rating FROM `Managers` Mg JOIN Manager_trend Mt ON Mt.`Manager_ID`=Mg.`EMPID`




```

## Human Resource Queries
1. Count of male and female employees.

```
SELECT COUNT(`EMPID`),`Gender` from `Employee`
GROUP BY Gender



```

2. 2. Count of employees by gender, categorized by manager.


```
SELECT E.`Manager_ID`, `M`.`First_Name`,E.`Gender`,COUNT(E.`EMPID`) from `Employee` as E JOIN `Managers` as M ON E.`Manager_ID`=M.`EMPID`
GROUP BY E.Gender,E.Manager_ID,M.`First_Name`



```

3. Gender-wise performance ratings..


```
SELECT E.`Gender`,E.`RATING`,COUNT(1) from `Employee` E
GROUP BY E.`Gender`,E.`RATING`
ORDER BY E.`RATING`



```

4. Basic salary distribution, broken down by gender.


```
SELECT `Gender`,ROUND(AVG(`BASIC_SAL`),0) as Basic_salary  FROM `Employee`
GROUP BY `Gender`



```
5. Identify the highest salary under each manager..


```
SELECT max(`BASIC_SAL`) as Max_Salary, `Manager_ID` FROM `Employee`
GROUP BY `Manager_ID`



```
6. Identify the highest salary under each manager..


```
SELECT CONCAT(`First_Name`,' ',`Last_Name`) as Employee_Name,`CL_BAl`,`SL_Bal`,`PL_Bal` FROM `Employee` JOIN `LEAVES_BALANCE` ON `Employee`.`EMPID`=`LEAVES_BALANCE`.`EMPID`



```

7. Average tenure of employees, categorized by manager ID.


```
SELECT `Manager_ID`, ROUND((AVG((EXTRACT(YEAR_MONTH FROM SYSDATE())-(EXTRACT(YEAR_MONTH FROM `DOJ`)))))/100,2) AS AVG_TENNURE FROM `Employee`
GROUP BY `Manager_ID`
ORDER BY AVG_TENNURE DESC

```

8. Procedure to apply for casual leave.



```
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


```

9. Procedure to view the hierarchy from a particular manager.


```
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

```

10. Divide employees into four quartiles based on their basic salary.


```
SELECT `EMPID`, CONCAT(`First_Name`,' ',`Last_Name`), `BASIC_SAL`, NTILE(4) OVER(ORDER BY `BASIC_SAL`) AS Quartile FROM `Employee`

```

## Quality Team Queries 

1. Procedure to enter QA audits.

```
DELIMITER $$
CREATE PROCEDURE ADD_QA(p_empid BIGINT,p_int_id BIGINT,qa VARCHAR(2))
BEGIN
DECLARE emp_cnt INT;
SELECT count(1) INTO emp_cnt from `Employee` WHERE `EMPID`=p_empid;
IF emp_cnt>0 THEN
    INSERT INTO `QA_Audits` VALUES(p_empid,p_int_id,qa);
ELSE   
    SELECT "Error" as Message;

END IF;

END;

$$

CALL `ADD_QA`(2159384,1223234,'Y') -- Sample Data insertion using the PROCEDURE
```

2. Error count of each agent..


```
SELECT `EMPID`,`SKILL`,COUNT(*) As Error_Count FROM (SELECT Q.`EMPID`,Q.`INT_ID`,Q.QA, `PD`.`SKILL` FROM `QA_Audits` Q JOIN `PRODUCTION_SHEET` PD ON Q.INT_ID=`PD`.`INT_ID`) QA_M
WHERE QA='Y'
GROUP BY `EMPID`,`SKILL`

```
3. Error count of each team, grouped by their manager ID.

```
WITH Q_A_AGENT(EMPID,SKILL,TOTAL_COUNT) AS
(
   SELECT `EMPID`,`SKILL`,COUNT(*) As Total_Count FROM (SELECT Q.`EMPID`,Q.`INT_ID`,Q.QA, `PD`.`SKILL` FROM `QA_Audits` Q JOIN `PRODUCTION_SHEET` PD ON Q.INT_ID=`PD`.`INT_ID` WHERE `QA`='Y') QA_M
   GROUP BY `EMPID`,`SKILL` 
)
SELECT EM.`Manager_ID`, Q_A_AGENT.SKILL, COUNT(Q_A_AGENT.TOTAL_COUNT) as Total_ERROR_Count FROM `Employee` EM JOIN Q_A_AGENT ON `EM`.`EMPID`=Q_A_AGENT.`EMPID`
GROUP BY EM.`Manager_ID`,`Q_A_AGENT`.`SKILL`
ORDER BY EM.`Manager_ID`

```

4. QA score of each team, grouped by their manager ID.

```
WITH AGENT_AUDIT(EMPID,AUDIT_COUNT,SKILL,QA) AS
(
    SELECT Q.`EMPID`, COUNT(*) as Audit_Count ,PS.`SKILL`, Q.`QA` from `QA_Audits` Q JOIN `PRODUCTION_SHEET` PS ON `Q`.`EMPID`=`PS`.`EMPID`
    GROUP BY Q.`EMPID`,PS.`SKILL`,Q.`QA`
)
SELECT E.`Manager_ID`,COUNT(AGENT_AUDIT.AUDIT_COUNT) as TOTAL_AUDITS, AGENT_AUDIT.SKILL, AGENT_AUDIT.QA FROM AGENT_AUDIT JOIN `Employee` E ON AGENT_AUDIT.EMPID=E.`EMPID`
GROUP BY `E`.`Manager_ID`,AGENT_AUDIT.SKILL,AGENT_AUDIT.QA
ORDER BY `Manager_ID`

```
## Dashboard


<a href="https://ibb.co/SBJk6bw"><img src="https://i.ibb.co/QMXWJLv/Screenshot-2024-07-23-at-5-07-29-PM.png" alt="Screenshot-2024-07-23-at-5-07-29-PM" border="0"></a>

Link : https://lookerstudio.google.com/reporting/f396405a-c830-4281-9868-37b5946a544f

## Authors

- [@npallab](https://www.github.com/npallab)


## 🚀 About Me
I am a Risk Analytics Professional with : Certififcation in Machine Learning from IIT Roorkee, Certified Scrum Master, Black Belt in Six Six Sigma, PMP Trained. I have worked with Amazon in the past and currently working as a Senior Analyst in Payment Risk team in Airbnb.


## 🔗 Links

[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/pallabnath/)


## 🛠 Skills
SQL,Python,C/C++,Machine Learning, Data Analytics, Project Management, Consulting, Risk Management


## Tech Stack

**Language** MYSQL

**Data Source** NA

