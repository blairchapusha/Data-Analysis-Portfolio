--Create database to store new data

CREATE DATABASE credit_data;
GO

--Specify the database

USE credit_data;
GO

--Create and format table to which the data will be inserted
--Ensure the columns do not take null values so that no blank data observations are imported
--Set client_id as the unique primary key

CREATE TABLE customer_data (
client_id INT NOT NULL PRIMARY KEY, customer_status VARCHAR(100) NOT NULL, age INT NOT NULL,
gender VARCHAR(1) NOT NULL, dependents INT NOT NULL, education VARCHAR(100) NOT NULL,
marital_status VARCHAR(100) NOT NULL, income VARCHAR(100) NOT NULL, months_active INT NOT NULL,
months_unused INT NOT NULL, credit_limit DECIMAL(10,2) NOT NULL, average_open_to_buy DECIMAL(10,2) NOT NULL,
revolving_balance DECIMAL(10,2) NOT NULL, transaction_amount DECIMAL(10,2) NOT NULL, transaction_count INT NOT NULL,
);
GO

--Ensure table is empty using truncate before importing data

TRUNCATE TABLE customer_data;
GO


--Utilize bulk insert to import data from CSV dataset using specified path, after modifying CSV file to match customer_data table
--Make the second row of the data in the CSV file as the first row of the table customer_data
BULK INSERT customer_data
FROM [FILE PATH]
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2
)
GO

--Display table with data with further analyze

SELECT *
FROM customer_data;
GO

--Remove any rows that contain incomplete or unusable data

DELETE FROM customer_data
WHERE education = 'unknown'
	OR marital_status = 'unknown' 
	OR income = 'unknown';
GO

--Perform analysis to better understand the dataset

SELECT count(*) FROM customer_data;
GO
SELECT DISTINCT age FROM customer_data;
GO
SELECT AVG(age) AS average_age FROM customer_data;

--Create columns to specify ranges to the data

ALTER TABLE customer_data
ADD age_group VARCHAR(100), 
	duration VARCHAR(100),
	usage VARCHAR(100);

--Create age ranges in increments of 11

UPDATE customer_data
SET age_group = '20-30'
WHERE age BETWEEN 20 AND 30;
GO
UPDATE customer_data
SET age_group = '30-40'
WHERE age BETWEEN 30 AND 40;
GO
UPDATE customer_data
SET age_group = '40-50'
WHERE age BETWEEN 40 AND 50;
GO
UPDATE customer_data
SET age_group = '50-75'
WHERE age BETWEEN 50 AND 75;
GO

--Update duration with two catergories

UPDATE customer_data
SET duration = 'Short-term Customer'
WHERE months_active <= 24;
GO
UPDATE customer_data
SET duration = 'Long-term Customer'
WHERE months_active > 24;
GO

--Set usage catergories

UPDATE customer_data
SET usage = 'Light Use'
WHERE revolving_balance < 500;
GO
UPDATE customer_data
SET usage = 'Fair Use'
WHERE revolving_balance BETWEEN 500 AND 1500;
GO
UPDATE customer_data
SET usage = 'Heavy Use'
WHERE revolving_balance > 1500;
GO
