/* 
Project: Home Health Agency Data Analysis 
Purpose: Explore home health agency characteristics, patient care ratings, services offered, and Medicare spending measures
Source Tables:
	- HHA_Info
	- HHA_QualityMeasures
Data source: CMS Home Health Care Agencies (data.cms.gov)
*/

/* 1. Explore Agency Data */

-- Preview agency information
SELECT TOP 100
CMS_Certification_Number_CCN, 
Provider_Name, 
State, 
City_Town, 
Type_of_Ownership, 
Certification_Date
FROM HHA_Info
ORDER BY State, Provider_Name

-- Count agencies nationwide
SELECT COUNT (*) AS TotalAgenciesNationwide
FROM HHA_Info

-- Check for duplicate agency identifiers
SELECT CMS_Certification_Number_CCN,
COUNT(*)
FROM HHA_Info
GROUP BY CMS_Certification_Number_CCN HAVING COUNT(*) > 1
 
-- Agencies per state
SELECT State, COUNT(*) AS NumberOfAgencies
FROM HHA_Info
GROUP BY State
ORDER BY NumberOfAgencies DESC

-- Distribution of ownership types
SELECT Type_of_Ownership, COUNT(*) AS AgencyCount
FROM HHA_Info
GROUP BY Type_of_Ownership

-- Preview quality measures
SELECT TOP 100 *
FROM HHA_QualityMeasures

/* 2. Prepare combined data set */

-- Combine agency information with quality measures
DROP Table if exists #Home_Health

CREATE Table #Home_Health (
CCN varchar(6),
Provider_Name nvarchar(255),
State nvarchar(255), 
Medicare_Spend_Index nvarchar(255),
Episode_Count nvarchar(255),
Type_Ownership nvarchar(255),
Star_Rating nvarchar(255))

INSERT into #Home_Health

SELECT 
RIGHT('0000000' + CAST(info.CMS_Certification_Number_CCN AS varchar(10)), 6),
info.Provider_Name, 
info.State,
quality.Medicare_Spending_Rate, 
quality.Medicare_Spending_Episodes, 
info.Type_of_Ownership,
quality.Patient_Care_Star_Rating
FROM HHA_Info info
JOIN HHA_QualityMeasures quality
	ON info.CMS_Certification_Number_CCN = quality.CCN

-- Checking for missing values
SELECT 
	COUNT(*) AS total_rows,
	COUNT(*) - COUNT(Provider_Name) AS missing_provider_name,
	COUNT(*) - COUNT(State) AS missing_state,
	COUNT(*) - COUNT(Medicare_Spend_Index) AS missing_medicare_spend_index,
	COUNT(*) - COUNT(Episode_Count) AS missing_episode_count,
	COUNT(*) - COUNT(Type_Ownership) AS missing_ownership,
	COUNT(*) - COUNT(Star_Rating) AS missing_rating
FROM #Home_Health;

/* 3. Patient care star ratings */

-- Average patient care rating by state
DROP TABLE if exists #State_Ratings;
SELECT 
	State, ROUND(AVG(TRY_CAST(Star_Rating AS FLOAT)),2) AS avg_rating,
	COUNT(*) AS provider_count
INTO #State_Ratings
FROM #Home_Health
WHERE TRY_CAST(Star_Rating AS FLOAT) >= 1
GROUP BY State

-- Average patient care rating by agency ownership type 
DROP TABLE if exists #Ownership_Ratings;
SELECT 
	Type_Ownership, ROUND(AVG(TRY_CAST(Star_Rating AS FLOAT)),2) AS avg_rating,
	COUNT(*) AS provider_count
INTO #Ownership_Ratings
FROM #Home_Health
WHERE TRY_CAST(Star_Rating AS FLOAT) >= 1
GROUP BY Type_Ownership

SELECT *
FROM #Ownership_Ratings
ORDER BY avg_rating DESC;

-- Average patient care rating by provider
DROP TABLE if exists #Provider_Ratings;
SELECT 
	CCN, 
	Provider_Name,
	State,
	TRY_CAST(Star_Rating AS FLOAT) AS avg_rating
INTO #Provider_Ratings
FROM #Home_Health
WHERE TRY_CAST(Star_Rating AS FLOAT) >= 1

SELECT *
FROM #Provider_Ratings
ORDER BY avg_rating DESC, State, Provider_Name;

/* 5. Medicare Spending */

-- Compare average spending index and ratings by state 
SELECT 
	State,
	ROUND(
		AVG(TRY_CAST(Medicare_Spend_Index AS FLOAT)),3) AS avg_spend_index,
	ROUND(
		AVG(TRY_CAST(Star_rating AS FLOAT)), 2) AS avg_star_rating,
	COUNT(*) AS provider_count
FROM #Home_Health
WHERE TRY_CAST(Medicare_Spend_Index AS FLOAT)IS NOT NULL
	AND TRY_CAST(Star_Rating AS FLOAT) >= 1
GROUP BY State
ORDER BY avg_spend_index DESC;

-- Prepare data for a spending vs rating plot
SELECT 
	CCN, 
	Provider_Name, 
	State,
	Type_Ownership,
	TRY_CAST(Medicare_Spend_Index AS FLOAT) AS Medicare_Spend_Index,
	TRY_CAST(Episode_Count AS FLOAT) AS Episode_Count,
	TRY_CAST(Star_rating AS FLOAT) AS Star_Rating
FROM #Home_Health
WHERE TRY_CAST(Medicare_Spend_Index AS FLOAT)IS NOT NULL
	AND TRY_CAST(Star_Rating AS FLOAT) >= 1

/* Home Health Services */

-- Number of service types offered by each agency
SELECT 
CMS_Certification_Number_CCN, Provider_Name, State,
(CASE WHEN CAST(offers_nursing_care_services AS NVARCHAR(10)) IN ('Yes', '1') THEN 1 ELSE 0 END
+ CASE WHEN CAST(offers_physical_therapy_services AS NVARCHAR(10)) IN ('Yes', '1') THEN 1 ELSE 0 END
+ CASE WHEN CAST(offers_occupational_therapy_services AS NVARCHAR(10)) IN ('Yes', '1') THEN 1 ELSE 0 END
+ CASE WHEN CAST(offers_speech_pathology_services AS NVARCHAR(10)) IN ('Yes', '1') THEN 1 ELSE 0 END
+ CASE WHEN CAST(offers_medical_social_services AS NVARCHAR(10)) IN ('Yes', '1') THEN 1 ELSE 0 END
+ CASE WHEN CAST(offers_home_health_aide_services AS NVARCHAR(10)) IN ('Yes', '1') THEN 1 ELSE 0 END)
AS Service_Count
FROM HHA_Info
ORDER BY Service_Count ASC

-- Number of services offered in each state
DROP TABLE if exists #State_FullService;

With ServiceCounts AS (
SELECT 
CMS_Certification_Number_CCN, Provider_Name, State,
(CASE WHEN CAST(offers_nursing_care_services AS NVARCHAR(10)) IN ('Yes', '1') THEN 1 ELSE 0 END
+ CASE WHEN CAST(offers_physical_therapy_services AS NVARCHAR(10)) IN ('Yes', '1') THEN 1 ELSE 0 END
+ CASE WHEN CAST(offers_occupational_therapy_services AS NVARCHAR(10)) IN ('Yes', '1') THEN 1 ELSE 0 END
+ CASE WHEN CAST(offers_speech_pathology_services AS NVARCHAR(10)) IN ('Yes', '1') THEN 1 ELSE 0 END
+ CASE WHEN CAST(offers_medical_social_services AS NVARCHAR(10)) IN ('Yes', '1') THEN 1 ELSE 0 END
+ CASE WHEN CAST(offers_home_health_aide_services AS NVARCHAR(10)) IN ('Yes', '1') THEN 1 ELSE 0 END)
AS Service_Count
FROM HHA_Info )

SELECT
	State,
	COUNT(*) AS provider_count,
	SUM(CASE WHEN Service_Count = 6 THEN 1 ELSE 0 END) AS full_service_count,
	ROUND(100.0 * SUM(CASE WHEN Service_Count = 6 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_full_service
INTO #State_FullService
FROM ServiceCounts
GROUP BY State
HAVING COUNT(*) >= 20;

SELECT * FROM #State_FullService
ORDER BY pct_full_service DESC;







