
--- After joining tables, check if any duplicates where introduced by the join logic

Select Cst_id , Count(*)
From
(
Select ci.cst_id,
ci.cst_key,
ci.cst_firtname,
ci.cst_lastname,
ci.cst_marital_status,
ci.cst_gender,
ci.cst_create_date,
ca.bdate,
ca.gen,
la.CNTRY
From Silver.crm_cust_info ci
Left Join Silver.erp_Cust_AZ12 as ca 
on ci.cst_key = ca.cid
Left Join silver.erp_Loc_A101 as la
on ci.cst_key = la.CID) t
Group by cst_id
Having count(*) > 1 or cst_id is null;


--- Check for matching of info in the 2 gen columns
Select Distinct
	ci.cst_gender,
	ca.gen
From Silver.crm_cust_info ci
	Left Join Silver.erp_Cust_AZ12 as ca 
on ci.cst_key = ca.cid
	Left Join silver.erp_Loc_A101 as la
on ci.cst_key = la.CID
Order by 1,2;


--- Correction of missing values and non matching values in the gender column
Select Distinct
	ci.cst_gender,
	ca.gen,
	Case When ci.cst_gender <> 'N/A' Then ci.cst_gender --- CRM is the master for gender information
	Else Coalesce(ca.gen,'N/A')  --- If ca.gen is NULL convert it to N/A
	End AS Cleaned_Gender

From Silver.crm_cust_info ci
	Left Join Silver.erp_Cust_AZ12 as ca 
on ci.cst_key = ca.cid
	Left Join silver.erp_Loc_A101 as la
on ci.cst_key = la.CID
Order by 1,2;

--- Check for duplicates in product key
Select prd_key , count(*)
from
(Select	pr.prd_id,
		pr.cat_id,
		pr.prd_key,
		pr.prd_nm,
		pr.prd_cost,
		pr.prd_line,
		pr.prd_start_dt,
		pc.cat,
		pc.subcat,
		pc.maintenance
From silver.crm_prod_info As pr
Left Join silver.erp_PX_Cat_G1V2 As pc
On pr.cat_id = pc.id
Where Prd_end_dt is Null)t --- Filtering all historical data;
Group By prd_key
Having count(*) > 1


--- Check if deminsion tables can successfully join to the fact table

 Select *
 From gold.fact_sales As fc
 Left Join gold.dim_product As dp
 On fc.Product_key = dp.product_key
 Left Join gold.dim_customers AS dc
 On fc.customer_key = dc.customer_key

---- Foriegn key intergrity
 Select *
 From gold.fact_sales As fc
 
 Left Join gold.dim_customers AS dc
 On fc.customer_key = dc.customer_key
 Where fc.customer_key is null
