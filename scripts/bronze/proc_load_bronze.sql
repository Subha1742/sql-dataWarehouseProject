/*
-----------------------------------------------------------------------------------------
THIS PROC WRAPS THE CODE THAT LOAD THE DATA INTO THE TABLES THAT ARE CREATED IN THE BRONZE
SCHEMA. AS IT IS A FULL LOAD, IT FIRST TRUNCATES THE DATA THAT IS CURRENLTY IN THE TABLE 
AND THE INSERT THE DATA INTO THEM.
-----------------------------------------------------------------------------------------
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @wholeStart_time DATETIME, @wholeEnd_time DATETIME
	SET @wholeStart_time = GETDATE();
	BEGIN TRY
		--EXEC bronze.load_bronze
		PRINT '======================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '======================================================';

		PRINT '------------------------------------------------------';
		PRINT 'LOAD CRM TABLES';
		PRINT '------------------------------------------------------';
		--AS DOING FULL LOAD, WE ARE TRUNCATING THE TABLE FIRST AND THEN BULK INSERTING THE DATA
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		PRINT 'TRUNCATING TABLE: bronze.crm_cust_info';
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_cust_info
		--BULK INSERT DATA FROM CSV FILES.

		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		PRINT 'INSERTING DATA INTO: bronze.crm_cust_info';
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		BULK INSERT bronze.crm_cust_info
		FROM 'D:\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH
		(
			FIRSTROW = 2 --AS FIRSTROW HAS HEADERS AND DATA STARTS FROM SECOND ROW
			,FIELDTERMINATOR = ','
			,TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';

		--TESTING
		--SELECT * FROM bronze.crm_cust_info

		--AS DOING FULL LOAD, WE ARE TRUNCATING THE TABLE FIRST AND THEN BULK INSERTING THE DATA

		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		PRINT 'TRUNCATING TABLE: bronze.crm_prd_info';
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_prd_info
		--BULK INSERT DATA FROM CSV FILES.

		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		PRINT 'INSERTING DATA INTO: bronze.crm_prd_info';
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		BULK INSERT bronze.crm_prd_info
		FROM 'D:\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH
		(
			FIRSTROW = 2 --AS FIRSTROW HAS HEADERS AND DATA STARTS FROM SECOND ROW
			,FIELDTERMINATOR = ','
			,TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		--TESTING
		--SELECT * FROM bronze.crm_prd_info

		--AS DOING FULL LOAD, WE ARE TRUNCATING THE TABLE FIRST AND THEN BULK INSERTING THE DATA
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		PRINT 'TRUNCATING TABLE: bronze.crm_sales_details';
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_sales_details
		--BULK INSERT DATA FROM CSV FILES.
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		PRINT 'INSERTING DATA INTO: bronze.crm_sales_details';
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		BULK INSERT bronze.crm_sales_details
		FROM 'D:\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH
		(
			FIRSTROW = 2 --AS FIRSTROW HAS HEADERS AND DATA STARTS FROM SECOND ROW
			,FIELDTERMINATOR = ','
			,TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		--TESTING
		--SELECT * FROM bronze.crm_sales_details

		PRINT '------------------------------------------------------';
		PRINT 'LOAD ERP TABLES';
		PRINT '------------------------------------------------------';

		--AS DOING FULL LOAD, WE ARE TRUNCATING THE TABLE FIRST AND THEN BULK INSERTING THE DATA
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		PRINT 'TRUNCATING TABLE: bronze.erp_cust_AZ12';
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_cust_AZ12
		--BULK INSERT DATA FROM CSV FILES.
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		PRINT 'INSERTING DATA INTO: bronze.erp_cust_AZ12';
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		BULK INSERT bronze.erp_cust_AZ12
		FROM 'D:\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH
		(
			FIRSTROW = 2 --AS FIRSTROW HAS HEADERS AND DATA STARTS FROM SECOND ROW
			,FIELDTERMINATOR = ','
			,TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		--TESTING
		--SELECT * FROM bronze.erp_cust_AZ12

		--AS DOING FULL LOAD, WE ARE TRUNCATING THE TABLE FIRST AND THEN BULK INSERTING THE DATA
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		PRINT 'TRUNCATING TABLE: bronze.erp_loc_A101';
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_loc_A101
		--BULK INSERT DATA FROM CSV FILES.
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		PRINT 'INSERTING DATA INTO: bronze.erp_loc_A101';
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		BULK INSERT bronze.erp_loc_A101
		FROM 'D:\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH
		(
			FIRSTROW = 2 --AS FIRSTROW HAS HEADERS AND DATA STARTS FROM SECOND ROW
			,FIELDTERMINATOR = ','
			,TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		--TESTING
		--SELECT * FROM bronze.erp_loc_A101

		--AS DOING FULL LOAD, WE ARE TRUNCATING THE TABLE FIRST AND THEN BULK INSERTING THE DATA
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		PRINT 'TRUNCATING TABLE: bronze.erp_px_cat_G1V2';
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_px_cat_G1V2
		--BULK INSERT DATA FROM CSV FILES.
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		PRINT 'INSERTING DATA INTO: bronze.erp_px_cat_G1V2';
		PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';
		BULK INSERT bronze.erp_px_cat_G1V2
		FROM 'D:\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH
		(
			FIRSTROW = 2 --AS FIRSTROW HAS HEADERS AND DATA STARTS FROM SECOND ROW
			,FIELDTERMINATOR = ','
			,TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		--TESTING
		--SELECT * FROM bronze.erp_px_cat_G1V2
		SET @wholeEnd_time = GETDATE();
		PRINT 'TIME TAKEN TO LOAD BRONZE LAYER: ' + CAST(DATEDIFF(SECOND,@wholeStart_time,@wholeEnd_time) AS NVARCHAR) + ' seconds;'
	END TRY
	BEGIN CATCH
		PRINT '>> AN ERROR OCCURED ON LOADING! >>'
		PRINT 'ERROR MESSAGE: ' + CAST(ERROR_MESSAGE() AS NVARCHAR)
		PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR)
		PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR)
	END CATCH
END
GO
