-- Main Database for storing the Tables
CREATE DATABASE CALL_CENTER

USE CALL_CENTER

--Main Employee Table for HR Use Contains generic Employee Details of all the agents 
CREATE TABLE Employee (
    EMPID BIGINT PRIMARY KEY, --Employee ID for the Employee
    First_Name VARCHAR(50), -- First Name 
    Last_Name VARCHAR(50), --Last Name
    DOB DATE, -- Date of Birth
    DOJ DATE, -- Date of Joining
    BASIC_SAL BIGINT, -- Basic Salary
    RATING VARCHAR(20), -- Rating for the previous calender year rating can be A,B,C where A is the top rating
    Gender VARCHAR(2) 
    CHECK (Gender IN ('M', 'F')) -- M signifies Males and F signifies Female
    Manager_ID BIGINT, --Manager ID of the employee
    Emp_type VARCHAR(2) -- Weather the employee is a Individual Contributor (IC) or a team lead(TL), team leads provide support to junior employees

);


--SKills and Targets : this table contains the various types of work the Call Center works on and the targets for each type of work, more skills can be addeed here as and when needed

CREATE TABLE SKILLS(
    Skill_name VARCHAR(20) PRIMARY KEY, -- Names of the skills 
    AHT DECIMAL(10,2), -- Average handle Time target for the particular skill
    QA_Target DECIMAL(10,2) -- Quality target for the skill
);

--Employee Skills , this table contains the employee IDs and the skills they are trained on , this table is mainly for the use of Operations team to see who all are trained on what skills

CREATE TABLE AGENT_SKILL(
    SL_No BIGINT PRIMARY KEY,
    EMPID BIGINT , -- Employee ID
    SKILL VARCHAR(20), -- SKills they are trained on
    EMP_STAT VARCHAR(20) -- Are they fully trained on it i.e 'Productive' or 'under training'
);

--Leaves Balance Data, contains leave balance for each employee for each type of leave
CREATE TABLE LEAVES_BALANCE(
    EMPID BIGINT PRIMARY KEY ,
    CL_BAl BIGINT, -- Casual Leave Balance
    SL_Bal BIGINT, -- Sick Leave Balance
    PL_Bal BIGINT --Planned Leave balance
)

--Leaves Data on running basis
CREATE TABLE LEAVES_RUNNING(
    SL_No BIGINT PRIMARY KEY,
    EMPID BIGINT , 
    Date_Lv DATE,
    TYPE_Lv VARCHAR(2)
);


--Main Production Sheet:: Contains Operational Data for each employees on a daily basis
CREATE TABLE PRODUCTION_SHEET(
    EMPID BIGINT,
    Date_login DATE, -- Date when the employee worked on a specific ticket/interraction
    SKILL VARCHAR(20), -- The type of interraction
    ASSIGN_TIME DATETIME, -- When the interraction was assigned 
    RESOLVE_TIME DATETIME, -- When the interraction was resolved
    CX_RATING INT(1), -- Customer rating post interraction
    INT_ID BIGINT PRIMARY KEY -- Interraction ID , the unique ID for each of the interraction
);

--QA Audits sheet contains all the audits of the agents
CREATE TABLE QA_Audits(
    EMPID BIGINT , -- Employee ID of the agent whose interraction was audited
    INT_ID BIGINT PRIMARY KEY, -- Interraction ID
    QA VARCHAR(2) -- Weather error present or not 'Y' for Error Present 'N' for no error
)

-- Management Staff Record

CREATE TABLE Managers (
    EMPID BIGINT PRIMARY KEY,
    First_Name VARCHAR(50),
    Last_Name VARCHAR(50),
    Manager_ID BIGINT,
    Designation VARCHAR(50)
);

