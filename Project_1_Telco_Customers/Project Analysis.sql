
-- Create a database called telco_customers 
CREATE DATABASE telco_customers;
GO

--Specify which database to perform the rest of the script
USE telco_customers;
GO

-- Create a table called customer_details to contain customer biographical data 
CREATE TABLE customer_details ( 
	customer_id VARCHAR(100) PRIMARY KEY, gender VARCHAR(100), senior_citizen VARCHAR(100), 
	spouse VARCHAR(100), dependents VARCHAR(100)
	);
-- Create a table called service_details to contain customer service information
CREATE TABLE service_details (
	customer_id VARCHAR(100) FOREIGN KEY REFERENCES customer_details (customer_id), tenure INT, phone_service VARCHAR(100), multiple_lines VARCHAR(100), internet_service VARCHAR(100), online_security VARCHAR(100), online_backup VARCHAR(100), device_protection VARCHAR(100), technical_support VARCHAR(100), streaming_tv VARCHAR(100), streaming_movies VARCHAR(100), contract_type VARCHAR(100), paperless_billing VARCHAR(100), payment_method VARCHAR(100), monthly_charges DEC(10,2), total_charges DEC(10,2), churn VARCHAR(100)
	);
GO

-- Ensure all tables are empty and ready for data importation
-- For the customer_details table we use DELETE statement because truncate cannot work with a referenced table
DELETE FROM customer_details;
TRUNCATE TABLE service_details;
GO

-- Use bulk insert to import data from csv files into each table
BULK INSERT customer_details
	FROM [File Path]
	WITH (
		FORMAT = 'CSV',
		FIRSTROW = 2
	);
BULK INSERT service_details
	FROM [File Path]
	WITH (
		FORMAT = 'CSV',
		FIRSTROW = 2
	);
GO

-- Display first 100 rows from each table to ensure the structure and format is sound
SELECT TOP 100 * FROM customer_details;
SELECT TOP 100 * FROM service_details;
GO

-- Identify the distinct information within each table column
-- Distinct data in the customer details table
SELECT DISTINCT gender FROM customer_details;
SELECT DISTINCT senior_citizen FROM customer_details;
SELECT DISTINCT spouse FROM customer_details;
SELECT DISTINCT dependents FROM customer_details;
GO

-- Distinct data in the services details table
SELECT DISTINCT phone_service FROM service_details;
SELECT DISTINCT multiple_lines FROM service_details;
SELECT DISTINCT internet_service FROM service_details;
SELECT DISTINCT online_security FROM service_details;
SELECT DISTINCT online_backup FROM service_details;
SELECT DISTINCT device_protection FROM service_details;
SELECT DISTINCT technical_support FROM service_details;
SELECT DISTINCT streaming_tv FROM service_details;
SELECT DISTINCT streaming_movies FROM service_details;
SELECT DISTINCT contract_type FROM service_details;
SELECT DISTINCT paperless_billing FROM service_details;
SELECT DISTINCT payment_method FROM service_details;
SELECT DISTINCT churn FROM service_details;
GO 

--Perform basic statistical analysis to get an idea of the numerical data by finding number of customers, and the sum, mean, largest and smallest values of the numerical data
SELECT COUNT(service_details.customer_id) AS 'Number of Customers'
	FROM service_details;
GO
SELECT 'Sum', SUM(service_details.monthly_charges) AS 'Monthly Charges', SUM(service_details.total_charges) AS 'Total Charges'
	FROM service_details
UNION
SELECT 'Average', AVG(service_details.monthly_charges), AVG(service_details.total_charges)
	FROM service_details
UNION
SELECT 'Minimum', MIN(service_details.monthly_charges), MIN(service_details.total_charges)
	FROM service_details
UNION
SELECT 'Maximum', MAX(service_details.monthly_charges), MAX(service_details.total_charges)
	FROM service_details;
GO

-- Select the top 50 rows with the highest total charges to get an idea of customer who spent the most
SELECT TOP 100 * FROM service_details
	INNER JOIN customer_details ON service_details.customer_id = customer_details.customer_id
	ORDER BY service_details.total_charges DESC;
GO

-- Identify how churning and current customers vary depending on gender
SELECT DISTINCT customer_details.gender, COUNT(service_details.churn) AS 'churners' 
	FROM service_details
	INNER JOIN customer_details ON customer_details.customer_id = service_details.customer_id
	WHERE service_details.churn = 'Yes'
	GROUP BY customer_details.gender;

SELECT DISTINCT customer_details.gender, COUNT(service_details.churn) AS 'current_customers' 
	FROM service_details
	INNER JOIN customer_details ON customer_details.customer_id = service_details.customer_id
	WHERE service_details.churn = 'No'
	GROUP BY customer_details.gender;
GO

-- Check to see which internet category has the highest number of current customers and largest sum of charges
-- Check also which category has the most churned customers and largest sum of charges
SELECT DISTINCT service_details.internet_service  AS 'internet_service_categories' , COUNT(service_details.internet_service) AS 'total_current_customers', SUM(service_details.monthly_charges) AS 'monthly_charges_sum', SUM(service_details.total_charges) AS 'total_charges_sum'
	FROM service_details
	WHERE service_details.churn = 'No'
	GROUP BY service_details.internet_service;

SELECT DISTINCT service_details.internet_service  AS 'internet_service_categories' , COUNT(service_details.internet_service) AS 'total_churned_customers', SUM(service_details.monthly_charges) AS 'gross_monthly_charges', SUM(service_details.total_charges) AS 'total_charges'
	FROM service_details
	WHERE service_details.churn = 'Yes'
	GROUP BY service_details.internet_service;

-- Examine how current customers and churned customers vary based on their tenure
SELECT DISTINCT service_details.tenure, COUNT(service_details.tenure) AS 'Number of Current Customers' 
	FROM service_details
	WHERE service_details.churn = 'No'
	GROUP BY service_details.tenure 
	ORDER BY service_details.tenure;

SELECT DISTINCT service_details.tenure, COUNT(service_details.tenure) AS 'Number of Churned Customers' 
	FROM service_details
	WHERE service_details.churn = 'Yes'
	GROUP BY service_details.tenure 
	ORDER BY service_details.tenure;

-- Create an additional column to represent time intervals in the tenure and group data
ALTER TABLE service_details
	ADD tenure_period VARCHAR(100);
GO

-- Update the new column
UPDATE service_details
	SET tenure_period = 'Under 6 months'
	WHERE tenure <= 6;
UPDATE service_details
	SET tenure_period = '6 months to 1 year'
	WHERE tenure > 6 AND tenure <= 12;
UPDATE service_details
	SET tenure_period = '1 to 2 years'
	WHERE tenure > 12 AND tenure <= 24;
UPDATE service_details
	SET tenure_period = '2 to 3 years'
	WHERE tenure > 24 AND tenure <= 36;	
UPDATE service_details
	SET tenure_period = '3 to 4 years'
	WHERE tenure > 36 AND tenure <= 48;
UPDATE service_details
	SET tenure_period = '4 to 5 years'
	WHERE tenure > 48 AND tenure <= 60;
UPDATE service_details
	SET tenure_period = '5 to 6 years'
	WHERE tenure > 60 AND tenure <= 72;

-- Exmine how the number of customers vary with each interval
SELECT service_details.tenure_period, COUNT(service_details.customer_id) AS 'Number of Churned Customers'
	FROM service_details
	WHERE service_details.churn = 'Yes'
	GROUP BY service_details.tenure_period
	ORDER BY COUNT(service_details.customer_id) DESC;

SELECT service_details.tenure_period, COUNT(service_details.customer_id) AS 'Number of Current Customers'
	FROM service_details
	WHERE service_details.churn = 'No'
	GROUP BY service_details.tenure_period
	ORDER BY COUNT(service_details.customer_id) DESC;
