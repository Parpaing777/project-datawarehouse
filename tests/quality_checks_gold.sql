SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,

	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master info for gender
		ELSE COALESCE(ca.gen, 'n/a')
	END AS gender
FROM silver.crm_cust_info ci 
LEFT JOIN silver.erp_cust_az12 ca 
ON		  ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON		  ci.cst_key = la.cid
ORDER BY 1, 2 


-- Check the two joins of product info and product category
-- Verify product keys are unique and no duplicates
SELECT prd_key, COUNT(*) FROM
(SELECT 
	pdi.prd_id,
	pdi.cat_id,
	pdi.prd_key,
	pdi.prd_nm,
	pdi.prd_cost,
	pdi.prd_line,
	pdi.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
FROM silver.crm_prd_info pdi
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON		  pdi.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Only active products
)t 
GROUP BY prd_key HAVING COUNT(*) > 1

SELECT * FROM gold.dim_products


-- Foreign key integrity check

SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL 


SELECT * FROM gold.fact_sales