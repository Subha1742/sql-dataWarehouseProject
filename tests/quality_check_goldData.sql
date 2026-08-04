--TO CHECK IF THERE ARE ANY DUPLICATE ROWS CREATED BY JOININ GTHE TABLES AS THEYA RE IN LEFT JOIN.
--GROUPING BY CUSTID AND HAVING A CONDITION AFTER THAT GETS THE RECORDS WHERE THE COUNT IS GREATER THAN 1 i.e., DUPLICATE FOUND
SELECT cst_id,COUNT(*) FROM
(
	SELECT
		CI.cst_id
		,CI.cst_key
		,CI.cst_firstname
		,CI.cst_lastname
		--,CI.cst_gndr
		,CASE WHEN CI.cst_gndr <> 'N/A' THEN UPPER(CI.cst_gndr)
			   ELSE COALESCE(UPPER(CA.GEN),'N/A')
		 END AS GENDER
		,CI.cst_marital_status
		,CI.cst_create_date
		,CA.BDATE
		--,CA.GEN
		,LA.CNTRY
	FROM
	silver.crm_cust_info CI
	LEFT JOIN silver.erp_cust_AZ12 CA
		ON CI.cst_key = CA.CID
	LEFT JOIN silver.erp_loc_A101 LA
		ON CI.cst_key = LA.CID
)T
GROUP BY cst_id
HAVING COUNT(*) > 1

--GIVING PRECEDENCE TO CRM TABLES TO GET THE GENDER DETAILS
SELECT DISTINCT
	CI.cst_gndr
	,CA.GEN
	,CASE WHEN CI.cst_gndr <> 'N/A' THEN UPPER(CI.cst_gndr)
		  ELSE COALESCE(UPPER(CA.GEN),'N/A')
	 END AS NEW_GEN
FROM
silver.crm_cust_info CI
LEFT JOIN silver.erp_cust_AZ12 CA
	ON CI.cst_key = CA.CID
LEFT JOIN silver.erp_loc_A101 LA
	ON CI.cst_key = LA.CID
ORDER BY 1,2

--CHECK DIMENSION_CUSTOMERS ONCE AFTER IT IS CREATED
SELECT distinct gender FROM gold.dim_customers


SELECT PRD_KEY, COUNT(*) FROM
(
SELECT
	PI.prd_id
	,PI.cat_id
	,PI.prd_key
	,PI.prd_nm
	,PI.prd_cost
	,PI.prd_line
	,PI.prd_start_dt
	,PX.CAT
	,PX.SUBCAT
	,PX.MAINTENANCE
FROM
silver.crm_prd_info PI
LEFT JOIN silver.erp_px_cat_G1V2 PX
	ON PI.cat_id = PX.ID
WHERE PI.prd_end_dt IS NULL --TO FILTER ONLY THE CURRENT DATA AS IT CONTAINS HISTORICAL DATA.
)T
GROUP BY prd_key
HAVING COUNT(*) > 1

SELECT * FROM gold.dim_products

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

select * from gold.fact_sales s
left join gold.dim_customers c
on s.customer_key = c.customer_key
--where c.customer_key is null -- any customerkey available without a match with sales fact
left join gold.dim_products p
on s.product_key = p.product_key
where p.product_key is null -- any productkey available without a match with sales fact
