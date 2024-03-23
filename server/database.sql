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
    customer_id VARCHAR(20) PRIMARY KEY CHECK (customer_id ~ '^[0-9]+$'),
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
    booking_id INT PRIMARY KEY,
    status VARCHAR(255) NOT NULL,
    customer_id VARCHAR(20),
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    room_number INT,
    hotel_id INT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE rentings(
    renting_id INT PRIMARY KEY,
    employee_id VARCHAR(20) NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    room_number INT NOT NULL,
    hotel_id INT NOT NULL,
    booking_id INT,
    has_booked BOOLEAN DEFAULT 't' NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY(employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY(booking_id) REFERENCES bookings(booking_id)
);

CREATE TABLE archives(
    archive_id INT PRIMARY KEY,
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
