set time zone 'UTC';
create extension pgcrypto;

CREATE TABLE payments (
    id VARCHAR(255) PRIMARY KEY NOT NULL,
    name VARCHAR(255) NOT NULL,
    billing_address VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    number VARCHAR(255) NOT NULL,
    expiration VARCHAR(255) NOT NULL,
    security_code VARCHAR(255) NOT NULL,
    status VARCHAR(255)
);

INSERT INTO payments (id, name, billing_address, created_at, number, expiration, security_code, status) VALUES ('2310d6be-0e80-11ed-861d-0242ac120002', 'Red Panda', '8 Eastern Himalayas Drive', CURRENT_DATE, '1234-5678-9012-3456', '10/2026', '987', 'paid');