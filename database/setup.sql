set time zone 'UTC';
create extension pgcrypto;

CREATE TABLE payments (
    id serial PRIMARY KEY,
    name VARCHAR (255) NOT NULL,
    billing_address VARCHAR(255) NOT NULL,
    payment_id INT NULL,
    created_at TIMESTAMP NOT NULL
);

INSERT INTO payments (id, name, billing_address, created_at) VALUES (1, 'Red Panda', '8 Eastern Himalayas Drive', CURRENT_DATE);