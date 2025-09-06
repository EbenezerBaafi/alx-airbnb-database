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