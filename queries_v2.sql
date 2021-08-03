SELECT * FROM housing_data;

ALTER TABLE housing_data DROP COLUMN owner_address;
ALTER TABLE housing_data DROP COLUMN property_address;

--create a table for land_use
CREATE TABLE land_use
(
	id SERIAL,
	title VARCHAR(128),
	PRIMARY KEY (id)
);
CREATE TABLE sold_as_vacant (
	id SERIAL,
	option VARCHAR(128),
	PRIMARY KEY(id)
);
CREATE TABLE tax_district
(
	id SERIAL,
	name VARCHAR(128),
	PRIMARY KEY(id)
);
CREATE TABLE property_split_city 
(
	id SERIAL,
	name VARCHAR(128),
	PRIMARY KEY(id)
);
CREATE TABLE owner_split_city
(
	id SERIAL,
	name VARCHAR(128),
	PRIMARY KEY(id)
);
CREATE TABLE owner_split_state 
(
	id SERIAL,
	name VARCHAR(128),
	PRIMARY KEY(id)
);

--inserting data into land_use from housing_data
INSERT INTO land_use (title) SELECT DISTINCT(housing_data.land_use) FROM housing_data;
SELECT * FROM land_use;

--inserting data into sold_as_vacant table from housing_data
INSERT INTO sold_as_vacant (option) SELECT DISTINCT(housing_data.sold_as_vacant) FROM housing_data;
SELECT * FROM sold_as_vacant;

--inserting data into tax_district table from housing_data
INSERT INTO tax_district (name) SELECT DISTINCT(housing_data.tax_district) FROM housing_data;
SELECT * FROM tax_district;

--inserting data into property_split_city from housing_data
INSERT INTO property_split_city (name) SELECT DISTINCT(housing_data.property_split_city) FROM housing_data;
SELECT * FROM property_split_city;

--inserting data into owner_split_city from housing_data
INSERT INTO owner_split_city (name) SELECT DISTINCT(housing_data.owner_split_city) FROM housing_data;
SELECT * FROM owner_split_city;

--inserting data into owner_split_state from housing_data
INSERT INTO owner_split_state (name) SELECT DISTINCT(housing_data.owner_split_state) FROM housing_data;
SELECT * FROM owner_split_state;

--now we have our tables created. to normalize, we need to create foreign keys in our housing_data table
ALTER TABLE housing_data 
ADD COLUMN land_use_id INTEGER,
ADD COLUMN sold_as_vacant_id INTEGER,
ADD COLUMN tax_district_id INTEGER,
ADD COLUMN property_split_city_id INTEGER,
ADD COLUMN owner_split_city_id INTEGER,
ADD COLUMN owner_split_state_id INTEGER;
SELECT * FROM housing_data;

-- adding foreign keys to housing_data table
UPDATE housing_data 
SET land_use_id = (SELECT land_use.id FROM land_use WHERE land_use.title = housing_data.land_use);

UPDATE housing_data
SET sold_as_vacant_id = (SELECT sold_as_vacant.id FROM sold_as_vacant WHERE sold_as_vacant.option = housing_data.sold_as_vacant);

UPDATE housing_data
SET tax_district_id = (SELECT tax_district.id FROM tax_district WHERE tax_district.name = housing_data.tax_district);

UPDATE housing_data
SET property_split_city_id = (SELECT property_split_city.id FROM property_split_city WHERE property_split_city.name = housing_data.property_split_city);

UPDATE housing_data
SET owner_split_city_id = (SELECT owner_split_city.id FROM owner_split_city WHERE owner_split_city.name = housing_data.owner_split_city);

UPDATE housing_data
SET owner_split_state_id = (SELECT owner_split_state.id FROM owner_split_state WHERE owner_split_state.name = housing_data.owner_split_state);

--now we have our foreign keys in housing_data table, we can go ahead and delete the columns for which we created foreign keys
ALTER TABLE housing_data
DROP COLUMN sold_as_vacant,
DROP COLUMN tax_district,
DROP COLUMN property_split_city,
DROP COLUMN owner_split_city,
DROP COLUMN owner_split_state,
DROP COLUMN land_use;

--reconstructing the orignal housing_data table
SELECT unique_id,parcel_id, sale_date,sale_price,legal_refrence,owner_name,acreage,land_value,building_value, total_value,year_buil,bedrooms,full_bath,half_bath,owner_split_address,
land_use.title,property_split_city.name,sold_as_vacant.option,tax_district.name, owner_split_city.name,owner_split_state.name
FROM housing_data
	JOIN land_use ON housing_data.land_use_id = land_use.id 
	JOIN owner_split_city ON housing_data.owner_split_city_id = owner_split_city.id 
	JOIN owner_split_state ON housing_data.owner_split_state_id = owner_split_state.id 
	JOIN property_split_city ON housing_data.property_split_city_id = property_split_city.id 
	JOIN sold_as_vacant ON housing_data.sold_as_vacant_id = sold_as_vacant.id 
	JOIN tax_district ON housing_data.tax_district_id = tax_district.id;

--on a small scale, such normalization might not be required, but for larger applications, normalizations increases the speed. we really are trading space for speed by performing such normalization
