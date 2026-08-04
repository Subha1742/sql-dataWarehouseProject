/*
DDL script for GOLD Layer.
This script creates views for the Gold layer using STAR Schema.

The data in gold layer flows from silver layer tables with further enriched, cleaned, standardised business-ready dataset.
*/
PRINT 'Dropping gold.dim_customers if exists...';
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
  DROP VIEW gold.dim_customers
  PRINT 'Dropped gold.dim_customers';
GO;

PRINT 'Creating dim_customers';
CREATE OR ALTER VIEW gold.dim_customers AS
	SELECT
		ROW_NUMBER() OVER(ORDER BY CI.cst_id) customer_key
		,CI.cst_id customer_id
		,CI.cst_key customer_number
		,CI.cst_firstname first_name
		,CI.cst_lastname last_name
		,LA.CNTRY country
		,CASE WHEN CI.cst_gndr <> 'N/A' THEN UPPER(CI.cst_gndr)
			  ELSE COALESCE(UPPER(CA.GEN),'N/A')
		 END AS gender
		,CI.cst_marital_status marital_status
		,CA.BDATE birth_date
		,CI.cst_create_date create_date
	FROM
	silver.crm_cust_info CI
	LEFT JOIN silver.erp_cust_AZ12 CA
		ON CI.cst_key = CA.CID
	LEFT JOIN silver.erp_loc_A101 LA
		ON CI.cst_key = LA.CID
GO

PRINT 'Dropping gold.dim_products if exists...';
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
  DROP VIEW gold.dim_products
  PRINT 'Dropped gold.dim_products';
GO;

PRINT 'Creating dim_products';
CREATE OR ALTER VIEW gold.dim_products AS
	SELECT
		ROW_NUMBER() OVER(ORDER BY PI.PRD_START_DT,PI.PRD_KEY) product_key
		,PI.prd_id product_id
		,PI.prd_key product_number
		,PI.prd_nm product_name
		,PI.cat_id category_id
		,PX.CAT category
		,PX.SUBCAT subcategory
		,PX.MAINTENANCE maintenance
		,PI.prd_cost cost
		,PI.prd_line product_line
		,PI.prd_start_dt start_date
	FROM
	silver.crm_prd_info PI
	LEFT JOIN silver.erp_px_cat_G1V2 PX
		ON PI.cat_id = PX.ID
	WHERE PI.prd_end_dt IS NULL --TO FILTER ONLY THE CURRENT DATA AS IT CONTAINS HISTORICAL DATA.
GO

PRINT 'Dropping gold.fact_sales if exists...';
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
  DROP VIEW gold.fact_sales
  PRINT 'Dropped gold.fact_sales';
GO;

PRINT 'Creating fact_sales';
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT 
	SD.sls_ord_num order_number
    ,PI.product_key 
    ,CU.customer_key
    ,SD.sls_order_dt order_date
    ,SD.sls_ship_dt shipping_date
    ,SD.sls_due_dt due_date
    ,SD.sls_sales sales_amount
    ,SD.sls_quantity quantity
    ,SD.sls_price price
FROM
silver.crm_sales_details SD
LEFT JOIN gold.dim_products PI
    ON SD.sls_prd_key = PI.product_number
LEFT JOIN gold.dim_customers CU
    ON SD.sls_cust_id = CU.customer_id
