CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN
BEGIN TRY
   DECLARE @start_time DATETIME,@end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME;
    --Cleaning Bronze.cre_cust_info
    --Inserting into Silver layer
    	PRINT '===================================='
		PRINT 'Loading Data In Silver Layer'
		PRINT '===================================='

    PRINT'-------- Inserting clean data in Silver.cre_cust_info---------'
    SET @batch_start_time = GETDATE();
	SET @start_time = GETDATE();
    TRUNCATE TABLE Silver.cre_cust_info
    INSERT INTO Silver.cre_cust_info(
    cst_id ,
    cst_key,
    cst_firstname,
    cst_lastname ,
    cst_material_status,
    cst_gender ,
    cst_create_date
    )

    SELECT
      cst_id,cst_key,
      TRIM(cst_firstname) AS cst_firstname,
      TRIM(cst_lastname) AS cst_laastname,
      CASE
          WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
          WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
          ELSE 'n/a'
      END AS cst_material_status,
      CASE 
          WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'
          WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'
          ELSE 'n/a'
      END AS cst_gender,
      cst_create_date
      FROM(
         SELECT *,
            ROW_NUMBER()OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
         FROM Bronze.cre_cust_info
         WHERE cst_id IS NOT NULL
         )t
      WHERE flag_last = 1;
      SET @end_time = GETDATE();
	  PRINT 'loding time:' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + 'sec';
	  PRINT '------------------------------------'

      --Cleaning Bronze.crm_prd_info
      --Inserting into Silver layer

      PRINT'-------- Inserting clean data in Silver.crm_prd_info---------'
      SET @start_time = GETDATE();
    TRUNCATE TABLE Silver.crm_prd_info
      INSERT INTO Silver.crm_prd_info(
    prd_id,
    prd_cat,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
    )
      SELECT prd_id,
         REPLACE(SUBSTRING(prd_key , 1,5), '-','_') AS cat_id,
         SUBSTRING(prd_key , 7,len(prd_key)) AS prd_key,
         prd_nm,
         ISNULL (prd_cost,0) AS prd_cost,
         CASE UPPER(TRIM(prd_line))
             WHEN 'M' THEN 'Mountain'
             WHEN 'R' THEN 'Road'
             WHEN 'S' THEN 'Other Sales'
             WHEN 'T' THEN 'Touring'
             ELSE 'n/a'
         END AS prd_line,
         CAST (prd_start_dt AS date) AS prd_start_dt,
         DATEADD(DAY, -1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
       FROM Bronze.crm_prd_info;
         SET @end_time = GETDATE();
		PRINT 'loding time:' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + 'sec';
		PRINT '------------------------------------'

        --Cleaning Bronze.crm_sales_details
       --Inserting into Silver layer

     PRINT'-------- Inserting clean data in Silver.crm_sales_details---------'
     SET @start_time = GETDATE();
    TRUNCATE TABLE Silver.crm_sales_details
    INSERT INTO Silver.crm_sales_details(
    sls_ord_num ,
    sls_prd_key ,
    sls_cust_id ,
    sls_order_dt ,
    sls_ship_dt ,
    sls_due_dt ,
    sls_sales ,
    sls_quantity,
    sls_price 
    )
    SELECT sls_ord_num, sls_prd_key, sls_cust_id,
    CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) !=8 THEN NULL
         ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
    END AS sls_order_dt,
    CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) !=8 THEN NULL
         ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
    END AS sls_ship_dt,
    CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) !=8 THEN NULL
         ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
    END AS sls_due_dt,
    CASE WHEN sls_sales IS NULL or sls_sales <=0 OR sls_sales != sls_quantity*ABS(sls_price)
         THEN sls_quantity*ABS(sls_price)
         ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE WHEN sls_price IS NULL OR sls_price<=0
         THEN sls_sales/NULLIF(sls_quantity,0)
         ELSE sls_price
    END AS sls_price
    FROM Bronze.crm_sales_details

    SET @end_time = GETDATE();
		PRINT 'loding time:' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + 'sec';
		PRINT '------------------------------------'

        --Cleaning Bronze.erp_cust_info
       --Inserting into Silver layer

     PRINT'-------- Inserting clean data in Silver.erp_cust_az12---------'
     SET @start_time = GETDATE();
    TRUNCATE TABLE Silver.erp_cust_az12
       INSERT INTO Silver.erp_cust_az12(
       cust_cid,cust_bdate,cust_gen)

       SELECT 
       CASE WHEN cust_cid LIKE 'NAS%' THEN SUBSTRING(cust_cid , 4,LEN(cust_cid))
            ELSE cust_cid 
       END AS cust_cid,
       CASE WHEN cust_bdate > GETDATE() THEN NULL
            ELSE cust_bdate
       END AS cust_bdate,
       CASE WHEN UPPER(TRIM(cust_gen)) IN ('F','FEMALE') Then 'Female'
           WHEN UPPER(TRIM(cust_gen))  IN ('M','MALE') THEN 'Male'
           ELSE 'n/a'
       END AS cust_gen
       FROM Bronze.erp_cust_az12
       SET @end_time = GETDATE();
		PRINT 'loding time:' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + 'sec';
		PRINT '------------------------------------'

        --Cleaning Bronze.erp_loc_a101
       --Inserting into Silver layer

    PRINT'-------- Inserting clean data in Silver.erp_loc_a101---------'
    SET @start_time = GETDATE();
    TRUNCATE TABLE Silver.erp_loc_a101
       INSERT INTO Silver.erp_loc_a101(
       loc_cid,
       loc_cntry
       )

       SELECT 
       REPLACE(loc_cid , '-','') AS loc_cid,
       CASE WHEN TRIM(loc_cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(loc_cntry) IN ('US','USA') THEN 'United States'
            WHEN TRIM(loc_cntry) = '' OR loc_cntry IS NULL THEN 'n/a'
            ELSE TRIM(loc_cntry)
       END AS loc_cntry
       FROM Bronze.erp_loc_a101
       SET @end_time = GETDATE();
		PRINT 'loding time:' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + 'sec';
		PRINT '------------------------------------'

          --Cleaning Bronze.erp_cust_info
       --Inserting into Silver layer


       PRINT'-------- Inserting clean data in Silver.erp_px_cat_g1v2---------'
       SET @start_time = GETDATE();
    TRUNCATE TABLE Silver.erp_px_cat_g1v2   
       INSERT INTO Silver.erp_px_cat_g1v2(
       px_id,
       px_cat ,
       px_subcat,
       px_maintenance
       )

    SELECT 
    px_id, px_cat,px_subcat,px_maintenance
    FROM Bronze.erp_px_cat_g1v2
    SET @end_time = GETDATE();
		PRINT 'loding time:' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + 'sec';
		PRINT '------------------------------------'
  END TRY
  BEGIN CATCH
     PRINT'==============================='
		PRINT 'ERROR OCCURED WHILE LOADING'
		PRINT 'Error Massage:' + ERROR_MESSAGE();
		PRINT '=============================='
  END CATCH

END

