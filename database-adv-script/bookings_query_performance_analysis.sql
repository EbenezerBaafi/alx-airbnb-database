-- =============================================
-- COMPREHENSIVE BOOKINGS QUERY PERFORMANCE ANALYSIS
-- Using EXPLAIN to identify inefficiencies
-- =============================================

-- Analyze the original query performance
EXPLAIN (ANALYZE, BUFFERS, COSTS)
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
-- IDENTIFIED PERFORMANCE ISSUES
-- =============================================

/*
PERFORMANCE INEFFICIENCIES FOUND:

1. FULL TABLE SCANS
   - Missing indexes on JOIN columns (user_id, property_id, host_id)
   - Result: Sequential scans instead of index seeks
   - Impact: O(n) complexity on large tables

2. EXPENSIVE CALCULATIONS
   - DATEDIFF() and CASE statements calculated for every row
   - CONCAT() operations on each result row
   - Impact: High CPU usage and slower response times

3. NO RESULT LIMITING
   - Query returns ALL bookings without LIMIT clause
   - Impact: Excessive memory usage and network transfer
   - Risk: Performance degradation with growing dataset

4. INEFFICIENT ORDER BY
   - ORDER BY created_at without corresponding index
   - Impact: Full result set sorting required

5. MULTIPLE USER TABLE ACCESS
   - User table joined twice (guest and host)
   - Impact: Potential for nested loop joins without proper indexes

RECOMMENDED FIXES:
- Add indexes: booking_user_id, booking_property_id, property_host_id, booking_created_at
- Add LIMIT clause for pagination
- Move complex calculations to application layer
- Consider covering indexes for frequently accessed columns
- Add WHERE filters to reduce result set size
*/