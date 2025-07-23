# Intermediate SQL – Sales Analysis

## Overview  
This project examines customer behavior, retention, and lifetime value (LTV) for an e‑commerce business. The goal is to surface actionable insights that boost customer loyalty, optimize marketing spend, and drive sustainable revenue growth.

## Key Questions  
1. **Customer Segmentation:** Which customers contribute the most to revenue, and how concentrated is that value?  
2. **Cohort Analysis:** How does revenue per customer evolve for different acquisition cohorts over time?  
3. **Retention Analysis:** Who is at greatest risk of churning, and what levers can we use to re‑engage them?

---

## Analysis Steps & Expanded Findings

### 1. Customer Segmentation  
- **Approach:** Divide our customer base into three LTV tiers (High, Mid, Low).  
- **SQL:** [`1_customer_segmentation.sql`](/Intermediate_SQL_Project/1_customer_segmentation.sql) 

```sql
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



```
- **Chart:**  
  ![1_customer_segmentation](/Intermediate_SQL_Project/images/1_customer_segmentation.png)

#### Key Findings  
- **High‑Value (top 25% of customers)**  
  - Generates **66%** of overall revenue (≈\$135.4 M).  
  - **Average spend** per customer is ~\$10.9 K, more than **30×** that of the low tier.  
- **Mid‑Value (middle 50%)**  
  - Contributes **32%** of revenue (≈\$66.6 M).  
  - **Average spend** ~\$2.7 K—suggests a healthy base but limited upsell to premium offerings.  
- **Low‑Value (bottom 25%)**  
  - Accounts for only **2%** of revenue (≈\$4.3 M).  
  - **Average spend** ~\$350—likely price-sensitive and infrequent purchasers.

 **Deep Insight:** The revenue distribution follows a classic Pareto pattern—≈25% of customers drive two‑thirds of revenue. This extreme concentration means small shifts in VIP behavior can have outsized impact on the P&L. Conversely, the vast “long tail” of low‑value customers represents an untapped growth opportunity if re‑engaged effectively.

#### Additional Recommendations  
- **VIP Loyalty Program:** Institute tiered perks (free shipping, early access) for the top 25%—even a 5% uplift in their repeat rate could add \$6–7 M annually.  
- **Mid‑Tier Upsells:** Bundle or cross‑sell complementary product lines to lift average order value from \$2.7 K toward the \$5 K+ range.  
- **Low‑Tier Nurturing:** Deploy automated win‑back emails, limited‑time coupons, and micro‑loyalty incentives (points, badges) to activate dormant buyers.

---

### 2. Cohort Revenue Trends  
- **Approach:** Track per‑customer revenue across cohorts defined by first purchase year.  
- **SQL:** [`2_cohort_analysis.sql`](/Intermediate_SQL_Project/2_cohort_analysis.sql)
```sql
SELECT
	c.cohort_year,
	COUNT(DISTINCT customerkey) AS total_customers,
	SUM(total_net_revenue) AS total_revenue,
	SUM(total_net_revenue)/COUNT(DISTINCT customerkey) AS customer_revenue

FROM 
	cohort_analysis c
GROUP BY 
	c.cohort_year 
```  
- **Chart:**  
  <img src="images/2_cohort_analysis.png" width="50%" alt="Cohort Analysis">

#### Key Findings  
- **Declining Revenue per Capita:** Newer cohorts (2022–2024) deliver **20–30% lower** revenue per customer than cohorts from 2016–2018.  
- **Base‑Driven Growth:** Overall revenue has grown year‑over‑year, but this is purely volume‑driven—not quality‑driven.  
- **Acquisition Dip in 2023:** We saw a **10% drop** in net new customer adds in 2023, compounding the shift toward lower‑value cohorts.

> **Deep Insight:** A growing customer count can mask erosion in individual customer value. If unchecked, the business risks a “hollow growth” scenario: rising headline revenue but shrinking margins and engagement. This trend often precedes profit stagnation and signals a need to revisit acquisition channels (e.g., over‑relying on broad paid ads versus high‑intent referrals).

#### Additional Recommendations  
- **Channel Effectiveness Audit:** Compare LTV by acquisition source—shift budget toward channels delivering higher‑value cohorts (e.g., organic search, referral partners).  
- **Onboarding Optimization:** Implement tailored onboarding flows (welcome series, product tutorials) for new cohorts to jump‑start their lifetime spend.  
- **Subscription & Bundles:** Introduce subscription plans or product bundles specifically for newer cohorts to boost initial revenue and lock in longer‑term value.

---

### 3. Retention & Churn Risk  
- **Approach:** Identify at‑risk customers by tracking recency of last purchase and churn cohorts.  
- **SQL:** [`3_retention_analysis.sql`](/Intermediate_SQL_Project/3_retention_analysis.sql)  
```sql
WITH customer_last_purchase AS (
	SELECT
		customerkey,
		cleaned_name,
		orderdate,
		ROW_NUMBER() OVER (PARTITION BY customerkey ORDER BY orderdate DESC) AS rn,
		first_purchase_date,
		cohort_year
	FROM
		cohort_analysis
), churned_customers AS (
	SELECT
		customerkey,
		cleaned_name,
		orderdate AS last_purchase_date,
		CASE
			WHEN orderdate < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months' THEN 'Churned'
			ELSE 'Active'
		END AS customer_status,
		cohort_year
	FROM customer_last_purchase 
	WHERE rn = 1
		AND first_purchase_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months'
)
SELECT
	cohort_year,
	customer_status,
	COUNT(customerkey) AS num_customers,
	SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year) AS total_customers,
	ROUND(COUNT(customerkey) / SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year), 2) AS status_percentage
FROM churned_customers 
GROUP BY cohort_year, customer_status
```
- **Chart:**  
  <img src="images/3_customer_churn_cohort_year.png" width="50%" alt="Churn by Cohort">

#### Key Findings  
- **High Base Churn:** Nearly **90%** of each cohort has churned by Year 2–3—only **10%** remain active.  
- **Uniform Churn Curve:** All cohorts, old and new, follow a similar steep decline in the first 12 months—this indicates systemic issues rather than cohort‑specific factors.  
- **Stagnant Retention Rates:** Despite product updates and marketing efforts, retention has remained flat at ~8–10% for the last five years.

> **Deep Insight:** When retention curves are virtually identical across cohorts, it often means friction points exist in the product or post‑purchase experience (e.g., lack of ongoing value, poor customer support, or unclear repeat purchase incentives). Addressing these root‑cause issues can shift the entire retention curve upward.

#### Additional Recommendations  
- **Churn Prediction Model:** Use behavioral and transactional signals (time since last purchase, support tickets, site engagement) to build a real‑time churn risk score.  
- **Personalized Interventions:** Trigger automated, highly personalized offers or content when a customer’s risk score crosses a threshold (e.g., 30 days post‑last order).  
- **Feedback Loop:** Solicit in‑product or post‑purchase feedback from soon‑to‑churn customers to diagnose and remedy pain points—feed learnings back into product development and support.

---

## Strategic Takeaways

1. **Revenue Concentration & Upside**  
   - The top 25% of customers drive two‑thirds of revenue. Small improvements among VIPs yield big returns.

2. **Quality over Quantity**  
   - Growth driven by customer count masks declining per‑customer value. Prioritize high‑LTV channels and cohorts.

3. **Retention as a Leverage Point**  
   - Systemic retention issues require product‑experience and lifecycle marketing fixes. Even a 1 pp increase in retention can compound to significant revenue gains over time.

---

## Technical Stack  
- **Database:** PostgreSQL  
- **Editor:** DBeaver, Visual Studio Code
- **DB Management:** DBeaver, pgAdmin  
- **Reporting:** ChatGPT for visualization  

---