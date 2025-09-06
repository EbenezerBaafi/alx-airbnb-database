-- INNER JOIN Query: Retrieve all bookings and the respective users who made those bookings
-- This query returns only bookings that have matching users (ensures data integrity)

SELECT 
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status AS booking_status,
    b.created_at AS booking_created,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role AS user_role
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
ORDER BY b.created_at DESC;



-- LEFT JOIN Query: Retrieve all properties and their reviews, including properties with no reviews

SELECT 
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.price_per_night,
    p.created_at AS property_created,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_date,
    CONCAT(u.first_name, ' ', u.last_name) AS reviewer_name,
    u.email AS reviewer_email
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
LEFT JOIN User u ON r.user_id = u.user_id
ORDER BY p.property_id, r.created_at DESC;

-- Summary version with review statistics per property
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.price_per_night,
    p.created_at AS property_created,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.rating), 2) AS average_rating,
    MAX(r.created_at) AS latest_review_date,
    MIN(r.created_at) AS first_review_date,
    CASE 
        WHEN COUNT(r.review_id) = 0 THEN 'No Reviews Yet'
        WHEN AVG(r.rating) >= 4.5 THEN 'Excellent (4.5+)'
        WHEN AVG(r.rating) >= 4.0 THEN 'Very Good (4.0+)'
        WHEN AVG(r.rating) >= 3.5 THEN 'Good (3.5+)'
        WHEN AVG(r.rating) >= 3.0 THEN 'Average (3.0+)'
        ELSE 'Below Average (<3.0)'
    END AS rating_category
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name, p.location, p.price_per_night, p.created_at
ORDER BY average_rating DESC NULLS LAST;

-- Simple version showing review status for each property
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.price_per_night,
    CASE 
        WHEN r.review_id IS NULL THEN 'No Reviews'
        ELSE CONCAT(r.rating, '/5 - ', LEFT(r.comment, 50), '...')
    END AS review_info,
    CASE 
        WHEN r.review_id IS NULL THEN 'Never Reviewed'
        ELSE DATE(r.created_at)
    END AS review_status
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
ORDER BY p.created_at DESC;



-- FULL OUTER JOIN Query: Retrieve all users and all bookings, even if user has no booking or booking has no user
-- This query shows ALL users (even those who never booked) AND ALL bookings (even orphaned ones)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role AS user_role,
    u.created_at AS user_registered_date,
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status AS booking_status,
    b.created_at AS booking_created_date,
    -- Categorize the relationship status
    CASE 
        WHEN u.user_id IS NULL THEN 'Orphaned Booking'
        WHEN b.booking_id IS NULL THEN 'User Never Booked'
        ELSE 'Active User with Bookings'
    END AS relationship_status
FROM User u
FULL OUTER JOIN Booking b ON u.user_id = b.user_id
ORDER BY u.created_at DESC NULLS LAST, b.created_at DESC NULLS LAST;

-- Summary version with user statistics and data integrity insights
SELECT 
    u.user_id,
    COALESCE(u.first_name, 'Unknown') AS first_name,
    COALESCE(u.last_name, 'User') AS last_name,
    COALESCE(u.email, 'No Email') AS email,
    u.role AS user_role,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_spent,
    AVG(b.total_price) AS average_booking_value,
    MAX(b.created_at) AS last_booking_date,
    MIN(b.created_at) AS first_booking_date,
    -- User classification based on booking behavior
    CASE 
        WHEN u.user_id IS NULL THEN 'Orphaned Bookings'
        WHEN COUNT(b.booking_id) = 0 THEN 'Registered but Never Booked'
        WHEN COUNT(b.booking_id) = 1 THEN 'Single Booking User'
        WHEN COUNT(b.booking_id) BETWEEN 2 AND 5 THEN 'Regular User'
        WHEN COUNT(b.booking_id) > 5 THEN 'Frequent User'
        ELSE 'Unknown Category'
    END AS user_category
FROM User u
FULL OUTER JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.role
ORDER BY total_bookings DESC NULLS LAST;

-- Data integrity report - identify potential issues
SELECT 
    'Data Integrity Report' AS report_type,
    COUNT(CASE WHEN u.user_id IS NULL THEN 1 END) AS orphaned_bookings_count,
    COUNT(CASE WHEN b.booking_id IS NULL THEN 1 END) AS users_with_no_bookings,
    COUNT(CASE WHEN u.user_id IS NOT NULL AND b.booking_id IS NOT NULL THEN 1 END) AS valid_user_booking_pairs,
    COUNT(*) AS total_records_in_result
FROM User u
FULL OUTER JOIN Booking b ON u.user_id = b.user_id;

-- Detailed view showing booking status distribution
SELECT 
    u.user_id,
    CONCAT(COALESCE(u.first_name, 'Unknown'), ' ', COALESCE(u.last_name, 'User')) AS full_name,
    u.email,
    u.role,
    b.booking_id,
    b.status AS booking_status,
    b.total_price,
    b.start_date,
    b.end_date,
    CASE 
        WHEN u.user_id IS NULL THEN 'ORPHANED BOOKING - No matching user'
        WHEN b.booking_id IS NULL THEN 'USER WITHOUT BOOKINGS'
        WHEN b.status = 'confirmed' THEN 'ACTIVE BOOKING'
        WHEN b.status = 'pending' THEN 'PENDING BOOKING'
        WHEN b.status = 'canceled' THEN 'CANCELED BOOKING'
        ELSE 'UNKNOWN STATUS'
    END AS record_type
FROM User u
FULL OUTER JOIN Booking b ON u.user_id = b.user_id
ORDER BY 
    CASE 
        WHEN u.user_id IS NULL THEN 1  -- Orphaned bookings first
        WHEN b.booking_id IS NULL THEN 2  -- Users without bookings second
        ELSE 3  -- Valid relationships last
    END,
    u.created_at DESC NULLS LAST,
    b.created_at DESC NULLS LAST;