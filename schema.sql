-- Table: salary
-- Purpose: Stores salary information for employees across different job roles, companies, and locations.

CREATE TABLE salary (
    work_year INT,  -- The year the salary was recorded (e.g., 2024)
    
    experience_level VARCHAR(5),  -- Employee's experience level:
                                  -- EN = Entry-level
                                  -- MI = Mid-level
                                  -- SE = Senior-level
                                  -- EX = Executive-level
    
    employment_type VARCHAR(5),   -- Type of employment:
                                  -- FT = Full-time
                                  -- PT = Part-time
                                  -- CT = Contract
                                  -- FL = Freelance
    
    job_title VARCHAR(50),        -- The job title (e.g., Data Scientist, ML Engineer)
    
    salary INT,                   -- Annual salary amount in original currency
    
    salary_currency VARCHAR(10),  -- Currency of the salary (e.g., USD, EUR, INR)
    
    salary_in_usd INT,            -- Annual salary converted to USD for standardization
    
    employee_residence VARCHAR(10),  -- Country code of where the employee resides (ISO Alpha-2 or Alpha-3 codes, e.g., US, CA, IN)
    
    remote_ratio INT,             -- Percentage of remote work (0 = Onsite, 50 = Hybrid, 100 = Fully Remote)
    
    company_location VARCHAR(10), -- Country code where the company is located (ISO Alpha-2 or Alpha-3 codes)
    
    company_size VARCHAR(5)       -- Company size:
                                  -- S = Small (less than 50 employees)
                                  -- M = Medium (50-250 employees)
                                  -- L = Large (250+ employees)
);
