--Operations wants to see each employee and their AHTs Against each worktype

SELECT P.`EMPID`,CONCAT(E.`First_Name`,' ',E.`Last_Name`) AS Emp_Name,ROUND(ROUND(AVG(P.`RESOLVE_TIME`- P.`ASSIGN_TIME`),0)/100,2) AS AHT, `P`.`SKILL`,P.`Date_login` FROM `PRODUCTION_SHEET` P JOIN `Employee` E 
ON P.`EMPID`=E.`EMPID`
GROUP BY `EMPID`,`SKILL`,`Date_login`

--Operations want to assess each team against each worktype with manager name
CREATE VIEW AHT_TREND AS (
WITH OPS_MANAGER(`Manager_ID`,Team_Span,SKILL,AHT) AS
(
SELECT E.`Manager_ID`, COUNT(P_D.`EMPID`) as Team_Span,`P_D`.`SKILL`, AVG(`P_D`.`RESOLVE_TIME`- P_D.`ASSIGN_TIME`) FROM `PRODUCTION_SHEET` P_D JOIN `Employee` E ON `E`.`EMPID`=`P_D`.`EMPID`
GROUP BY `E`.`Manager_ID`,`P_D`.`SKILL`
)
SELECT CONCAT(M.`First_Name`,' ',M.`Last_Name`) as Manager_Name, OM.* FROM `Managers` M JOIN OPS_MANAGER OM ON OM.`Manager_ID`=M.`EMPID`
)

--Operations wants to see if targets are met and if met what is the achieved percentage

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

--The Operations wants to see the shrinkage pattern over days Grouped by Managers with their names

SELECT CONCAT(MG.`First_Name`,' ',`MG`.`Last_Name`) AS Manager_name, MG.`Designation`, M.* from (WITH LEAVES_PERDAY(EMP_No,`Date_Lv`,`Manager_ID`) AS
(
SELECT COUNT(L.`SL_No`),L.`Date_Lv`, E.`Manager_ID` FROM `LEAVES_RUNNING` L JOIN `Employee` E ON L.`EMPID`=E.`EMPID`
GROUP BY `Manager_ID`,Date_Lv
)
SELECT LP.Manager_ID,COUNT(EM.`EMPID`) as Total_HC, LP.EMP_No as 'HC_on_leave', `Date_Lv`  as Date_of_leave, ROUND((LP.EMP_No/COUNT(EM.`EMPID`))*100,2) as Shrinkage FROM `Employee` EM JOIN LEAVES_PERDAY LP ON EM.`Manager_ID`=LP.`Manager_ID`
GROUP BY EM.Manager_ID,`Date_Lv`) as M JOIN `Managers` as MG ON M.`Manager_ID`=`MG`.`EMPID`

--The operations also wants to see the Customer rating Trend across all Managers

WITH Manager_trend(Manager_ID,Avg_rating) AS 
(
SELECT E.Manager_ID,ROUND(AVG(P.`CX_RATING`),2) as "Avg Rating" from `PRODUCTION_SHEET` P JOIN `Employee` E ON `P`.`EMPID`=E.`EMPID`
GROUP BY `Manager_ID`
)
SELECT CONCAT(`Mg`.`First_Name`,' ',`Mg`.`Last_Name`) AS Manager_Name,`Mt`.Avg_rating FROM `Managers` Mg JOIN Manager_trend Mt ON Mt.`Manager_ID`=Mg.`EMPID`





