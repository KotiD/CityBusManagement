CREATE DATABASE ChennaiBusDB;
USE ChennaiBusDB;
CREATE TABLE buses (
    bus_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_number VARCHAR(10) NOT NULL UNIQUE, 
    bus_type ENUM('AC', 'Non-AC', 'Electric', 'Mini-Bus') NOT NULL,
    capacity INT NOT NULL,
    operator VARCHAR(100) DEFAULT 'MTC Chennai'
);
CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    route_name VARCHAR(100) NOT NULL UNIQUE,
    start_location VARCHAR(100) NOT NULL,
    end_location VARCHAR(100) NOT NULL
);
CREATE TABLE stops (
    stop_id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT,
    stop_name VARCHAR(100) NOT NULL,
    stop_order INT NOT NULL, 
    FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE CASCADE
);
CREATE TABLE schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,buses
    bus_id INT,
    route_id INT,
    stop_id INT,
    arrival_time TIME NOT NULL,
    departure_time TIME NOT NULL,
    FOREIGN KEY (bus_id) REFERENCES buses(bus_id) ON DELETE CASCADE,
    FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE CASCADE,
    FOREIGN KEY (stop_id) REFERENCES stops(stop_id) ON DELETE CASCADE
);
INSERT INTO buses (bus_number, bus_type, capacity)
VALUES 
('21G', 'Non-AC', 55),
('570', 'AC', 45),
('M15', 'Mini-Bus', 30),
('E18', 'Electric', 40);
INSERT INTO routes (route_name, start_location, end_location)
VALUES 
('Route 21G', 'Tambaram', 'Broadway'),
('Route 570', 'Kelambakkam', 'T. Nagar'),
('Route M15', 'Saidapet', 'Thiruvanmiyur'),
('Route E18', 'Koyambedu', 'Sholinganallur');
INSERT INTO stops (route_id, stop_name, stop_order)
VALUES 
-- Stops for Route 21G
(1, 'Tambaram', 1),
(1, 'Chromepet', 2),
(1, 'Guindy', 3),
(1, 'Broadway', 4),

-- Stops for Route 570
(2, 'Kelambakkam', 1),
(2, 'Sholinganallur', 2),
(2, 'Tidel Park', 3),
(2, 'T. Nagar', 4),

-- Stops for Route M15
(3, 'Saidapet', 1),
(3, 'Guindy', 2),
(3, 'Adyar', 3),
(3, 'Thiruvanmiyur', 4),

-- Stops for Route E18
(4, 'Koyambedu', 1),
(4, 'Vadapalani', 2),
(4, 'Medavakkam', 3),
(4, 'Sholinganallur', 4);
INSERT INTO schedules (bus_id, route_id, stop_id, arrival_time, departure_time)
VALUES 
-- Schedule for 21G
(1, 1, 1, '06:00:00', '06:05:00'),
(1, 1, 2, '06:20:00', '06:25:00'),
(1, 1, 3, '06:45:00', '06:50:00'),
(1, 1, 4, '07:10:00', '07:15:00'),

-- Schedule for 570
(2, 2, 1, '07:00:00', '07:05:00'),
(2, 2, 2, '07:30:00', '07:35:00'),
(2, 2, 3, '08:00:00', '08:05:00'),
(2, 2, 4, '08:30:00', '08:35:00'),

-- Schedule for M15
(3, 3, 1, '08:00:00', '08:05:00'),
(3, 3, 2, '08:20:00', '08:25:00'),
(3, 3, 3, '08:45:00', '08:50:00'),
(3, 3, 4, '09:10:00', '09:15:00'),

-- Schedule for E18
(4, 4, 1, '09:00:00', '09:05:00'),
(4, 4, 2, '09:30:00', '09:35:00'),
(4, 4, 3, '10:00:00', '10:05:00'),
(4, 4, 4, '10:30:00', '10:35:00');

CREATE TABLE edit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50),
    record_id INT,
    operation VARCHAR(20),
    old_values TEXT,
    new_values TEXT,
    edited_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE buses
ADD COLUMN route_id INT,
ADD CONSTRAINT fk_route_id FOREIGN KEY (route_id) REFERENCES routes(route_id);
