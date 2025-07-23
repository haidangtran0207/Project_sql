# Data Analyst Salary Insights — SQL-Based Job Market Analysis

This README presents a concise overview of my project exploring the Data Analyst job market through targeted SQL queries. It highlights key findings, expands on strategic insights, and provides recommendations for both job seekers and hiring teams.

---

## 📌 Project Overview

**Objective:** Uncover patterns in compensation, skill demand, and role optimization for Data Analysts by analyzing real-world job posting data.

**Inspiration:** Built upon concepts from Luke Barousse’s SQL course, leveraging PostgreSQL and VS Code to translate career questions into actionable queries.

**Dataset:** Thousands of enriched job postings including:

* Roles and titles
* Locations and remote status
* Salary ranges (annual averages)
* Required technical skills
* Company metadata

All SQL scripts live in the `Project_SQL/` folder for reference.

---

## 🛠 Tools & Environment

* **SQL & PostgreSQL**: Core querying, filtering, and aggregations
* **Visual Studio Code**: Editor for SQL scripts and Markdown
* **Git & GitHub**: Version control and sharing

---

## 🔍 Analysis & Key Findings

### 1. Top Paying Data Analyst Jobs

```sql
SELECT
  job_id,
  job_title,
  job_location,
  job_schedule_type,
  salary_year_avg,
  job_posted_date,
  name AS company_name
FROM job_postings_fact
LEFT JOIN company_dim USING (company_id)
WHERE job_title_short = 'Data Analyst'
  AND job_location = 'Anywhere'
  AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
```

**Findings:**

* Top salaries span **\$184K–\$650K**, heavily skewed by a handful of tech giants and specialized finance roles.
* Remote roles dominate the high end—employers like **Meta**, **SmartAsset**, and **AT\&T** lead.
* Job titles can mask distinct functions (e.g., Financial Analyst vs. Business Data Analyst).

> **Expanded Insight:**
>
> * The extreme salary outliers may reflect commission-based or bonus-heavy structures; consider filtering base vs. total comp in future.
> * A deeper look at industry sectors shows Financial Services roles trend higher than pure tech startups.

---

### 2. Skills Driving Highest Salaries

```sql
WITH top_paying_jobs AS (
SELECT  Job_id,
        job_title,
        company_dim.name AS company_name,
        salary_year_avg

FROM    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE   job_title_short = 'Data Analyst' AND
        job_location = 'Anywhere' AND
        salary_year_avg IS NOT null
ORDER BY salary_year_avg DESC
LIMIT 10
                        )    
SELECT  top_paying_jobs.*,
        skills_dim.skills
FROM top_paying_jobs      
INNER JOIN skills_job_dim ON top_paying_jobs.Job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
ORDER BY salary_year_avg DESC
;        
```

**Findings:**

* **SQL** appears in 8/10 roles—still table stakes.
* **Python**, **Tableau**, and emerging tools (**Snowflake**, **R**) surface in specialized roles.

> **Expanded Insight:**
>
> * Advanced cloud-data tools (e.g., Snowflake, Redshift) are gaining traction: mastering these can open premium roles.
> * Visualization skills (Tableau, Power BI) remain crucial for translating analysis to stakeholders.

---

### 3. Most In-Demand Skills (Remote Data Analyst)

```sql
SELECT  skills,

        COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact      
INNER JOIN skills_job_dim ON job_postings_fact.Job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE   job_title_short = 'Data Analyst' AND  
        job_work_from_home = true
GROUP BY skills
ORDER BY demand_count DESC
LIMIT 5
;
```

| Skill    | Demand Count |
| -------- | -----------: |
| SQL      |        7 291 |
| Excel    |        4 611 |
| Python   |        4 330 |
| Tableau  |        3 745 |
| Power BI |        2 609 |

> **Expanded Insight:**
>
> * Traditional skills (SQL, Excel) still top the list, but **Python** and **BI tools** are quickly closing the gap.
> * Job seekers should reinforce fundamentals before layering on advanced toolkits.

---

### 4. Salary by Skill

```sql
SELECT  skills,
        skills_dim.type,
        ROUND(AVG(salary_year_avg),1)  as salary_average
FROM job_postings_fact      
INNER JOIN skills_job_dim ON job_postings_fact.Job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE   
        job_title_short = 'Data Analyst' AND
        salary_year_avg IS NOT null
        --AND job_work_from_home = true
GROUP BY skills, skills_dim.type

ORDER BY salary_average DESC
LIMIT 10
```

| Skill         | Avg Salary |
| ------------- | ---------: |
| PySpark       |  \$208 172 |
| Bitbucket     |  \$189 155 |
| Couchbase     |  \$160 515 |
| Watson        |  \$160 515 |
| DataRobot     |  \$155 486 |
| GitLab        |  \$154 500 |
| Swift         |  \$153 750 |
| Jupyter       |  \$152 777 |
| Pandas        |  \$151 821 |
| Elasticsearch |  \$145 000 |

> **Expanded Insight:**
>
> * Skills tied to big data frameworks (PySpark) and MLOps/tooling (DataRobot, Watson) command the highest premiums.
> * There’s a strong correlation between emerging platform expertise and salary boosts—prioritize learning cloud-native analytics.

---

### 5. Optimal Skills to Learn

```sql
SELECT
  sd.skill_id,
  sd.skills,
  COUNT(*) AS demand_count,
  ROUND(AVG(jf.salary_year_avg), 0) AS avg_salary
FROM job_postings_fact jf
JOIN skills_job_dim sj USING (job_id)
JOIN skills_dim sd USING (skill_id)
WHERE jf.job_title_short = 'Data Analyst'
  AND jf.job_work_from_home = TRUE
  AND jf.salary_year_avg IS NOT NULL
GROUP BY sd.skill_id, sd.skills
HAVING COUNT(*) > 10
ORDER BY avg_salary DESC, demand_count DESC
LIMIT 10;
```

| Skills     | Demand | Avg Salary |
| ---------- | -----: | ---------: |
| Go         |     27 |  \$115 320 |
| Confluence |     11 |  \$114 210 |
| Hadoop     |     22 |  \$113 193 |
| Snowflake  |     37 |  \$112 948 |
| Azure      |     34 |  \$111 225 |
| BigQuery   |     13 |  \$109 654 |
| AWS        |     32 |  \$108 317 |
| Java       |     17 |  \$106 906 |
| SSIS       |     12 |  \$106 683 |
| Jira       |     20 |  \$104 918 |

> **Expanded Insight:**
>
> * **Cloud & engineering skillsets** (Snowflake, AWS, Azure) show balanced demand and salary—ideal leverages for career growth.
> * Lesser-known languages/tools (Go, SSIS) can also differentiate you in a crowded marketplace.

---

## 🚀 Recommendations

1. **Job Seekers**:

   * **Skill roadmap**: Start with **SQL + Excel**, then layer **Python**, **BI tools** (Tableau/Power BI), and finally **advanced cloud/data frameworks**.

2. **Hiring Teams**:

   * **Competitive offers**: Benchmark salaries against top market medians (e.g., \$150K+ for specialized roles).
   * **Talent pipeline**: Partner with training programs focused on cloud analytics and big data to build future-ready teams.

---

## 📈 Next Steps

* Drill into **industry-specific** salary trends (e.g., Finance vs. Tech).
* Segment by **geography** or **company size** for more granular benchmarks.
* Incorporate **bonus and equity** data to capture total compensation picture.

---

> *“Data drives decisions—knowing where the market values your skills is half the battle."*
