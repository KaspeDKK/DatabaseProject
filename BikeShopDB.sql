SET SQL_SAFE_UPDATES = 0;
DROP DATABASE IF EXISTS BikeRepairShop;
CREATE DATABASE BikeRepairShop;
USE BikeRepairShop;

CREATE TABLE Customer (
    customerCPR		CHAR(10),               -- 123456 78910
    first_name		VARCHAR(20),            -- Reasonable limit
    last_name		VARCHAR(20),            -- Reasonable limit
    email_address	VARCHAR(73),            -- 64 max length + gmail.com, which should cover the majority of emails. 
    phone_number	VARCHAR(10) NOT NULL,   -- 1-2 3-4 5-6 7-8 - only 8 because only danes allowed as customers since only danes have CPR number. We choose phone nr to have not null. Not because its required for functionality in the DB, but because it makes sense for the business to have at least 1 form of contact with the customer.

    PRIMARY KEY(customerCPR)
);

CREATE TABLE Address (
    customerCPR		CHAR(10),   -- fk
    street_name   VARCHAR(64),  -- 64 max length is chosen to both cover the average street name length as well as outliers that might be longer
    civic_number  VARCHAR(6),   -- refers to the specific house number, VARCHAR to account for adresses like Kollegiebakken '15A'
    city          VARCHAR(64),  -- 64 max length due to some cases of cities having very long names
    ZIP_code      CHAR(4),      -- we will use char(4) because all danish postcodes are 4 digits always, and only danes are allowed to repair in the shop since CPR is required to be a customer. Why not INT? because the example of DR Byen : "0999" which starts with a 0. Which is not possible for INT

    PRIMARY KEY(customerCPR),
    FOREIGN KEY(customerCPR) 
        REFERENCES Customer(customerCPR) 
        ON DELETE CASCADE       -- We dont need to retain adress if a customer is removed
);

CREATE TABLE Manufacturer (
    manufacturer_ID     INT,            -- we will use 5 digits. its sufficient to always have a unique ID, 6 million possibilites - name is insufficient as we operate with bikes and parts from many countries, and cant garuantee that there arent two companies called E.g "Bikeparts". ID will be assigned by the bikeshop and we wont use autoincrement in accordance with the projects policy.
    manufacturer_name   VARCHAR(64),    -- 64 Characters should be enough for manufacturer name, changed from "name" since name is a keyword. We could use it, but we do not consider that a good practice 

    PRIMARY KEY(manufacturer_ID)
);

CREATE TABLE Bikes (
    bike_code       VARCHAR(10),    -- Its undefined in the requirements what the code would look like. Its possible it can be e.g "A-49-Zero" so it should be a varchar
    manufacturer_ID INT,            -- fk
    type            VARCHAR(20),    -- Bike type name e.g "Mountain Bike"
    speeds          INT,            -- number of gears on the bike
    weight          DECIMAL(5,2),   -- weight in kg
    wheel_diameter  DECIMAL(4,1),   -- diameter in inches

    PRIMARY KEY (bike_code),   

    FOREIGN KEY (manufacturer_ID) 
        REFERENCES Manufacturer(manufacturer_ID)
        ON DELETE CASCADE -- If a manufacturer is removed we can assume that the bikes they produce are no longer relevant either.
);

CREATE TABLE Parts (
    part_code       VARCHAR(10),    -- Same argument as bike code
    manufacturer_ID INT,            -- fk
    description     VARCHAR(256),   -- Fair length (rougly 50 words on average). Should be enough for a short description.
    unit_price      DECIMAL(8,2),

    PRIMARY KEY (part_code),   

    FOREIGN KEY (manufacturer_ID) 
        REFERENCES Manufacturer(manufacturer_ID)
        ON DELETE CASCADE -- If a manufacturer is removed we can assume that the parts they produce are no longer relevant either.
);

CREATE TABLE RepairJobs (

    repair_ID   INT,            -- Unique ID with the same complexity as manufacturers ID. Each repair job is uniquely identified by a manually assigned repair_ID. It is a surrogate key because no natural key (e.g., date + customer + bike) can guarantee uniqueness as a customer may bring in two bikes of the same exact variant on the same date. We avoid AUTO_INCREMENT in line with project policy and assume repair IDs are generated systematically by the business (e.g., “R001”, “R002”, …)
    customerCPR CHAR(10),       -- fk
    bike_code   VARCHAR(10),    -- fk
    repair_date DATE,
    duration    INT,            -- duration in minutes, since time would be a bit more complex to handle, we could also use decimal but then 1 hour 30 minutes would be 1.5. We may as well input 90 minutes
    
    total_cost DECIMAL(8,2),    -- we will calculate this later as its a derived attribute. Will be null until computed

    PRIMARY KEY (repair_ID),

    FOREIGN KEY (customerCPR) 
        REFERENCES Customer(customerCPR)
        ON DELETE RESTRICT,          -- dont delete a customer thats referenced in repairjobs.
    
    FOREIGN KEY (bike_code)
        REFERENCES Bikes(bike_code)
        ON DELETE RESTRICT          -- dont delete a bike thats referenced in repairjobs.
);

CREATE TABLE Uses (
    repair_ID   INT,            -- fk
    part_code   VARCHAR(10),    -- fk
    quantity    INT,            -- number of parts used.

    PRIMARY KEY (repair_ID, part_code),

    FOREIGN KEY (repair_ID) 
        REFERENCES RepairJobs(repair_ID)
        ON DELETE CASCADE,      -- No reason to keep uses if the repair job is removed

    FOREIGN KEY (part_code) 
        REFERENCES Parts(part_code)
);

CREATE TABLE CompatibleParts (
    bike_code   VARCHAR(10), -- fk
    part_code   VARCHAR(10), -- fk

    PRIMARY KEY (bike_code, part_code),

    FOREIGN KEY (bike_code) 
        REFERENCES Bikes(bike_code)
        ON DELETE CASCADE, -- If a bike is removed that compatibility is automatically void

    FOREIGN KEY (part_code) 
        REFERENCES Parts(part_code)
        ON DELETE CASCADE -- If a part is removed that compatibility is automatically void
);

-- INSERT DATA BELOW
-- MANUFACTURERS
-- Two manufacturers share the same name ("Bike Parts") but have unique IDs to demonstrate
-- that name alone is not sufficient as a primary key.
INSERT INTO Manufacturer VALUES
(11111, 'Bike Parts'),
(22222, 'Bike Parts'),
(33333, 'Only Bikes'),
(43126, 'All Things Bikes'),
(12372, 'Quality Bikes'),
(55555, 'Part Performance'),
(98765, 'Nordic Speed');

-- CUSTOMERS
-- All have 10-char CPRs, 8-digit Danish phone numbers, and unique CPR primary keys.
-- Two customers share the same last name and even live together (shows same address later).
-- One customer has an extremely long email to show VARCHAR(73) works.
INSERT INTO Customer VALUES
('1308981817','John','Name','John@gmail.com','22334455'),
('1212824762','Jane','Doe','JaneTheDoeWithLongEmailAddress@gmail.com','12312312'),
('3108789976','Joergen','Von Einer','abc@gmail.com','11111123'),
('0101014321','Mads','Andersen','MAndersen@outlook.com','12345678'),
('1212988825','Emma','Sky','emmasky@gmail.com','87654321'),
('2307127139','Jan','Mikkelson','Unreasonablylongemailthatiswaytohardtorememberinownhead@gmail.com','88884312'),
('1203112231','Mia','Mikkelson','mia23153@outlook.com','88776655'),
('1606047842','Karl Emil','Kraghe','altdetgode@gmail.com','23234490'),
('1104671111','Maria','Nielsen','Nielsen.m@outlook.com','11992288'),
('0102037755','Ella','Larsen','elllar@gmail.com','12323556'),
('1309092385','Agnes','Andersen','Hemmeligperson@gmail.com','27346892'),
('1010828850','Valdemar','Pedersen','Valde.ped27823@outlook.com','49027643'),
('0710299836','Matheo','Soerensen','2324234MS@gmail.com','38127374'),
('1111111111','Esther','Jensen','Estherjensen@outlook.com','22736475'),
('2212978765','Hannah','Larsen','hannnnnnnnnnnnnnnnnnnnah83457@gmail.com','18239102');

-- ADDRESSES
-- Includes edge cases: 
-- - civic numbers with letters (e.g. "4A"), 
-- - very long street name, 
-- - ZIP codes with leading zeros ("0999"), 
-- - two customers sharing the same address (Mia and Jan Mikkelson)
INSERT INTO Address VALUES
('1308981817','Roskildevej','12','Haderslev','6070'),
('1212824762','Hovedvej','4A','Roskilde','4000'),
('3108789976','Faglaertvej','67','Herlev','2730'),
('0101014321','Landevej','419','Slagelse','4270'),
('1212988825','Uhyggeligvej','7B','Herning','6933'),
('2307127139','Funktionelletbanevej','9980C','Aarhus','8000'),
('1203112231','Funktionelletbanevej','9980C','Aarhus','8000'), -- shared address
('1606047842','Havvej','21','Skagen','9990'),
('1104671111','Nyvej','420','Ishoej','2625'),
('0102037755','Strandvej','152','Rungsted','2960'),
('1309092385','Bagsværdvej','99','Bagsvaerd','2800'),
('1010828850','Ballerupvej','31D','Ballerup','2740'),
('0710299836','Kongensvej','1','Kokkedal','2970'),
('1111111111','En rigtig vej med utrolig langt navn som en test af grænse på 64','12345','Helsinge','0999'),
('2212978765','Denforkertevej','54321','Koebenhavn S','2300');

-- BIKES
-- Manufacturer 11111 and 22222 both named "Bike Parts" to show name-duplication tolerance.
-- IDs are manually assigned, bike_code uses VARCHAR with mixed letters/numbers to illustrate flexibility.
INSERT INTO Bikes VALUES
('BK-A100','11111','Mountain Bike',18,14.50,27.5),
('BK-B200','22222','Mountain Bike',18,14.55,27.5), -- nearly identical bike from different manufacturer
('BK-C300','43126','Road Bike',22,9.50,28.0),
('BK-D400','33333','Hybrid',21,12.10,27.0),
('BK-E500','12372','Electric',8,24.00,29.0),
('BK-F600','98765','City',7,11.20,26.0);

-- PARTS
-- Same idea: multiple manufacturers with overlapping part names, long descriptions, and realistic prices.
INSERT INTO Parts VALUES
('P-100','11111','Bike chain 9-speed - stainless steel, rust resistant, designed for mountain bikes',120.50),
('P-101','22222','Bike chain 9-speed - identical name but different manufacturer',119.99),
('P-200','11111','Front wheel 27.5 inch, reinforced rim, compatible with BK-A100',340.00),
('P-300','55555','Hydraulic brake lever with ergonomic grip and anti-slip design',290.00),
('P-400','55555','Bike seat ergonomic with double padding and weatherproof leather cover',150.00),
('P-500','43126','Pedal set with reflectors, alloy build',180.00),
('P-600','98765','Universal inner tube, 26-29 inch range',90.00);

-- REPAIR JOBS
-- Manually assigned IDs, demonstrating surrogate key logic. (we have to argue why this is preffered over composite key (CPR, Bike, Date))
-- total_cost remains NULL (derived attribute later)
INSERT INTO RepairJobs VALUES
(1,'1308981817','BK-F600','2023-12-19',90,NULL),
(2,'1212824762','BK-B200','2024-03-15',60,NULL),
(3,'3108789976','BK-C300','2024-04-10',120,NULL),
(4,'0101014321','BK-D400','2025-04-12',45,NULL),
(5,'1212988825','BK-E500','2025-05-01',180,NULL),
(6,'1203112231','BK-A100','2025-05-01',100,NULL),
(7,'1203112231','BK-A100','2025-05-15',25,NULL); -- No parts used in this job

-- USES
-- Illustrates 1-to-many and many-to-many relationships.
-- One repair uses multiple parts, some parts used multiple times, etc.
INSERT INTO Uses VALUES
(1,'P-300', '55555', 1),
(1,'P-600', '98765', 2),
(2,'P-101', '22222' ,1),
(3,'P-400', '55555', 1),
(4,'P-500', '43126', 1),
(5,'P-400', '55555', 2),
(5,'P-600', '98765', 1),
(6,'P-100', '11111', 3),
(6,'P-200', '11111', 1);

-- COMPATIBLE PARTS
-- Demonstrates many-to-many relationships between bikes and parts.
-- Some parts compatible with multiple bikes and vice versa.
INSERT INTO CompatibleParts VALUES
('BK-A100','P-100','11111','11111'),
('BK-A100','P-200','11111','11111'),
('BK-B200','P-101','22222','22222'),
('BK-C300','P-400'.'43126','55555'),
('BK-D400','P-500','33333','43126'),
('BK-E500','P-400','12372','55555'),
('BK-E500','P-600','12372','98765'),
('BK-F600','P-600','98765','98765'),
('BK-F600','P-300','98765','55555');
