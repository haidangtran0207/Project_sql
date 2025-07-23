SELECT
	c.cohort_year,
	COUNT(DISTINCT customerkey) AS total_customers,
	SUM(total_net_revenue) AS total_revenue,
	SUM(total_net_revenue)/COUNT(DISTINCT customerkey) AS customer_revenue

FROM 
	cohort_analysis c
GROUP BY 
	c.cohort_year 