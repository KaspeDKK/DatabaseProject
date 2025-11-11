INSERT INTO Manufacturer VALUES
(11111, 'Bike Parts'),
(22222, 'Only Bikes'),
(43126, 'All Things Bikes'),
(12372, 'Quality Bikes'),
(55555, 'Part Performance');

INSERT INTO Customer VALUES
('1308981817','John','Name','John@gmail.com','22334455'),
('1212824762','Jane','Doe','sadjwokj7sdwushd@gmail.com','12312312'),
('3108789976','Joergen Von','Einer','abc@gmail.com','11111123'),
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

INSERT INTO Address VALUES
('1308981817','Roskildevej','12','Haderslev','6070'),
('1212824762','Hovedvej','4A','Roskilde','4000'),
('3108789976','Faglaertvej','67','Herlev','2730'),
('0101014321','Landevej','419','Slagelse','4270'),
('1212988825','Uhyggeligvej','7B','Herning','6933'),
('2307127139','Funktionelletbanevej','9980C','Aarhus','8000'),
('1203112231','Funktionelletbanevej','9980C','Aarhus','8000'),
('1606047842','Havvej','21','Skagen','9990'),
('1104671111','Nyvej','420','Ishoej','2625'),
('0102037755','Strandvej','152','Rungsted','2960'),
('1309092385','Bagsværdvej','99','Bagsvaerd','2800'),
('1010828850','Ballerupvej','31D','Ballerup','2740'),
('0710299836','Kongensvej','1','Kokkedal','2970'),
('1111111111','Denrigtigevej','12345','Helsinge','3200'),
('2212978765','Denforkertevej','54321','Koebenhavn S','2300');

INSERT INTO Bikes VALUES
('BK100','22222','Mountain Bike',18,14.5,27.5),
('BK200','12372','City Bike',7,11.2,26.0),
('BK300','43126','Road Bike',22,9.5,28.0),
('BK400','22222','Hybrid',21,12.1,27.0),
('BK500','12372','Electric',8,24.0,29.0);

INSERT INTO Parts VALUES
('P100','11111','Bike chain 9-speed',120.50),
('P200','11111','Front wheel 27.5 inch',340.00),
('P300','55555','Hydraulic brake lever',290.00),
('P400','55555','Bike seat ergonomic',150.00),
('P500','43126','Pedal set with reflectors',180.00);

INSERT INTO RepairJobs VALUES
(1,'1308981817','BK100','2025-02-02',90,NULL),
(2,'1212824762','BK200','2025-03-15',60,NULL),
(3,'3108789976','BK300','2025-04-10',120,NULL),
(4,'0101014321','BK400','2025-04-12',45,NULL),
(5,'1212988825','BK500','2025-05-01',180,NULL);

INSERT INTO Uses VALUES
(1,'P100',1),
(1,'P200',2),
(2,'P300',1),
(3,'P400',1),
(3,'P100',1),
(4,'P500',2),
(5,'P400',1);

INSERT INTO CompatibleParts VALUES
('BK100','P100'),
('BK100','P200'),
('BK200','P300'),
('BK300','P400'),
('BK400','P500'),
('BK500','P400'),
('BK500','P100');
