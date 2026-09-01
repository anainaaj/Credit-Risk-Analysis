-- =====================================================================
-- 02_business_analysis.sql
-- Credit Risk & Loan Approval Analytics
-- Purpose: Answer real business questions about the loan portfolio.
-- These numbers also feed the Tableau dashboard.
-- Table: loans  (614 applications, 1 row = 1 applicant)
-- =====================================================================


-- -----------------------------------------------------------------
-- Q1. Overall approval rate: how many applications were approved,
-- and what percentage of all applications does that represent?
-- -----------------------------------------------------------------
SELECT
    Loan_Status,
    COUNT(*) AS applications,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM loans), 2
    ) AS pct_of_total
FROM loans
GROUP BY Loan_Status;


-- -----------------------------------------------------------------
-- Q2. Approval rate by credit history.
-- Credit_History = 1 (good) vs 0 (poor/no history).
-- -----------------------------------------------------------------
SELECT
    Credit_History_Label,
    COUNT(*) AS applications,
    SUM(Loan_Status_Binary) AS approved,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY Credit_History_Label
ORDER BY approval_rate_pct DESC;


-- -----------------------------------------------------------------
-- Q3. Approval rate by property area.
-- Which locations (Urban / Rural / Semiurban) approve more often?
-- -----------------------------------------------------------------
SELECT
    Property_Area,
    COUNT(*) AS applications,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY Property_Area
ORDER BY approval_rate_pct DESC;


-- -----------------------------------------------------------------
-- Q4. Does graduate status relate to approval outcomes?
-- -----------------------------------------------------------------
SELECT
    Education,
    COUNT(*) AS applications,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY Education
ORDER BY approval_rate_pct DESC;


-- -----------------------------------------------------------------
-- Q5. Approval rate across income bands (Low / Middle / High),
-- along with average requested loan amount per band.
-- -----------------------------------------------------------------
SELECT
    Income_Band,
    COUNT(*) AS applications,
    ROUND(AVG(LoanAmount), 0) AS avg_loan_amount,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY Income_Band
ORDER BY
    CASE Income_Band WHEN 'Low' THEN 1 WHEN 'Middle' THEN 2 WHEN 'High' THEN 3 END;


-- -----------------------------------------------------------------
-- Q6. Loan burden: do applicants borrowing a lot relative to their
-- income (high Loan_to_Income ratio) get approved less often?
-- We bucket Loan_to_Income into terciles-style bands here.
-- -----------------------------------------------------------------
SELECT
    CASE
        WHEN Loan_to_Income < 18 THEN 'Low burden (<18x)'
        WHEN Loan_to_Income < 28 THEN 'Moderate burden (18-28x)'
        ELSE 'High burden (28x+)'
    END AS loan_burden_band,
    COUNT(*) AS applications,
    ROUND(AVG(Loan_to_Income), 2) AS avg_loan_to_income,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY loan_burden_band
ORDER BY avg_loan_to_income;


-- -----------------------------------------------------------------
-- Q7. Marital status and dependents: do applicants with a spouse
-- and/or more dependents get approved at different rates?
-- -----------------------------------------------------------------
SELECT
    Married,
    Dependents,
    COUNT(*) AS applications,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY Married, Dependents
ORDER BY Married, Dependents;


-- -----------------------------------------------------------------
-- Q8. Average loan amount and average income, split by whether the
-- application was approved or rejected.
-- -----------------------------------------------------------------
SELECT
    Loan_Status,
    COUNT(*) AS applications,
    ROUND(AVG(ApplicantIncome), 0) AS avg_applicant_income,
    ROUND(AVG(Total_Income), 0)    AS avg_total_income,
    ROUND(AVG(LoanAmount), 0)      AS avg_loan_amount
FROM loans
GROUP BY Loan_Status;
