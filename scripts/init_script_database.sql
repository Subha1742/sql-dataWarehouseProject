/*
------------------------------------------------------------------------------------------
This script creates a new database called 'DataWarehouse'.
It first does a safety check that if the database already exists. If yes then rollback all
the transactions that is being happening and drops the DB. Then create a new database and
create corresponding schemas - bronze, silver, gold.

WARNING:
RUNNING THIS SCRIPT DROPS THE WHOLE DATABASE, LEAVING THE DATA IN THE DB BEING ERASED FOREVER.
SO TAKE A BACKUP OF THE DATABASE IF NEEDED BEFORE RUNNING THE SCRIPT.
------------------------------------------------------------------------------------------
*/
USE master;
GO

--CHECK IF THE DATABASE THAT IS TO BE CREATED ALREADY EXISTS
IF EXISTS(SELECT 1 FROM SYS.DATABASES WHERE NAME = 'DATAWAREHOUSE')
BEGIN
	ALTER DATABASE DATAWAREHOUSE SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DATAWAREHOUSE;
END
GO

--CREATING A NEW DATABASE
CREATE DATABASE DATAWAREHOUSE;

USE DATAWAREHOUSE;
GO
--CREATE SCHEMAS

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
