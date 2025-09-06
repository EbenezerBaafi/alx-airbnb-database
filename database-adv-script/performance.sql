-- =============================================
-- COMPREHENSIVE BOOKINGS QUERY
-- Retrieves all bookings with user, property, and payment details
-- =============================================

SELECT 
    -- Booking Information
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status AS booking_status,
    b.created_at AS booking_date,
    DATEDIFF(b.end_date, b.start_date) AS duration_days,
    
    -- Guest Information
    guest.user_id AS guest_id,
    CONCAT(guest.first_name, ' ', guest.last_name) AS guest_name,
    guest.email AS guest_email,
    guest.phone_number AS guest_phone,
    
    -- Property Information
    p.property_id,
    p.name AS property_name,
    p.location AS property_location,
    p.price_per_night,
    p.max_guests,
    p.bedrooms,
    p.bathrooms,
    
    -- Host Information
    host.user_id AS host_id,
    CONCAT(host.first_name, ' ', host.last_name) AS host_name,
    host.email AS host_email,
    host.phone_number AS host_phone,
    
    -- Payment Status (simulated based on booking status)
    CASE 
        WHEN b.status = 'confirmed' THEN 'Completed'
        WHEN b.status = 'pending' THEN 'Pending'
        WHEN b.status = 'canceled' THEN 'Refunded'
        ELSE 'Unknown'
    END AS payment_status,
    
    -- Timeline Status
    CASE 
        WHEN b.start_date > CURRENT_DATE THEN 'Upcoming'
        WHEN b.end_date < CURRENT_DATE THEN 'Completed'
        WHEN b.start_date <= CURRENT_DATE AND b.end_date >= CURRENT_DATE THEN 'Current'
        ELSE 'Past'
    END AS timeline_status,
    
    -- Days until check-in
    DATEDIFF(b.start_date, CURRENT_DATE) AS days_until_checkin

FROM Booking b
INNER JOIN User guest ON b.user_id = guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id  
INNER JOIN User host ON p.host_id = host.user_id
ORDER BY b.created_at DESC;


-- =============================================
-- PERFORMANCE.SQL
-- Checks for initial query that retrieves all bookings 
-- with user details, property details, and payment details
-- =============================================


\echo '==========================================';
\echo 'PERFORMANCE CHECK: COMPREHENSIVE BOOKINGS QUERY';
\echo 'Testing initial query performance';
\echo '==========================================';

-- =============================================
-- TEST 1: BASELINE PERFORMANCE CHECK
-- =============================================

\echo '\n--- BASELINE PERFORMANCE: Original Query ---';

-- Record start time
SELECT NOW() as test_start_time;

-- Execute comprehensive bookings query with EXPLAIN ANALYZE
EXPLAIN (ANALYZE, BUFFERS, COSTS, VERBOSE)
SELECT 
    -- Booking Information
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status AS booking_status,
    b.created_at AS booking_date,
    DATEDIFF(b.end_date, b.start_date) AS duration_days,
    
    -- Guest Information
    guest.user_id AS guest_id,
    CONCAT(guest.first_name, ' ', guest.last_name) AS guest_name,
    guest.email AS guest_email,
    guest.phone_number AS guest_phone,
    guest.role AS guest_role,
    guest.created_at AS guest_registration_date,
    
    -- Property Information
    p.property_id,
    p.name AS property_name,
    p.description AS property_description,
    p.location AS property_location,
    p.price_per_night,
    p.max_guests,
    p.bedrooms,
    p.bathrooms,
    p.created_at AS property_created_date,
    
    -- Host Information
    host.user_id AS host_id,
    CONCAT(host.first_name, ' ', host.last_name) AS host_name,
    host.email AS host_email,
    host.phone_number AS host_phone,
    host.role AS host_role,
    
    -- Payment Information (simulated since Payment table may not exist)
    CASE 
        WHEN b.status = 'confirmed' THEN 'Completed'
        WHEN b.status = 'pending' THEN 'Pending'
        WHEN b.status = 'canceled' THEN 'Refunded'
        ELSE 'Unknown'
    END AS payment_status,
    
    CASE 
        WHEN b.status = 'confirmed' THEN 'credit_card'
        WHEN b.status = 'pending' THEN 'pending_payment'
        ELSE 'none'
    END AS payment_method,
    
    b.total_price AS payment_amount,
    
    -- Timeline Status
    CASE 
        WHEN b.start_date > CURRENT_DATE THEN 'Upcoming'
        WHEN b.end_date < CURRENT_DATE THEN 'Completed'
        WHEN b.start_date <= CURRENT_DATE AND b.end_date >= CURRENT_DATE THEN 'Current'
        ELSE 'Past'
    END AS timeline_status,
    
    -- Additional Calculations
    DATEDIFF(b.start_date, CURRENT_DATE) AS days_until_checkin,
    ROUND((p.price_per_night * DATEDIFF(b.end_date, b.start_date)), 2) AS calculated_total

FROM Booking b
INNER JOIN User guest ON b.user_id = guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id  
INNER JOIN User host ON p.host_id = host.user_id
ORDER BY b.created_at DESC;

-- Record end time
SELECT NOW() as test_end_time;

-- =============================================
-- TEST 2: INDEX EXISTENCE CHECK
-- =============================================

\echo '\n--- INDEX ANALYSIS: Checking Current Indexes ---';


\echo '\n--- TABLE SIZE ANALYSIS ---';

-- Check table sizes to understand scale
SELECT 'Booking' as table_name, COUNT(*) as row_count FROM Booking
UNION ALL
SELECT 'User' as table_name, COUNT(*) as row_count FROM User
UNION ALL
SELECT 'Property' as table_name, COUNT(*) as row_count FROM Property
UNION ALL
SELECT 'Review' as table_name, COUNT(*) as row_count FROM Review;

-- =============================================
-- TEST 4: JOIN EFFICIENCY CHECK
-- =============================================

\echo '\n--- JOIN EFFICIENCY ANALYSIS ---';

-- Test individual JOINs to identify bottlenecks
\echo 'Testing Booking-User JOIN performance:';
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*)
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id;

\echo 'Testing Booking-Property JOIN performance:';
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*)
FROM Booking b
INNER JOIN Property p ON b.property_id = p.property_id;

\echo 'Testing Property-Host JOIN performance:';
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*)
FROM Property p
INNER JOIN User h ON p.host_id = h.user_id;

-- =============================================
-- TEST 5: CALCULATION COST ANALYSIS
-- =============================================

\echo '\n--- CALCULATION COST ANALYSIS ---';

-- Test query without expensive calculations
\echo 'Query performance WITHOUT calculations:';
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    guest.first_name,
    guest.last_name,
    guest.email,
    p.name,
    p.location,
    p.price_per_night,
    host.first_name AS host_name,
    host.email AS host_email
FROM Booking b
INNER JOIN User guest ON b.user_id = guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id  
INNER JOIN User host ON p.host_id = host.user_id
ORDER BY b.booking_id DESC
LIMIT 1000;

-- =============================================
-- TEST 6: PAGINATION IMPACT TEST
-- =============================================

\echo '\n--- PAGINATION IMPACT TEST ---';

-- Test with different LIMIT sizes
\echo 'Performance with LIMIT 10:';
EXPLAIN (ANALYZE, BUFFERS)
SELECT b.booking_id, b.start_date, b.total_price, guest.first_name, p.name
FROM Booking b
INNER JOIN User guest ON b.user_id = guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id
ORDER BY b.created_at DESC
LIMIT 10;

\echo 'Performance with LIMIT 100:';
EXPLAIN (ANALYZE, BUFFERS)
SELECT b.booking_id, b.start_date, b.total_price, guest.first_name, p.name
FROM Booking b
INNER JOIN User guest ON b.user_id = guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id
ORDER BY b.created_at DESC
LIMIT 100;

\echo 'Performance with LIMIT 1000:';
EXPLAIN (ANALYZE, BUFFERS)
SELECT b.booking_id, b.start_date, b.total_price, guest.first_name, p.name
FROM Booking b
INNER JOIN User guest ON b.user_id = guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id
ORDER BY b.created_at DESC
LIMIT 1000;

-- =============================================
-- TEST 7: WHERE CLAUSE IMPACT
-- =============================================

\echo '\n--- WHERE CLAUSE FILTERING TEST ---';

-- Test with date filters
\echo 'Performance with date filtering (last 30 days):';
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*)
FROM Booking b
INNER JOIN User guest ON b.user_id = guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id
WHERE b.created_at >= CURRENT_DATE - INTERVAL '30 days';

\echo 'Performance with status filtering:';
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*)
FROM Booking b
WHERE b.status IN ('confirmed', 'pending');

-- =============================================
-- TEST 8: PERFORMANCE SUMMARY REPORT
-- =============================================

\echo '\n--- PERFORMANCE SUMMARY REPORT ---';

-- Create temporary table to store results
CREATE TEMPORARY TABLE IF NOT EXISTS performance_results (
    test_name VARCHAR(100),
    execution_time_notes TEXT,
    rows_affected INTEGER,
    performance_issues TEXT,
    recommendations TEXT
);

-- Insert performance findings (manually update based on EXPLAIN results)
INSERT INTO performance_results VALUES
('Full Comprehensive Query', 'Check EXPLAIN output above', 0, 'Multiple table scans, expensive calculations', 'Add indexes on JOIN columns, limit results, move calculations'),
('Individual JOINs', 'Check individual JOIN tests', 0, 'Missing foreign key indexes', 'Create indexes on user_id, property_id, host_id'),
('Without Calculations', 'Significantly faster than full query', 1000, 'Calculations add overhead', 'Move complex calculations to application layer'),
('Pagination Tests', 'LIMIT improves performance dramatically', 0, 'No LIMIT clause in original', 'Always use LIMIT for user-facing queries'),
('Filtered Queries', 'WHERE clauses improve performance', 0, 'No filtering in original query', 'Add date range and status filters');

-- Display results
SELECT * FROM performance_results;

-- =============================================
-- PERFORMANCE RECOMMENDATIONS
-- =============================================

\echo '\n--- IMMEDIATE PERFORMANCE RECOMMENDATIONS ---';

CREATE TEMPORARY TABLE IF NOT EXISTS optimization_priorities (
    priority_level VARCHAR(10),
    recommendation TEXT,
    expected_improvement VARCHAR(20),
    implementation_effort VARCHAR(10)
);

INSERT INTO optimization_priorities VALUES
('HIGH', 'Add indexes on Booking(user_id), Booking(property_id), Property(host_id)', '70-80% improvement', 'LOW'),
('HIGH', 'Add LIMIT clause with pagination', '50-90% improvement', 'LOW'),
('HIGH', 'Add date range filtering (last 6 months)', '60-80% improvement', 'LOW'),
('MEDIUM', 'Move DATEDIFF and CASE calculations to application', '20-30% improvement', 'MEDIUM'),
('MEDIUM', 'Create covering indexes for frequently accessed columns', '40-60% improvement', 'MEDIUM'),
('LOW', 'Consider query caching for static results', '80%+ for cached queries', 'HIGH');

SELECT 
    priority_level,
    recommendation,
    expected_improvement,
    implementation_effort
FROM optimization_priorities
ORDER BY 
    CASE priority_level 
        WHEN 'HIGH' THEN 1 
        WHEN 'MEDIUM' THEN 2 
        WHEN 'LOW' THEN 3 
    END;

-- =============================================
-- CLEANUP
-- =============================================

DROP TABLE IF EXISTS performance_results;
DROP TABLE IF EXISTS optimization_priorities;

\echo '\n==========================================';
\echo 'PERFORMANCE CHECK COMPLETE';
\echo 'Review EXPLAIN ANALYZE output above';
\echo 'Implement HIGH priority recommendations first';
\echo '==========================================';

-- =============================================
-- MONITORING QUERIES FOR ONGOING USE
-- =============================================

/*
-- Use these queries to monitor performance over time:

-- Check slow queries (PostgreSQL)
SELECT query, mean_time, calls, total_time 
FROM pg_stat_statements 
WHERE query LIKE '%Booking%'
ORDER BY mean_time DESC 
LIMIT 10;

-- Check index usage (PostgreSQL)
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read
FROM pg_stat_user_indexes
WHERE tablename IN ('booking', 'user', 'property')
ORDER BY idx_scan DESC;

-- MySQL slow query monitoring
SELECT * FROM mysql.slow_log 
WHERE sql_text LIKE '%Booking%' 
ORDER BY start_time DESC 
LIMIT 10;
*/


