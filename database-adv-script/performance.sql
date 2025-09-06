-- ==============================
-- Optimize Complex Queries
-- ==============================

-- Write an initial query that retrieves all bookings along with the user details, property details, and payment details and save it on perfomance.sql
EXPLAIN
SELECT bookings.start_date, bookings.end_date, users.first_name, users.last_name, properties.name, properties.description, payments.amounts, payments.payment_date, payments.payment_method
FROM bookings
INNER JOIN users
ON bookings.user_id = users.user_id
INNER JOIN properties
ON bookings.property_id = properties.property_id
INNER JOIN payments
ON bookings.booking_id = payments.booking_id;

-- Refactor the query to reduce execution time, such as reducing unnecessary joins or using indexing.
SELECT 
  b.start_date, b.end_date, 
  u.first_name, u.last_name, 
  p.name, 
  p.description, -- only if truly needed
  pm.amounts, pm.payment_date, pm.payment_method
FROM bookings AS b
JOIN users AS u
  ON b.user_id = u.user_id
JOIN properties AS p
  ON b.property_id = p.property_id
JOIN payments AS pm
  ON b.booking_id = pm.booking_id
WHERE b.start_date >= CURDATE() AND b.end_date > CURDATE()
ORDER BY b.start_date DESC
LIMIT 50;