/*
-----------------------------------------------------------------------------------------
THIS PROC WRAPS THE CODE THAT LOAD THE DATA INTO THE TABLES THAT ARE CREATED IN THE SILVER
SCHEMA. AS IT IS A FULL LOAD, IT FIRST TRUNCATES THE DATA THAT IS CURRENLTY IN THE TABLE 
AND THE INSERT THE DATA INTO THEM.
-----------------------------------------------------------------------------------------
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    PRINT '======================================================';
	PRINT 'Loading Silver Layer';
	PRINT '======================================================';

	PRINT '------------------------------------------------------';
	PRINT 'LOAD CRM TABLES';
	PRINT '------------------------------------------------------';
    DECLARE @startTime DATETIME, @endTime DATETIME, @wholeStart_time DATETIME, @wholeEnd_time DATETIME
	SET @wholeStart_time = GETDATE();
    BEGIN TRY
        --EXEC silver.load_silver
        --SILVER.CRM_CUST_INFO
        SET @startTime = GETDATE(); 
        PRINT 'Truncating silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT 'Inserting data into silver.crm_cust_info'
        INSERT INTO silver.crm_cust_info
        (
	        cst_id
	        ,cst_key
	        ,cst_firstname
	        ,cst_lastname
	        ,cst_marital_status
	        ,cst_gndr
	        ,cst_create_date
        )
        SELECT 
        cst_id
        ,cst_key
        ,TRIM(cst_firstname) cst_firstname
        ,TRIM(cst_lastname) cst_lastname
        ,CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'SINGLE'
	          WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'MARRIED'
	          ELSE 'N/A' END AS cst_marital_status
        ,CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'FEMALE'
	          WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE'
	          ELSE 'N/A' END AS cst_gndr
        ,cst_create_date
        FROM
        (
        SELECT *,
        ROW_NUMBER() OVER(PARTITION BY CST_ID ORDER BY CST_CREATE_DATE DESC) LATEST_RECORD
        FROM bronze.CRM_CUST_INFO
		WHERE cst_id IS NOT NULL
        ) T WHERE LATEST_RECORD = 1

        SET @endTime = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@startTime,@endTime) AS NVARCHAR) + ' seconds';

        --SILVER.CRM_PROD_INFO
        SET @startTime = GETDATE();
        PRINT 'Truncating silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT 'Inserting data into silver.crm_prd_info'
        INSERT INTO silver.crm_prd_info
        (
             prd_id
            ,cat_id
            ,prd_key
            ,prd_nm
            ,prd_cost
            ,prd_line
            ,prd_start_dt
            ,prd_end_dt
        )
        SELECT 
            prd_id
            ,REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id
            ,SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key
            ,prd_nm
            ,ISNULL(prd_cost,0) prd_cost
            ,CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'N/A' END AS prd_line
            ,prd_start_dt
            ,LEAD(DATEADD(DAY,-1,prd_start_dt)) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS TESTCOL
          FROM bronze.crm_prd_info

          SET @endTime = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@startTime,@endTime) AS NVARCHAR) + ' seconds';

          --SILVER.CRM_SALES_DETAILS INFO
          SET @startTime = GETDATE();
        PRINT 'Truncating silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT 'Inserting data into silver.crm_sales_details'
          INSERT INTO silver.crm_sales_details
          (
             sls_ord_num
            ,sls_prd_key
            ,sls_cust_id
            ,sls_order_dt
            ,sls_ship_dt
            ,sls_due_dt
            ,sls_sales
            ,sls_quantity
            ,sls_price
          )
            SELECT
               sls_ord_num
              ,sls_prd_key
              ,sls_cust_id
              ,CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                    ELSE CAST(CAST([sls_order_dt] AS varchar) AS date) END AS sls_order_dt
              ,CASE WHEN [sls_ship_dt] = 0 OR LEN([sls_ship_dt]) != 8 THEN NULL
                    ELSE CAST(CAST([sls_ship_dt] AS varchar) AS date) END AS sls_ship_dt
              ,CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                    ELSE CAST(CAST([sls_due_dt] AS varchar) AS date) END AS sls_due_dt
              ,CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != ABS(sls_price) * sls_quantity THEN ABS(sls_price) * sls_quantity
                    ELSE sls_sales
                    END AS sls_sales
              ,sls_quantity
              ,CASE WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity,0)
                    ELSE sls_price
                    END AS sls_price
          FROM bronze.crm_sales_details

          SET @endTime = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@startTime,@endTime) AS NVARCHAR) + ' seconds';
  
        PRINT '------------------------------------------------------';
	    PRINT 'LOAD ERP TABLES';
	    PRINT '------------------------------------------------------';

        --SILVER.ERP_CUST_AZ12
        SET @startTime = GETDATE();
        PRINT 'Truncating silver.erp_cust_AZ12';
        TRUNCATE TABLE silver.erp_cust_AZ12;
        PRINT 'Inserting data into silver.erp_cust_AZ12'
        INSERT INTO silver.erp_cust_AZ12
        (
        CID
        ,BDATE
        ,GEN
        )
        SELECT    
            CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
            ELSE CID END AS CID
        ,CASE WHEN BDATE > GETDATE() THEN NULL
                ELSE BDATE END AS BDATE
        ,CASE WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
                WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
                ELSE 'N/A' END AS GEN
        FROM bronze.erp_cust_AZ12

        SET @endTime = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@startTime,@endTime) AS NVARCHAR) + ' seconds';


        --SILVER.ERP_LOC_A101
        SET @startTime = GETDATE();
        PRINT 'Truncating silver.erp_loc_A101';
        TRUNCATE TABLE silver.erp_loc_A101;
        PRINT 'Inserting data into silver.erp_loc_A101'
        INSERT INTO silver.erp_loc_A101
        (
            CID
            ,CNTRY
        )
        SELECT 
            TRIM(REPLACE(CID,'-','')) AS CID
        ,CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
                WHEN TRIM(CNTRY) IN ('US','USA') THEN 'United States'
                WHEN TRIM(CNTRY) = '' OR TRIM(CNTRY) IS NULL THEN 'N/A'
                ELSE TRIM(CNTRY) 
                END AS CNTRY
        FROM bronze.erp_loc_A101

        SET @endTime = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@startTime,@endTime) AS NVARCHAR) + ' seconds';

        --===================================================================================================
        --silver.erp_px_cat_G1V2
        SET @startTime = GETDATE();
        PRINT 'Truncating silver.erp_px_cat_G1V2';
        TRUNCATE TABLE silver.erp_px_cat_G1V2;
        PRINT 'Inserting data into silver.erp_px_cat_G1V2'
        INSERT INTO silver.erp_px_cat_G1V2
        (
            [ID]
            ,[CAT]
            ,[SUBCAT]
            ,[MAINTENANCE]
        )
        SELECT [ID]
              ,[CAT]
              ,[SUBCAT]
              ,[MAINTENANCE]
          FROM bronze.[erp_px_cat_G1V2]
        
        SET @endTime = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@startTime,@endTime) AS NVARCHAR) + ' seconds';

        SET @wholeEnd_time = GETDATE();
        PRINT 'TOTAL LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@wholeStart_time,@wholeEnd_time) AS NVARCHAR) + ' seconds';
    END TRY
    BEGIN CATCH
        PRINT '>> AN ERROR OCCURED ON LOADING! >>'
		PRINT 'ERROR MESSAGE: ' + CAST(ERROR_MESSAGE() AS NVARCHAR)
		PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR)
		PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR)
    END CATCH
END
GO
