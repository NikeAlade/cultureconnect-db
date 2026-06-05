-- ============================================================
-- CultureConnect - Analytical SQL Queries
-- Database: MySQL / MariaDB
-- ============================================================


-- ============================================================
-- SECTION 1: BASIC QUERIES
-- ============================================================

-- All areas in the platform
SELECT area_id, area_name, postcode
FROM areas
ORDER BY area_name;

-- All categories available
SELECT category_id, category_name, description
FROM categories
ORDER BY category_name;

-- All active users
SELECT user_ref_no, name, user_code, status, created_at
FROM users
WHERE status = 'active'
ORDER BY created_at DESC;

-- All approved SME businesses
SELECT s.sme_id, s.business_name, s.category, s.location, u.name AS owner
FROM sme_businesses s
JOIN users u ON s.user_ref_no = u.user_ref_no
WHERE s.approval_status = 'approved'
ORDER BY s.business_name;


-- ============================================================
-- SECTION 2: JOINS
-- ============================================================

-- All listings with their category name and SME business name
SELECT
    l.listing_id,
    l.title,
    c.category_name,
    s.business_name,
    l.price,
    l.status
FROM listings l
JOIN categories c ON l.category_id = c.category_id
JOIN sme_businesses s ON l.sme_id = s.sme_id
ORDER BY c.category_name;

-- All users with their role and area
SELECT
    u.user_ref_no,
    u.name,
    u.user_code,
    r.role_name,
    a.area_name,
    u.status
FROM users u
JOIN roles r ON u.role_id = r.role_id
JOIN areas a ON u.area_id = a.area_id
ORDER BY r.role_name, u.name;

-- All service bookings with user name and listing title
SELECT
    sb.booking_id,
    u.name AS customer,
    l.title AS listing,
    c.category_name,
    sb.booking_date,
    sb.status
FROM service_bookings sb
JOIN users u ON sb.user_ref_no = u.user_ref_no
JOIN listings l ON sb.listing_id = l.listing_id
JOIN categories c ON l.category_id = c.category_id
ORDER BY sb.booking_date DESC;

-- All reviews with rating, user name and listing title
SELECT
    r.review_id,
    u.name AS reviewer,
    l.title AS listing,
    r.rating,
    r.comment,
    r.created_at
FROM reviews r
JOIN users u ON r.user_ref_no = u.user_ref_no
JOIN listings l ON r.listing_id = l.listing_id
ORDER BY r.rating DESC;

-- Orders with user details and total amount
SELECT
    o.order_id,
    u.name AS customer,
    a.area_name,
    o.order_date,
    o.total_amount,
    o.status
FROM orders o
JOIN users u ON o.user_ref_no = u.user_ref_no
JOIN areas a ON u.area_id = a.area_id
ORDER BY o.order_date DESC;


-- ============================================================
-- SECTION 3: AGGREGATIONS
-- ============================================================

-- Number of users per role
SELECT
    r.role_name,
    COUNT(u.user_ref_no) AS total_users
FROM roles r
LEFT JOIN users u ON r.role_id = u.role_id
GROUP BY r.role_name
ORDER BY total_users DESC;

-- Number of listings per category
SELECT
    c.category_name,
    COUNT(l.listing_id) AS total_listings,
    ROUND(AVG(l.price), 2) AS avg_price,
    MIN(l.price) AS min_price,
    MAX(l.price) AS max_price
FROM categories c
LEFT JOIN listings l ON c.category_id = l.category_id
GROUP BY c.category_name
ORDER BY total_listings DESC;

-- Total bookings per area
SELECT
    a.area_name,
    COUNT(sb.booking_id) AS total_bookings
FROM areas a
LEFT JOIN users u ON a.area_id = u.area_id
LEFT JOIN service_bookings sb ON u.user_ref_no = sb.user_ref_no
GROUP BY a.area_name
ORDER BY total_bookings DESC;

-- Average review rating per category
SELECT
    c.category_name,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.review_id) AS total_reviews
FROM categories c
LEFT JOIN listings l ON c.category_id = l.category_id
LEFT JOIN reviews r ON l.listing_id = r.listing_id
GROUP BY c.category_name
ORDER BY avg_rating DESC;

-- Total revenue per category
SELECT
    c.category_name,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(SUM(oi.price * oi.quantity), 2) AS total_revenue
FROM categories c
JOIN listings l ON c.category_id = l.category_id
JOIN order_items oi ON l.listing_id = oi.listing_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

-- Number of users registered per month
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(*) AS new_users
FROM users
GROUP BY month
ORDER BY month;


-- ============================================================
-- SECTION 4: FILTERING WITH HAVING
-- ============================================================

-- Categories with more than 5 listings
SELECT
    c.category_name,
    COUNT(l.listing_id) AS total_listings
FROM categories c
JOIN listings l ON c.category_id = l.category_id
GROUP BY c.category_name
HAVING total_listings > 5
ORDER BY total_listings DESC;

-- SME businesses with more than 3 listings
SELECT
    s.business_name,
    COUNT(l.listing_id) AS total_listings
FROM sme_businesses s
JOIN listings l ON s.sme_id = l.sme_id
GROUP BY s.business_name
HAVING total_listings > 3
ORDER BY total_listings DESC;

-- Areas with above average number of users
SELECT
    a.area_name,
    COUNT(u.user_ref_no) AS user_count
FROM areas a
JOIN users u ON a.area_id = u.area_id
GROUP BY a.area_name
HAVING user_count > (SELECT AVG(cnt) FROM (SELECT COUNT(*) AS cnt FROM users GROUP BY area_id) sub)
ORDER BY user_count DESC;


-- ============================================================
-- SECTION 5: SUBQUERIES
-- ============================================================

-- Listings priced above the average listing price
SELECT title, price, status
FROM listings
WHERE price > (SELECT AVG(price) FROM listings)
ORDER BY price DESC;

-- Users who have never made a booking
SELECT u.user_ref_no, u.name, u.user_code
FROM users u
WHERE u.user_ref_no NOT IN (
    SELECT DISTINCT user_ref_no FROM service_bookings
)
AND u.role_id = 1;

-- The highest rated listing in each category
SELECT category_name, title, avg_rating
FROM (
    SELECT
        c.category_name,
        l.title,
        ROUND(AVG(r.rating), 2) AS avg_rating,
        RANK() OVER (PARTITION BY c.category_name ORDER BY AVG(r.rating) DESC) AS rnk
    FROM categories c
    JOIN listings l ON c.category_id = l.category_id
    JOIN reviews r ON l.listing_id = r.listing_id
    GROUP BY c.category_name, l.title
) ranked
WHERE rnk = 1;


-- ============================================================
-- SECTION 6: WINDOW FUNCTIONS
-- ============================================================

-- Rank listings by price within each category
SELECT
    c.category_name,
    l.title,
    l.price,
    RANK() OVER (PARTITION BY c.category_name ORDER BY l.price DESC) AS price_rank
FROM listings l
JOIN categories c ON l.category_id = c.category_id;

-- Running total of orders by date
SELECT
    order_date,
    total_amount,
    SUM(total_amount) OVER (ORDER BY order_date) AS running_total
FROM orders
ORDER BY order_date;

-- Rank SME businesses by number of bookings
SELECT
    s.business_name,
    COUNT(sb.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(sb.booking_id) DESC) AS booking_rank
FROM sme_businesses s
JOIN listings l ON s.sme_id = l.sme_id
JOIN service_bookings sb ON l.listing_id = sb.listing_id
GROUP BY s.business_name;

-- Each user's most recent booking
SELECT
    u.name,
    l.title AS listing,
    sb.booking_date,
    ROW_NUMBER() OVER (PARTITION BY u.user_ref_no ORDER BY sb.booking_date DESC) AS rn
FROM users u
JOIN service_bookings sb ON u.user_ref_no = sb.user_ref_no
JOIN listings l ON sb.listing_id = l.listing_id;


-- ============================================================
-- SECTION 7: BUSINESS INSIGHT QUERIES
-- ============================================================

-- Which area generates the most cultural activity (bookings + orders combined)?
SELECT
    a.area_name,
    COUNT(DISTINCT sb.booking_id) AS bookings,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT sb.booking_id) + COUNT(DISTINCT o.order_id) AS total_activity
FROM areas a
LEFT JOIN users u ON a.area_id = u.area_id
LEFT JOIN service_bookings sb ON u.user_ref_no = sb.user_ref_no
LEFT JOIN orders o ON u.user_ref_no = o.user_ref_no
GROUP BY a.area_name
ORDER BY total_activity DESC;

-- Which categories have the best customer satisfaction (avg rating >= 4)?
SELECT
    c.category_name,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM categories c
JOIN listings l ON c.category_id = l.category_id
JOIN reviews r ON l.listing_id = r.listing_id
GROUP BY c.category_name
HAVING avg_rating >= 4
ORDER BY avg_rating DESC;

-- Top 5 most booked listings
SELECT
    l.title,
    c.category_name,
    s.business_name,
    COUNT(sb.booking_id) AS total_bookings
FROM listings l
JOIN categories c ON l.category_id = c.category_id
JOIN sme_businesses s ON l.sme_id = s.sme_id
JOIN service_bookings sb ON l.listing_id = sb.listing_id
GROUP BY l.title, c.category_name, s.business_name
ORDER BY total_bookings DESC
LIMIT 5;

-- Monthly revenue trend
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.total_amount), 2) AS monthly_revenue
FROM orders o
WHERE o.status = 'completed'
GROUP BY month
ORDER BY month;

-- SME approval rate by category
SELECT
    category,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN approval_status = 'approved' THEN 1 ELSE 0 END) AS approved,
    ROUND(SUM(CASE WHEN approval_status = 'approved' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS approval_rate_pct
FROM sme_businesses
GROUP BY category
ORDER BY approval_rate_pct DESC;

-- Poll engagement - which polls got the most votes?
SELECT
    p.title AS poll,
    COUNT(v.vote_id) AS total_votes,
    p.start_date,
    p.end_date
FROM polls p
LEFT JOIN votes v ON p.poll_id = v.poll_id
GROUP BY p.poll_id, p.title, p.start_date, p.end_date
ORDER BY total_votes DESC;
