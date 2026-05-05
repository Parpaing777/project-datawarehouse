/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================

Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Important note:
    Before executing this script, ensure that the file paths in the `BULK INSERT` statements are updated to point to the correct locations of your CSV files.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '===========================';
		PRINT 'Loading Bronze Layer';
		PRINT '===========================';

		PRINT '---------------------------';
		PRINT 'Loading CRM Data';
		PRINT '---------------------------';

		SET @start_time = GETDATE();

		PRINT '>>Truncating Table : bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>>Inserting Data into : bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'path-to-files\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : ' +CAST( DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
		PRINT '>>-------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>>Truncating Table : bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>>Inserting Data into : bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'path-to-files\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : ' +CAST( DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
		PRINT '>>-------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table : bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>>Inserting Data into : bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'path-to-files\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : ' +CAST( DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
		PRINT '>>-------------------------------------';

		PRINT '---------------------------';
		PRINT 'Loading ERP Data';
		PRINT '---------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table : bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>>Inserting Data into : bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'path-to-files\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : ' +CAST( DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
		PRINT '>>-------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table : bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>>Inserting Data into : bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'path-to-files\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : ' +CAST( DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
		PRINT '>>-------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table : bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>>Inserting Data into : bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'path-to-files\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : ' +CAST( DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
		PRINT '>>-------------------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '===========================';
		PRINT 'Bronze Layer Load Completed';
		PRINT ' Total Duration :' + CAST( DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR)+ ' seconds';
		PRINT '===========================';
	END TRY

	BEGIN CATCH
	PRINT '=================================';
	PRINT 'ERROR OCCURED LOADING BRONZE LAYER'
	PRINT 'ERROR MESSAGE' + Error_Message();
	PRINT 'ERROR MESSAGE' + CAST(Error_number() AS NVARCHAR);
	PRINT 'ERROR STATE' + CAST(Error_State() AS NVARCHAR);
	PRINT '=================================';
	END CATCH
END