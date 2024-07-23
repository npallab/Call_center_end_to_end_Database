SELECT * from `QA_Audits`

-- A procedure to enter QA Audits
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

-- Quality wants to see the Error Count of each agent
SELECT `EMPID`,`SKILL`,COUNT(*) As Error_Count FROM (SELECT Q.`EMPID`,Q.`INT_ID`,Q.QA, `PD`.`SKILL` FROM `QA_Audits` Q JOIN `PRODUCTION_SHEET` PD ON Q.INT_ID=`PD`.`INT_ID`) QA_M
WHERE QA='Y'
GROUP BY `EMPID`,`SKILL`

-- Quality wants to see the Error Count of each agent against each worktype
SELECT `EMPID`,`SKILL`,COUNT(*) As Total_Count FROM (SELECT Q.`EMPID`,Q.`INT_ID`,Q.QA, `PD`.`SKILL` FROM `QA_Audits` Q JOIN `PRODUCTION_SHEET` PD ON Q.INT_ID=`PD`.`INT_ID`) QA_M
GROUP BY `EMPID`,`SKILL`

-- Quality wants to see the Error Count of each team grouped by their Manager ID    
WITH Q_A_AGENT(EMPID,SKILL,TOTAL_COUNT) AS
(
   SELECT `EMPID`,`SKILL`,COUNT(*) As Total_Count FROM (SELECT Q.`EMPID`,Q.`INT_ID`,Q.QA, `PD`.`SKILL` FROM `QA_Audits` Q JOIN `PRODUCTION_SHEET` PD ON Q.INT_ID=`PD`.`INT_ID` WHERE `QA`='Y') QA_M
   GROUP BY `EMPID`,`SKILL` 
)
SELECT EM.`Manager_ID`, Q_A_AGENT.SKILL, COUNT(Q_A_AGENT.TOTAL_COUNT) as Total_ERROR_Count FROM `Employee` EM JOIN Q_A_AGENT ON `EM`.`EMPID`=Q_A_AGENT.`EMPID`
GROUP BY EM.`Manager_ID`,`Q_A_AGENT`.`SKILL`
ORDER BY EM.`Manager_ID`

-- Quality wants to see the QA Score of each team grouped by their Manager ID 
WITH AGENT_AUDIT(EMPID,AUDIT_COUNT,SKILL,QA) AS
(
    SELECT Q.`EMPID`, COUNT(*) as Audit_Count ,PS.`SKILL`, Q.`QA` from `QA_Audits` Q JOIN `PRODUCTION_SHEET` PS ON `Q`.`EMPID`=`PS`.`EMPID`
    GROUP BY Q.`EMPID`,PS.`SKILL`,Q.`QA`
)
SELECT E.`Manager_ID`,COUNT(AGENT_AUDIT.AUDIT_COUNT) as TOTAL_AUDITS, AGENT_AUDIT.SKILL, AGENT_AUDIT.QA FROM AGENT_AUDIT JOIN `Employee` E ON AGENT_AUDIT.EMPID=E.`EMPID`
GROUP BY `E`.`Manager_ID`,AGENT_AUDIT.SKILL,AGENT_AUDIT.QA
ORDER BY `Manager_ID`


