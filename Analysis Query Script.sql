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
-- Hospital with the lowest average covered charge for 871
SELECT 
	*,
    hospital_info.hospital_name
FROM ipps_info
JOIN hospital_info ON ipps_info.provider_id = hospital_info.provider_id
WHERE hospital_info.state = 'NY' AND ipps_info.drg_code = 871
ORDER BY average_covered_charges;