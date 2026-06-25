-- =============================================================================
--  IBM HR EMPLOYEE ATTRITION  |  SQL ANALYSIS
--  Dataset  : 1,470 employees  |  35 columns  |  Overall attrition: 16.1%
-- =============================================================================


-- =============================================================================
--  TABLE DATA TYPE SETUP
-- =============================================================================
Select * from IBM_Employee_Attrition
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN Age INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN DailyRate INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN DistanceFromHome INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN Education INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN EmployeeCount INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN EmployeeNumber INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN EnvironmentSatisfaction INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN HourlyRate INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN JobInvolvement INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN JobLevel INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN JobSatisfaction INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN MonthlyIncome INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN MonthlyRate INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN NumCompaniesWorked INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN PercentSalaryHike INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN PerformanceRating INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN RelationshipSatisfaction INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN StandardHours INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN StockOptionLevel INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN TotalWorkingYears INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN TrainingTimesLastYear INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN WorkLifeBalance INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN YearsAtCompany INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN YearsInCurrentRole INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN YearsSinceLastPromotion INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN YearsWithCurrManager INT;
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN Attrition NVARCHAR(10);
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN BusinessTravel NVARCHAR(50);
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN Department NVARCHAR(50);
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN EducationField NVARCHAR(50);
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN Gender NVARCHAR(10);
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN JobRole NVARCHAR(50);
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN MaritalStatus NVARCHAR(20);
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN Over18 NVARCHAR(5);
ALTER TABLE IBM_Employee_Attrition ALTER COLUMN OverTime NVARCHAR(5);


UPDATE IBM_Employee_Attrition
SET Attrition = TRIM(REPLACE(Attrition, '"', ''));



-- =============================================================================
--  SECTION 1  |  OVERVIEW & BASELINE METRICS
-- =============================================================================
-- ──────────Attrition vs Retained — head-to-head comparison ───────────────────
-- Business question: How different are leavers vs stayers across key metrics?
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)
-- Used Overtime as (Yes = 1 and No = 0)
SELECT
    Attrition AS attrition_status,
    COUNT(*) AS employee_count,
    ROUND(AVG(MonthlyIncome), 0) AS avg_monthly_income,
    ROUND(AVG(Age), 1) AS avg_age,
    ROUND(AVG(YearsAtCompany), 1) AS avg_tenure_years,
    ROUND(AVG(JobSatisfaction), 2) AS avg_job_satisfaction,
    ROUND(AVG(WorkLifeBalance), 2) AS avg_wlb_score,
    ROUND(AVG(YearsSinceLastPromotion), 1) AS avg_yrs_since_promo,
    ROUND(AVG(TrainingTimesLastYear), 1) AS avg_trainings_per_yr,
    SUM(CASE WHEN OverTime = 1 THEN 1 ELSE 0 END) AS doing_overtime_count
FROM IBM_Employee_Attrition
GROUP BY Attrition
ORDER BY Attrition DESC;


-- ── Attrition by gender ────────────────────────────────────────────────

SELECT
    Gender,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) AS retained,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_pct
FROM IBM_Employee_Attrition
GROUP BY Gender
ORDER BY attrition_pct DESC;

-- ── Attrition by marital status ───────────────────────────────────────
--- Single employees have the highest attrition (26%)

SELECT
    MaritalStatus,
    COUNT(*) AS total,
   SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) AS retained,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_percentage,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income
FROM IBM_Employee_Attrition
GROUP BY MaritalStatus
ORDER BY attrition_percentage DESC;



-- =============================================================================
--  SECTION 2  |  DEPARTMENT & JOB ROLE ANALYSIS
-- =============================================================================

-- ── Department-wise attrition rate ────────────────────────────────────
-- Business Question = Which department is bleeding talent the most?
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    Department,
    COUNT(*) AS total_headcount,
 SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) AS retained,
ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_percentage,
    ROUND(AVG(MonthlyIncome), 0) AS avg_monthly_income,
    ROUND(AVG(JobSatisfaction), 2) AS avg_job_satisfaction,
    CASE WHEN ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) >= 20  THEN 'HIGH RISK'
         WHEN ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) >= 15  THEN 'MEDIUM RISK'
        ELSE 'LOW RISK' 
		END AS risk_level
FROM IBM_Employee_Attrition
GROUP BY Department
ORDER BY attrition_percentage DESC;


-- ── Job Role ranking by attrition ─────────────────────────────────────
-- Business question: Which specific roles are flight risks?
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    JobRole,
    Department,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_percentage,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income,
    ROUND(AVG(JobSatisfaction), 2) AS avg_satisfaction,
    RANK() OVER (ORDER BY SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) DESC) AS risk_rank
FROM IBM_Employee_Attrition
GROUP BY JobRole, Department
ORDER BY attrition_percentage DESC;


-- ── Department × Job Role cross-tab ───────────────────────────────────
-- Business question: Within each department, which roles drive the most loss?
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    Department,
    JobRole,
    COUNT(*) AS headcount,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_percentage,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income,
    -- rank within each dept
    RANK() OVER ( PARTITION BY Department ORDER BY SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) DESC) AS rank_in_dept
FROM IBM_Employee_Attrition
GROUP BY Department, JobRole
ORDER BY Department, attrition_percentage DESC;


-- ── Job Level attrition ────────────────────────────────────────────────
-- 1=Entry  2=Junior  3=Mid  4=Senior  5=Executive
-- Insight: Entry-level (Level 1) has highest attrition — career growth gap
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    JobLevel,
    CASE JobLevel
        WHEN 1 THEN 'Entry Level'
        WHEN 2 THEN 'Junior'
        WHEN 3 THEN 'Mid Level'
        WHEN 4 THEN 'Senior'
        WHEN 5 THEN 'Executive' END AS level_label,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_pct,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income,
    ROUND(AVG(PercentSalaryHike), 1) AS avg_hike_percentage
FROM IBM_Employee_Attrition
GROUP BY JobLevel
ORDER BY JobLevel;



-- =============================================================================
--  SECTION 3  |  OVERTIME ANALYSIS
-- =============================================================================

-- ── Overtime vs No-Overtime attrition ──────────────────────────────────
-- Business question: How much does overtime drive attrition?
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    OverTime,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END)             AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END)/ COUNT(*), 1) AS attrition_pct,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income,
    ROUND(AVG(WorkLifeBalance), 2) AS avg_wlb,
    ROUND(AVG(JobSatisfaction), 2) AS avg_satisfaction
FROM IBM_Employee_Attrition
GROUP BY OverTime
ORDER BY attrition_pct DESC;


-- ── Overtime × Department — where is the burn the worst? ───────────────
-- Business question: Which departments are most impacted by overtime?
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    Department,
    OverTime,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_pct,
    ROUND(AVG(WorkLifeBalance), 2) AS avg_wlb
FROM IBM_Employee_Attrition
GROUP BY Department, OverTime
ORDER BY Department, OverTime DESC;


-- ── Overtime × Job Role — highest-risk combinations ───────────────────
-- which roles need immediate workload review
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    JobRole,
    OverTime,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_percentage
FROM IBM_Employee_Attrition
WHERE OverTime = 1                                           
GROUP BY JobRole, OverTime
HAVING COUNT(*) >= 10                                               
ORDER BY attrition_percentage DESC;

-- ── Double-risk employees: OverTime + Low WLB ─────────────────────────
-- Business question: Who is at the highest burnout risk right now?
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    EmployeeNumber,
    Department,
    JobRole,
    MonthlyIncome,
    WorkLifeBalance,
    JobSatisfaction,
    YearsAtCompany,
    OverTime,
    Attrition
FROM IBM_Employee_Attrition
WHERE OverTime        = 1
  AND WorkLifeBalance <= 2                                          -- Bad or Below Average
  AND JobSatisfaction <= 2                                          -- Low or Medium
ORDER BY MonthlyIncome ASC, JobSatisfaction ASC;                    -- lowest paid, lowest sat first


-- ── Overtime concentration — what % of each dept does OT? ─────────────
-- Used Overtime as (Yes = 1 and No = 0)

SELECT
    Department,
    COUNT(*) AS total_headcount,
    SUM(CASE WHEN OverTime = 1 THEN 1 ELSE 0 END) AS OverTime_employees,
    ROUND(100.0 * SUM(CASE WHEN OverTime = 1 THEN 1 ELSE 0 END)/ COUNT(*), 1) AS percentage_doing_OverTime
FROM IBM_Employee_Attrition
GROUP BY Department
ORDER BY percentage_doing_OverTime DESC;



-- =============================================================================
--  SECTION 4  |  SALARY BAND ANALYSIS
-- =============================================================================

-- ──  Attrition by salary band ──────────────────────────────────────────
-- Business question: At which income level is attrition the highest?
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    CASE
        WHEN MonthlyIncome <  3000  THEN '1. Below $3,000  (Low)'
        WHEN MonthlyIncome <  6000  THEN '2. $3,000-$5,999  (Mid-Low)'
        WHEN MonthlyIncome < 10000  THEN '3. $6,000-$9,999  (Mid-High)'
        ELSE '4. $10,000+  (High)' 
		END AS Salary_Level,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_pct,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income_in_band,
    ROUND(AVG(PercentSalaryHike), 1) AS avg_last_hike_pct,
    CASE
        WHEN ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) >= 25  THEN 'CRITICAL'
        WHEN ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) >= 15  THEN 'HIGH'
        ELSE 'STABLE' END AS risk_flag
FROM IBM_Employee_Attrition
GROUP BY CASE
        WHEN MonthlyIncome <  3000  THEN '1. Below $3,000  (Low)'
        WHEN MonthlyIncome <  6000  THEN '2. $3,000-$5,999  (Mid-Low)'
        WHEN MonthlyIncome < 10000  THEN '3. $6,000-$9,999  (Mid-High)'
        ELSE '4. $10,000+  (High)' 
		END
ORDER BY Salary_Level;


-- ── Salary gap: how much more do retained employees earn? ───────────────
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    Attrition,
    COUNT(*) AS employee_count,
    ROUND(MIN(MonthlyIncome), 0) AS min_income,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income,
    ROUND(MAX(MonthlyIncome), 0) AS max_income,
    ROUND(AVG(PercentSalaryHike), 1) AS avg_last_hike_percentage,
    ROUND(AVG(DailyRate), 0) AS avg_daily_rate
FROM IBM_Employee_Attrition
GROUP BY Attrition


-- ── Salary band × Department — where is underpayment concentrated? ────
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    Department,
    CASE
        WHEN MonthlyIncome <  3000  THEN '1. Below $3K'
        WHEN MonthlyIncome <  6000  THEN '2. $3K-$6K'
        WHEN MonthlyIncome < 10000  THEN '3. $6K-$10K'
        ELSE '4. $10K+' END AS salary_band,
    COUNT(*) AS headcount,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) AS retained,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_percentage
FROM IBM_Employee_Attrition
GROUP BY Department,
    CASE
        WHEN MonthlyIncome <  3000  THEN '1. Below $3K'
        WHEN MonthlyIncome <  6000  THEN '2. $3K-$6K'
        WHEN MonthlyIncome < 10000  THEN '3. $6K-$10K'
        ELSE '4. $10K+'
    END
ORDER BY Department, salary_band;


-- ── Salary hike adequacy — do low hikes drive attrition? ──────────────
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    CASE
        WHEN PercentSalaryHike <= 12  THEN '11-12% (Low)'
        WHEN PercentSalaryHike <= 15  THEN '13-15% (Medium)'
        WHEN PercentSalaryHike <= 18  THEN '16-18% (Good)'
        ELSE '19-25% (High)' END AS hike_band,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_percentage,
    ROUND(AVG(PerformanceRating), 2) AS avg_performance
FROM IBM_Employee_Attrition
GROUP BY CASE
        WHEN PercentSalaryHike <= 12  THEN '11-12% (Low)'
        WHEN PercentSalaryHike <= 15  THEN '13-15% (Medium)'
        WHEN PercentSalaryHike <= 18  THEN '16-18% (Good)'
        ELSE '19-25% (High)' END
ORDER BY hike_band;


-- ── Stock options impact on retention ──────────────────────────────────
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    StockOptionLevel,
    CASE StockOptionLevel
        WHEN 0 THEN 'No Stock Options'
        WHEN 1 THEN 'Level 1 (Low)'
        WHEN 2 THEN 'Level 2 (Medium)'
        WHEN 3 THEN 'Level 3 (High)'
    END AS stock_desc,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_pct,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income
FROM IBM_Employee_Attrition
GROUP BY StockOptionLevel
ORDER BY StockOptionLevel;



-- =============================================================================
--  SECTION 5  |  PROMOTION GAP ANALYSIS
-- =============================================================================

-- ── Years since last promotion vs attrition ────────────────────────────
-- Business question: Does career stagnation drive attrition?
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    CASE
        WHEN YearsSinceLastPromotion = 0  THEN '0 yrs (just promoted)'
        WHEN YearsSinceLastPromotion = 1  THEN '1 yr'
        WHEN YearsSinceLastPromotion <= 3 THEN '2-3 yrs'
        WHEN YearsSinceLastPromotion <= 5 THEN '4-5 yrs'
        ELSE '6+ yrs (stagnant)'
    END AS promotion_gap,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_percentage,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income,
    ROUND(AVG(JobSatisfaction), 2) AS avg_satisfaction,
    ROUND(AVG(PerformanceRating), 2) AS avg_performance
FROM IBM_Employee_Attrition
GROUP BY
    CASE
        WHEN YearsSinceLastPromotion = 0  THEN '0 yrs (just promoted)'
        WHEN YearsSinceLastPromotion = 1  THEN '1 yr'
        WHEN YearsSinceLastPromotion <= 3 THEN '2-3 yrs'
        WHEN YearsSinceLastPromotion <= 5 THEN '4-5 yrs'
        ELSE '6+ yrs (stagnant)'
        END
ORDER BY
 CASE
        WHEN YearsSinceLastPromotion = 0  THEN '0 yrs (just promoted)'
        WHEN YearsSinceLastPromotion = 1  THEN '1 yr'
        WHEN YearsSinceLastPromotion <= 3 THEN '2-3 yrs'
        WHEN YearsSinceLastPromotion <= 5 THEN '4-5 yrs'
        ELSE '6+ yrs (stagnant)'
        END;
  


-- ── Tenure segmentation — when do employees leave most? ─────────────────
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    CASE
        WHEN YearsAtCompany <= 1   THEN '1. New Joiners (0-1 yr)'
        WHEN YearsAtCompany <= 3   THEN '2. Early Career (2-3 yr)'
        WHEN YearsAtCompany <= 6   THEN '3. Mid Tenure (4-6 yr)'
        WHEN YearsAtCompany <= 10  THEN '4. Senior (7-10 yr)'
        ELSE '5. Veterans (10+ yr)'
    END AS tenure_bucket,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_pct,
    ROUND(AVG(YearsSinceLastPromotion), 1) AS avg_promo_gap,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income,
    ROUND(AVG(JobSatisfaction), 2) AS avg_satisfaction
FROM IBM_Employee_Attrition
GROUP BY CASE
        WHEN YearsAtCompany <= 1   THEN '1. New Joiners (0-1 yr)'
        WHEN YearsAtCompany <= 3   THEN '2. Early Career (2-3 yr)'
        WHEN YearsAtCompany <= 6   THEN '3. Mid Tenure (4-6 yr)'
        WHEN YearsAtCompany <= 10  THEN '4. Senior (7-10 yr)'
        ELSE '5. Veterans (10+ yr)'
    END
ORDER BY tenure_bucket;


-- ── Stagnant employees — no promo in 4+ yrs, still performing ──────────
-- These are your highest-risk "quiet quitters"
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    EmployeeNumber,
    Department,
    JobRole,
    JobLevel,
    YearsAtCompany,
    YearsSinceLastPromotion,
    PerformanceRating,
    MonthlyIncome,
    JobSatisfaction,
    OverTime,
    Attrition
FROM IBM_Employee_Attrition
WHERE YearsSinceLastPromotion >= 4
  AND PerformanceRating >= 3                                        -- still performing well
ORDER BY YearsSinceLastPromotion DESC, PerformanceRating DESC;


-- ── Manager impact on attrition — same manager for long time ────────────
-- Does staying with the same manager too long create a ceiling effect?
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    CASE
        WHEN YearsWithCurrManager <= 1  THEN '0-1 yr (new manager)'
        WHEN YearsWithCurrManager <= 3  THEN '2-3 yrs'
        WHEN YearsWithCurrManager <= 7  THEN '4-7 yrs'
        ELSE '8+ yrs (long tenure)'
    END AS manager_tenure_group,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_pct,
    ROUND(AVG(RelationshipSatisfaction), 2) AS avg_rel_satisfaction
FROM IBM_Employee_Attrition
GROUP BY 
      CASE
        WHEN YearsWithCurrManager <= 1  THEN '0-1 yr (new manager)'
        WHEN YearsWithCurrManager <= 3  THEN '2-3 yrs'
        WHEN YearsWithCurrManager <= 7  THEN '4-7 yrs'
        ELSE '8+ yrs (long tenure)'
    END         
ORDER BY manager_tenure_group;



-- =============================================================================
--  SECTION 6  |  SATISFACTION & WELLNESS ANALYSIS
-- =============================================================================

-- ── All 4 satisfaction scores vs attrition ─────────────────────────────
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    JobSatisfaction AS score,
    CASE JobSatisfaction WHEN 1 THEN 'Low'
	                     WHEN 2 THEN 'Medium'
                         WHEN 3 THEN 'High' 
						 ELSE 'Very High' END AS score_label,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS job_satisfaction_attrition_percentage,
    -- showing all 4 metrics in one row using subqueries
    (SELECT ROUND(100.0 * SUM(CASE WHEN a.Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1)
     FROM IBM_Employee_Attrition a WHERE a.EnvironmentSatisfaction = IBM_Employee_Attrition.JobSatisfaction) AS environment_satisfaction_attrition_percentage,

    (SELECT ROUND(100.0 * SUM(CASE WHEN a.Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1)
     FROM IBM_Employee_Attrition a WHERE a.WorkLifeBalance = IBM_Employee_Attrition.JobSatisfaction) AS WorkLifeBalance_attrition_percentage,

    (SELECT ROUND(100.0 * SUM(CASE WHEN a.Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1)
     FROM IBM_Employee_Attrition a WHERE a.RelationshipSatisfaction = IBM_Employee_Attrition.JobSatisfaction) AS Relationship_satisfaction_attrition_percentage

FROM IBM_Employee_Attrition
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;


-- ── Composite Wellness Index (average of 4 satisfaction scores) ─────────
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    CASE
        WHEN (JobSatisfaction + EnvironmentSatisfaction
             + WorkLifeBalance + RelationshipSatisfaction) / 4.0 < 2.0 THEN 'At-Risk (< 2.0)'
        WHEN (JobSatisfaction + EnvironmentSatisfaction
             + WorkLifeBalance + RelationshipSatisfaction) / 4.0 < 3.0 THEN 'Watch (2.0-2.99)'
        ELSE 'Stable (3.0+)'
    END AS wellness_band,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END)/ COUNT(*), 1) AS attrition_pct,
    ROUND(AVG((JobSatisfaction + EnvironmentSatisfaction + WorkLifeBalance + RelationshipSatisfaction) / 4.0), 2) AS avg_wellness_index
FROM IBM_Employee_Attrition
GROUP BY CASE
        WHEN (JobSatisfaction + EnvironmentSatisfaction
             + WorkLifeBalance + RelationshipSatisfaction) / 4.0 < 2.0 THEN 'At-Risk (< 2.0)'
        WHEN (JobSatisfaction + EnvironmentSatisfaction
             + WorkLifeBalance + RelationshipSatisfaction) / 4.0 < 3.0 THEN 'Watch (2.0-2.99)'
        ELSE 'Stable (3.0+)'
    END
ORDER BY wellness_band;


-- ── Business travel impact ─────────────────────────────────────────────
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    BusinessTravel,
    COUNT(*)                                                        AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END)             AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_pct,
    ROUND(AVG(WorkLifeBalance), 2) AS avg_wlb,
    ROUND(AVG(DistanceFromHome), 1) AS avg_distance_home
FROM IBM_Employee_Attrition
GROUP BY BusinessTravel
ORDER BY attrition_pct DESC;


-- ── Training investment vs attrition ───────────────────────────────────
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT
    TrainingTimesLastYear,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_pct,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income
FROM IBM_Employee_Attrition
GROUP BY TrainingTimesLastYear
ORDER BY TrainingTimesLastYear;


-- =============================================================================
--  SECTION 7  |  ADVANCED — CTE + WINDOW FUNCTIONS
-- =============================================================================

-- ── Employee attrition risk score (0–100) ───────────────────────────────
-- Combined 5 key risk factors into a single score per employee
-- Higher score = higher risk of attrition
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

WITH risk_scores AS (
    SELECT
        EmployeeNumber, Department, JobRole, MonthlyIncome, OverTime, JobSatisfaction, YearsSinceLastPromotion, WorkLifeBalance, YearsAtCompany, Attrition,
        CASE WHEN OverTime = 'Yes' THEN 25 ELSE 0 END AS score_overtime,
        CASE
            WHEN MonthlyIncome < 3000 THEN 25
            WHEN MonthlyIncome < 6000 THEN 10
            ELSE 0
        END AS score_income,
        CASE
            WHEN JobSatisfaction = 1 THEN 20
            WHEN JobSatisfaction = 2 THEN 10
            ELSE 0
        END AS score_satisfaction,
        CASE
            WHEN YearsSinceLastPromotion >= 4 THEN 15
            WHEN YearsSinceLastPromotion >= 2 THEN 7
            ELSE 0
        END AS score_promo_gap,
        CASE
            WHEN WorkLifeBalance = 1 THEN 15
            WHEN WorkLifeBalance = 2 THEN 7
            ELSE 0
        END AS score_wlb
    FROM IBM_Employee_Attrition)
SELECT TOP 50
    EmployeeNumber, Department, JobRole, MonthlyIncome, OverTime, JobSatisfaction, YearsSinceLastPromotion, WorkLifeBalance, Attrition,
    score_overtime + score_income + score_satisfaction
    + score_promo_gap + score_wlb AS total_risk_score,
    CASE
        WHEN score_overtime + score_income + score_satisfaction + score_promo_gap + score_wlb >= 60 THEN 'CRITICAL RISK'
        WHEN score_overtime + score_income + score_satisfaction + score_promo_gap + score_wlb >= 40 THEN 'HIGH RISK'
        WHEN score_overtime + score_income + score_satisfaction + score_promo_gap + score_wlb >= 20 THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS risk_category
FROM risk_scores
ORDER BY total_risk_score DESC, MonthlyIncome ASC;

-- ── Department attrition trend — running total ─────────────────────────
-- Shows cumulative attrition count sorted by tenure (oldest joiners first)
-- Useful for: spotting which cohort started the exodus
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

WITH tenure_attrition AS (
    SELECT 
	YearsAtCompany, Department,
        COUNT(*) AS total,
        SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS left_count
    FROM IBM_Employee_Attrition
    GROUP BY YearsAtCompany, Department)
SELECT
    YearsAtCompany,
    Department,
    total,
    left_count,
    ROUND(100.0 * left_count / total, 1) AS attrition_pct,
    SUM(left_count) OVER (
        PARTITION BY Department
        ORDER BY YearsAtCompany
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_left
FROM tenure_attrition
ORDER BY Department, YearsAtCompany;


-- ── Peer income comparison — who earns less than their role average? ────
-- Employees earning significantly below their job role average = flight risk
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

WITH role_avg AS (
    SELECT
        JobRole,
        Department,
        ROUND(AVG(MonthlyIncome), 0) AS role_avg_income,
        ROUND(MIN(MonthlyIncome), 0) AS role_min_income,
        ROUND(MAX(MonthlyIncome), 0) AS role_max_income
    FROM IBM_Employee_Attrition
    GROUP BY JobRole, Department)
SELECT
    e.EmployeeNumber,
    e.Department,
    e.JobRole,
    e.MonthlyIncome,
    r.role_avg_income,
    e.MonthlyIncome - r.role_avg_income AS income_vs_avg,
    ROUND(100.0 * (e.MonthlyIncome - r.role_avg_income) / r.role_avg_income, 1) AS pct_vs_avg,
    e.PerformanceRating,
    e.YearsAtCompany,
    e.Attrition
FROM IBM_Employee_Attrition e
JOIN role_avg r ON e.JobRole = r.JobRole AND e.Department = r.Department
WHERE e.MonthlyIncome < r.role_avg_income * 0.85                    -- earning 15%+ below avg
ORDER BY pct_vs_avg ASC;


-- ── Top 10 most critical risk factors (ranked by attrition lift) ────────
-- Which single factor, when present, raises attrition the MOST above baseline?
-- Baseline: 16.1% overall attrition
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

WITH baseline AS (SELECT 
              ROUND(100.0 * SUM(CASE WHEN Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS overall_rate FROM IBM_Employee_Attrition)
SELECT
    factor_name,
    group_label,
    group_count,
    group_attrition_pct,
    b.overall_rate AS baseline_pct,
    group_attrition_pct - b.overall_rate AS lift_vs_baseline
FROM (SELECT 'OverTime' AS factor_name, 'Yes' AS group_label,
           COUNT(*) AS group_count,
           ROUND(100.0 * SUM(CASE WHEN Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS group_attrition_pct
    FROM IBM_Employee_Attrition WHERE OverTime = 'Yes'
    UNION ALL
    SELECT 'Salary Band',  'Below $3,000',
           COUNT(*),
           ROUND(100.0 * SUM(CASE WHEN Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1)
    FROM IBM_Employee_Attrition WHERE MonthlyIncome < 3000
    UNION ALL
    SELECT 'Tenure Bucket', '0-1 Year',
           COUNT(*),
           ROUND(100.0 * SUM(CASE WHEN Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1)
    FROM IBM_Employee_Attrition WHERE YearsAtCompany <= 1
    UNION ALL
    SELECT 'Job Role', 'Sales Representative',
           COUNT(*),
           ROUND(100.0 * SUM(CASE WHEN Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1)
    FROM IBM_Employee_Attrition WHERE JobRole = 'Sales Representative'
    UNION ALL
    SELECT 'Stock Options', 'Level 0 (None)',
           COUNT(*),
           ROUND(100.0 * SUM(CASE WHEN Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1)
    FROM IBM_Employee_Attrition WHERE StockOptionLevel = 0
    UNION ALL
    SELECT 'BusinessTravel', 'Travel_Frequently',
           COUNT(*),
           ROUND(100.0 * SUM(CASE WHEN Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1)
    FROM IBM_Employee_Attrition WHERE BusinessTravel = 'Travel_Frequently'
    UNION ALL
    SELECT 'Job Satisfaction', 'Score = 1 (Low)',
           COUNT(*),
           ROUND(100.0 * SUM(CASE WHEN Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1)
    FROM IBM_Employee_Attrition WHERE JobSatisfaction = 1
    UNION ALL
    SELECT 'MaritalStatus', 'Single',
           COUNT(*),
           ROUND(100.0 * SUM(CASE WHEN Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1)
    FROM IBM_Employee_Attrition WHERE MaritalStatus = 'Single'
    UNION ALL
    SELECT 'WLB Score', 'Score = 1 (Bad)',
           COUNT(*),
           ROUND(100.0 * SUM(CASE WHEN Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1)
    FROM IBM_Employee_Attrition WHERE WorkLifeBalance = 1
    UNION ALL
    SELECT 'Job Level', 'Level 1 (Entry)',
           COUNT(*),
           ROUND(100.0 * SUM(CASE WHEN Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1)
    FROM IBM_Employee_Attrition WHERE JobLevel = 1) factors, baseline b
ORDER BY lift_vs_baseline DESC;



-- =============================================================================
--  SECTION 8  |  BUSINESS RECOMMENDATIONS SUMMARY VIEW
-- =============================================================================

-- ──  Final executive summary: top problem areas, one query ───────────────
-- one-page summary to present to HR leadership
-- used Attrition as (Left(Yes)=1 and Stay(No)=0)

SELECT '=== OVERALL ===' AS section, '' AS metric, '' AS value, '' AS action
UNION ALL
SELECT '', 'Total Employees',
    CAST(COUNT(*) AS CHAR),
    'Baseline'
FROM IBM_Employee_Attrition
UNION ALL
SELECT '', 'Attrition Rate',
    CONCAT(ROUND(100.0 * SUM(CASE WHEN Attrition= 1 THEN 1 ELSE 0 END) / COUNT(*), 1), '%'),
    'Industry avg: 13-15%. Company is above average.'
FROM IBM_Employee_Attrition
UNION ALL
SELECT '=== TOP 3 RISKS ===', '', '', ''
UNION ALL
SELECT 'RISK 1', 'Overtime Attrition',
    '30.5% (3.1× baseline)',
    'Immediate: Audit OT-heavy roles, add headcount or enforce limits'
UNION ALL
SELECT 'RISK 2', 'Low Income (<$3K)',
    '28.6% attrition rate',
    'Salary review for bottom quartile, propose 15-20% hike cycle'
UNION ALL
SELECT 'RISK 3', 'New Joiners 0-1yr',
    '34.9% attrition rate',
    'Redesign onboarding, assign mentors, weekly 1:1 for 6 months';


-- =============================================================================
--  END OF FILE
-- =============================================================================
