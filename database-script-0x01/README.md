# Airbnb Database Schema

## Overview
This directory contains the normalized database schema for an Airbnb-like application. The schema follows **Third Normal Form (3NF)** principles to ensure data integrity, minimize redundancy, and optimize performance.

## Database Structure

### Core Entities
The database consists of **7 main tables** that represent the core business logic:

- **User** - Platform users (guests, hosts, admins)
- **Property** - Rental properties listed by hosts
- **Booking** - Reservation records linking users and properties
- **Payment** - Financial transactions for bookings
- **PaymentMethod** - Normalized lookup table for payment types
- **Review** - User reviews and ratings for properties
- **Message** - Communication system between users

### Normalization Applied
- **1NF**: All attributes contain atomic values
- **2NF**: No partial dependencies on primary keys
- **3NF**: Eliminated transitive dependencies by creating `PaymentMethod` lookup table

## Entity Relationships

```
User (1) ──→ (Many) Property [host relationship]
User (1) ──→ (Many) Booking [guest relationship]
User (1) ──→ (Many) Review [reviewer relationship]
User (1) ──→ (Many) Message [sender/recipient]

Property (1) ──→ (Many) Booking
Property (1) ──→ (Many) Review

Booking (1) ──→ (1) Payment
PaymentMethod (1) ──→ (Many) Payment
```

## Key Features

### Data Integrity
- **Primary Keys**: UUID identifiers for all entities
- **Foreign Key Constraints**: Maintain referential integrity
- **Check Constraints**: Rating validation (1-5 scale)
- **Unique Constraints**: Email uniqueness for users

### Performance Optimization
- **Indexed Columns**: 
  - `User.email` for fast authentication
  - `Property.property_id` for quick property lookups
  - `Booking.property_id` for booking history queries
  - `Payment.booking_id` for payment processing

### Business Logic
- **User Roles**: Guest, Host, Admin with ENUM validation
- **Booking Status**: Pending, Confirmed, Canceled workflow
- **Payment Methods**: Credit Card, PayPal, Stripe (normalized)
- **Rating System**: 1-5 star reviews with validation

## Schema Files

- `schema.sql` - Complete database creation script with all tables, constraints, and indexes

## Installation & Usage

### Prerequisites
- MySQL 5.7+ or compatible database system

### Setup Instructions

1. **Create Database**
   ```sql
   CREATE DATABASE airbnb_db;
   USE airbnb_db;
   ```

2. **Run Schema Script**
   ```bash
   mysql -u username -p airbnb_db < schema.sql
   ```

3. **Verify Installation**
   ```sql
   SHOW TABLES;
   DESCRIBE User;
   ```

## Database Design Decisions

### Why PaymentMethod Normalization?
Originally, payment methods were stored as ENUM values. We normalized this into a separate table to:
- Enable easy addition of new payment methods
- Support additional attributes (fees, processing details)
- Follow 3NF principles by eliminating transitive dependencies
- Provide better extensibility for business growth

### UUID Primary Keys
We use VARCHAR(36) to store UUID values because:
- Globally unique across distributed systems
- Better security (non-sequential IDs)
- Easier data migration and replication
- Industry standard for modern applications

### Timestamp Strategy
- `created_at`: Auto-populated on record creation
- `updated_at`: Auto-updated on any record modification
- `sent_at`/`payment_date`: Specific business timestamp fields

## Future Enhancements

Potential schema expansions for additional features:
- **Location normalization**: Separate City/State/Country tables
- **Amenities**: Many-to-many relationship with properties
- **Property Images**: Media storage table
- **Booking modifications**: Change history tracking
- **User preferences**: Settings and preferences table

## Performance Considerations

### Query Optimization
The current indexing strategy supports these common query patterns:
- User authentication by email
- Property search and filtering
- Booking history retrieval
- Payment processing workflows
- Review display for properties

### Scalability Notes
- Consider partitioning for large `Booking` and `Message` tables
- Implement read replicas for heavy SELECT workloads
- Cache frequently accessed property data
- Monitor index usage and optimize as needed

## Contributing

When modifying this schema:
1. Maintain 3NF compliance
2. Update this README with changes
3. Add appropriate indexes for new query patterns
4. Test foreign key constraints thoroughly
5. Document any breaking changes

## Technical Specifications

- **Database Engine**: MySQL/MariaDB compatible
- **Character Set**: UTF-8 (utf8mb4)
- **Primary Key Type**: UUID (VARCHAR 36)
- **Normalization Level**: Third Normal Form (3NF)
- **Relationship Types**: One-to-Many, One-to-One, Many-to-Many

---

**Author**: Ebenzer Baafi  
**Email**:ebaafi007@gmail.com
**Last Updated**: 8/28/2025 
**Program**: ALX Software Engineering Program
**Project**: Airbnb Database Design
**Version**: 1.0.0