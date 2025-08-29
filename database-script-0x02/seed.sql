-- Seed script to populate the PaymentMethod table (required first)
INSERT INTO PaymentMethod (method_id, method_name) VALUES 
('pm-001', 'credit_card'),
('pm-002', 'paypal'),
('pm-003', 'stripe');

-- Seed script to populate the User table with initial data
INSERT INTO User (user_id, first_name, last_name, email, password_hash, phone_number, role) VALUES 
('user-001', 'John', 'Smith', 'admin@airbnb.com', 'hashed_password_123', '+1234567890', 'admin'),
('user-002', 'Alice', 'kwakye', 'alice@gmail.com', 'hashed_password_456', '+1987654321', 'host'),
('user-003', 'Kwaku', 'Atta', 'kwaku@gmail.com', 'hashed_password_789', '+1122334455', 'guest');

-- Seed script to populate the Property table with initial data
INSERT INTO Property (property_id, host_id, name, description, location, price_per_night) VALUES 
('prop-001', 'user-002', 'Cozy Cottage', 'A cozy cottage in the countryside.', '123 Maroon st, Spintex', 120.00),
('prop-002', 'user-002', 'Modern Apartment', 'A modern apartment in the city center.', '456 City St, Accra', 200.00);
('prop-003', 'user-002', 'Beach House', 'A beautiful beach house with ocean views.', '789 Beach Rd, Cape Coast', 300.00);


-- Seed script to populate the Booking table with initial data
INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status) VALUES 
('book-001', 'prop-001', 'user-003', '2023-10-01', '2023-10-05', 480.00, 'confirmed'),
('book-002', 'prop-002', 'user-003', '2023-11-10', '2023-11-15', 1000.00, 'pending');
('book-003', 'prop-003', 'user-003', '2023-12-20', '2023-12-25', 1500.00, 'canceled');

-- seed script to populate the Review table with initial data
INSERT INTO Review (review_id, property_id, user_id, rating, comment) VALUES 
('rev-001', 'prop-001', 'user-003', 5, 'Amazing stay! Highly recommend.'),
('rev-002', 'prop-002', 'user-003', 4, 'Great location but a bit noisy.');
('rev-003', 'prop-003', 'user-003', 3, 'Average experience, could be better.');

--seed script to populate the message table with initial data
INSERT INTO Message (message_id, sender_id, receiver_id, content) VALUES 
('msg-001', 'user-003', 'user-002', 'Hello, I would like to inquire about the availability of your property.'),
('msg-002', 'user-002', 'user-003', 'Sure! Please let me know your preferred dates.');
('msg-003', 'user-003', 'user-002', 'I am looking to book from October 1st to October 5th.');

-- Seed script to populate the Payment table with initial data
INSERT INTO Payment (payment_id, booking_id, amount, payment_method) VALUES 
('pay-001', 'book-001', 480.00, 'credit_card'),
('pay-002', 'book-002', 1000.00, 'paypal');
('pay-003', 'book-003', 1500.00, 'stripe');
