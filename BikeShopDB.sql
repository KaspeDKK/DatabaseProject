SET SQL_SAFE_UPDATES = 0;
DROP DATABASE IF EXISTS BikeRepairShop;
CREATE DATABASE BikeRepairShop;
USE BikeRepairShop;


-- Creation of tables

CREATE TABLE Manufacturer
(
    manufacturerID INT(5), -- 5 Characters is sufficient to always have a unique ID, 6 million possibilites
    manufacturer_name VARCHAR(64), -- 64 Characters should be enough for manufacturer name, changed from "name" since name is a keyword. We could use it, but we do not consider that a good practice 

    PRIMARY KEY(manufacturerID)
);


CREATE TABLE Customer 
(
    customerCPR		VARCHAR(10), -- 123456 78910
    email_adress	VARCHAR(73), -- 64 max length + gmail.com, which should cover the majority of emails
    phone_number	VARCHAR(10), -- 1-2 3-4 5-6 7-8 9-10
    first_name		VARCHAR(20), -- Reasonable limit
    last_name		VARCHAR(20), -- Reasonable limit

    PRIMARY KEY(CPR)
);


CREATE TABLE Address
(
    street_name   VARCHAR(64), -- 64 max length is chosen to both cover the average street name length as well as outliers that might be longer
    civic_number  VARCHAR(6),  -- refers to the specific house number, VARCHAR to account for adresses like Kollegiebakken '15A'
    city          VARCHAR(64), -- 64 max length due to some cases of cities having very long names
    ZIP_code      VARCHAR(12), -- 12 max length, ZIP code is represented by a varchar instead of an int due to large countries like Canada and the UK using a mix of numbers and letters
    CPR           VARCHAR(10), -- Foreign key

    PRIMARY KEY(CPR),
    FOREIGN KEY(CPR) REFERENCES Customer(CPR) ON DELETE CASCADE
);


CREATE TABLE Parts
  (
    serial_number      VARCHAR(20) PRIMARY KEY,                             -- SerialNumber: Globally unique identifier for each part. Primary Key implies NOT NULL automatically.             
    manufacturerID     INT NOT NULL,                                        -- ManufacturerID: Foreign key to Manufacturer table. NOT NULL ensures total participation, each part must belong to one manufacturer.
    code               VARCHAR(20) NOT NULL,                                -- Code: Manufacturer-specific part code (fx. "BRK-102"). is Required for identification in catalogs. NOT NULL ensures every part has a code.                                                     
    description        VARCHAR(100),                                        -- Description: Optional human-readable info about the part. Nullable because some manufacturers may omit it.                             
    unit_price         DECIMAL(8,2) CHECK (unit_price >= 0),                -- Unit_Price: Decimal value for the cost of one part. Nullable because prototypes or new parts may lack a price. CHECK constraint ensures non negative prices.
    
    FOREIGN KEY (manufacturerID) REFERENCES Manufacturer(manufacturerID)    -- Foreign key linking parts to their manufacturer.
        ON DELETE RESTRICT                                                  -- ON DELETE RESTRICT: prevents deleting a manufacturer that still has parts.
  );


CREATE TABLE Bikes 
(
    serial_number VARCHAR(20),                                              -- WTU108C2032D....
    manufacturerID INT NOT NULL,
    bike_type VARCHAR(40),                                                  -- Mountain Bike, Road Bike BMX etc
    bike_speeds INT,                                                        -- number of gears
    bike_weight DECIMAL(5,2),                                               -- weight in kg
    bike_wheel_diameter DECIMAL(4,1),                                       -- diameter in inches
    
    PRIMARY KEY (serial_number, manufacturerID)
    FOREIGN KEY (manufacturerID) REFERENCES Manufacturer(manufacturerID)
        ON DELETE RESTRICT                                                  -- ON DELETE RESTRICT: prevents deleting a manufacturer that still has parts.
);


CREATE TABLE CompatibleParts
(
    PartSN   VARCHAR(20),                                           -- PartSN: Foreign key referencing a part (SerialNumber), each row links one partt to one compatible bike.
    bike_SN   VARCHAR(20),                                          -- bike_SN: Foreign key referencing a bike (SerialNumber), Each row indicates that a specific bike can use a specific part.

    PRIMARY KEY (PartSN, bike_SN),                                  -- Composite Primary Key
    FOREIGN KEY (PartSN) REFERENCES Parts(serial_number)             -- Foreign key linking to Parts table.
        ON DELETE CASCADE,                                          -- ON DELETE CASCADE: if a part is deleted, all its compatibility links are deleted.

    FOREIGN KEY (bike_SN) REFERENCES Bikes(serial_number)            -- Foreign key linking to Bikes table.
        ON DELETE CASCADE                                           -- ON DELETE CASCADE: if a bike is deleted, all its compatibility records are removed.
);


CREATE TABLE RepairJobs
(

    customerCPR VARCHAR(10) ,
    bike_SN VARCHAR(20),
    repair_date DATE,
    duration INT,               -- duration in minutes, since time would be a bit more complex to handle, we could also use decimal but then 1 hour 30 minutes would be 1.50
    
    -- Make these derived attributes
    quantity INT,               -- calculated from parts table via trigger i think
    total_cost DECIMAL(8,2),    -- we will also calculate this later

    PRIMARY KEY (customerCPR, bike_SN, repair_date),
    FOREIGN KEY (customerCPR) REFERENCES Customer(customerCPR),
    FOREIGN KEY (bike_SN) REFERENCES Bikes(serial_number)
);


CREATE TABLE Uses
(
    repair_date DATE,
    bike_SN VARCHAR(20),
    parts_SN VARCHAR(20),
    customerCPR VARCHAR(10),

    PRIMARY KEY (parts_SN, bike_SN, repair_date),

    FOREIGN KEY (customerCPR, bike_SN, repair_date)
        REFERENCES RepairJobs (customerCPR, bikesSN, repair_date) -- we need to use the whole composite key
        ON DELETE RESTRICT,

    FOREIGN KEY (parts_SN)
        REFERENCES Parts(serial_number)
        ON DELETE RESTRICT
);


-- Insert data