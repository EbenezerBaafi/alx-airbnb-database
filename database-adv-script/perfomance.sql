-- =============================================
-- PERFORMANCE.SQL
-- Checks initial query and analyzes performance using EXPLAIN
-- =============================================

-- Initial query that retrieves all bookings with user details, property details, and payment details
SELECT 
    -- Booking Information
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status AS booking_status,
    b.created_at AS booking_date,
    
    -- Guest Information
    guest.user_id AS guest_id,
    guest.first_name AS guest_first_name,
    guest.last_name AS guest_last_name,
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
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    host.email AS host_email,
    host.phone_number AS host_phone,
    
    -- Payment Details (simulated based on booking status)
    CASE 
        WHEN b.status = 'confirmed' THEN 'Completed'
        WHEN b.status = 'pending' THEN 'Pending'
        WHEN b.status = 'canceled' THEN 'Refunded'
        ELSE 'Unknown'
    END AS payment_status,
    
    CASE 
        WHEN b.status = 'confirmed' THEN 'credit_card'
        WHEN b.status = 'pending' THEN 'pending'
        ELSE 'none'
    END AS payment_method,
    
    b.total_price AS payment_amount

FROM Booking b
INNER JOIN User guest ON b.user_id = guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id  
INNER JOIN User host ON p.host_id = host.user_id
ORDER BY b.created_at DESC;

-- =============================================
-- PERFORMANCE ANALYSIS USING EXPLAIN
-- =============================================

-- Analyze query performance and identify inefficiencies
EXPLAIN (ANALYZE, BUFFERS, COSTS)
SELECT 
    -- Booking Information
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status AS booking_status,
    b.created_at AS booking_date,
    
    -- Guest Information
    guest.user_id AS guest_id,
    guest.first_name AS guest_first_name,
    guest.last_name AS guest_last_name,
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
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    host.email AS host_email,
    host.phone_number AS host_phone,
    
    -- Payment Details (simulated based on booking status)
    CASE 
        WHEN b.status = 'confirmed' THEN 'Completed'
        WHEN b.status = 'pending' THEN 'Pending'
        WHEN b.status = 'canceled' THEN 'Refunded'
        ELSE 'Unknown'
    END AS payment_status,
    
    CASE 
        WHEN b.status = 'confirmed' THEN 'credit_card'
        WHEN b.status = 'pending' THEN 'pending'
        ELSE 'none'
    END AS payment_method,
    
    b.total_price AS payment_amount

FROM Booking b
INNER JOIN User guest ON b.user_id = guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id  
INNER JOIN User host ON p.host_id = host.user_id
ORDER BY b.created_at DESC;

-- =============================================
-- IDENTIFIED INEFFICIENCIES
-- =============================================

/*
PERFORMANCE INEFFICIENCIES IDENTIFIED:

1. FULL TABLE SCANS
   - Missing indexes on JOIN columns (user_id, property_id, host_id)
   - Evidence: "Seq Scan" operations in EXPLAIN output
   - Impact: O(n) complexity instead of O(log n)

2. INEFFICIENT JOINS
   - No foreign key indexes for JOIN operations
   - Evidence: High cost Nested Loop joins
   - Impact: Poor JOIN performance on large datasets

3. NO RESULT LIMITING
   - Query returns ALL bookings without LIMIT
   - Evidence: No "Limit" node in execution plan
   - Impact: Excessive memory and network usage

4. EXPENSIVE ORDER BY
   - Sorting without index on created_at column
   - Evidence: "Sort" operation with high cost
   - Impact: Full result set sorting required

5. COMPLEX CALCULATIONS
   - CASE statements calculated for every row
   - Evidence: High execution time in projection
   - Impact: CPU overhead per result row
*/