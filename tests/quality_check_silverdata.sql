/*

This script checks for accuracy, data consistency and standardisation of data across the silver schema:
Null or duplication
Unwanted spaced in the string fields
Invalid Date range and date orders
Data consistency and standardisation of related fields

*/

SELECT * FROM bronze.CRM_CUST_INFO WHERE CST_ID = 29466

--QUERY TO IDENTIFY ISSUE RECORDS
WITH CTE_ISSUERECORDS AS(
SELECT 
DISTINCT CST_ID
FROM silver.CRM_CUST_INFO
GROUP BY CST_ID
HAVING COUNT(*) >1 OR CST_ID IS NULL
)

SELECT 
DISTINCT prd_id
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) >1 OR prd_id IS NULL

--QUERYING THE RECORDS WITH ISSUE IN STRING FIELDS
SELECT * FROM silver.CRM_CUST_INFO
WHERE cst_firstname != TRIM(cst_firstname)

SELECT * FROM silver.CRM_CUST_INFO
WHERE cst_lastname != TRIM(cst_lastname)

SELECT * FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--CHECK IF THE NUMBER FIELD HAVE ANY NEGATIVES OR NULLS

SELECT * FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

SELECT * FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--QUERYING THE LOW CARDINAL FIELDS FOR DATA CONSISTENCY AND STANDARDISATION
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info

SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info

SELECT DISTINCT prd_line FROM silver.crm_prd_info

select * from silver.crm_prd_info where prd_end_dt < prd_start_dt

--==========================================================================================================
--crm_prd_info
--RANKING THE ISSUE RECORDS BY THE LATEST CREATED DATE
SELECT
*,LEAD(DATEADD(DAY,-1,prd_start_dt)) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS TESTCOL
FROM
bronze.crm_prd_info
where prd_key in ('AC-HE-HL-U509-R','AC-HE-HL-U509')


SELECT prd_id
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

  select * from silver.crm_prd_info

  --================================================================================================================
  --crm_sales_details
  SELECT
       [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
      ,CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
            ELSE CAST(CAST([sls_order_dt] AS nvarchar)AS date) END AS sls_order_dt
      ,CAST(CAST([sls_ship_dt] AS nvarchar)AS date) sls_ship_dt
      ,CAST(CAST([sls_due_dt] AS nvarchar)AS date) sls_due_dt
      ,CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != ABS(sls_price) * sls_quantity THEN ABS(sls_price) * sls_quantity
            ELSE sls_sales
            END AS sls_sales
      ,[sls_quantity]
      ,CASE WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity,0)
            ELSE sls_price
            END AS sls_price
  FROM [DATAWAREHOUSE].[bronze].[crm_sales_details]

  SELECT * FROM silver.[crm_sales_details]
WHERE [sls_prd_key] != TRIM([sls_prd_key])

SELECT * FROM SILVER.crm_sales_details WHERE LEN(sls_ship_dt) <8
              
SELECT * FROM SILVER.crm_sales_details WHERE sls_due_dt = 0
              
SELECT * FROM SILVER.crm_sales_details WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


  SELECT * FROM silver.[crm_sales_details] WHERE sls_sales < 0 OR sls_sales != sls_quantity*sls_price OR sls_sales IS NULL
  OR sls_price <= 0 OR sls_price IS NULL OR sls_quantity <= 0 OR sls_quantity IS NULL

    SELECT * FROM silver.[crm_sales_details] WHERE sls_price <= 0 OR sls_price IS NULL

      SELECT * FROM silver.[crm_sales_details] WHERE sls_quantity <= 0 OR sls_quantity IS NULL

        SELECT * FROM silver.[crm_sales_details]

--===============================================================================================================
--ERP_CUST_AZ12
SELECT    
     CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
     ELSE CID END AS CID
    ,CASE WHEN BDATE > GETDATE() THEN NULL
          ELSE BDATE END AS BDATE
    ,CASE WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
          WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
          ELSE 'N/A' END AS GEN
FROM bronze.erp_cust_AZ12

SELECT * FROM silver.erp_cust_AZ12 WHERE BDATE < '1924-01-01' OR BDATE > GETDATE()

SELECT DISTINCT GEN FROM silver.erp_cust_AZ12

SELECT * FROM silver.erp_cust_AZ12

--============================================================================================================
--erp_loc_A101

SELECT 
 TRIM(REPLACE(CID,'-','')) AS CID
,CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
      WHEN TRIM(CNTRY) IN ('US','USA') THEN 'United States'
      WHEN TRIM(CNTRY) = '' OR TRIM(CNTRY) IS NULL THEN 'N/A'
      ELSE TRIM(CNTRY) 
      END AS CNTRY
FROM bronze.erp_loc_A101
WHERE TRIM(REPLACE(CID,'-','')) NOT IN (SELECT cst_key FROM silver.crm_cust_info)

SELECT TOP 10 * FROM silver.crm_cust_info
ORDER BY cst_key 

SELECT DISTINCT CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
      WHEN TRIM(CNTRY) IN ('US','USA') THEN 'United States'
      WHEN TRIM(CNTRY) = '' OR TRIM(CNTRY) IS NULL THEN 'N/A'
      ELSE TRIM(CNTRY) 
      END AS CNTRY FROM silver.erp_loc_A101 WHERE CNTRY IS NULL

SELECT * FROM silver.erp_loc_A101 WHERE CID NOT IN (SELECT cst_key FROM silver.crm_cust_info)

--=========================================================================================================
--erp_px_cat_G1V2
SELECT [ID]
      ,[CAT]
      ,[SUBCAT]
      ,[MAINTENANCE]
      --,[dwh_create_date]
  FROM bronze.[erp_px_cat_G1V2] where id not in (
  select distinct cat_id from silver.crm_prd_info)

  select cat from silver.[erp_px_cat_G1V2] where cat <> TRIM(CAT)

  select SUBCAT from silver.[erp_px_cat_G1V2] where SUBCAT <> TRIM(SUBCAT)

    select distinct MAINTENANCE from silver.[erp_px_cat_G1V2] where MAINTENANCE <> trim(MAINTENANCE)

    select * from silver.erp_px_cat_G1V2
