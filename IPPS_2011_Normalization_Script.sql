/* The goal of this project wil be to take the ipps_2011 table and transform it into third normal form (3NF) */
SET SQL_SAFE_UPDATES = 0;
-- create table to upload excel file into
CREATE TABLE ipps_2011 (
    ipps_2011_id VARCHAR(45) NOT NULL,
    drg_definition VARCHAR(500),
    provider_id VARCHAR(45) NOT NULL,
    hospital_referral_region VARCHAR(500),
    total_discharges INT,
    average_covered_charges DOUBLE,
    average_total_payments DOUBLE,
    average_medicare_payments DOUBLE,
    hospital_name VARCHAR(500),
    state VARCHAR(4),
    PRIMARY KEY (ipps_2011_id)
);
-- load data using Local Infile method */
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'ipps_2011_complete.csv'
INTO TABLE ipps_2011
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
/* 160,847 rows have been uploaded to the table. The goal is to transform the table into 3NF, so the first thing that needs to be done is make sure the table conforms to 
first normal form */
SELECT 
    *
FROM
    ipps_2011;
DESCRIBE ipps_2011;
/* This table has a primary key (ipps_2011_id), no repeats in column names and all columns are the same datatype. However the data is not
atomic, specifically the 'drg_definition' column. The data  in the 'hospital_referral_region' doesn't seem atommic, but the reason for the way it's
written is do to the fact that some referral regions service patients living on the border of two or more states. This can help lesson ambiguity,
especially when the state the hospital is located in doesn't match the referral region.For now, the 'drg_definition column will be split' to create a 
'drg_code' column and 'drg_name' column.*/
-- this function will split the 'drg_definintion' column.
DELIMITER $$

CREATE FUNCTION SPLIT_STR(
  x VARCHAR(255),
  delim VARCHAR(12),
  pos INT
)
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN 
    RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
       LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
       delim, '');
END$$

DELIMITER ;
/* Now that the table has been transformed to 1NF, it needs to be transformed into second normal form (2NF). The table has no partial dependencies. all information in each row
is based on its respective primary key. Now the table must be tested for 3NF. The table has multiple transitive dependencies so the original ipps 2011 table will be split to
remove transitive dependencies.*/
-- the 'state' column is based on the 'hospital_name' column which in turn is based on the 'provider_id' column. these columns will be made into a new table 
CREATE TABLE hospital_info AS SELECT DISTINCT provider_id, hospital_name, state, hospital_referral_region FROM
    ipps_2011;
-- add  'provider_id' column as primary key
ALTER TABLE hospital_info
ADD PRIMARY KEY(provider_id);
-- this table will split the 'drg_definition' column and create a new table
CREATE TABLE drg AS 
	SELECT DISTINCT 
				SPLIT_STR(drg_definition, '-', 1) AS drg_code,
				SPLIT_STR(drg_definition, '-', 2) AS drg_meaning,
				drg_definition 
	FROM ipps_2011
ORDER BY drg_code ASC;
-- INDEX is missing for drg, so index will be created for drg
CREATE UNIQUE INDEX idx
ON drg(drg_code);
-- set 'drg_code' as primary key
ALTER TABLE drg
ADD PRIMARY KEY(drg_code);
-- a table with ipps_id, drg_code, provider_id, total_discharges, avg_cov_charges, avg_tot_payments,avg_med_payments
CREATE TABLE ipps_info AS 
	SELECT 
		ipps_2011_id,
        drg_definition,
        provider_id, 
        total_discharges,
        average_covered_charges,
        average_total_payments,
        average_medicare_payments
	FROM ipps_2011;
-- set ipps_2011_id as primary key
ALTER TABLE ipps_info
ADD PRIMARY KEY(ipps_2011_id);
-- the drg_definition will be replaced with drg_code from drg table
UPDATE ipps_info i
        INNER JOIN
    drg d ON i.drg_definition = d.drg_definition 
SET 
    i.drg_definition = d.drg_code;
-- change 'drg_definition' name to 'drg_code' 
ALTER TABLE ipps_info 
CHANGE drg_definition drg_code VARCHAR (255);
-- make 'drg_definition' and 'provider_id' foreigns keys to connect other two tables together
ALTER TABLE ipps_info
ADD FOREIGN KEY(drg_code)
	REFERENCES drg(drg_code),
ADD FOREIGN KEY(provider_id)
	REFERENCES hospital_info(provider_id);
-- drop drg_definition from drg to transform table to 3NF
ALTER TABLE drg
DROP COLUMN drg_definition;
-- remove ipps 2011 table
DROP TABLE ipps_2011;
/* the ipps_2011 was removed and transformed into three seperate tables in order to meet the requirements for 3NF*/
SELECT
	*
FROM ipps_info;
-- which drg in NY had the highest collective discharge count?
SELECT
	state,
    ipps_info.drg_code,
    drg.drg_meaning,
    SUM(ipps_info.total_discharges) AS discharge_count
FROM hospital_info
JOIN ipps_info ON hospital_info.provider_id  = ipps_info.provider_id
JOIN drg ON ipps_info.drg_code = drg.drg_code
WHERE state = 'NY' 
GROUP BY ipps_info.drg_code
ORDER BY SUM(ipps_info.total_discharges) DESC
LIMIT 1;
/* In the state of NY, the drg with the highest collective discharge count was 871 , SEPTICEMIA OR SEVERE SEPSIS W/O MV 96+ HOURS W MCC
 with a discharge count of 21,596.*/

-- what is the average medicare payment for SEPTICEMIA OR SEVERE SEPSIS W/O MV 96+ HOURS W MCC in NY?
SELECT
	hospital_info.state,
    drg_code,
	SUM(average_medicare_payments * total_discharges)/ SUM(total_discharges) AS AVG_MEDICARE_PAYMENTS
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.state = 'NY' AND drg_code = 871;
/* In the state of NY, the average medicare payment for SEPTICEMIA OR SEVERE SEPSIS W/O MV 96+ HOURS W MCC
is $16,195.60*/
-- what is the average total payment for SEPTICEMIA OR SEVERE SEPSIS W/O MV 96+ HOURS W MCC in NY?
SELECT
	hospital_info.state,
    drg_code,
    SUM(average_total_payments * total_discharges)/SUM(total_discharges) AS AVG_TOTAL_PAYMENTS
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.state = 'NY' AND drg_code = 871;
/* In the state of NY, the average total payment for SEPTICEMIA OR SEVERE SEPSIS W/O MV 96+ HOURS W MCC
is $17,315.26*/
-- what is the average cover charge for SEPTICEMIA OR SEVERE SEPSIS W/O MV 96+ HOURS W MCC in NY?
SELECT
	hospital_info.state,
    drg_code,
    SUM(average_covered_charges * total_discharges)/SUM(total_discharges) AS AVG_COVER_CHARGES
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.state = 'NY' AND drg_code = 871;
/* In the state of NY, the average cover charges for SEPTICEMIA OR SEVERE SEPSIS W/O MV 96+ HOURS W MCC
is $47,609.06*/
-- Which are the top 3 hospitals in NY that charge above the average cover charge for  SEPTICEMIA OR SEVERE SEPSIS W/O MV 96+ HOURS W MCC?
SELECT
	hospital_info.provider_id,
    hospital_name,
    ipps_info.average_covered_charges,
    ipps_info.drg_code
FROM hospital_info
JOIN ipps_info ON hospital_info.provider_id = ipps_info.provider_id
WHERE  ipps_info.average_covered_charges > (SELECT
												SUM(average_covered_charges * total_discharges)/SUM(total_discharges) AS AVG_COVER_CHARGES
											FROM ipps_info
											JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
											WHERE hospital_info.state = 'NY' AND drg_code = 871)
AND hospital_info.state = 'NY' AND ipps_info.drg_code = 871
ORDER BY ipps_info.average_covered_charges DESC
LIMIT 3 ;
SELECT
	hospital_info.provider_id,
    hospital_info.hospital_name,
    drg_code,
    total_discharges,
    average_covered_charges,
    average_total_payments,
    average_medicare_payments
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.provider_id = 330234 AND drg_code = 871;
-- What is the average amount of Debt Owed to Westchester Medical Center after average total payments are deducted?
SELECT
	hospital_info.provider_id,
    hospital_info.hospital_name,
    drg_code,
    ipps_info.average_covered_charges - ipps_info.average_total_payments AS AVG_DEBT
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.provider_id = 330234 AND drg_code = 871;
SELECT
	hospital_info.provider_id,
    hospital_info.hospital_name,
    drg_code,
    total_discharges,
    average_covered_charges,
    average_total_payments,
    average_medicare_payments
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.provider_id = 330119 AND drg_code = 871;
-- What is the average amount of Debt Owed to lenox Hill Hospital after average total payments are deducted?
SELECT
	hospital_info.provider_id,
    hospital_info.hospital_name,
    drg_code,
    ipps_info.average_covered_charges - ipps_info.average_total_payments AS AVG_DEBT
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.provider_id = 330119 AND drg_code = 871;
SELECT
	hospital_info.provider_id,
    hospital_info.hospital_name,
    drg_code,
    total_discharges,
    average_covered_charges,
    average_total_payments,
    average_medicare_payments
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.provider_id = 330214 AND drg_code = 871;  
-- What is the average amount of Debt Owed to NYU Hospital Center after average total payments are deducted?
SELECT
	hospital_info.provider_id,
    hospital_info.hospital_name,
    drg_code,
    ipps_info.average_covered_charges - ipps_info.average_total_payments AS AVG_DEBT
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.provider_id = 330214 AND drg_code = 871;  
/* The top 2 hospital with the most expensive covere charges for sepsis are in NYC, and 1 is in westchester county, right outside of city limits.The average cover charges are twice as high as
as the state-wide weighted average cover charge*/
-- Which are the top 3 hospitals in NY that charge below the average cover charge for  SEPTICEMIA OR SEVERE SEPSIS W/O MV 96+ HOURS W MCC
SELECT
	hospital_info.provider_id,
    hospital_name,
    ipps_info.average_covered_charges,
    ipps_info.drg_code
FROM hospital_info
JOIN ipps_info ON hospital_info.provider_id = ipps_info.provider_id
WHERE  ipps_info.average_covered_charges > (SELECT
												SUM(average_covered_charges * total_discharges)/SUM(total_discharges) AS AVG_COVER_CHARGES
											FROM ipps_info
											JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
											WHERE hospital_info.state = 'NY' AND drg_code = 871)
AND hospital_info.state = 'NY' AND ipps_info.drg_code = 871
ORDER BY ipps_info.average_covered_charges
LIMIT 3 ;
SELECT
	hospital_info.provider_id,
    hospital_info.hospital_name,
    drg_code,
    total_discharges,
    average_covered_charges,
    average_total_payments,
    average_medicare_payments
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.provider_id = 330340 AND drg_code = 871; 
-- What is the average amount of Debt Owed to South Hampton Hospital Center after average total payments are deducted?
SELECT
	hospital_info.provider_id,
    hospital_info.hospital_name,
    drg_code,
    ipps_info.average_covered_charges - ipps_info.average_total_payments AS AVG_DEBT
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.provider_id = 330340 AND drg_code = 871;
SELECT
	hospital_info.provider_id,
    hospital_info.hospital_name,
    drg_code,
    total_discharges,
    average_covered_charges,
    average_total_payments,
    average_medicare_payments
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.provider_id = 330372 AND drg_code = 871;  
-- What is the average amount of Debt Owed to Franklin Hospital Center after average total payments are deducted?
SELECT
	hospital_info.provider_id,
    hospital_info.hospital_name,
    drg_code,
    ipps_info.average_covered_charges - ipps_info.average_total_payments AS AVG_DEBT
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.provider_id = 330372 AND drg_code = 871;
SELECT
	hospital_info.provider_id,
    hospital_info.hospital_name,
    drg_code,
    total_discharges,
    average_covered_charges,
    average_total_payments,
    average_medicare_payments
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.provider_id = 330259 AND drg_code = 871;         
-- What is the average amount of Debt Owed to Mercy Hospital after average total payments are deducted?
SELECT
	hospital_info.provider_id,
    hospital_info.hospital_name,
    drg_code,
    ipps_info.average_covered_charges - ipps_info.average_total_payments AS AVG_DEBT
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.provider_id = 330259 AND drg_code = 871;
/* The bottom 3 hospital with the least expensive covere charges above the weighted mean coverage charge for sepsis are In Long Island. */
SELECT
	*
FROM ipps_info;
SELECT 
	*,
    hospital_info.hospital_name
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.state = 'NY' AND ipps_info.drg_code = 871
ORDER BY average_covered_charges;
