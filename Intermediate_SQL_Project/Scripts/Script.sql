WITH sales_date AS (
SELECT
	customerkey,
	SUM(quantity*netprice*exchangerate) AS net_revenue
FROM 	
	sales s 
GROUP BY customerkey )

SELECT 
	
	AVG(s.net_revenue),
	AVG(COALESCE(s.net_revenue,0))
FROM customer c
LEFT JOIN sales_date s ON c.customerkey = s.customerkey

