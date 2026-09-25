
USE DataWarehouse

IF OBJECT_ID ('Silver.cre_cust_info','U') IS NOT NULL
  DROP TABLE Silver.cre_cust_info;

CREATE TABLE Silver.cre_cust_info(
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_material_status NVARCHAR(50),
cst_gender NVARCHAR(50),
cst_create_date DATE,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('Silver.crm_prd_info','U') IS NOT NULL
  DROP TABLE Silver.crm_prd_info;

CREATE TABLE Silver.crm_prd_info(
prd_id INT,
prd_cat NVARCHAR(50),
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost NVARCHAR(50),
prd_line NVARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('Silver.crm_sales_details','U') IS NOT NULL
  DROP TABLE Silver.crm_sales_details;

CREATE TABLE Silver.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT,
sls_price INT,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);
IF OBJECT_ID ('Silver.erp_cust_az12','U') IS NOT NULL
  DROP TABLE Silver.erp_cust_az12;

CREATE TABLE Silver.erp_cust_az12(
cust_cid NVARCHAR(50),
cust_bdate DATE,
cust_gen NVARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('Silver.erp_loc_a101','U') IS NOT NULL
  DROP TABLE Silver.erp_loc_a101;

CREATE TABLE Silver.erp_loc_a101(
loc_cid NVARCHAR(50),
loc_cntry NVARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('Silver.erp_px_cat_g1v2','U') IS NOT NULL
  DROP TABLE Silver.erp_px_cat_g1v2;

CREATE TABLE Silver.erp_px_cat_g1v2(
px_id NVARCHAR(50),
px_cat NVARCHAR(50),
px_subcat NVARCHAR(50),
px_maintenance NVARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);


EXEC Silver.load_silver
