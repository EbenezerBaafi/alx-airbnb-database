# Airbnb Database - Sample Data

## Overview
This directory contains SQL scripts to populate the Airbnb database with realistic sample data for testing and development purposes. The seed data demonstrates typical usage patterns and relationships within the system.

## File Structure
```
database-script-0x02/
├── seed.sql          # Complete sample data insertion script
└── README.md         # This documentation file
```

## Sample Data Overview

### Users (3 records)
- **1 Administrator**: System admin with full platform access
- **1 Host**: Property owner managing multiple listings
- **1 Guest**: Regular user making bookings and reviews

| Role  | Name | Email | Properties Owned | Bookings Made |
|-------|------|-------|------------------|---------------|
| Admin | John Smith | admin@airbnb.com | 0 | 0 |
| Host  | Alice Kwakye | alice@gmail.com | 3 | 0 |
| Guest | Kwaku Atta | kwaku@gmail.com | 0 | 3 |

### Properties (3 records)
All properties owned by Alice (user-002) representing different accommodation types:

| Property | Type | Location | Price/Night | Description |
|----------|------|----------|-------------|-------------|
| Cozy Cottage | Countryside | Spintex | $120.00 | Rural retreat |
| Modern Apartment | City Center | Accra | $200.00 | Urban convenience |
| Beach House | Coastal | Cape Coast | $300.00 | Ocean views |

### Bookings (3 records)
All bookings made by Kwaku (user-003) showing different booking statuses:

| Booking | Property | Dates | Total | Status | Duration |
|---------|----------|-------|-------|--------|----------|
| book-001 | Cozy Cottage | Oct 1-5, 2023 | $480.00 | Confirmed | 4 nights |
| book-002 | Modern Apartment | Nov 10-15, 2023 | $1,000.00 | Pending | 5 nights |
| book-003 | Beach House | Dec 20-25, 2023 | $1,500.00 | Canceled | 5 nights |

### Reviews (3 records)
Guest reviews for each property with varying ratings:

| Property | Rating | Comment Summary |
|----------|--------|-----------------|
| Cozy Cottage | ⭐⭐⭐⭐⭐ (5/5) | Excellent stay, highly recommended |
| Modern Apartment | ⭐⭐⭐⭐ (4/5) | Good location, minor noise issues |
| Beach House | ⭐⭐⭐ (3/5) | Average experience, room for improvement |

### Messages (3 records)
Communication thread between guest and host:
1. Initial inquiry about property availability
2. Host's helpful response
3. Guest's specific date request

### Payments (3 records)
Payment records for each booking using different methods:
- **Credit Card**: $480.00 (Confirmed booking)
- **PayPal**: $1,000.00 (Pending booking)
- **Stripe**: $1,500.00 (Canceled booking)

## Usage Instructions

### Prerequisites
- MySQL database server running
- Airbnb database schema already created (from database-script-0x01)
- Proper permissions to insert data

### Running the Seed Script

1. **Ensure schema is loaded first**:
   ```bash
   mysql -u username -p airbnb_db < ../database-script-0x01/schema.sql
   ```

2. **Load sample data**:
   ```bash
   mysql -u username -p airbnb_db < seed.sql
   ```

3. **Verify data insertion**:
   ```sql
   USE airbnb_db;
   SELECT COUNT(*) FROM User;      -- Should return 3
   SELECT COUNT(*) FROM Property;  -- Should return 3
   SELECT COUNT(*) FROM Booking;   -- Should return 3
   SELECT COUNT(*) FROM Review;    -- Should return 3
   SELECT COUNT(*) FROM Message;   -- Should return 3
   SELECT COUNT(*) FROM Payment;   -- Should return 3
   ```

## Data Relationships Demonstrated

### Host-Property Relationship
- Alice (host) manages all 3 properties, showing a typical host with multiple listings

### Guest-Booking Pattern  
- Kwaku has varied booking history: confirmed, pending, and canceled reservations
- Demonstrates realistic user behavior with different outcomes

### Review Correlation
- Reviews align with booking confirmations
- Rating distribution (5, 4, 3 stars) shows realistic guest feedback patterns

### Communication Flow
- Message thread shows typical pre-booking inquiry process
- Demonstrates guest-host interaction workflow

### Payment Processing
- Each booking has corresponding payment record
- Multiple payment methods showcase platform flexibility
- Payment amounts match calculated booking totals

## Business Logic Validation

### Price Calculations ✅
- **Cozy Cottage**: 4 nights × $120 = $480 ✅
- **Modern Apartment**: 5 nights × $200 = $1,000 ✅
- **Beach House**: 5 nights × $300 = $1,500 ✅

### Referential Integrity ✅
- All foreign keys reference valid records
- User roles align with their activities (host owns properties, guest makes bookings)
- Review authors match booking guests

### Date Logic ✅
- Booking dates are sequential and realistic
- No overlapping bookings for same property
- Historical dates appropriate for sample data

## Testing Scenarios

This sample data enables testing of:

### User Management
- Admin operations and permissions
- Host property management
- Guest booking workflows

### Booking System
- Reservation creation and status updates
- Price calculation accuracy
- Booking conflicts and availability

### Review System
- Rating submission and display
- Review authenticity (reviewer must have booking)
- Property rating aggregation

### Communication
- User-to-user messaging
- Inquiry and response handling
- Message threading

### Payment Processing
- Multiple payment method support
- Transaction recording
- Payment-booking relationships

## Extending the Sample Data

To add more realistic data:

### Additional Users
```sql
INSERT INTO User VALUES 
('user-004', 'Mary', 'Johnson', 'mary@example.com', 'hash456', '+1555000001', 'guest'),
('user-005', 'David', 'Wilson', 'david@example.com', 'hash789', '+1555000002', 'host');
```

### More Properties
- Add properties for new hosts
- Include different price ranges
- Vary property types and locations

### Complex Booking Scenarios
- Overlapping date requests
- Long-term stays
- Group bookings
- Seasonal pricing variations

## Notes and Limitations

### Data Quality
- Phone numbers are formatted consistently
- Email addresses follow realistic patterns
- Passwords are appropriately hashed (placeholder values)

### Geographic Context
- Sample locations use Ghana-based addresses (Accra, Cape Coast, Spintex)
- Prices in USD for international compatibility

### Date Considerations
- Sample dates use 2023 for historical context
- Adjust dates as needed for current testing requirements

### Known Issues
- PaymentMethod table requires pre-population (handled in schema)
- UUID values are sequential for simplicity (use proper UUID generation in production)

---

**Author**: Ebenezer Baafi  
**Program**: ALX Software Engineering Program  
**Last Updated**: August 29, 2025  
**Version**: 1.0.0