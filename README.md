# Synthetic-Financial-Datasets-For-Fraud-Detection
# Fraud Detection Using SQL on Bank Transaction Dataset

## Project Overview
This project focuses on detecting fraudulent transactions in a large banking dataset using advanced SQL queries. The dataset, sourced from Kaggle, contains transaction details such as origin and destination accounts, transaction amounts, balances, and fraud indicators. We use SQL techniques like recursive CTEs, window functions, subqueries, and complex joins to identify suspicious activity and validate transaction consistency.

## Dataset
- **Source**: [Kaggle - Paysim1 Banking Dataset](https://www.kaggle.com/datasets/ealaxi/paysim1)
- **File**: `PS_20174392719_1491204439457_log.csv`
- **Columns**:
  - `step`: Time step of the transaction.
  - `type`: Type of transaction (`TRANSFER`, `CASH_OUT`, etc.).
  - `amount`: Transaction amount.
  - `nameOrig`: Origin account identifier.
  - `oldbalanceOrg`: Initial balance of the origin account.
  - `newbalanceOrig`: Updated balance of the origin account.
  - `nameDest`: Destination account identifier.
  - `oldbalanceDest`: Initial balance of the destination account.
  - `newbalanceDest`: Updated balance of the destination account.
  - `isFraud`: Indicates if the transaction is fraudulent.
  - `isFlaggedFraud`: Indicates if the transaction was flagged as potentially fraudulent.

## SQL Queries Overview
1. **Recursive Fraudulent Transaction Detection**:
   - Detects chains of fraudulent transfers across accounts.
   
2. **Rolling Fraud Detection**:
   - Tracks fraudulent behavior within a 5-step window using SQL window functions.
   
3. **Complex Fraud Detection with Multiple CTEs**:
   - Identifies accounts with suspicious activity based on large transfers, no balance changes, and flagged transactions.

4. **Balance Validation**:
   - Validates whether computed balances match the actual balances in the dataset.

## Usage
1. **Load Dataset into MySQL**:

2. **Run SQL Queries**:
- Open your MySQL client or workbench.
- Copy and paste the provided SQL queries to detect fraud, validate balances, and perform various other analyses.

## Project Structure
- `fraud_detection_queries.sql`: Contains all SQL queries used for fraud detection and balance validation.
- `README.md`: This readme file.
- `transactions_table.sql`: SQL script to create the `transactions` table used in the project.

## License
This project is open-source and available under the [MIT License](LICENSE).

