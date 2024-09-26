use bank;

select * from transactions;

-- 1.Find accounts with the highest number of fraudulent transactions
SELECT nameOrig, COUNT(*) AS fraud_count
FROM transactions
WHERE isFraud = 1
GROUP BY nameOrig
ORDER BY fraud_count DESC
LIMIT 10;

-- 2.Identify suspicious accounts with consecutive flagged frauds
WITH flagged_fraud AS (
    SELECT nameOrig, step, isFlaggedFraud,
           LAG(isFlaggedFraud) OVER (PARTITION BY nameOrig ORDER BY step) AS prev_flagged
    FROM transactions
)
SELECT * 
FROM flagged_fraud 
WHERE isFlaggedFraud = 1 AND prev_flagged = 1;

-- 3.Detect the largest transfer fraud for each day 
WITH ranked_transfers AS (
    SELECT step, nameOrig, nameDest, amount, 
    ROW_NUMBER() OVER (PARTITION BY step ORDER BY amount DESC) AS row_rank
    FROM transactions
    WHERE isFraud = 1 AND type = 'TRANSFER'
)
SELECT step, nameOrig, nameDest, amount 
FROM ranked_transfers 
WHERE row_rank = 1;

-- 4.Compare average balances of fraudulent and non-fraudulent transactions
SELECT 
    AVG(CASE WHEN isFraud = 1 THEN oldbalanceOrg ELSE NULL END) AS avg_fraud_oldbalance,
    AVG(CASE WHEN isFraud = 0 THEN oldbalanceOrg ELSE NULL END) AS avg_non_fraud_oldbalance
FROM transactions;

-- 5. Find all transactions where the balance difference is unusually high
SELECT nameOrig, step, amount, oldbalanceOrg, newbalanceOrig,
    (oldbalanceOrg - newbalanceOrig) - amount AS balance_discrepancy
FROM transactions
WHERE (oldbalanceOrg - newbalanceOrig) > amount + 5000;

-- 6.Find accounts that transferred money to multiple flagged fraud accounts
WITH flagged_destinations AS (
    SELECT nameDest 
    FROM transactions 
    WHERE isFlaggedFraud = 1
)
SELECT nameOrig, COUNT(DISTINCT nameDest) AS distinct_flagged_destinations
FROM transactions
WHERE nameDest IN (SELECT nameDest FROM flagged_destinations)
GROUP BY nameOrig
HAVING COUNT(DISTINCT nameDest) > 1;

-- 7.Identify accounts involved in both receiving and initiating fraud
WITH fraud_senders AS (
    SELECT DISTINCT nameOrig 
    FROM transactions 
    WHERE isFraud = 1 AND type = 'TRANSFER'
),
fraud_receivers AS (
    SELECT DISTINCT nameDest 
    FROM transactions 
    WHERE isFraud = 1 AND type = 'TRANSFER'
)
SELECT fs.nameOrig 
FROM fraud_senders fs
JOIN fraud_receivers fr ON fs.nameOrig = fr.nameDest;

-- 8.Check if Computed Balance Matches Actual Balance
WITH CTE AS (
    SELECT amount, nameOrig, oldbalanceOrg, oldbalanceDest, newbalanceOrig, newbalanceDest,
           (oldbalanceOrg - amount) AS computed_newbalanceOrig,
           (oldbalanceDest + amount) AS computed_newbalanceDest
    FROM transactions
)
SELECT * 
FROM CTE 
WHERE computed_newbalanceOrig = newbalanceOrig 
  AND computed_newbalanceDest = newbalanceDest;

-- 9.Complex Fraud Detection Using Multiple CTEs
WITH large_transfers AS (
    SELECT nameOrig, step, amount 
    FROM transactions 
    WHERE type = 'TRANSFER' AND amount > 500000
),
no_balance_change AS (
    SELECT nameOrig, step, oldbalanceOrg, newbalanceOrig 
    FROM transactions 
    WHERE oldbalanceOrg = newbalanceOrig
),
flagged_transactions AS (
    SELECT nameOrig, step 
    FROM transactions 
    WHERE isFlaggedFraud = 1
),
circular_transfers AS (
    SELECT t1.nameOrig, t1.nameDest 
    FROM transactions t1 
    JOIN transactions t2 ON t1.nameDest = t2.nameOrig 
    WHERE t1.type = 'TRANSFER' AND t2.type = 'TRANSFER' AND t1.nameOrig = t2.nameDest
)
SELECT lt.nameOrig
FROM large_transfers lt
JOIN no_balance_change nbc ON lt.nameOrig = nbc.nameOrig AND lt.step = nbc.step
JOIN flagged_transactions ft ON lt.nameOrig = ft.nameOrig AND lt.step = ft.step
JOIN circular_transfers ct ON lt.nameOrig = ct.nameOrig;

-- 10. Detecting Recursive Fraudulent Transactions
WITH RECURSIVE fraud_chain AS (
    SELECT nameOrig AS initial_account,
           nameDest AS next_account,
           step,
           amount,
           newbalanceOrig
    FROM transactions
    WHERE isFraud = 1 AND type IN ('TRANSFER', 'CASH_OUT')

    UNION ALL 

    SELECT fc.initial_account,
           t.nameDest, t.step, t.amount, t.newbalanceOrig
    FROM fraud_chain fc
    JOIN transactions t
    ON fc.next_account = t.nameOrig AND fc.step < t.step 
    WHERE t.isFraud = 1 AND t.type IN ('TRANSFER', 'CASH_OUT')
)
SELECT * FROM fraud_chain;







