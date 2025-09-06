# 🔍 High-Usage Column Analysis

Based on the queries written throughout our session, here are the high-usage columns identified in each table:

## USER TABLE High-Usage Columns

### Primary Usage
- **`user_id`** (PRIMARY KEY) - Used in ALL JOINs with Booking, Property, and Review tables
- **`email`** - Used in WHERE clauses for authentication/login queries
- **`role`** - Used in WHERE clauses to filter by user type (guest, host, admin)
- **`created_at`** - Used in ORDER BY clauses for user registration reports

### Secondary Usage
- **`first_name`, `last_name`** - Used in SELECT clauses and CONCAT operations
- **`phone_number`** - Retrieved in user profile queries

## BOOKING TABLE High-Usage Columns

### Primary Usage
- **`booking_id`** (PRIMARY KEY) - Used in all booking-related queries and COUNT operations
- **`user_id`** (FOREIGN KEY) - Heavily used in JOINs with User table
- **`property_id`** (FOREIGN KEY) - Heavily used in JOINs with Property table
- **`status`** - Used in WHERE clauses to filter bookings ('pending', 'confirmed', 'canceled')
- **`start_date`, `end_date`** - Used in WHERE clauses for date range queries and availability checks

### Secondary Usage
- **`total_price`** - Used in SUM, AVG aggregations and ORDER BY clauses
- **`created_at`** - Used in ORDER BY clauses for booking history

## PROPERTY TABLE High-Usage Columns

### Primary Usage
- **`property_id`** (PRIMARY KEY) - Used in ALL JOINs with Booking and Review tables
- **`host_id`** (FOREIGN KEY) - Used in JOINs with User table to get host information
- **`location`** - Used in WHERE clauses for location-based searches (LIKE operations)
- **`price_per_night`** - Used in WHERE clauses for price range filtering and ORDER BY

### Secondary Usage
- **`name`** - Used in SELECT clauses and search results
- **`created_at`** - Used in ORDER BY clauses for property listings
- **`description`** - Retrieved in property detail queries

## REVIEW TABLE High-Usage Columns

### Primary Usage
- **`review_id`** (PRIMARY KEY) - Used in COUNT operations
- **`property_id`** (FOREIGN KEY) - Heavily used in JOINs and WHERE clauses for property reviews
- **`user_id`** (FOREIGN KEY) - Used in JOINs with User table for reviewer information
- **`rating`** - Used in WHERE clauses, AVG aggregations, and HAVING clauses

### Secondary Usage
- **`created_at`** - Used in ORDER BY clauses for recent reviews
- **`comment`** - Retrieved in review display queries

---

## 📊 Usage Pattern Summary

### Most Critical for Indexing
1. **All Foreign Keys** (`user_id`, `property_id`, `host_id`) - JOIN performance
2. **Filter Columns** (`email`, `role`, `status`, `location`) - WHERE clause performance
3. **Date Columns** (`start_date`, `end_date`, `created_at`) - Range queries
4. **Aggregation Columns** (`rating`, `total_price`) - GROUP BY and aggregation performance

### Query Patterns Observed
- **User authentication**: `WHERE email = ?`
- **Booking availability**: `WHERE start_date BETWEEN ? AND ?`
- **Location search**: `WHERE location LIKE ?`
- **Price filtering**: `WHERE price_per_night BETWEEN ? AND ?`
- **Rating aggregation**: `AVG(rating) GROUP BY property_id`
- **Status filtering**: `WHERE status = 'confirmed'`

### 💡 Recommendation
These columns should be prioritized for indexing to optimize the performance of your most common query patterns. Focus on creating composite indexes for frequently combined WHERE clause conditions and ensure all foreign keys have appropriate indexes for JOIN operations.