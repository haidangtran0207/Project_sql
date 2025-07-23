WITH customer_ltv AS (
SELECT
	customerkey,
	cleaned_name,
	SUM(total_net_revenue) AS total_ltv	
FROM
	cohort_analysis c 
GROUP BY
	c.customerkey,
	c.cleaned_name
), customer_segment AS(
	
SELECT 	
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentile,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentile

FROM customer_ltv
), segment_values AS (
SELECT 
	c.*,
	CASE
		WHEN c.total_ltv  < cs.ltv_25th_percentile  THEN '1- Low-Value'
		WHEN c.total_ltv  > cs.ltv_75th_percentile  THEN '3- High-Value'
		ELSE '2-Mid-Value'
	END AS customer_segment
	
FROM
	customer_ltv  c,
	customer_segment cs	

) 
SELECT 
	customer_segment,
	SUM(total_ltv) AS total_ltv ,
	COUNT(customerkey) AS customer_count,
	SUM(total_ltv)/COUNT(customerkey) AS avg_ltv
FROM 
	segment_values 
GROUP BY customer_segment 
ORDER BY total_ltv DESC;


SELECT orderkey, orderdate, productkey, unitprice, netprice, unitprice*netprice
FROM sales c;


