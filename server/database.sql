-- Creating Tables
CREATE TABLE addresses(
    street_number INT NOT NULL,
    street_name VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province_state VARCHAR(50),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    CONSTRAINT pk_address PRIMARY KEY (street_number, street_name, postal_code)
);

CREATE TABLE hotel_chains(
    chain_name VARCHAR(255) PRIMARY KEY,
    contact_phone_numbers VARCHAR(20) NOT NULL CHECK (contact_phone_numbers ~ '^\+?[0-9\s-]+$'),
    contact_emails VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    CONSTRAINT valid_contact_emails CHECK (
        contact_emails ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    )
);

CREATE TABLE employees(
    employee_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    employee_email VARCHAR(255) DEFAULT '' NOT NULL,
    role VARCHAR(50) NOT NULL,
    salary INT NOT NULL,
    street_name VARCHAR(100) NOT NULL,
    street_number INT NOT NULL,
    city VARCHAR(100) NOT NULL,
    province_state VARCHAR(50),
    postal_code VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    CONSTRAINT valid_employee_email CHECK (
        employee_email ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    ),
    FOREIGN KEY(street_number, street_name, postal_code) REFERENCES addresses(street_number, street_name, postal_code)
);

CREATE TABLE hotels(
    hotel_id INT NOT NULL,
    chain_name VARCHAR(255) NOT NULL,
    category INT NOT NULL,
    manager_id VARCHAR(20) NOT NULL,
    phone_number VARCHAR(20) NOT NULL CHECK (phone_number ~ '^\+?[0-9\s-]+$'),
    contact_email VARCHAR(255) NOT NULL,
    street_name VARCHAR(100) NOT NULL,
    street_number INT NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province_state VARCHAR(50),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    CONSTRAINT valid_contact_email CHECK (
        contact_email ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    ),
    FOREIGN KEY(chain_name) REFERENCES hotel_chains(chain_name),
    FOREIGN KEY(manager_id) REFERENCES employees(employee_id),
    FOREIGN KEY(street_number, street_name, postal_code) REFERENCES addresses(street_number, street_name, postal_code),
    CONSTRAINT pk_hotels PRIMARY KEY (hotel_id, chain_name)
);

CREATE TABLE employee_works_for(
    employee_id VARCHAR(20) NOT NULL,
    hotel_id INT NOT NULL,
    chain_name VARCHAR(255) NOT NULL,

    FOREIGN KEY(employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY(hotel_id, chain_name) REFERENCES hotels(hotel_id, chain_name)
);

CREATE TABLE rooms(
    room_number INT NOT NULL,
    hotel_id INT NOT NULL,
    chain_name VARCHAR(255) NOT NULL,
    price FLOAT NOT NULL,
    capacity INT NOT NULL,
    mountain_view BOOLEAN DEFAULT 'f' NOT NULL,
    sea_view BOOLEAN DEFAULT 'f' NOT NULL,
    is_expandable BOOLEAN DEFAULT 'f' NOT NULL,
    amenities TEXT DEFAULT '',
    damages TEXT DEFAULT '',
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    FOREIGN KEY(hotel_id, chain_name) REFERENCES hotels(hotel_id, chain_name),
    CONSTRAINT pk_room PRIMARY KEY (room_number, hotel_id)
);

CREATE TABLE customers(
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(255) DEFAULT '' NOT NULL,
    street_number INT NOT NULL,
    street_name VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province_state VARCHAR(50),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    CONSTRAINT valid_customer_email CHECK (
        customer_email ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    ),
    FOREIGN KEY(street_number, street_name, postal_code) REFERENCES addresses(street_number, street_name, postal_code)
);

CREATE TABLE bookings(
    booking_id SERIAL PRIMARY KEY,
    status VARCHAR(255) NOT NULL,
    customer_id INT,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    room_number INT NOT NULL,
    hotel_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY(room_number, hotel_id) REFERENCES rooms(room_number, hotel_id)
);

CREATE TABLE rentings(
    renting_id SERIAL PRIMARY KEY,
    booking_id INT,
    employee_id VARCHAR(20) NOT NULL,
    customer_id INT NOT NULL,
    status VARCHAR(255) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    room_number INT NOT NULL,
    hotel_id INT NOT NULL,
    has_booked BOOLEAN DEFAULT 't' NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY(employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY(booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY(room_number, hotel_id) REFERENCES rooms(room_number, hotel_id)
);

CREATE TABLE archives(
    archive_id SERIAL PRIMARY KEY,
    renting_id INT NOT NULL,
    booking_id INT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    FOREIGN KEY(renting_id) REFERENCES rentings(renting_id),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

CREATE INDEX idx_customer_id ON bookings (customer_id); --Justification: this is very common in a booking system and will speed up filter queries
CREATE INDEX idx_employee_email ON employees (employee_email); --Justification: for future systems this will be important for an email system.
CREATE INDEX idx_chain_name ON hotels (chain_name); --Justification: the management of severeal hotels will be easier if indexed by chain name

ALTER TABLE bookings ADD
  CONSTRAINT fk_room_key
  FOREIGN KEY (room_number, hotel_id)
  REFERENCES rooms(room_number, hotel_id);

ALTER TABLE bookings ADD
  CONSTRAINT check_booking_status
  CHECK (status IN (
    'scheduled', 'active', 'completed'
  ));

  ALTER TABLE rentings ADD
  CONSTRAINT check_renting_status
  CHECK (status IN (
   'renting', 'completed'
  ));

ALTER TABLE hotels ADD
  CONSTRAINT check_category
  CHECK (category IN (1, 2, 3, 4, 5));

CREATE VIEW available_rooms_per_hotel AS --Justificaton: number of available rooms per hotel in total
    SELECT h.hotel_id, h.chain_name, COUNT(r.room_number) AS available_rooms
    FROM hotels h
    LEFT JOIN rooms r ON h.hotel_id = r.hotel_id
    LEFT JOIN rentings rt ON r.room_number = rt.room_number AND r.hotel_id = rt.hotel_id
    WHERE rt.renting_id IS NULL
    GROUP BY h.hotel_id, h.chain_name;

CREATE VIEW bookings_history AS --Justification: well this is obvious. this is neccessary because we need to know customers history
    SELECT b.booking_id, b.status, c.customer_id, c.full_name AS customer_name, b.start_date, b.end_date, r.room_number, h.hotel_id, h.chain_name
    FROM bookings b
    JOIN customers c ON b.customer_id = c.customer_id
    LEFT JOIN rooms r ON b.room_number = r.room_number AND b.hotel_id = r.hotel_id
    LEFT JOIN hotels h ON b.hotel_id = h.hotel_id;

CREATE OR REPLACE FUNCTION transfer_booking_to_renting()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  IF new.status = 'active' AND new.status <> old.status AND NOT EXISTS(SELECT 1 FROM rentings WHERE booking_id = old.booking_id) THEN
    INSERT INTO rentings(status, employee_id, customer_id, start_date, end_date, room_number, hotel_id, booking_id, has_booked, created_at, updated_at)
    VALUES ('renting', 'EMP001', old.customer_id, old.start_date, old.end_date, old.room_number, old.hotel_id, old.booking_id, 't', now(), now());
  END IF;
  RETURN new;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

CREATE TRIGGER bookings_check_in
  AFTER UPDATE
  ON bookings
  FOR EACH ROW
  EXECUTE PROCEDURE transfer_booking_to_renting();

CREATE OR REPLACE FUNCTION archive_completed_renting()
RETURNS TRIGGER AS
$BODY$
BEGIN
    IF NEW.status = 'completed' AND NEW.status <> OLD.status THEN
        INSERT INTO archives (renting_id, booking_id, created_at, updated_at)
        VALUES (old.renting_id, old.booking_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    END IF;
    RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

CREATE TRIGGER archive_completed_renting_trigger
AFTER UPDATE ON rentings
FOR EACH ROW
EXECUTE FUNCTION archive_completed_renting();


-- Populating Database 
INSERT INTO addresses (street_number, street_name, postal_code, city, province_state, created_at, updated_at)
VALUES
    (123, 'Oak Street', '54321', 'Springfield', 'New York', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (127, 'Pine Ave', '54327', 'Springfield', 'New York', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (456, 'Maple Avenue', '98765', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (787, 'Elm Street', '45678', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (101, 'Pine Road', '23456', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (222, 'Cedar Lane', '78901', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (333, 'Willow Street', '13579', 'Springfield', 'Illinois', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (444, 'Magnolia Drive', '97531', 'Riverside', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    (555, 'Birch Avenue', '75390', 'Lexington', 'Tennessee', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (666, 'Sycamore Lane', '25874', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (777, 'Juniper Road', '36985', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (888, 'Poplar Boulevard', '96325', 'Springfield', 'Ohio', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (777, 'Oakwood Boulevard', '63258', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (999, 'Cypress Street', '74185', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (111, 'Acorn Lane', '85296', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (222, 'Cherry Avenue', '36985', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    (444, 'Spruce Road', '25874', 'Springfield', 'Missouri', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (555, 'Hickory Lane', '69325', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (666, 'Cedar Avenue', '35789', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (676, 'Cypress Street', '74185', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (888, 'Maple Street', '78963', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (999, 'Willow Avenue', '25874', 'Springfield', 'Illinois', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (111, 'Birchwood Drive', '98574', 'Riverside', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (222, 'Magnolia Lane', '14785', 'Lexington', 'Tennessee', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    (331, 'Sycamore Avenue', '69325', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (444, 'Juniper Lane', '35789', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (555, 'Poplar Road', '78963', 'Springfield', 'Ohio', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (666, 'Cypress Lane', '63258', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (777, 'Acacia Boulevard', '25874', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (888, 'Cherry Street', '98574', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (999, 'Palm Boulevard', '14785', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (111, 'Spruce Lane', '69325', 'Springfield', 'Missouri', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    (222, 'Hickory Drive', '35789', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (333, 'Cedar Road', '78963', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (444, 'Oak Lane', '63258', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (555, 'Maple Boulevard', '25874', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (333, 'Palm Drive', '14785', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (666, 'Pine Street', '95123', 'Portland', 'Oregon', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (777, 'Elm Avenue', '12345', 'Austin', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (888, 'Spruce Lane', '36987', 'Seattle', 'Washington', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (999, 'Birch Court', '45678', 'Denver', 'Colorado', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),


    (122, 'Oak Street', '54321', 'Springfield', 'New York', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (457, 'Maple Avenue', '98765', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (788, 'Elm Street', '45678', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (102, 'Pine Road', '23456', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (333, 'Cedar Lane', '78901', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (333, 'Sycamore Avenue', '69325', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (555, 'Juniper Lane', '35789', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (123, 'Poplar Road', '78963', 'Springfield', 'Ohio', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (133, 'Cypress Lane', '63258', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (123, 'Cherry Street', '98574', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (123, 'Palm Boulevard', '14785', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (333, 'Spruce Lane', '69325', 'Springfield', 'Missouri', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (111, 'Hickory Drive', '35789', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (939, 'Cedar Road', '78963', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (101, 'Oak Lane', '63258', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (333, 'Maple Boulevard', '25874', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (123, 'Palm Drive', '14785', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (323, 'Pine Street', '95123', 'Portland', 'Oregon', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (031, 'Elm Avenue', '12345', 'Austin', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (555, 'Spruce Lane', '69325', 'Seattle', 'Washington', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (991, 'Birch Court', '45678', 'Denver', 'Colorado', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (132, 'Oak Street', '54321', 'Springfield', 'New York', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (459, 'Maple Avenue', '98765', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (789, 'Elm Street', '45678', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (103, 'Pine Road', '23456', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (444, 'Cedar Lane', '78901', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (332, 'Sycamore Avenue', '69325', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (331, 'Pine Oak Ave', '69325', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (777, 'Juniper Lane', '35789', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (321, 'Poplar Road', '78963', 'Springfield', 'Ohio', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (313, 'Cypress Lane', '63258', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (565, 'Acacia Boulevard', '25874', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (193, 'Cherry Street', '98574', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (111, 'Palm Boulevard', '14785', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (444, 'Spruce Lane', '36987', 'Springfield', 'Missouri', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (123, 'Hickory Drive', '35789', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (949, 'Cedar Road', '78963', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (202, 'Oak Lane', '63258', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (444, 'Maple Boulevard', '25874', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (656, 'Acacia Boulevard', '25874', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);


INSERT INTO hotel_chains (chain_name, contact_phone_numbers, contact_emails, created_at, updated_at)
VALUES
    ('Luxury Resorts', '555-123-4567', 'info@luxuryresorts.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Azure Haven Hotels', '555-987-6543', 'info@azurehavenhotels.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Golden Gate Resorts', '555-234-5678', 'info@goldengateresorts.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Crystal Crown Suites', '555-876-5432', 'info@crystalcrownsuites.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Emerald Oasis Lodges', '555-345-6789', 'info@emeraldoasislodges.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO employees (employee_id, full_name, employee_email, role, salary, street_number, street_name, postal_code, city, province_state, created_at, updated_at)
VALUES
    ('EMP001', 'John Doe', 'john.doe@example.com', 'Manager', 60000, 122, 'Oak Street', '54321', 'Springfield', 'New York', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP002', 'Jane Smith', 'jane.smith@example.com', 'Front Desk Clerk', 40000, 457, 'Maple Avenue', '98765', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP003', 'Michael Johnson', 'michael.johnson@example.com', 'Housekeeper', 35000, 788, 'Elm Street', '45678', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP004', 'Emily Brown', 'emily.brown@example.com', 'Concierge', 45000, 102, 'Pine Road', '23456', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP005', 'William Wilson', 'william.wilson@example.com', 'Chef', 55000, 333, 'Cedar Lane', '78901', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP006', 'Sarah Martinez', 'sarah.martinez@example.com', 'Front Desk Manager', 50000, 331, 'Sycamore Avenue', '69325', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP007', 'David Anderson', 'david.anderson@example.com', 'Maintenance Supervisor', 48000, 555, 'Juniper Lane', '35789', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP008', 'Olivia Taylor', 'olivia.taylor@example.com', 'Housekeeping Manager', 47000, 123, 'Poplar Road', '78963', 'Springfield', 'Ohio', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    ('EMP011', 'James Thomas', 'james.thomas@example.com', 'Restaurant Manager', 58000, 133, 'Cypress Lane', '63258', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP012', 'Daniel White', 'daniel.white@example.com', 'Valet', 38000, 123, 'Cherry Street', '98574', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP013', 'Ava Harris', 'ava.harris@example.com', 'Spa Therapist', 46000, 123, 'Palm Boulevard', '14785', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP014', 'Liam Nelson', 'liam.nelson@example.com', 'Security Officer', 42000, 333, 'Spruce Lane', '69325', 'Springfield', 'Missouri', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP015', 'Sophia Carter', 'sophia.carter@example.com', 'Event Coordinator', 50000, 111, 'Hickory Drive', '35789', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP016', 'Logan Perez', 'logan.perez@example.com', 'Housekeeping Supervisor', 49000, 939, 'Cedar Road', '78963', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP017', 'Isabella Roberts', 'isabella.roberts@example.com', 'Concierge Supervisor', 52000, 101, 'Oak Lane', '63258', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP018', 'Mason Rivera', 'mason.rivera@example.com', 'Assistant Restaurant Manager', 54000, 333, 'Maple Boulevard', '25874', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    ('EMP021', 'Avery Evans', 'avery.evans@example.com', 'Head Chef', 60000, 123, 'Palm Drive', '14785', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP022', 'Evelyn Barnes', 'evelyn.barnes@example.com', 'Front Office Manager', 52000, 323, 'Pine Street', '95123', 'Portland', 'Oregon', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP023', 'Noah Hernandez', 'noah.hernandez@example.com', 'Night Auditor', 41000, 031, 'Elm Avenue', '12345', 'Austin', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP024', 'Lily Gonzalez', 'lily.gonzalez@example.com', 'Reservation Agent', 40000, 444, 'Spruce Lane', '36987', 'Springfield', 'Missouri', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP025', 'Jackson Thompson', 'jackson.thompson@example.com', 'Housekeeping Attendant', 36000, 991, 'Birch Court', '45678', 'Denver', 'Colorado', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP026', 'Addison Walker', 'addison.walker@example.com', 'Banquet Server', 37000, 132, 'Oak Street', '54321', 'Springfield', 'New York', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP027', 'Scarlett Scott', 'scarlett.scott@example.com', 'Room Service Attendant', 35000, 459, 'Maple Avenue', '98765', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP028', 'Lucas Murphy', 'lucas.murphy@example.com', 'Barista', 32000, 789, 'Elm Street', '45678', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    ('EMP031', 'Aria Perez', 'aria.perez@example.com', 'Pool Attendant', 33000, 103, 'Pine Road', '23456', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP032', 'Grayson Ramirez', 'grayson.ramirez@example.com', 'Bell Captain', 38000, 444, 'Cedar Lane', '78901', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP033', 'Victoria Cook', 'victoria.cook@example.com', 'Concierge Agent', 42000, 332, 'Sycamore Avenue', '69325', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP034', 'Henry Bailey', 'henry.bailey@example.com', 'Maintenance Technician', 40000, 331, 'Pine Oak Ave', '69325', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP035', 'Madison Hill', 'madison.hill@example.com', 'Front Desk Agent', 35000, 777, 'Juniper Lane', '35789', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP036', 'Ethan Cooper', 'ethan.cooper@example.com', 'Housekeeper', 32000, 321, 'Poplar Road', '78963', 'Springfield', 'Ohio', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP037', 'Peyton Reed', 'peyton.reed@example.com', 'Concierge', 40000, 313, 'Cypress Lane', '63258', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP038', 'Harper King', 'harper.king@example.com', 'Chef', 48000, 565, 'Acacia Boulevard', '25874', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    ('EMP041', 'Landon Wright', 'landon.wright@example.com', 'Front Desk Manager', 50000, 193, 'Cherry Street', '98574', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP042', 'Bella Hill', 'bella.hill@example.com', 'Housekeeping Manager', 48000, 111, 'Palm Boulevard', '14785', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP043', 'Mateo Baker', 'mateo.baker@example.com', 'Restaurant Manager', 55000, 555, 'Spruce Lane', '69325', 'Seattle', 'Washington', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP044', 'Nora Bell', 'nora.bell@example.com', 'Spa Therapist', 45000, 123, 'Hickory Drive', '35789', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP045', 'Leo Murphy', 'leo.murphy@example.com', 'Security Officer', 42000, 949, 'Cedar Road', '78963', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP046', 'Stella Foster', 'stella.foster@example.com', 'Event Coordinator', 50000, 202, 'Oak Lane', '63258', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP047', 'Hudson Gray', 'hudson.gray@example.com', 'Assistant Restaurant Manager', 52000, 444, 'Maple Boulevard', '25874', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('EMP048', 'Emma Jackson', 'emma.jackson@example.com', 'Bellhop', 38000, 656, 'Acacia Boulevard', '25874', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);


INSERT INTO hotels (hotel_id, chain_name, category, manager_id, phone_number, contact_email, street_number, street_name, postal_code, city, province_state, created_at, updated_at)
VALUES
    (1, 'Luxury Resorts', 3, 'EMP001', '000-000-0001', 'hotelA@luxuryresorts.com', 123, 'Oak Street', '54321', 'Springfield', 'New York', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2, 'Luxury Resorts', 3, 'EMP002', '000-000-0002', 'hotelB@luxuryresorts.com', 127, 'Pine Ave', '54327', 'Springfield', 'New York', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (3, 'Luxury Resorts', 2, 'EMP003', '000-000-0003', 'hotelC@luxuryresorts.com', 787, 'Elm Street', '45678', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (4, 'Luxury Resorts', 3, 'EMP004', '000-000-0004', 'hotelD@luxuryresorts.com', 101, 'Pine Road', '23456', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (5, 'Luxury Resorts', 4, 'EMP005', '000-000-0005', 'hotelE@luxuryresorts.com', 456, 'Maple Avenue', '98765', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (6, 'Luxury Resorts', 3, 'EMP006', '000-000-0006', 'hotelF@luxuryresorts.com', 222, 'Cedar Lane', '78901', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (7, 'Luxury Resorts', 2, 'EMP007', '000-000-0007', 'hotelG@luxuryresorts.com', 333, 'Willow Street', '13579', 'Springfield', 'Illinois', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (8, 'Luxury Resorts', 3, 'EMP008', '000-000-0008', 'hotelH@luxuryresorts.com', 444, 'Magnolia Drive', '97531', 'Riverside', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    (11, 'Azure Haven Hotels', 3, 'EMP011', '111-111-1111', 'hotelA@azurehavenhotels.com', 555, 'Birch Avenue', '75390', 'Lexington', 'Tennessee', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (12, 'Azure Haven Hotels', 4, 'EMP012', '111-111-1112', 'hotelB@azurehavenhotels.com', 666, 'Sycamore Lane', '25874', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (13, 'Azure Haven Hotels', 5, 'EMP013', '111-111-1113', 'hotelC@azurehavenhotels.com', 777, 'Juniper Road', '36985', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (14, 'Azure Haven Hotels', 5, 'EMP014', '111-111-1114', 'hotelD@azurehavenhotels.com', 888, 'Poplar Boulevard', '96325', 'Springfield', 'Ohio', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (15, 'Azure Haven Hotels', 5, 'EMP015', '111-111-1115', 'hotelE@azurehavenhotels.com', 777, 'Oakwood Boulevard', '63258', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (16, 'Azure Haven Hotels', 3, 'EMP016', '111-111-1116', 'hotelF@azurehavenhotels.com', 999, 'Cypress Street', '74185', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (17, 'Azure Haven Hotels', 3, 'EMP017', '111-111-1117', 'hotelG@azurehavenhotels.com', 111, 'Acorn Lane', '85296', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (18, 'Azure Haven Hotels', 4, 'EMP018', '111-111-1118', 'hotelH@azurehavenhotels.com', 222, 'Cherry Avenue', '36985', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
        
    (21, 'Golden Gate Resorts', 3, 'EMP021', '222-222-2221', 'hotelA@goldengateresorts.com', 444, 'Spruce Road', '25874', 'Springfield', 'Missouri', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (22, 'Golden Gate Resorts', 4, 'EMP021', '222-222-2222', 'hotelB@goldengateresorts.com', 555, 'Hickory Lane', '69325', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (23, 'Golden Gate Resorts', 4, 'EMP021', '222-222-2223', 'hotelC@goldengateresorts.com', 666, 'Cedar Avenue', '35789', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (24, 'Golden Gate Resorts', 4, 'EMP021', '222-222-2224', 'hotelD@goldengateresorts.com', 999, 'Cypress Street', '74185', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (25, 'Golden Gate Resorts', 4, 'EMP021', '222-222-2225', 'hotelE@goldengateresorts.com', 888, 'Maple Street', '78963', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (26, 'Golden Gate Resorts', 4, 'EMP021', '222-222-2226', 'hotelF@goldengateresorts.com', 999, 'Willow Avenue', '25874', 'Springfield', 'Illinois', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (27, 'Golden Gate Resorts', 4, 'EMP021', '222-222-2227', 'hotelG@goldengateresorts.com', 111, 'Birchwood Drive', '98574', 'Riverside', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (28, 'Golden Gate Resorts', 3, 'EMP021', '222-222-2228', 'hotelH@goldengateresorts.com', 222, 'Magnolia Lane', '14785', 'Lexington', 'Tennessee', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    (31, 'Crystal Crown Suites', 3, 'EMP031', '333-333-3331', 'hotelA@crystalcrownsuites.com', 333, 'Sycamore Avenue', '69325', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (32, 'Crystal Crown Suites', 3, 'EMP032', '333-333-3332', 'hotelB@crystalcrownsuites.com', 444, 'Juniper Lane', '35789', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (33, 'Crystal Crown Suites', 3, 'EMP033', '333-333-3333', 'hotelC@crystalcrownsuites.com', 555, 'Poplar Road', '78963', 'Springfield', 'Ohio', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (34, 'Crystal Crown Suites', 3, 'EMP034', '333-333-3334', 'hotelD@crystalcrownsuites.com', 666, 'Cypress Lane', '63258', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (35, 'Crystal Crown Suites', 3, 'EMP035', '333-333-3335', 'hotelE@crystalcrownsuites.com', 777, 'Acacia Boulevard', '25874', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (36, 'Crystal Crown Suites', 3, 'EMP036', '333-333-3336', 'hotelF@crystalcrownsuites.com', 888, 'Cherry Street', '98574', 'Greenville', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (37, 'Crystal Crown Suites', 3, 'EMP037', '333-333-3337', 'hotelG@crystalcrownsuites.com', 999, 'Palm Boulevard', '14785', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (38, 'Crystal Crown Suites', 3, 'EMP038', '333-333-3338', 'hotelH@crystalcrownsuites.com', 111, 'Spruce Lane', '69325', 'Springfield', 'Missouri', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    (41, 'Emerald Oasis Lodges', 3, 'EMP041', '444-444-4441', 'hotelA@emeraldoasislodges.com', 222, 'Hickory Drive', '35789', 'Riverside', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (42, 'Emerald Oasis Lodges', 5, 'EMP042', '444-444-4442', 'hotelB@emeraldoasislodges.com', 333, 'Cedar Road', '78963', 'Lexington', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (43, 'Emerald Oasis Lodges', 5, 'EMP043', '444-444-4443', 'hotelC@emeraldoasislodges.com', 444, 'Oak Lane', '63258', 'Greenville', 'South Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (44, 'Emerald Oasis Lodges', 3, 'EMP044', '444-444-4444', 'hotelD@emeraldoasislodges.com', 555, 'Maple Boulevard', '25874', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (45, 'Emerald Oasis Lodges', 5, 'EMP045', '444-444-4445', 'hotelE@emeraldoasislodges.com', 333, 'Palm Drive', '14785', 'Birmingham', 'Alabama', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (46, 'Emerald Oasis Lodges', 5, 'EMP046', '444-444-4446', 'hotelF@emeraldoasislodges.com', 666, 'Pine Street', '95123', 'Portland', 'Oregon', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (47, 'Emerald Oasis Lodges', 3, 'EMP047', '444-444-4447', 'hotelG@emeraldoasislodges.com', 777, 'Elm Avenue', '12345', 'Austin', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (48, 'Emerald Oasis Lodges', 5, 'EMP048', '444-444-4448', 'hotelH@emeraldoasislodges.com', 888, 'Spruce Lane', '36987', 'Seattle', 'Washington', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);


INSERT INTO employee_works_for (employee_id, hotel_id, chain_name)
VALUES ('EMP001', 1, 'Luxury Resorts');


INSERT INTO rooms (room_number, hotel_id, chain_name, price, capacity, mountain_view, sea_view, is_expandable, amenities, damages, created_at, updated_at)
VALUES
    (101, 1, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (102, 1, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (103, 1, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (104, 1, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (105, 1, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (121, 2, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (122, 2, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (123, 2, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (124, 2, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (125, 2, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (131, 3, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (132, 3, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (133, 3, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (134, 3, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (135, 3, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (141, 4, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (142, 4, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (143, 4, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (144, 4, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (145, 4, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (151, 5, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (152, 5, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (153, 5, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (154, 5, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (155, 5, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (161, 6, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (162, 6, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (163, 6, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (164, 6, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (165, 6, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (171, 7, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (172, 7, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (173, 7, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (174, 7, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (175, 7, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (181, 8, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (182, 8, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (183, 8, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (184, 8, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (185, 8, 'Luxury Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    (201, 11, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (202, 11, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (203, 11, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (204, 11, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (205, 11, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (221, 12, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (222, 12, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (223, 12, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (224, 12, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (225, 12, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (231, 13, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (232, 13, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (233, 13, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (234, 13, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (235, 13, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (241, 14, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (242, 14, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (243, 14, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (244, 14, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (245, 14, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (251, 15, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (252, 15, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (253, 15, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (254, 15, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (255, 15, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (261, 16, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (262, 16, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (263, 16, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (264, 16, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (265, 16, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (271, 17, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (272, 17, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (273, 17, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (274, 17, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (275, 17, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (281, 18, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (282, 18, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (283, 18, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (284, 18, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (285, 18, 'Azure Haven Hotels', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    (301, 21, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (302, 21, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (303, 21, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (304, 21, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (305, 21, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (321, 22, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (322, 22, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (323, 22, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (324, 22, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (325, 22, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (331, 23, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (332, 23, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (333, 23, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (334, 23, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (335, 23, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (341, 24, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (342, 24, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (343, 24, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (344, 24, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (345, 24, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (351, 25, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (352, 25, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (353, 25, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (354, 25, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (355, 25, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (361, 26, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (362, 26, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (363, 26, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (364, 26, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (365, 26, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (371, 27, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (372, 27, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (373, 27, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (374, 27, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (375, 27, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (381, 28, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (382, 28, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (383, 28, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (384, 28, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (385, 28, 'Golden Gate Resorts', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    (401, 31, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (402, 31, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (403, 31, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (404, 31, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (405, 31, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (421, 32, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (422, 32, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (423, 32, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (424, 32, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (425, 32, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (431, 33, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (432, 33, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (433, 33, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (434, 33, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (435, 33, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (441, 34, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (442, 34, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (443, 34, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (444, 34, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (445, 34, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (451, 35, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (452, 35, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (453, 35, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (454, 35, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (455, 35, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (461, 36, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (462, 36, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (463, 36, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (464, 36, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (465, 36, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (471, 37, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (472, 37, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (473, 37, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (474, 37, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (475, 37, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (481, 38, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (482, 38, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (483, 38, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (484, 38, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (485, 38, 'Crystal Crown Suites', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

    (501, 41, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (502, 41, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (503, 41, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (504, 41, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (505, 41, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (521, 42, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (522, 42, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (523, 42, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (524, 42, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (525, 42, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (531, 43, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (532, 43, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (533, 43, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (534, 43, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (535, 43, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (541, 44, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (542, 44, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (543, 44, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (544, 44, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (545, 44, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (551, 45, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (552, 45, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (553, 45, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (554, 45, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (555, 45, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (561, 46, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (562, 46, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (563, 46, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (564, 46, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (565, 46, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (571, 47, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (572, 47, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (553, 47, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (574, 47, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (575, 47, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (581, 48, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (582, 48, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (583, 48, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (584, 48, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (585, 48, 'Emerald Oasis Lodges', 200.00, 2, TRUE, FALSE, FALSE, 'Mini-bar, TV, WiFi', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

--Customers Addresses & Info

INSERT INTO addresses (street_number, street_name, postal_code, city, province_state, created_at, updated_at)
VALUES
    (123, 'Main Street', '12345', 'New York City', 'New York', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (456, 'Oak Avenue', '23456', 'Los Angeles', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (789, 'Maple Lane', '34567', 'Chicago', 'Illinois', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (101, 'Elm Street', '45678', 'Houston', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (202, 'Cedar Road', '56789', 'Phoenix', 'Arizona', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (303, 'Pine Street', '67890', 'San Francisco', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (404, 'Birch Lane', '78901', 'Seattle', 'Washington', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (505, 'Spruce Avenue', '89012', 'Miami', 'Florida', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (606, 'Ash Street', '90123', 'Denver', 'Colorado', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (707, 'Cherry Road', '01234', 'Boston', 'Massachusetts', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (808, 'Willow Lane', '12356', 'Dallas', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (909, 'Hickory Avenue', '23467', 'Atlanta', 'Georgia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (111, 'Poplar Court', '34578', 'San Diego', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (222, 'Juniper Lane', '45679', 'Las Vegas', 'Nevada', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (333, 'Cypress Street', '56780', 'Orlando', 'Florida', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (444, 'Fir Road', '67890', 'Philadelphia', 'Pennsylvania', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (555, 'Sycamore Avenue', '78901', 'Portland', 'Oregon', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (666, 'Redwood Lane', '89012', 'Austin', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (777, 'Chestnut Lane', '90123', 'San Antonio', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (888, 'Cottonwood Court', '01234', 'Charlotte', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (999, 'Magnolia Avenue', '12345', 'San Jose', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1010, 'Palm Street', '23456', 'Jacksonville', 'Florida', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1111, 'Cedar Street', '34567', 'Indianapolis', 'Indiana', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1212, 'Maple Court', '45678', 'San Francisco', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1313, 'Birch Avenue', '56789', 'Columbus', 'Ohio', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1414, 'Pine Road', '67890', 'Fort Worth', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1515, 'Oak Lane', '78901', 'Detroit', 'Michigan', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1616, 'Elm Court', '89012', 'Memphis', 'Tennessee', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1717, 'Willow Road', '90123', 'Baltimore', 'Maryland', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1818, 'Hickory Street', '01234', 'Boston', 'Massachusetts', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1919, 'Cherry Lane', '12345', 'Washington D.C.', 'District of Columbia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2020, 'Chestnut Avenue', '23456', 'Milwaukee', 'Wisconsin', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2121, 'Sycamore Road', '34567', 'Portland', 'Oregon', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2222, 'Cottonwood Lane', '45678', 'Louisville', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2323, 'Redwood Court', '56789', 'Las Vegas', 'Nevada', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2424, 'Magnolia Street', '67890', 'Oklahoma City', 'Oklahoma', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2525, 'Palm Avenue', '78901', 'Albuquerque', 'New Mexico', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2626, 'Cedar Lane', '89012', 'Tucson', 'Arizona', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2727, 'Maple Road', '90123', 'Fresno', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2828, 'Birch Court', '01234', 'Sacramento', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2929, 'Pine Lane', '12345', 'Long Beach', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (3030, 'Oak Road', '23456', 'Kansas City', 'Missouri', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (3131, 'Elm Avenue', '34567', 'Mesa', 'Arizona', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (3232, 'Willow Street', '45678', 'Virginia Beach', 'Virginia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO customers (full_name, customer_email, street_number, street_name, postal_code, city, province_state, created_at, updated_at)
VALUES
    ('John Doe', 'john.doe@example.com', 123, 'Main Street', '12345', 'New York City', 'New York', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Jane Smith', 'jane.smith@example.com', 456, 'Oak Avenue', '23456', 'Los Angeles', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Michael Johnson', 'michael.johnson@example.com', 789, 'Maple Lane', '34567', 'Chicago', 'Illinois', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Emily Davis', 'emily.davis@example.com', 101, 'Elm Street', '45678', 'Houston', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Robert Wilson', 'robert.wilson@example.com', 202, 'Cedar Road', '56789', 'Phoenix', 'Arizona', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Alice Brown', 'alice.brown@example.com', 303, 'Pine Street', '67890', 'San Francisco', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('David Martinez', 'david.martinez@example.com', 404, 'Birch Lane', '78901', 'Seattle', 'Washington', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Sarah Taylor', 'sarah.taylor@example.com', 505, 'Spruce Avenue', '89012', 'Miami', 'Florida', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('James Anderson', 'james.anderson@example.com', 606, 'Ash Street', '90123', 'Denver', 'Colorado', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Michelle Thomas', 'michelle.thomas@example.com', 707, 'Cherry Road', '01234', 'Boston', 'Massachusetts', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Christopher Garcia', 'christopher.garcia@example.com', 808, 'Willow Lane', '12356', 'Dallas', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Amanda Hernandez', 'amanda.hernandez@example.com', 909, 'Hickory Avenue', '23467', 'Atlanta', 'Georgia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Daniel King', 'daniel.king@example.com', 111, 'Poplar Court', '34578', 'San Diego', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Linda Martinez', 'linda.martinez@example.com', 222, 'Juniper Lane', '45679', 'Las Vegas', 'Nevada', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('William Lee', 'william.lee@example.com', 333, 'Cypress Street', '56780', 'Orlando', 'Florida', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Karen Clark', 'karen.clark@example.com', 444, 'Fir Road', '67890', 'Philadelphia', 'Pennsylvania', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Brandon Rodriguez', 'brandon.rodriguez@example.com', 555, 'Sycamore Avenue', '78901', 'Portland', 'Oregon', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Jennifer Scott', 'jennifer.scott@example.com', 666, 'Redwood Lane', '89012', 'Austin', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Taylor Walker', 'taylor.walker@example.com', 777, 'Chestnut Lane', '90123', 'San Antonio', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Rachel Perez', 'rachel.perez@example.com', 888, 'Cottonwood Court', '01234', 'Charlotte', 'North Carolina', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Matthew Evans', 'matthew.evans@example.com', 999, 'Magnolia Avenue', '12345', 'San Jose', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Lauren Turner', 'lauren.turner@example.com', 1010, 'Palm Street', '23456', 'Jacksonville', 'Florida', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Ryan Hill', 'ryan.hill@example.com', 1111, 'Cedar Street', '34567', 'Indianapolis', 'Indiana', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Ashley White', 'ashley.white@example.com', 1212, 'Maple Court', '45678', 'San Francisco', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Joshua Harris', 'joshua.harris@example.com', 1313, 'Birch Avenue', '56789', 'Columbus', 'Ohio', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Megan Martinez', 'megan.martinez@example.com', 1414, 'Pine Road', '67890', 'Fort Worth', 'Texas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Justin Nelson', 'justin.nelson@example.com', 1515, 'Oak Lane', '78901', 'Detroit', 'Michigan', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Brittany Carter', 'brittany.carter@example.com', 1616, 'Elm Court', '89012', 'Memphis', 'Tennessee', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Brandon Bell', 'brandon.bell@example.com', 1717, 'Willow Road', '90123', 'Baltimore', 'Maryland', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Stephanie Ross', 'stephanie.ross@example.com', 1818, 'Hickory Street', '01234', 'Boston', 'Massachusetts', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Nicole Rivera', 'nicole.rivera@example.com', 1919, 'Cherry Lane', '12345', 'Washington D.C.', 'District of Columbia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Jessica Stewart', 'jessica.stewart@example.com', 2121, 'Sycamore Road', '34567', 'Portland', 'Oregon', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Timothy Sanchez', 'timothy.sanchez@example.com', 2222, 'Cottonwood Lane', '45678', 'Louisville', 'Kentucky', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Heather Cooper', 'heather.cooper@example.com', 2323, 'Redwood Court', '56789', 'Las Vegas', 'Nevada', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Zachary Morris', 'zachary.morris@example.com', 2424, 'Magnolia Street', '67890', 'Oklahoma City', 'Oklahoma', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Diana Bailey', 'diana.bailey@example.com', 2525, 'Palm Avenue', '78901', 'Albuquerque', 'New Mexico', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Stephen Murphy', 'stephen.murphy@example.com', 2626, 'Cedar Lane', '89012', 'Tucson', 'Arizona', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Katherine Cook', 'katherine.cook@example.com', 2727, 'Maple Road', '90123', 'Fresno', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Austin Bailey', 'austin.bailey@example.com', 2828, 'Birch Court', '01234', 'Sacramento', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Rebecca Simmons', 'rebecca.simmons@example.com', 2929, 'Pine Lane', '12345', 'Long Beach', 'California', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Emma Powell', 'emma.powell@example.com', 3030, 'Oak Road', '23456', 'Kansas City', 'Missouri', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Vincent Cox', 'vincent.cox@example.com', 3131, 'Elm Avenue', '34567', 'Mesa', 'Arizona', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Evelyn Peterson', 'evelyn.peterson@example.com', 3232, 'Willow Street', '45678', 'Virginia Beach', 'Virginia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO customers (full_name, customer_email, street_number, street_name, postal_code, city, province_state, created_at, updated_at)
VALUES ('John Doe', 'johndoe@example.com', 656, 'Acacia Boulevard', '25874', 'Lexington', 'Kentucky', NOW(), NOW());
