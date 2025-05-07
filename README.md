# CityBusManagement
The Chennai Metropolitan Transport System (ChennaiBusDB) is a robust and scalable database application designed to streamline the management and operation of urban bus transport services in Chennai

# 🚌 CityBusDB - Chennai Metropolitan Transport System Database

CityBusDB is a database project developed to model and manage the Chennai Metropolitan Transport Corporation (MTC) operations using MySQL. It includes a complete schema, sample data, advanced SQL features like constraints, joins, views, triggers, and cursors, along with a Python GUI interface for user interaction.

## 📌 Table of Contents

- [Features](#-features)
- [Entity Overview](#-entity-overview)
- [Project Structure](#-project-structure)
- [Installation](#-installation)
- [How to Run](#-how-to-run)
- [Sample SQL Queries](#-sample-sql-queries)
- [GUI Interface](#-gui-interface)
- [Future Enhancements](#-future-enhancements)
- [License](#-license)

---

## 🚀 Features

- Real-world DBMS modeling for urban transport
- MySQL-based schema design with:
  - Primary and Foreign Keys
  - Check constraints
  - Joins (inner, left, right)
  - Views for simplified reporting
  - Triggers for data validation and logging
  - Cursors for row-by-row operations
- GUI built using Python (`tkinter`)
- Supports passenger queries and schedule viewing
- Includes sample data for buses, routes, stops, staff, and trips

---

## 🧩 Entity Overview

| Table        | Description |
|--------------|-------------|
| `Bus`        | Stores bus details (number, capacity, type) |
| `Stop`       | Contains stop names, location (lat, long), pincode |
| `Route`      | Details of routes, mapped to bus numbers |
| `Schedule`   | Timings and bus-stop mappings for daily operations |
| `Driver`     | Driver details including license and assigned route |
| `Conductor`  | Conductor info for schedule assignments |
| `Passenger`  | Info on passengers for digital feedback system |

---

## 📁 Project Structure

CityBusDB/
├── schema.sql # Table creation and constraints
├── data.sql # Sample data insertion
├── views.sql # SQL views
├── triggers.sql # Database triggers
├── cursors.sql # Sample cursor usage
├── queries.sql # Sample use-case queries
├── gui/
│ ├── main.py # Python GUI main script
│ ├── db_connection.py # MySQL connection script
│ └── assets/ # Optional GUI assets (logos, icons)
└── README.md # Project documentation


---

## ⚙️ Installation

### 🔧 Requirements

- MySQL Server
- Python 3.8+
- MySQL Connector for Python:
  ```bash
  pip install mysql-connector-python
