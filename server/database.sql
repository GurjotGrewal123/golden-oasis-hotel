CREATE TABLE addresses(
    street_number INT NOT NULL,
    street_name VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province_state VARCHAR(50),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    CONSTRAINT pk_address PRIMARY KEY (street_name, street_number, postal_code)
);

CREATE TABLE hotel_chain(
    chain_name VARCHAR(255) PRIMARY KEY,
    contact_phone_numbers VARCHAR(20) NOT NULL,
    contact_emails VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);


CREATE TABLE employees(
    employee_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    employee_email VARCHAR(255) DEFAULT '' NOT NULL,
    role VARCHAR(20) NOT NULL,
    salary INT NOT NULL,
    street_name VARCHAR(100) NOT NULL,
    street_number INT NOT NULL,
    city VARCHAR(100) NOT NULL,
    province_state VARCHAR(50),
    country VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    FOREIGN KEY(street_number, street_name, postal_code) REFERENCES addresses(street_number, street_name, postal_code)
);

CREATE TABLE hotels(
    hotel_id INT PRIMARY KEY,
    chain_name VARCHAR(255) NOT NULL,
    manager_id VARCHAR(20) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    street_name VARCHAR(100) NOT NULL,
    street_number int NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province_state VARCHAR(50),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    FOREIGN KEY(chain_name) REFERENCES hotel_chain(chain_name),
    FOREIGN KEY(manager_id) REFERENCES employees(employee_id),
    FOREIGN KEY(street_number, street_name, postal_code) REFERENCES addresses(street_number, street_name, postal_code)
);

CREATE TABLE employee_works_for(
    employee_id VARCHAR(20) NOT NULL,
    hotel_id INT NOT NULL,

    FOREIGN KEY(employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY(hotel_id) REFERENCES hotels(hotel_id)
);

CREATE TABLE rooms(
    room_number INT NOT NULL,
    hotel_id INT NOT NULL,
    price FLOAT NOT NULL,
    capacity INT NOT NULL,
    mountain_view BOOLEAN default 'f' NOT NULL,
    sea_view BOOLEAN default 'f' NOT NULL,
    is_expandable BOOLEAN default 'f' NOT NULL,
    amenities TEXT default '',
    damages TEXT default '',
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    FOREIGN KEY(hotel_id) REFERENCES hotels(hotel_id),
    CONSTRAINT pk_room PRIMARY KEY (room_number, hotel_id)
);

CREATE TABLE customers(
    customer_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(255) DEFAULT '' NOT NULL,
    street_number int NOT NULL,
    street_name VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province_state VARCHAR(50),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    FOREIGN KEY(street_number, street_name, postal_code) REFERENCES addresses(street_number, street_name, postal_code)
);


CREATE TABLE bookings(
    booking_id INT PRIMARY KEY,
    status VARCHAR NOT NULL,
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
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
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

