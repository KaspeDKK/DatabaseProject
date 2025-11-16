SET SQL_SAFE_UPDATES = 0;
DROP DATABASE IF EXISTS BikeRepairShop;
CREATE DATABASE BikeRepairShop;
USE BikeRepairShop;

CREATE TABLE Customer (
    customerCPR		CHAR(10),               
    first_name		VARCHAR(20),            
    last_name		VARCHAR(20),            
    email_address	VARCHAR(73),            
    phone_number	INT NOT NULL,           

    PRIMARY KEY(customerCPR)
);

CREATE TABLE Address (
    customerCPR		CHAR(10),   
    street_name   VARCHAR(64),  
    civic_number  VARCHAR(6),   
    city          VARCHAR(64),  
    ZIP_code      CHAR(4),      

    PRIMARY KEY(customerCPR),
    FOREIGN KEY(customerCPR) 
        REFERENCES Customer(customerCPR) 
        ON DELETE CASCADE       
);

CREATE TABLE Manufacturer (
    manufacturer_ID     INT,            
    manufacturer_name   VARCHAR(64),    

    PRIMARY KEY(manufacturer_ID)
);

CREATE TABLE Bikes (
    bike_code       VARCHAR(10),    
    manufacturer_ID INT,            
    type            VARCHAR(20),    
    speeds          INT,            
    weight          DECIMAL(5,2),   
    wheel_diameter  DECIMAL(4,1),   

    PRIMARY KEY (bike_code, manufacturer_ID), 

    FOREIGN KEY (manufacturer_ID) 
        REFERENCES Manufacturer(manufacturer_ID)
        ON DELETE CASCADE 
);

CREATE TABLE Parts (
    part_code       VARCHAR(10),    
    manufacturer_ID INT,            
    description     VARCHAR(256),   
    unit_price      DECIMAL(8,2),

    PRIMARY KEY (part_code, manufacturer_ID), 

    FOREIGN KEY (manufacturer_ID) 
        REFERENCES Manufacturer(manufacturer_ID)
        ON DELETE CASCADE 
);

CREATE TABLE RepairJobs (

    repair_ID           INT,            
    bike_code           VARCHAR(10) NOT NULL,    
    bike_manufacturer   INT NOT NULL,            
    customerCPR         CHAR(10) NOT NULL,       
    repair_date         DATE,
    duration            INT,            
    
    total_cost DECIMAL(8,2),    

    PRIMARY KEY (repair_ID),

    FOREIGN KEY (customerCPR) 
        REFERENCES Customer(customerCPR),
    
    FOREIGN KEY (bike_code, bike_manufacturer)
        REFERENCES Bikes(bike_code, manufacturer_ID)
);

CREATE TABLE Uses (
    repair_ID   INT,            
    part_code   VARCHAR(10),    
    part_manufacturer INT,      
    quantity    INT,            

    PRIMARY KEY (repair_ID, part_code,part_manufacturer),

    FOREIGN KEY (repair_ID) 
        REFERENCES RepairJobs(repair_ID)
        ON DELETE CASCADE, 

    FOREIGN KEY (part_code, part_manufacturer) 
        REFERENCES Parts(part_code,manufacturer_ID) 

);

CREATE TABLE CompatibleParts (
    bike_code   VARCHAR(10), 
    part_code   VARCHAR(10), 
    bike_manufacturer INT, 
    part_manufacturer INT, 


    PRIMARY KEY (bike_code, part_code,bike_manufacturer,part_manufacturer),

    FOREIGN KEY (bike_code,bike_manufacturer) 
        REFERENCES Bikes(bike_code,manufacturer_ID)
        ON DELETE CASCADE, 

    FOREIGN KEY (part_code,part_manufacturer) 
        REFERENCES Parts(part_code,manufacturer_ID)
        ON DELETE CASCADE 
);