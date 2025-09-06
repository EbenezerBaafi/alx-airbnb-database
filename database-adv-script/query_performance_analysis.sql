-- =============================================
-- QUERY PERFORMANCE ANALYSIS
-- File: query_performance_analysis.sql
-- Measures performance before and after adding indexes
-- =============================================

-- =============================================
-- SETUP: Enable Query Analysis
-- =============================================

-- PostgreSQL: Enable timing and detailed analysis
-- SET track_io_timing = ON;
-- SET log_statement_stats = ON;

-- MySQL: Enable profiling
-- SET profiling = 1;

-- SQL Server: Enable statistics
-- SET STATISTICS IO ON;
-- SET STATISTICS TIME ON;

-- =============================================
-- PHASE 1: BASELINE PERFORMANCE (BEFORE INDEXES)
-- =============================================

\echo '==========================================';
\echo 'PHASE 1: BASELINE PERFORMANCE ANALYSIS';
\echo 'Testing queries WITHOUT custom indexes';
\echo '==========================================';

-- =============================================
-- TEST 1: User Authentication Query
-- =============================================

\echo '\n--- TEST 1: User Authentication Query ---';

-- PostgreSQL/MySQL
EXPLAIN (ANALYZE, BUFFERS) 
SELECT user_id, first_name, last_name, role 
FROM User 
WHERE email = 'john.doe@email.com';

-- Alternative for SQL Server
-- SET STATISTICS IO ON;
-- SELECT user_id, first_name, last_name, role FROM User WHERE email = 'john.doe@email.com';

-- =============================================
-- TEST 2: Booking Availability Check
-- =============================================

\echo '\n--- TEST 2: Booking Availability Check ---';

EXPLAIN (ANALYZE, BUFFERS)
SELECT b.booking_id, b.start_date, b.end_date, b.status,
       p.name AS property_name, u.first_name, u.last_name
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
JOIN User u ON b.user_id = u.user_id
WHERE b.property_id = 1
  AND b.status IN ('confirmed', 'pending')
  AND b.start_date >= '2024-01-01'
  AND b.end_date <= '2024-12-31';

-- =============================================
-- TEST 3: Location-Based Property Search
-- =============================================

\echo '\n--- TEST 3: Location-Based Property Search ---';

EXPLAIN (ANALYZE, BUFFERS)
SELECT p.property_id, p.name, p.location, p.price_per_night,
       u.first_name AS host_name,
       AVG(r.rating) AS avg_rating,
       COUNT(r.review_id) AS review_count
FROM Property p
JOIN User u ON p.host_id = u.user_id
LEFT JOIN Review r ON p.property_id = r.property_id
WHERE p.location LIKE '%New York%'
  AND p.price_per_night BETWEEN 100 AND 300
GROUP BY p.property_id, p.name, p.location, p.price_per_night, u.first_name
HAVING AVG(r.rating) >= 4.0
ORDER BY avg_rating DESC, p.price_per_night ASC;

-- =============================================
-- TEST 4: Host Revenue Analysis
-- =============================================

\echo '\n--- TEST 4: Host Revenue Analysis ---';

EXPLAIN (ANALYZE, BUFFERS)
SELECT u.user_id, u.first_name, u.last_name,
       COUNT(b.booking_id) AS total_bookings,
       SUM(b.total_price) AS total_revenue,
       AVG(b.total_price) AS avg_booking_value
FROM User u
JOIN Property p ON u.user_id = p.host_id
JOIN Booking b ON p.property_id = b.property_id
WHERE u.role = 'host'
  AND b.status = 'confirmed'
  AND b.created_at >= '2024-01-01'
GROUP BY u.user_id, u.first_name, u.last_name
HAVING COUNT(b.booking_id) >= 5
ORDER BY total_revenue DESC;

-- =============================================
-- TEST 5: Recent Reviews Query
-- =============================================

\echo '\n--- TEST 5: Recent Reviews Query ---';

EXPLAIN (ANALYZE, BUFFERS)
SELECT r.review_id, r.rating, r.comment, r.created_at,
       p.name AS property_name,
       u.first_name AS reviewer_name
FROM Review r
JOIN Property p ON r.property_id = p.property_id
JOIN User u ON r.user_id = u.user_id
WHERE r.created_at >= CURRENT_DATE - INTERVAL '30 days'
  AND r.rating >= 4
ORDER BY r.created_at DESC
LIMIT 20;

-- =============================================
-- SAVE BASELINE RESULTS
-- =============================================

\echo '\n--- SAVING BASELINE PERFORMANCE METRICS ---';

-- Create a temporary table to store baseline results
CREATE TEMPORARY TABLE baseline_performance (
    test_name VARCHAR(100),
    execution_time_ms DECIMAL(10,3),
    rows_examined INTEGER,
    query_cost DECIMAL(10,2),
    notes TEXT
);

-- Note: You'll need to manually record the EXPLAIN ANALYZE results
-- Insert sample baseline data (replace with actual values from your tests)
INSERT INTO baseline_performance VALUES 
('User Authentication', 15.234, 10000, 125.50, 'Full table scan on User table'),
('Booking Availability', 45.678, 25000, 380.75, 'Multiple table scans, no index usage'),
('Location Search', 120.456, 50000, 750.25, 'Full table scan with LIKE operation'),
('Host Revenue Analysis', 200.789, 75000, 1200.50, 'Multiple JOINs with GROUP BY'),
('Recent Reviews', 35.123, 15000, 285.30, 'Date range scan without index');

-- =============================================
-- PHASE 2: CREATE INDEXES
-- =============================================

\echo '\n==========================================';
\echo 'PHASE 2: CREATING PERFORMANCE INDEXES';
\echo '==========================================';

-- Execute the index creation script
-- \i database_index.sql

-- For demonstration, creating key indexes inline:

-- User table indexes
CREATE INDEX IF NOT EXISTS idx_user_email ON User(email);
CREATE INDEX IF NOT EXISTS idx_user_role ON User(role);
CREATE INDEX IF NOT EXISTS idx_user_email_role ON User(email, role);

-- Booking table indexes
CREATE INDEX IF NOT EXISTS idx_booking_user_id ON Booking(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_property_id ON Booking(property_id);
CREATE INDEX IF NOT EXISTS idx_booking_status ON Booking(status);
CREATE INDEX IF NOT EXISTS idx_booking_date_range ON Booking(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_booking_property_status ON Booking(property_id, status);
CREATE INDEX IF NOT EXISTS idx_booking_status_dates ON Booking(status, start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_booking_created_at ON Booking(created_at);

-- Property table indexes
CREATE INDEX IF NOT EXISTS idx_property_host_id ON Property(host_id);
CREATE INDEX IF NOT EXISTS idx_property_location ON Property(location);
CREATE INDEX IF NOT EXISTS idx_property_price_per_night ON Property(price_per_night);
CREATE INDEX IF NOT EXISTS idx_property_location_price ON Property(location, price_per_night);

-- Review table indexes
CREATE INDEX IF NOT EXISTS idx_review_property_id ON Review(property_id);
CREATE INDEX IF NOT EXISTS idx_review_user_id ON Review(user_id);
CREATE INDEX IF NOT EXISTS idx_review_rating ON Review(rating);
CREATE INDEX IF NOT EXISTS idx_review_created_at ON Review(created_at);
CREATE INDEX IF NOT EXISTS idx_review_property_rating ON Review(property_id, rating);

\echo 'Indexes created successfully!';

-- Update table statistics
ANALYZE User;
ANALYZE Booking;
ANALYZE Property;
ANALYZE Review;

-- =============================================
-- PHASE 3: POST-INDEX PERFORMANCE ANALYSIS
-- =============================================

\echo '\n==========================================';
\echo 'PHASE 3: POST-INDEX PERFORMANCE ANALYSIS';
\echo 'Testing same queries WITH indexes';
\echo '==========================================';

-- =============================================
-- RE-TEST 1: User Authentication Query
-- =============================================

\echo '\n--- RE-TEST 1: User Authentication Query (With Index) ---';

EXPLAIN (ANALYZE, BUFFERS) 
SELECT user_id, first_name, last_name, role 
FROM User 
WHERE email = 'john.doe@email.com';

-- =============================================
-- RE-TEST 2: Booking Availability Check
-- =============================================

\echo '\n--- RE-TEST 2: Booking Availability Check (With Index) ---';

EXPLAIN (ANALYZE, BUFFERS)
SELECT b.booking_id, b.start_date, b.end_date, b.status,
       p.name AS property_name, u.first_name, u.last_name
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
JOIN User u ON b.user_id = u.user_id
WHERE b.property_id = 1
  AND b.status IN ('confirmed', 'pending')
  AND b.start_date >= '2024-01-01'
  AND b.end_date <= '2024-12-31';

-- =============================================
-- RE-TEST 3: Location-Based Property Search
-- =============================================

\echo '\n--- RE-TEST 3: Location-Based Property Search (With Index) ---';

EXPLAIN (ANALYZE, BUFFERS)
SELECT p.property_id, p.name, p.location, p.price_per_night,
       u.first_name AS host_name,
       AVG(r.rating) AS avg_rating,
       COUNT(r.review_id) AS review_count
FROM Property p
JOIN User u ON p.host_id = u.user_id
LEFT JOIN Review r ON p.property_id = r.property_id
WHERE p.location LIKE '%New York%'
  AND p.price_per_night BETWEEN 100 AND 300
GROUP BY p.property_id, p.name, p.location, p.price_per_night, u.first_name
HAVING AVG(r.rating) >= 4.0
ORDER BY avg_rating DESC, p.price_per_night ASC;

-- =============================================
-- RE-TEST 4: Host Revenue Analysis
-- =============================================

\echo '\n--- RE-TEST 4: Host Revenue Analysis (With Index) ---';

EXPLAIN (ANALYZE, BUFFERS)
SELECT u.user_id, u.first_name, u.last_name,
       COUNT(b.booking_id) AS total_bookings,
       SUM(b.total_price) AS total_revenue,
       AVG(b.total_price) AS avg_booking_value
FROM User u
JOIN Property p ON u.user_id = p.host_id
JOIN Booking b ON p.property_id = b.property_id
WHERE u.role = 'host'
  AND b.status = 'confirmed'
  AND b.created_at >= '2024-01-01'
GROUP BY u.user_id, u.first_name, u.last_name
HAVING COUNT(b.booking_id) >= 5
ORDER BY total_revenue DESC;

-- =============================================
-- RE-TEST 5: Recent Reviews Query
-- =============================================

\echo '\n--- RE-TEST 5: Recent Reviews Query (With Index) ---';

EXPLAIN (ANALYZE, BUFFERS)
SELECT r.review_id, r.rating, r.comment, r.created_at,
       p.name AS property_name,
       u.first_name AS reviewer_name
FROM Review r
JOIN Property p ON r.property_id = p.property_id
JOIN User u ON r.user_id = u.user_id
WHERE r.created_at >= CURRENT_DATE - INTERVAL '30 days'
  AND r.rating >= 4
ORDER BY r.created_at DESC
LIMIT 20;

-- =============================================
-- PHASE 4: PERFORMANCE COMPARISON
-- =============================================

\echo '\n==========================================';
\echo 'PHASE 4: PERFORMANCE COMPARISON ANALYSIS';
\echo '==========================================';

-- Create table for post-index results
CREATE TEMPORARY TABLE post_index_performance (
    test_name VARCHAR(100),
    execution_time_ms DECIMAL(10,3),
    rows_examined INTEGER,
    query_cost DECIMAL(10,2),
    notes TEXT
);

-- Insert sample post-index data (replace with actual values)
INSERT INTO post_index_performance VALUES 
('User Authentication', 2.145, 1, 15.25, 'Index scan on email'),
('Booking Availability', 8.234, 150, 45.50, 'Index seeks on foreign keys and status'),
('Location Search', 25.789, 500, 180.75, 'Index scan on location with price filter'),
('Host Revenue Analysis', 45.123, 2500, 320.25, 'Index seeks on role and status'),
('Recent Reviews', 5.678, 100, 35.80, 'Index scan on created_at with rating filter');

-- Performance comparison report
\echo '\n--- PERFORMANCE COMPARISON REPORT ---';

SELECT 
    b.test_name,
    b.execution_time_ms AS baseline_time_ms,
    p.execution_time_ms AS indexed_time_ms,
    ROUND((b.execution_time_ms - p.execution_time_ms), 3) AS time_saved_ms,
    ROUND(((b.execution_time_ms - p.execution_time_ms) / b.execution_time_ms * 100), 2) AS improvement_percentage,
    b.rows_examined AS baseline_rows,
    p.rows_examined AS indexed_rows,
    (b.rows_examined - p.rows_examined) AS rows_saved,
    b.query_cost AS baseline_cost,
    p.query_cost AS indexed_cost,
    ROUND((b.query_cost - p.query_cost), 2) AS cost_reduction
FROM baseline_performance b
JOIN post_index_performance p ON b.test_name = p.test_name
ORDER BY improvement_percentage DESC;

-- =============================================
-- INDEX USAGE ANALYSIS
-- =============================================

\echo '\n--- INDEX USAGE ANALYSIS ---';

-- PostgreSQL: Check index usage statistics
-- SELECT 
--     schemaname,
--     tablename,
--     indexname,
--     idx_scan,
--     idx_tup_read,
--     idx_tup_fetch
-- FROM pg_stat_user_indexes
-- ORDER BY idx_scan DESC;

-- MySQL: Check index usage
-- SELECT 
--     TABLE_SCHEMA,
--     TABLE_NAME,
--     INDEX_NAME,
--     CARDINALITY
-- FROM INFORMATION_SCHEMA.STATISTICS
-- WHERE TABLE_SCHEMA = DATABASE()
-- ORDER BY CARDINALITY DESC;

-- =============================================
-- RECOMMENDATIONS
-- =============================================

\echo '\n==========================================';
\echo 'PERFORMANCE ANALYSIS RECOMMENDATIONS';
\echo '==========================================';

-- Create recommendations table
CREATE TEMPORARY TABLE performance_recommendations (
    priority VARCHAR(10),
    recommendation TEXT,
    expected_impact VARCHAR(20)
);

INSERT INTO performance_recommendations VALUES
('HIGH', 'Keep all foreign key indexes - they show significant JOIN performance improvement', 'Major'),
('HIGH', 'Email index is critical for authentication queries - 85%+ improvement expected', 'Major'),
('MEDIUM', 'Location index with LIKE operations shows good improvement but consider full-text search', 'Moderate'),
('MEDIUM', 'Date range indexes are essential for booking availability queries', 'Moderate'),
('LOW', 'Monitor composite indexes for actual usage - some may be redundant', 'Minor'),
('LOW', 'Consider partitioning large tables by date for historical data', 'Future');

SELECT * FROM performance_recommendations ORDER BY 
    CASE priority 
        WHEN 'HIGH' THEN 1 
        WHEN 'MEDIUM' THEN 2 
        WHEN 'LOW' THEN 3 
    END;

-- =============================================
-- CLEANUP
-- =============================================

-- Drop temporary tables
DROP TABLE IF EXISTS baseline_performance;
DROP TABLE IF EXISTS post_index_performance;
DROP TABLE IF EXISTS performance_recommendations;

\echo '\n==========================================';
\echo 'PERFORMANCE ANALYSIS COMPLETE';
\echo 'Review the EXPLAIN ANALYZE output above';
\echo 'for detailed execution plans and timings';
\echo '==========================================';

-- =============================================
-- ADDITIONAL MONITORING QUERIES
-- =============================================

-- Uncomment and run these periodically to monitor index performance

/*
-- PostgreSQL: Monitor slow queries
SELECT query, mean_time, calls, total_time 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;

-- MySQL: Check query performance
SHOW FULL PROCESSLIST;
SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST WHERE COMMAND != 'Sleep';

-- SQL Server: Check expensive queries
SELECT 
    qs.execution_count,
    qs.total_elapsed_time / qs.execution_count AS avg_elapsed_time,
    qs.total_logical_reads / qs.execution_count AS avg_logical_reads,
    SUBSTRING(qt.text, qs.statement_start_offset/2, 
        (CASE WHEN qs.statement_end_offset = -1 
         THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
         ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY avg_elapsed_time DESC;
*/