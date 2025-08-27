# ERD Requirements

## Entities
- User: id, name, email, password, etc.
- Property: id, title, price, host_id, etc.
- Booking: id, user_id, property_id, dates, status, etc.
- Payment: id, booking_id, amount, status, etc.
- Review: id, user_id, property_id, rating, comment, etc.

## Relationships
- A **user** can create many **bookings**.
- A **property** can have many **bookings**.
- Each **booking** has one **payment**.
- Users can leave many **reviews** on properties.

## ERD Diagram
![ERD Diagram](./air-bnb_erd.png)
