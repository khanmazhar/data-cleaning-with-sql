DROP TABLE housing_data;
--creating table and importing data
CREATE TABLE housing_data (
	unique_id INTEGER,
	parcel_id VARCHAR(128),
	land_use VARCHAR(128),
	property_address TEXT,
	sale_date VARCHAR(128),
	sale_price VARCHAR(128),
	legal_refrence VARCHAR(128),
	sold_as_vacant VARCHAR(128),
	owner_name VARCHAR(128),
	owner_address VARCHAR(128),
	acreage float,
	tax_district VARCHAR(128),
	land_value INTEGER,
	building_value INTEGER,
	total_value INTEGER,
	year_buil INTEGER,
	bedrooms INTEGER,
	full_bath INTEGER,
	half_bath INTEGER
);

-- Inspect the data
SELECT * 
FROM housing_data;

-- Standardize the date formate
SELECT sale_date, CAST(sale_date as Date)
FROM housing_data;

UPDATE housing_data SET sale_date = CAST(sale_date as Date);
SELECT * FROM housing_data;

---------------------------------------------------
-- Populate the address column where values are null
SELECT *
FROM housing_data 
WHERE property_address IS NULL;
--we have 29 rows that are null

SELECT a.parcel_id,a.property_address,b.parcel_id,b.property_address,COALESCE(a.property_address,b.property_address)
FROM housing_data a
	JOIN housing_data b ON a.parcel_id = b.parcel_id
	AND a.unique_id != b.unique_id
WHERE a.property_address IS NULL;

--now we have our query ready, we can go ahead and update the table
UPDATE housing_data
SET property_address = COALESCE(a.property_address,b.property_address)
FROM housing_data a
	JOIN housing_data b ON a.parcel_id = b.parcel_id
	AND a.unique_id <> b.unique_id
WHERE a.property_address IS NULL;
-------------------------------------------------------------------
--splitting the property_address into address and city columns
SELECT property_address, SUBSTRING(property_address FROM '(.+),'), SUBSTRING(property_address FROM ',\s(.+\S$)')
FROM housing_data;

ALTER TABLE housing_data
ADD property_split_address VARCHAR(128);
UPDATE housing_data
SET property_split_address = SUBSTRING(property_address FROM '(.+),');

ALTER TABLE housing_data
ADD property_split_city VARCHAR(128);
UPDATE housing_data
SET property_split_city = SUBSTRING(property_address FROM ',\s(.+\S$)');

SELECT * FROM housing_data;
--------------------------------------------------------------------
--split the owner address into address, city and state columns
SELECT SPLIT_PART(owner_address,',',1),SPLIT_PART(owner_address,',',2),SPLIT_PART(owner_address,',',3)
FROM housing_data;

ALTER TABLE housing_data ADD owner_split_address VARCHAR(128);
ALTER TABLE housing_data ADD owner_split_city VARCHAR(128);
ALTER TABLE housing_data ADD owner_split_state VARCHAR(128);

UPDATE housing_data
SET owner_split_address = SPLIT_PART(owner_address,',',1), 
	owner_split_city = SPLIT_PART(owner_address,',',2),
	owner_split_state = SPLIT_PART(owner_address,',',3);

--------------------------------------------------------------------
--converting the 'y' and 'n' in sold_as_vacant column to 'Yes' and 'N'
SELECT sold_as_vacant, COUNT(sold_as_vacant) 
FROM housing_data
GROUP BY sold_as_vacant
ORDER BY 2;

SELECT sold_as_vacant, 
CASE 
	WHEN sold_as_vacant = 'Y' THEN 'Yes'
	WHEN sold_as_vacant = 'N' THEN 'No'
	ELSE sold_as_vacant
END
FROM housing_data;

UPDATE housing_data 
SET sold_as_vacant = CASE 
	WHEN sold_as_vacant = 'Y' THEN 'Yes'
	WHEN sold_as_vacant = 'N' THEN 'No'
	ELSE sold_as_vacant
END;
-----------------------------------------------------------------
--Removing Duplicates
SELECT  parcel_id,property_address,sale_price,sale_date,legal_refrence,COUNT(*) as duplicate_count
FROM housing_data
GROUP BY  parcel_id,property_address,sale_price,sale_date,legal_refrence
HAVING COUNT(*) > 1;

DELETE FROM housing_data
WHERE unique_id IN 
(
	SELECT unique_id
	FROM (
		SELECT unique_id,
		ROW_NUMBER() OVER (PARTITION BY parcel_id,
						   				property_address,
						   				sale_price,
						   				sale_date,
						   				legal_refrence 
						   				ORDER BY 
						   					unique_id) AS row_num 
	FROM housing_data) t 
WHERE t.row_num > 1);
	
