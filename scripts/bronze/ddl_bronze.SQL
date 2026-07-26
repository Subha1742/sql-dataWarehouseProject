/*
---------------------------------------------------------------------------------
CREATING THE DDL TABLES FOR THE DATA AVAILABLE IN THE SOURCE 
SYSTEMS - CRM AND ERP AND STORE IT IN THE SCHEMA - BRONZE: THE RAW FORM OF DATA
---------------------------------------------------------------------------------
*/

--crm data
--crm_cust_info
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info
(
	cst_id INT
	,cst_key NVARCHAR(50)
	,cst_firstname NVARCHAR(50)
	,cst_lastname NVARCHAR(50)
	,cst_marital_status NVARCHAR(50)
	,cst_gndr NVARCHAR(50)
	,cst_create_date DATE
)

--prd_info
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info
(
	prd_id INT
	,prd_key NVARCHAR(50)
	,prd_nm NVARCHAR(50)
	,prd_cost INT
	,prd_line NVARCHAR(50)
	,prd_start_dt DATE
	,prd_end_dt DATE
)

--sales_details
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details
(
	sls_ord_num NVARCHAR(50)
	,sls_prd_key NVARCHAR(50)
	,sls_cust_id INT
	,sls_order_dt INT
	,sls_ship_dt INT
	,sls_due_dt INT
	,sls_sales INT
	,sls_quantity INT
	,sls_price INT
)

--erp data
--erp_cust_az12
IF OBJECT_ID('bronze.erp_cust_AZ12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_AZ12;
CREATE TABLE bronze.erp_cust_AZ12
(
	CID NVARCHAR(50)
	,BDATE DATE
	,GEN NVARCHAR(50)
)

--erp_loca101
IF OBJECT_ID('bronze.erp_loc_A101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_A101;
CREATE TABLE bronze.erp_loc_A101
(
	CID NVARCHAR(50)
	,CNTRY NVARCHAR(50)
)

--erp_px_cat_g1v2
IF OBJECT_ID('bronze.erp_px_cat_G1V2', 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_G1V2;
CREATE TABLE bronze.erp_px_cat_G1V2
(
	ID NVARCHAR(50)
	,CAT NVARCHAR(50)
	,SUBCAT NVARCHAR(50)
	,MAINTENANCE NVARCHAR(50)
)
