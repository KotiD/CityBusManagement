USE ChennaiBusDB;
SELECT b.bus_number, s.stop_name, sc.arrival_time
FROM schedules sc
INNER JOIN buses b ON sc.bus_id = b.bus_id
INNER JOIN stops s ON sc.stop_id = s.stop_id;

SELECT b.bus_number, r.route_name
FROM buses b
LEFT JOIN schedules sc ON b.bus_id = sc.bus_id
LEFT JOIN routes r ON sc.route_id = r.route_id;

SELECT r.route_name, b.bus_number
FROM routes r
RIGHT JOIN schedules sc ON r.route_id = sc.route_id
RIGHT JOIN buses b ON sc.bus_id = b.bus_id;

CREATE TABLE backup_buses (
    bus_number VARCHAR(10)
);

INSERT INTO backup_buses VALUES ('21G'), ('M15'), ('999');

SELECT bus_number FROM buses
UNION
SELECT route_name FROM routes;

SELECT bus_number FROM buses
UNION ALL
SELECT route_name FROM routes;

-- Conceptual (if your SQL engine supports it)
SELECT bus_number FROM buses
INTERSECT
SELECT route_name FROM routes;

CREATE VIEW bus_schedule_view AS
SELECT b.bus_number, r.route_name, s.stop_name, sc.arrival_time, sc.departure_time
FROM schedules sc
JOIN buses b ON sc.bus_id = b.bus_id
JOIN routes r ON sc.route_id = r.route_id
JOIN stops s ON sc.stop_id = s.stop_id;

SELECT * FROM bus_schedule_view;

CREATE TABLE bus_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_number VARCHAR(10),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER after_bus_insert
AFTER INSERT ON buses
FOR EACH ROW
BEGIN
    INSERT INTO bus_log (bus_number) VALUES (NEW.bus_number);
END;
//

DELIMITER ;

DELIMITER //

CREATE TRIGGER before_capacity_update
BEFORE UPDATE ON buses
FOR EACH ROW
BEGIN
    IF NEW.capacity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Capacity must be greater than zero';
    END IF;
END;
//

DELIMITER ;
INSERT INTO buses (bus_number, bus_type, capacity, operator)
VALUES 
('12A', 'Non-AC', 50, 'MTC Chennai'),
('102B', 'AC', 40, 'MTC Chennai'),
('E35', 'Electric', 42, 'MTC Chennai Green'),
('M27', 'Mini-Bus', 28, 'MTC Suburban'),
('85G', 'Non-AC', 55, 'Private Operator');


SELECT * FROM  bus_log;

SELECT * FROM buses;

DROP PROCEDURE IF EXISTS list_bus_numbers;

DELIMITER $$

CREATE PROCEDURE list_bus_numbers()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE b_number VARCHAR(10);
    DECLARE cur CURSOR FOR SELECT bus_number FROM buses;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO b_number;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- This SELECT will show each bus number one by one
        SELECT b_number AS bus_number;
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;

CALL list_bus_numbers();

ALTER TABLE schedules
ADD CONSTRAINT fk_bus FOREIGN KEY (bus_id) REFERENCES buses(bus_id) ON DELETE CASCADE;

ALTER TABLE schedules
ADD CONSTRAINT fk_route FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE CASCADE;

ALTER TABLE schedules
ADD CONSTRAINT fk_stop FOREIGN KEY (stop_id) REFERENCES stops(stop_id) ON DELETE CASCADE;


SHOW tables;

SELECT s.schedule_id, b.bus_number, b.bus_type, b.capacity
FROM schedules s
JOIN buses b ON s.bus_id = b.bus_id;

-- Query to find stop_name using schedule_id indirectly
SELECT s.schedule_id, st.stop_name
FROM schedules s
JOIN stops st ON s.stop_id = st.stop_id;

-- 2NF: Create table for bus details
CREATE TABLE buses_2NF (
    bus_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_number VARCHAR(10) NOT NULL UNIQUE, 
    bus_type ENUM('AC', 'Non-AC', 'Electric', 'Mini-Bus') NOT NULL,
    capacity INT NOT NULL,
    operator VARCHAR(100) DEFAULT 'MTC Chennai'
);

-- 2NF: Create table for route details
CREATE TABLE routes_2NF (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    route_name VARCHAR(100) NOT NULL UNIQUE,
    start_location VARCHAR(100) NOT NULL,
    end_location VARCHAR(100) NOT NULL
);

-- 2NF: Create table for stops with route reference
CREATE TABLE stops_2NF (
    stop_id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT,
    stop_name VARCHAR(100) NOT NULL,
    stop_order INT NOT NULL, 
    FOREIGN KEY (route_id) REFERENCES routes_2NF(route_id) ON DELETE CASCADE
);

-- 2NF: Create table for schedules with references to bus, route, and stop
CREATE TABLE schedules_2NF (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_id INT,
    route_id INT,
    stop_id INT,
    arrival_time TIME NOT NULL,
    departure_time TIME NOT NULL,
    FOREIGN KEY (bus_id) REFERENCES buses_2NF(bus_id) ON DELETE CASCADE,
    FOREIGN KEY (route_id) REFERENCES routes_2NF(route_id) ON DELETE CASCADE,
    FOREIGN KEY (stop_id) REFERENCES stops_2NF(stop_id) ON DELETE CASCADE
);

show tables;

-- Create final table for bus details in BCNF
CREATE TABLE buses_bcnf (
    bus_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_number VARCHAR(10) NOT NULL UNIQUE, 
    bus_type ENUM('AC', 'Non-AC', 'Electric', 'Mini-Bus') NOT NULL,
    capacity INT NOT NULL,
    operator VARCHAR(100) DEFAULT 'MTC Chennai'
);

-- Create final table for route details in BCNF
CREATE TABLE routes_bcnf (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    route_name VARCHAR(100) NOT NULL UNIQUE,
    start_location VARCHAR(100) NOT NULL,
    end_location VARCHAR(100) NOT NULL
);

-- Create final table for stops with route reference in BCNF
CREATE TABLE stops_bcnf (
    stop_id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT,
    stop_name VARCHAR(100) NOT NULL,
    stop_order INT NOT NULL, 
    FOREIGN KEY (route_id) REFERENCES routes_bcnf(route_id) ON DELETE CASCADE
);

-- Create final table for schedules with references to bus, route, and stop in BCNF
CREATE TABLE schedules_bcnf (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_id INT,
    route_id INT,
    stop_id INT,
    arrival_time TIME NOT NULL,
    departure_time TIME NOT NULL,
    FOREIGN KEY (bus_id) REFERENCES buses_bcnf(bus_id) ON DELETE CASCADE,
    FOREIGN KEY (route_id) REFERENCES routes_bcnf(route_id) ON DELETE CASCADE,
    FOREIGN KEY (stop_id) REFERENCES stops_bcnf(stop_id) ON DELETE CASCADE
);


-- Inserting data into buses_bcnf (normalized bus table)
INSERT INTO buses_bcnf (bus_number, bus_type, capacity)
VALUES 
('21G', 'Non-AC', 55),
('570', 'AC', 45),
('M15', 'Mini-Bus', 30),
('E18', 'Electric', 40);

-- Inserting data into routes_bcnf (normalized route table)
INSERT INTO routes_bcnf (route_name, start_location, end_location)
VALUES 
('Route 21G', 'Tambaram', 'Broadway'),
('Route 570', 'Kelambakkam', 'T. Nagar'),
('Route M15', 'Saidapet', 'Thiruvanmiyur'),
('Route E18', 'Koyambedu', 'Sholinganallur');

-- Inserting data into stops_bcnf (normalized stops table)
INSERT INTO stops_bcnf (route_id, stop_name, stop_order)
VALUES 
(1, 'Tambaram', 1),
(1, 'Chromepet', 2),
(1, 'Guindy', 3),
(1, 'Broadway', 4),
(2, 'Kelambakkam', 1),
(2, 'Sholinganallur', 2),
(2, 'Tidel Park', 3),
(2, 'T. Nagar', 4),
(3, 'Saidapet', 1),
(3, 'Guindy', 2),
(3, 'Adyar', 3),
(3, 'Thiruvanmiyur', 4),
(4, 'Koyambedu', 1),
(4, 'Vadapalani', 2),
(4, 'Medavakkam', 3),
(4, 'Sholinganallur', 4);

-- Inserting data into schedules_bcnf (normalized schedules table)
INSERT INTO schedules_bcnf (bus_id, route_id, stop_id, arrival_time, departure_time)
VALUES 
(1, 1, 1, '06:00:00', '06:05:00'),
(1, 1, 2, '06:20:00', '06:25:00'),
(1, 1, 3, '06:45:00', '06:50:00'),
(1, 1, 4, '07:10:00', '07:15:00'),
(2, 2, 1, '07:00:00', '07:05:00'),
(2, 2, 2, '07:30:00', '07:35:00'),
(2, 2, 3, '08:00:00', '08:05:00'),
(2, 2, 4, '08:30:00', '08:35:00'),
(3, 3, 1, '08:00:00', '08:05:00'),
(3, 3, 2, '08:20:00', '08:25:00'),
(3, 3, 3, '08:45:00', '08:50:00'),
(3, 3, 4, '09:10:00', '09:15:00'),
(4, 4, 1, '09:00:00', '09:05:00'),
(4, 4, 2, '09:30:00', '09:35:00'),
(4, 4, 3, '10:00:00', '10:05:00'),
(4, 4, 4, '10:30:00', '10:35:00');

USE ChennaiBusDB;
-- View structure of buses_bcnf table
DESCRIBE buses_bcnf;

-- View structure of routes_bcnf table
DESCRIBE routes_bcnf;

-- View structure of stops_bcnf table
DESCRIBE stops_bcnf;

-- View structure of schedules_bcnf table
DESCRIBE schedules_bcnf;
USE ChennaiBusDB;
SELECT * FROM schedules;

CREATE TABLE buses (
    bus_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_number VARCHAR(10) NOT NULL UNIQUE,
    bus_type ENUM('AC', 'Non-AC', 'Electric', 'Mini-Bus') NOT NULL,
    capacity INT NOT NULL CHECK (capacity >= 20),
    operator VARCHAR(100) DEFAULT 'MTC Chennai'
);

SELECT bus_number FROM buses
WHERE bus_type = 'Electric'
UNION 
SELECT bus_number FROM buses
WHERE capacity > 50
EXCEPT
SELECT bus_number FROM buses
WHERE bus_type = 'Electric' AND capacity > 50;

SELECT r.route_name, COUNT(s.bus_id) AS total_buses, SUM(b.capacity) AS total_capacity
FROM schedules s
JOIN buses b ON s.bus_id = b.bus_id
JOIN routes r ON s.route_id = r.route_id
GROUP BY r.route_name
HAVING COUNT(s.bus_id) >= 3 AND SUM(b.capacity) > 100;

CREATE VIEW ElectricBusesView AS
SELECT b.bus_number, b.capacity, r.route_name
FROM buses b
JOIN schedules s ON b.bus_id = s.bus_id
JOIN routes r ON s.route_id = r.route_id
WHERE b.bus_type = 'Electric';

DELIMITER //
CREATE TRIGGER PreventInvalidSchedule
BEFORE INSERT ON schedules
FOR EACH ROW
BEGIN
    DECLARE route_exists INT;
    SELECT COUNT(*) INTO route_exists FROM routes WHERE route_id = NEW.route_id;
    IF route_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Schedule - Bus is not assigned to any route!';
    END IF;
END;
//
DELIMITER ;

DELIMITER //
DECLARE route_cursor CURSOR FOR
SELECT r.route_name, COUNT(s.stop_id) AS total_stops
FROM routes r
LEFT JOIN stops s ON r.route_id = s.route_id
GROUP BY r.route_name;

DECLARE done INT DEFAULT FALSE;
DECLARE route_name VARCHAR(100);
DECLARE total_stops INT;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN route_cursor;

read_loop: LOOP
    FETCH route_cursor INTO route_name, total_stops;
    IF done THEN 
        LEAVE read_loop;
    END IF;

    IF total_stops = 0 THEN
        SELECT CONCAT('No stops for route ', route_name);
    ELSE
        SELECT CONCAT('Route: ', route_name, ' - Total Stops: ', total_stops);
    END IF;
END LOOP;

CLOSE route_cursor;
//
DELIMITER ;

SELECT DISTINCT b.bus_number 
FROM buses b
JOIN schedules s ON b.bus_id = s.bus_id
JOIN stops st ON s.stop_id = st.stop_id
WHERE st.stop_name = 'Guindy'
INTERSECT
SELECT DISTINCT b.bus_number 
FROM buses b
JOIN schedules s ON b.bus_id = s.bus_id
JOIN stops st ON s.stop_id = st.stop_id
WHERE st.stop_name = 'Sholinganallur';

DELIMITER //
CREATE TRIGGER ValidateScheduleTiming
BEFORE INSERT ON schedules
FOR EACH ROW
BEGIN
    IF NEW.arrival_time >= NEW.departure_time THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Schedule - Arrival time must be before departure time!';
    END IF;
END;
//
DELIMITER ;

CREATE VIEW BusyRoutes AS
SELECT r.route_name, COUNT(DISTINCT s.stop_id) AS total_stops, COUNT(sch.schedule_id) AS total_schedules
FROM routes r
JOIN stops s ON r.route_id = s.route_id
JOIN schedules sch ON r.route_id = sch.route_id
GROUP BY r.route_name
HAVING COUNT(DISTINCT s.stop_id) >= 4 AND COUNT(sch.schedule_id) >= 5;

SELECT b.bus_number 
FROM buses b
LEFT JOIN schedules s ON b.bus_id = s.bus_id
LEFT JOIN routes r ON s.route_id = r.route_id
WHERE b.bus_id NOT IN (
    SELECT DISTINCT s.bus_id FROM schedules s
    JOIN routes r ON s.route_id = r.route_id
    WHERE r.start_location = 'Koyambedu'
);

DELIMITER //
CREATE TRIGGER DefaultBusType
BEFORE INSERT ON buses
FOR EACH ROW
BEGIN
    IF NEW.bus_type IS NULL THEN
        SET NEW.bus_type = 'Non-AC';
    END IF;
END;
//
DELIMITER ;

CREATE DATABASE ChennaiBusDB;
USE ChennaiBusDB;

INSERT INTO buses (bus_number, bus_type, capacity)
VALUES 
('1', 'Non-AC', 55),
('101', 'Non-AC', 55),
('102', 'Non-AC', 55),
('104', 'Non-AC', 55);

INSERT INTO routes (route_name, start_location, end_location)
VALUES 
('Route 1', 'Thiruvotriyur', 'Thiruvanmiyur'),
('Route 101', 'Thiruvotriyur', 'Poonamallee'),
('Route 102', 'Broadway', 'Kelambakkam'),
('Route 104', 'Redhills', 'Tambaram');

SELECT COLUMN_NAME, TABLE_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'ChennaiBusDB' 
AND DATA_TYPE = 'int';

DESC stops;

USE ChennaiBusDB;
SELECT r.route_name,COUNT(s.stops_id) AS total_stops
FROM routes 
JOIN stops s ON r.route_id = s.route_id
GROUP BY r.route_name;


DELIMITER //
CREATE TRIGGER DefaultBusType
BEFORE INSERT ON Buses
FOR EACH ROW
BEGIN
	IF NEW.bus_type is null then
    new.bus_type=' Non-AC ';
END IF;
END;
//
DELIMITER;

DELIMITER //
CREATE TRIGGER ValidateScheduleTiming
BEFORE INSERT ON schedules
FOR EACH ROW
BEGIN
    IF NEW.arrival_time >= NEW.departure_time THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Schedule - Arrival time must be before departure time!';
    END IF;
END;
//
DELIMITER ;
USE ChennaiBusDB;
SELECT bus_number FROM buses
WHERE bus_type = 'Electric'
UNION 
SELECT bus_number FROM buses
WHERE capacity > 50
EXCEPT
SELECT bus_number FROM buses
WHERE bus_type = 'Electric' AND capacity > 50;

CREATE VIEW ElectricBusesView AS
SELECT b.bus_number, b.capacity, r.route_name
FROM buses b
JOIN schedules s ON b.bus_id = s.bus_id
JOIN routes r ON s.route_id = r.route_id
WHERE b.bus_type = 'Electric';

select *from ElectricBusesView;

SELECT b.bus_number 
FROM buses b
LEFT JOIN schedules s ON b.bus_id = s.bus_id
LEFT JOIN routes r ON s.route_id = r.route_id
WHERE b.bus_id NOT IN (
    SELECT DISTINCT s.bus_id FROM schedules s
    JOIN routes r ON s.route_id = r.route_id
    WHERE r.start_location = 'Koyambedu'
);
use ChennaiBusDB;
select * from buses;
select * from routes;
select * from stops;
select * from schedules;
select * from edit_logs;

use ChennaiBusDB;
START TRANSACTION;
SELECT * FROM schedules WHERE route_id = 2;  

START TRANSACTION;
UPDATE schedules SET arrival_time = '08:30:00' WHERE schedule_id = 2;
COMMIT;

START TRANSACTION;
-- Mistakenly assigning the same bus to two routes
INSERT INTO routes_buses (route_id, bus_id) VALUES (12, 101);
-- Realize it's wrong
ROLLBACK;



