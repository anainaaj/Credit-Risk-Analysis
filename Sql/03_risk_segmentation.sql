-- =====================================================================
-- 03_risk_segmentation.sql
-- Credit Risk & Loan Approval Analytics
-- Purpose: Combine multiple characteristics (not just one at a time)
-- to find applicant SEGMENTS that carry the highest rejection risk.
-- Table: loans  (614 applications, 1 row = 1 applicant)
-- =====================================================================


-- -----------------------------------------------------------------
-- Q1. Credit History + Income Band combined.
-- Does a good income still get punished by poor credit history?
-- -----------------------------------------------------------------
SELECT
    Credit_History_Label,
    Income_Band,
    COUNT(*) AS applications,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY Credit_History_Label, Income_Band
ORDER BY approval_rate_pct ASC;


-- -----------------------------------------------------------------
-- Q2. Credit History + Loan Burden (Loan-to-Income ratio band).
-- Is "poor credit + high burden" the worst combination?
-- -----------------------------------------------------------------
SELECT
    Credit_History_Label,
    CASE
        WHEN Loan_to_Income < 18 THEN 'Low burden (<18x)'
        WHEN Loan_to_Income < 28 THEN 'Moderate burden (18-28x)'
        ELSE 'High burden (28x+)'
    END AS loan_burden_band,
    COUNT(*) AS applications,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY Credit_History_Label, loan_burden_band
ORDER BY approval_rate_pct ASC;


-- -----------------------------------------------------------------
-- Q3. The full three-way segment: Credit History + Income Band +
-- Loan Burden -> a single "Applicant_Segment" label, ranked by
-- approval rate to surface the riskiest combinations.
-- -----------------------------------------------------------------
SELECT
    Credit_History_Label || ' | ' ||
    Income_Band || ' Income | ' ||
    CASE
        WHEN Loan_to_Income < 18 THEN 'Low burden'
        WHEN Loan_to_Income < 28 THEN 'Moderate burden'
        ELSE 'High burden'
    END AS applicant_segment,
    COUNT(*) AS applications,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY applicant_segment
ORDER BY approval_rate_pct ASC;


-- -----------------------------------------------------------------
-- Q4. Same segmentation as Q3, but filtered to segments with at
-- least 15 applicants, so we only act on statistically meaningful
-- groups rather than tiny, noisy buckets.
-- -----------------------------------------------------------------
SELECT
    Credit_History_Label || ' | ' ||
    Income_Band || ' Income | ' ||
    CASE
        WHEN Loan_to_Income < 18 THEN 'Low burden'
        WHEN Loan_to_Income < 28 THEN 'Moderate burden'
        ELSE 'High burden'
    END AS applicant_segment,
    COUNT(*) AS applications,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY applicant_segment
HAVING COUNT(*) >= 15
ORDER BY approval_rate_pct ASC;


-- -----------------------------------------------------------------
-- Q5. Self-employed applicants with poor/no credit history:
-- a segment that often carries elevated risk in lending.
-- -----------------------------------------------------------------
SELECT
    Self_Employed,
    Credit_History_Label,
    COUNT(*) AS applications,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY Self_Employed, Credit_History_Label
ORDER BY approval_rate_pct ASC;


-- -----------------------------------------------------------------
-- Q6. Dependents + Income Band: do applicants with more dependents
-- and lower income form a distinct high-risk group?
-- -----------------------------------------------------------------
SELECT
    Dependents,
    Income_Band,
    COUNT(*) AS applications,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY Dependents, Income_Band
ORDER BY approval_rate_pct ASC;


-- -----------------------------------------------------------------
-- Q7. Assign every applicant a simple Risk_Score (0-3) based on
-- three risk flags, then check approval rate by score.
-- Flags: poor credit history, high loan burden, low income band.
-- -----------------------------------------------------------------
SELECT
    (CASE WHEN Credit_History = 0 THEN 1 ELSE 0 END) +
    (CASE WHEN Loan_to_Income >= 28 THEN 1 ELSE 0 END) +
    (CASE WHEN Income_Band = 'Low' THEN 1 ELSE 0 END)
        AS risk_score,
    COUNT(*) AS applications,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY risk_score
ORDER BY risk_score;


-- -----------------------------------------------------------------
-- Q8. Rank the top 5 highest-risk meaningful segments (min. 10
-- applicants) by approval rate, for a quick executive summary.
-- -----------------------------------------------------------------
SELECT
    Credit_History_Label || ' | ' ||
    Income_Band || ' Income | ' ||
    CASE
        WHEN Loan_to_Income < 18 THEN 'Low burden'
        WHEN Loan_to_Income < 28 THEN 'Moderate burden'
        ELSE 'High burden'
    END AS applicant_segment,
    COUNT(*) AS applications,
    ROUND(AVG(Loan_Status_Binary) * 100, 2) AS approval_rate_pct
FROM loans
GROUP BY applicant_segment
HAVING COUNT(*) >= 10
ORDER BY approval_rate_pct ASC
LIMIT 5;
