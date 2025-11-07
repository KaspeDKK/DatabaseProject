CREATE TABLE Bikes 
(
    
    serial_number VARCHAR(20),  -- WTU108C2032D....
    manufacturerID INT NOT NULL,
    bike_type VARCHAR(40), -- Mountain Bike, Road Bike BMX etc
    bike_speeds INT, -- number of gears
    bike_weight DECIMAL(5,2), -- weight in kg
    bike_wheel_diameter DECIMAL(4,1), -- diameter in inches
    FOREIGN KEY (manufacturerID) REFERENCES Manufacturer(manufacturerID)
);

CREATE TABLE RepairJobs
(

    customerCPR VARCHAR(10) ,
    bikesSN VARCHAR(20),
    repair_date DATE,
    duration INT, -- duration in minutes, since time would be a bit more complex to handle, we could also use decimal but then 1 hour 30 minutes would be 1.50
    
    --should be computed attributes
    quantity INT, -- calculated from parts table via scripts i think
    total_cost DECIMAL(8,2), -- we will also calculate this later

    PRIMARY KEY (customerCPR, bikesSN, repair_date),
    FOREIGN KEY (customerCPR) REFERENCES Customer(CPR),
    FOREIGN KEY (bikesSN) REFERENCES Bikes(serial_number)
);


