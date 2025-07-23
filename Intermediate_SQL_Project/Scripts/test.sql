CREATE VIEW cohort_analysis AS
WITH customer_revenue AS(
SELECT 
	s.customerkey,
	s.orderdate,
	sum(s.quantity*s.netprice*s.exchangerate) AS total_net_revenue,
	COUNT(s.orderkey),
	c.countryfull,
	c.age,
	c.givenname,
	c.surname
FROM
	sales s
LEFT JOIN customer c ON s.customerkey = c.customerkey
GROUP BY 
	s.customerkey,
	s.orderdate,
	c.countryfull,
	c.age,
	c.givenname,
	c.surname)
SELECT 
	cr.*,
	EXTRACT(YEAR FROM MIN(cr.orderdate) OVER (PARTITION BY cr.customerkey)) AS cohort_year
FROM customer_revenue cr
	
;

ALTER VIEW cohort_analysis RENAME COLUMN count TO num_orders;

DROP VIEW cohort_analysis;

CREATE OR REPLACE VIEW cohort_analysis
AS WITH customer_revenue AS (
         SELECT s.customerkey,
            s.orderdate,
            sum(s.quantity::double precision * s.netprice * s.exchangerate) AS total_net_revenue,
            count(s.orderkey) AS num_orders,
            c.countryfull,
            c.age,
            c.givenname,
            c.surname
           FROM sales s
             LEFT JOIN customer c ON s.customerkey = c.customerkey
          GROUP BY s.customerkey, s.orderdate, c.countryfull, c.age, c.givenname, c.surname
        )
 SELECT customerkey,
    orderdate,
    total_net_revenue,
   	num_orders,
    countryfull,
    age,
    givenname,
    surname,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_revenue cr;