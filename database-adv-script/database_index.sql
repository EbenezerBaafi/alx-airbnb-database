-- =============================================
-- DATABASE INDEXES FOR PERFORMANCE OPTIMIZATION
-- File: database_index.sql
-- Based on high-usage column analysis
-- =============================================

-- =============================================
-- USER TABLE INDEXES
-- =============================================

-- Primary key index (automatically created, but listed for reference)
-- CREATE INDEX idx_user_primary ON User(user_id);

-- Authentication and user lookup indexes
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_user_role ON User(role);
CREATE INDEX idx_user_created_at ON User(created_at);

-- Composite index for user authentication with role filtering
CREATE INDEX idx_user_email_role ON User(email, role);

-- Index for user registration reports (ordered by creation date)
CREATE INDEX idx_user_role_created_at ON User(role, created_at);

-- =============================================
-- BOOKING TABLE INDEXES
-- =============================================

-- Foreign key indexes for JOIN performance
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_property_id ON Booking(property_id);

-- Status filtering index
CREATE INDEX idx_booking_status ON Booking(status);

-- Date range indexes for availability checks
CREATE INDEX idx_booking_start_date ON Booking(start_date);
CREATE INDEX idx_booking_end_date ON Booking(end_date);
CREATE INDEX idx_booking_date_range ON Booking(start_date, end_date);

-- Composite indexes for common query patterns
CREATE INDEX idx_booking_property_status ON Booking(property_id, status);
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);
CREATE INDEX idx_booking_property_dates ON Booking(property_id, start_date, end_date);
CREATE INDEX idx_booking_status_dates ON Booking(status, start_date, end_date);

-- Index for booking history and reporting
CREATE INDEX idx_booking_created_at ON Booking(created_at);
CREATE INDEX idx_booking_user_created_at ON Booking(user_id, created_at);

-- Index for price aggregations and sorting
CREATE INDEX idx_booking_total_price ON Booking(total_price);
CREATE INDEX idx_booking_status_price ON Booking(status, total_price);

-- =============================================
-- PROPERTY TABLE INDEXES
-- =============================================

-- Foreign key index for host information JOINs
CREATE INDEX idx_property_host_id ON Property(host_id);

-- Location search index (for LIKE operations)
CREATE INDEX idx_property_location ON Property(location);

-- Price filtering and sorting index
CREATE INDEX idx_property_price_per_night ON Property(price_per_night);

-- Composite indexes for common search patterns
CREATE INDEX idx_property_location_price ON Property(location, price_per_night);
CREATE INDEX idx_property_host_created_at ON Property(host_id, created_at);

-- Index for property listings ordered by creation date
CREATE INDEX idx_property_created_at ON Property(created_at);

-- Full-text search index for property names (if supported by your database)
-- Note: Syntax may vary depending on database system
-- CREATE FULLTEXT INDEX idx_property_name_fulltext ON Property(name);

-- =============================================
-- REVIEW TABLE INDEXES
-- =============================================

-- Foreign key indexes for JOINs
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);

-- Rating filtering and aggregation index
CREATE INDEX idx_review_rating ON Review(rating);

-- Composite indexes for property review aggregations
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);
CREATE INDEX idx_review_property_created_at ON Review(property_id, created_at);

-- Index for recent reviews
CREATE INDEX idx_review_created_at ON Review(created_at);

-- Index for user review history
CREATE INDEX idx_review_user_created_at ON Review(user_id, created_at);

-- Composite index for property reviews with ratings and dates
CREATE INDEX idx_review_property_rating_date ON Review(property_id, rating, created_at);

-- =============================================
-- ADDITIONAL PERFORMANCE INDEXES
-- =============================================

-- Covering indexes for frequently accessed data combinations
-- (Include additional columns to avoid table lookups)

-- User profile information covering index
CREATE INDEX idx_user_email_covering ON User(email, user_id, first_name, last_name, role);

-- Property search covering index
CREATE INDEX idx_property_search_covering ON Property(location, price_per_night, property_id, name, host_id);

-- Booking confirmation covering index
CREATE INDEX idx_booking_confirmation_covering ON Booking(property_id, status, start_date, end_date, booking_id, user_id);

-- Property rating summary covering index
CREATE INDEX idx_review_rating_covering ON Review(property_id, rating, review_id, created_at);

-- =============================================
-- PARTIAL INDEXES (PostgreSQL specific)
-- Uncomment if using PostgreSQL for better performance
-- =============================================

-- Partial index for confirmed bookings only
-- CREATE INDEX idx_booking_confirmed_dates ON Booking(property_id, start_date, end_date) WHERE status = 'confirmed';

-- Partial index for active properties only
-- CREATE INDEX idx_property_active_location ON Property(location, price_per_night) WHERE status = 'active';

-- Partial index for high-rated reviews only
-- CREATE INDEX idx_review_high_rating ON Review(property_id, created_at) WHERE rating >= 4;

-- =============================================
-- INDEX MAINTENANCE NOTES
-- =============================================

/*
IMPORTANT MAINTENANCE CONSIDERATIONS:

1. Monitor index usage with database-specific tools:
   - PostgreSQL: pg_stat_user_indexes
   - MySQL: INFORMATION_SCHEMA.STATISTICS
   - SQL Server: sys.dm_db_index_usage_stats

2. Regularly analyze query execution plans to ensure indexes are being used

3. Consider dropping unused indexes to reduce storage overhead and improve write performance

4. Update statistics regularly for optimal query planning:
   - PostgreSQL: ANALYZE table_name;
   - MySQL: ANALYZE TABLE table_name;
   - SQL Server: UPDATE STATISTICS table_name;

5. Monitor index fragmentation and rebuild when necessary

6. Test index performance in a staging environment before applying to production

7. Consider the impact on INSERT/UPDATE/DELETE performance when adding indexes
*/