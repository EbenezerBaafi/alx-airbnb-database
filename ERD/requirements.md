# ERD Requirements

## Entities
- User: 
user_id: Primary Key
first_name: VARCHAR
last_name: VARCHAR
email: VARCHAR, UNIQUE
password_hash: VARCHAR
phone_number: VARCHAR, NULL
role: ENUM 
created_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

- Property:
property_id: Primary Key
host_id: Foreign Key
name: VARCHAR
description: TEXT
location: VARCHAR
pricepernight: DECIMAL
created_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
updated_at: TIMESTAMP, ON UPDATE CURRENT_TIMESTAMP

- Booking: 
booking_id: Primary Key
property_id: Foreign Key 
user_id: Foreign Key
start_date: DATE
end_date: DATE
total_price: DECIMAL
status: ENUM 
created_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

- Payment: 
payment_id: Primary Key
booking_id: Foreign Key
amount: DECIMAL
payment_date: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
payment_method: ENUM

- Review: 
review_id: Primary Key
property_id: Foreign Key
user_id: Foreign Key
rating: INTEGER
comment: TEXT
created_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

-Message:
message_id: Primary Key
sender_id: Foreign Key
recipient_id: Foreign Key
message_body: TEXT
sent_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

## Relationships
- A **user** can create many **bookings**.
- A **property** can have many **bookings**.
- Each **booking** has one **payment**.
- Users can leave many **reviews** on properties.

## ERD Diagram
![ERD Diagram](air-bnb_erd.png)


