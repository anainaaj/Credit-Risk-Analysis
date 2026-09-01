-- =====================================================================
-- 01_data_quality.sql
-- Credit Risk & Loan Approval Analytics
-- Purpose: Confirm the `loans` table is clean and trustworthy BEFORE
-- we run any business analysis on it.
-- Table: loans  (614 applications, 1 row = 1 applicant)
-- =====================================================================


-- -----------------------------------------------------------------
-- Q1. How many applications do we have in total?
-- -----------------------------------------------------------------
SELECT COUNT(*) AS total_applications
FROM loans;


-- -----------------------------------------------------------------
-- Q2. Are there duplicate applicants (duplicate Loan_ID)?
-- If unique_applicants < total_rows, we have duplicates to clean.
-- -----------------------------------------------------------------
SELECT
    COUNT(*)                  AS total_rows,
    COUNT(DISTINCT Loan_ID)   AS unique_applicants
FROM loans;


-- -----------------------------------------------------------------
-- Q3. Are there any NULL / missing values in key fields?
-- One row per column, so we can scan the result at a glance.
-- -----------------------------------------------------------------
SELECT 'Gender'             AS column_name, COUNT(*) AS missing_values FROM loans WHERE Gender IS NULL
UNION ALL
SELECT 'Married',                    COUNT(*) FROM loans WHERE Married IS NULL
UNION ALL
SELECT 'Dependents',                 COUNT(*) FROM loans WHERE Dependents IS NULL
UNION ALL
SELECT 'Education',                  COUNT(*) FROM loans WHERE Education IS NULL
UNION ALL
SELECT 'Self_Employed',              COUNT(*) FROM loans WHERE Self_Employed IS NULL
UNION ALL
SELECT 'ApplicantIncome',            COUNT(*) FROM loans WHERE ApplicantIncome IS NULL
UNION ALL
SELECT 'CoapplicantIncome',          COUNT(*) FROM loans WHERE CoapplicantIncome IS NULL
UNION ALL
SELECT 'LoanAmount',                 COUNT(*) FROM loans WHERE LoanAmount IS NULL
UNION ALL
SELECT 'Loan_Amount_Term',           COUNT(*) FROM loans WHERE Loan_Amount_Term IS NULL
UNION ALL
SELECT 'Credit_History',             COUNT(*) FROM loans WHERE Credit_History IS NULL
UNION ALL
SELECT 'Property_Area',              COUNT(*) FROM loans WHERE Property_Area IS NULL
UNION ALL
SELECT 'Loan_Status',                COUNT(*) FROM loans WHERE Loan_Status IS NULL;


-- -----------------------------------------------------------------
-- Q4. Do the categorical columns only contain expected values?
-- If any of these return rows,something unexpected slipped through.
-- -----------------------------------------------------------------
SELECT DISTINCT Gender FROM loans
WHERE Gender NOT IN ('Male', 'Female');

SELECT DISTINCT Married FROM loans
WHERE Married NOT IN ('Yes', 'No');

SELECT DISTINCT Education FROM loans
WHERE Education NOT IN ('Graduate', 'Not Graduate');

SELECT DISTINCT Self_Employed FROM loans
WHERE Self_Employed NOT IN ('Yes', 'No');

SELECT DISTINCT Property_Area FROM loans
WHERE Property_Area NOT IN ('Urban', 'Rural', 'Semiurban');

SELECT DISTINCT Loan_Status FROM loans
WHERE Loan_Status NOT IN ('Y', 'N');

SELECT DISTINCT Credit_History FROM loans
WHERE Credit_History NOT IN (0, 1);


-- -----------------------------------------------------------------
-- Q5. Are there any suspicious / impossible numeric values?
-- (negative or zero income, negative or zero loan amount, etc.)
-- -----------------------------------------------------------------
SELECT *
FROM loans
WHERE ApplicantIncome <= 0
   OR CoapplicantIncome < 0
   OR LoanAmount <= 0
   OR Loan_Amount_Term <= 0
   OR Total_Income <= 0;


-- -----------------------------------------------------------------
-- Q6.Does Total_Income actually equal
-- ApplicantIncome + CoapplicantIncome for every row?
-- -----------------------------------------------------------------
SELECT COUNT(*) AS mismatched_total_income_rows
FROM loans
WHERE ROUND(Total_Income, 2) <> ROUND(ApplicantIncome + CoapplicantIncome, 2);


-- -----------------------------------------------------------------
-- Q7. What does the overall Loan_Status distribution look like?
-- Gives us a first read on class balance (approved vs rejected).
-- -----------------------------------------------------------------
SELECT
    Loan_Status,
    COUNT(*) AS applications,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loans), 2) AS pct_of_total
FROM loans
GROUP BY Loan_Status;


-- -----------------------------------------------------------------
-- Q8. Quick outlier scan on income and loan amount using min/max/avg.
-- Helps spot extreme values worth a closer look before analysis.
-- -----------------------------------------------------------------
SELECT
    MIN(ApplicantIncome) AS min_income,
    MAX(ApplicantIncome) AS max_income,
    ROUND(AVG(ApplicantIncome), 0) AS avg_income,
    MIN(LoanAmount)  AS min_loan_amount,
    MAX(LoanAmount)  AS max_loan_amount,
    ROUND(AVG(LoanAmount), 0) AS avg_loan_amount
FROM loans;
