/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/



-- ====================
-- Table Validation: silver.crm_cust_info
-- Check for Nulls and duplicates 
SELECT 
cst_id, 
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Check for unwanted spaces in name fields
SELECT cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- Data standardization and consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT * FROM silver.crm_cust_info


-- ====================
-- Table Validation: silver.crm_prd_info

SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL


-- Check unwanted spaces
SELECT prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- NULLS or Negative numbers in prd cost
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0

-- Data consistiency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Start and end dates 
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt > prd_start_dt

SELECT *
FROM silver.crm_prd_info

-- CRM sales details
SELECT 
NULLIF(sls_due_dt,0) AS sls_due_dt
FROM silver.crm_sales_details
WHERE 
	sls_due_dt <= 0 
	OR LEN(sls_due_dt) != 8
	OR sls_due_dt > 20500101
	OR sls_due_dt < 19900101
	
-- CHECK DATE ORDERS
SELECT 
* 
FROM silver.crm_sales_details
WHERE 
	sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt OR sls_due_dt< sls_ship_dt


-- Check data consistency of sales, quantity and price
-- >> Sales = Quantity * Price
-- >> Values must not be null, zero, or Negative

SELECT DISTINCT 
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != (sls_quantity * sls_price)
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales,sls_quantity,sls_price

-- Test query 
SELECT DISTINCT 
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,

CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
	THEN  sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <= 0
	THEN sls_sales/ NULLIF(sls_quantity, 0)
	ELSE sls_price
END AS sls_price

FROM bronze.crm_sales_details
WHERE sls_sales != (sls_quantity * sls_price)
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales,sls_quantity,sls_price


SELECT * FROM silver.crm_sales_details

--====================================
-- ERP_cust_az12

-- CID standardization: Remove 'NAS' prefix if exists, and check for nulls or duplicates
SELECT 
	cid,
	CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4,LEN(CID))
		ELSE cid
	END AS cid,
	bdate,
	gen
FROM silver.erp_cust_az12

-- Check range for birthdates
SELECT 
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1920-01-01' OR bdate > GETDATE()

-- GENDER
SELECT DISTINCT 
gen,

CASE 
	WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	ELSE 'n/a'
END AS gen
FROM silver.erp_cust_az12

SELECT * FROM silver.erp_cust_az12

--=============================
-- ERP_loc_a101

SELECT 
REPLACE (cid, '-','') cid,
cntry
FROM bronze.erp_loc_a101
WHERE REPLACE (cid, '-','') NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)

SELECT
cst_key FROM silver.crm_cust_info
-- Check countries 

SELECT 
DISTINCT cntry 
FROM silver.erp_loc_a101
ORDER BY cntry

SELECT * FROM silver.erp_loc_a101

-- ===========================
-- ERP_px_cat_g1v2

-- CHECK for unwanted spaces in category fields

SELECT 
id,
cat,
subcat,
maintenance
FROM 
bronze.erp_px_cat_g1v2
WHERE  cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data standardization
SELECT DISTINCT 
maintenance
FROM bronze.erp_px_cat_g1v2