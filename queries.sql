-- CultureConnect Database Queries
-- These queries are used to explore and analyse data from the CultureConnect platform


-- =====================
-- BASIC QUERIES
-- =====================

-- Get all areas
SELECT area_id, area_name, postcode
FROM areas;

-- Get all categories
SELECT category_id, category_name
FROM categories;

-- Get all users
SELECT user_ref_no, name, user_code, status
FROM users;

-- Get only active users
SELECT user_ref_no, name, status
FROM users
WHERE status = 'active';

-- Get all approved SME businesses
SELECT business_name, category, location, approval_status
FROM sme_businesses
WHERE approval_status = 'approved';


-- =====================
-- JOINING TABLES
-- =====================

-- Get each user with their role name
SELECT u.name, r.role_name, u.status
FROM users u
JOIN roles r ON u.role_id = r.role_id;

-- Get each user with their area
SELECT u.name, a.area_name, u.status
FROM users u
JOIN areas a ON u.area_id = a.area_id;

-- Get listings with their category name
SELECT l.title, c.category_name, l.price, l.status
FROM listings l
JOIN categories c ON l.category_id = c.category_id;

-- Get bookings with the user name and listing title
SELECT u.name AS customer, l.title AS listing, sb.booking_date, sb.status
FROM service_bookings sb
JOIN users u ON sb.user_ref_no = u.user_ref_no
JOIN listings l ON sb.listing_id = l.listing_id;

-- Get reviews with user name, listing title and rating
SELECT u.name, l.title, r.rating, r.comment
FROM reviews r
JOIN users u ON r.user_ref_no = u.user_ref_no
JOIN listings l ON r.listing_id = l.listing_id
ORDER BY r.rating DESC;


-- =====================
-- COUNTING AND GROUPING
-- =====================

-- How many users are in each role?
SELECT r.role_name, COUNT(u.user_ref_no) AS total_users
FROM roles r
LEFT JOIN users u ON r.role_id = u.role_id
GROUP BY r.role_name
ORDER BY total_users DESC;

-- How many listings are in each category?
SELECT c.category_name, COUNT(l.listing_id) AS total_listings
FROM categories c
LEFT JOIN listings l ON c.category_id = l.category_id
GROUP BY c.category_name
ORDER BY total_listings DESC;

-- Average listing price per category
SELECT c.category_name, ROUND(AVG(l.price), 2) AS avg_price
FROM categories c
JOIN listings l ON c.category_id = l.category_id
GROUP BY c.category_name
ORDER BY avg_price DESC;

-- How many bookings has each user made?
SELECT u.name, COUNT(sb.booking_id) AS total_bookings
FROM users u
LEFT JOIN service_bookings sb ON u.user_ref_no = sb.user_ref_no
GROUP BY u.name
ORDER BY total_bookings DESC;

-- Average review rating per category
SELECT c.category_name, ROUND(AVG(r.rating), 2) AS avg_rating
FROM categories c
JOIN listings l ON c.category_id = l.category_id
JOIN reviews r ON l.listing_id = r.listing_id
GROUP BY c.category_name
ORDER BY avg_rating DESC;


-- =====================
-- FILTERING RESULTS
-- =====================

-- Categories with more than 5 listings
SELECT c.category_name, COUNT(l.listing_id) AS total_listings
FROM categories c
JOIN listings l ON c.category_id = l.category_id
GROUP BY c.category_name
HAVING total_listings > 5;

-- Users who have never made a booking
SELECT u.name, u.user_code
FROM users u
WHERE u.user_ref_no NOT IN (
    SELECT DISTINCT user_ref_no FROM service_bookings
);

-- Listings that cost more than the average price
SELECT title, price
FROM listings
WHERE price > (SELECT AVG(price) FROM listings)
ORDER BY price DESC;


-- =====================
-- USEFUL BUSINESS QUERIES
-- =====================

-- Total bookings per area
SELECT a.area_name, COUNT(sb.booking_id) AS total_bookings
FROM areas a
LEFT JOIN users u ON a.area_id = u.area_id
LEFT JOIN service_bookings sb ON u.user_ref_no = sb.user_ref_no
GROUP BY a.area_name
ORDER BY total_bookings DESC;

-- Top 5 most booked listings
SELECT l.title, c.category_name, COUNT(sb.booking_id) AS total_bookings
FROM listings l
JOIN categories c ON l.category_id = c.category_id
JOIN service_bookings sb ON l.listing_id = sb.listing_id
GROUP BY l.title, c.category_name
ORDER BY total_bookings DESC
LIMIT 5;

-- Monthly revenue from completed orders
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       COUNT(order_id) AS total_orders,
       ROUND(SUM(total_amount), 2) AS total_revenue
FROM orders
WHERE status = 'completed'
GROUP BY month
ORDER BY month;

-- Categories with an average rating of 4 or above
SELECT c.category_name, ROUND(AVG(r.rating), 2) AS avg_rating
FROM categories c
JOIN listings l ON c.category_id = l.category_id
JOIN reviews r ON l.listing_id = r.listing_id
GROUP BY c.category_name
HAVING avg_rating >= 4
ORDER BY avg_rating DESC;
