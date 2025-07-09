/******************************************************************************************
 * Scenario 1: Compensation Analyst - Identify countries offering fully remote manager roles
 * paying more than $90,000 USD.
 ******************************************************************************************/

-- View all records (for inspection)
SELECT * FROM salary;

-- Identify distinct countries where fully remote managers earn above $90,000 USD
SELECT DISTINCT 
    company_location
FROM 
    salary
WHERE 
    job_title LIKE '%Manager%'
    AND salary_in_usd > 90000
    AND remote_ratio = 100;



/******************************************************************************************
 * Scenario 2: Talent Acquisition Specialist - Top 3 highest-paying part-time job titles 
 * in 2023 for companies with more than 50 employees.
 ******************************************************************************************/

SELECT 
    job_title, 
    ROUND(AVG(salary_in_usd), 2) AS average_salary
FROM 
    salary
WHERE 
    employment_type = 'PT'  -- Part-time positions
    AND company_size IN ('M', 'L')  -- Medium or Large companies (more than 50 employees)
    AND work_year = 2023
GROUP BY 
    job_title
ORDER BY 
    average_salary DESC
LIMIT 3;



/******************************************************************************************
 * Scenario 3: Data Scientist - Calculate percentage of fully remote employees 
 * earning above $100,000 USD to highlight high-paying remote positions.
 ******************************************************************************************/

SELECT
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM salary WHERE salary_in_usd > 100000), 2) AS percentage
FROM
    salary
WHERE
    remote_ratio = 100
    AND salary_in_usd > 100000;



/******************************************************************************************
 * Scenario 4: Data Analyst - Identify countries where entry-level average salaries 
 * exceed the global average for the same job title.
 ******************************************************************************************/

SELECT 
    t1.job_title,
    t2.company_location,
    t2.average_salary_per_country,
    t1.average_salary AS global_average_salary
FROM 
    (
        SELECT 
            job_title,
            AVG(salary_in_usd) AS average_salary
        FROM 
            salary
        GROUP BY 
            job_title
    ) AS t1
INNER JOIN
    (
        SELECT 
            company_location,
            job_title, 
            AVG(salary_in_usd) AS average_salary_per_country
        FROM 
            salary
        GROUP BY 
            company_location, job_title
    ) AS t2 
ON  
    t1.job_title = t2.job_title
WHERE 
    t2.average_salary_per_country > t1.average_salary;



/******************************************************************************************
 * Scenario 5: HR Consultancy - For each job title, find the country paying the 
 * maximum average salary (for candidate placement insights).
 ******************************************************************************************/

SELECT 
    job_title,
    company_location,
    average_salary
FROM 
    (
        SELECT 
            job_title,
            company_location,
            ROUND(AVG(salary_in_usd), 2) AS average_salary,
            DENSE_RANK() OVER (PARTITION BY job_title ORDER BY AVG(salary_in_usd) DESC) AS rank
        FROM 
            salary
        GROUP BY 
            job_title, company_location
    ) ranked_salaries
WHERE 
    rank = 1
ORDER BY 
    job_title;



/******************************************************************************************
 * Scenario 6: Business Consultant - Identify countries with consistently increasing 
 * average salaries over the past 3 years (2022, 2023, 2024).
 ******************************************************************************************/

WITH valid_countries AS (
    SELECT 
        company_location
    FROM 
        salary
    WHERE 
        work_year IN (2022, 2023, 2024)
    GROUP BY 
        company_location
    HAVING 
        COUNT(DISTINCT work_year) = 3
),
average_salaries AS (
    SELECT 
        company_location,
        work_year,
        ROUND(AVG(salary_in_usd), 2) AS average_salary
    FROM 
        salary
    WHERE 
        work_year IN (2022, 2023, 2024)
        AND company_location IN (SELECT company_location FROM valid_countries)
    GROUP BY 
        company_location, work_year
),
pivot AS (
    SELECT 
        company_location,
        MAX(CASE WHEN work_year = 2022 THEN average_salary END) AS avg_salary_2022,
        MAX(CASE WHEN work_year = 2023 THEN average_salary END) AS avg_salary_2023,
        MAX(CASE WHEN work_year = 2024 THEN average_salary END) AS avg_salary_2024
    FROM 
        average_salaries
    GROUP BY 
        company_location
)
SELECT 
    *,
    CASE 
        WHEN avg_salary_2023 > avg_salary_2022 AND avg_salary_2024 > avg_salary_2023 THEN 'Uniform Growth'
        ELSE 'Not Uniform'
    END AS growth_pattern
FROM 
    pivot;



/******************************************************************************************
 * Scenario 7: Workforce Strategist - Compare percentage of fully remote work 
 * by experience level between 2021 and 2024.
 ******************************************************************************************/

-- Calculate 2021 remote work percentages by experience level
WITH remote_2021 AS (
    SELECT 
        experience_level,
        COUNT(*) AS num_remote_2021
    FROM 
        salary
    WHERE 
        work_year = 2021
        AND remote_ratio = 100
    GROUP BY 
        experience_level
),
total_2021 AS (
    SELECT 
        experience_level,
        COUNT(*) AS total_employees_2021
    FROM 
        salary
    WHERE 
        work_year = 2021
    GROUP BY 
        experience_level
),
percent_2021 AS (
    SELECT 
        t1.experience_level,
        ROUND((t1.num_remote_2021 * 100.0) / t2.total_employees_2021, 2) AS percentage_2021
    FROM 
        remote_2021 t1
    JOIN 
        total_2021 t2 
    ON 
        t1.experience_level = t2.experience_level
),

-- Calculate 2024 remote work percentages by experience level
remote_2024 AS (
    SELECT 
        experience_level,
        COUNT(*) AS num_remote_2024
    FROM 
        salary
    WHERE 
        work_year = 2024
        AND remote_ratio = 100
    GROUP BY 
        experience_level
),
total_2024 AS (
    SELECT 
        experience_level,
        COUNT(*) AS total_employees_2024
    FROM 
        salary
    WHERE 
        work_year = 2024
    GROUP BY 
        experience_level
),
percent_2024 AS (
    SELECT 
        t1.experience_level,
        ROUND((t1.num_remote_2024 * 100.0) / t2.total_employees_2024, 2) AS percentage_2024
    FROM 
        remote_2024 t1
    JOIN 
        total_2024 t2 
    ON 
        t1.experience_level = t2.experience_level
)

-- Combine both years for comparison
SELECT 
    COALESCE(p21.experience_level, p24.experience_level) AS experience_level,
    p21.percentage_2021,
    p24.percentage_2024
FROM 
    percent_2021 p21
FULL OUTER JOIN 
    percent_2024 p24
ON 
    p21.experience_level = p24.experience_level
ORDER BY 
    experience_level;
