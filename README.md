# CultureConnect — Database & Data Analysis

SQL database design and exploratory data analysis for CultureConnect, a community platform connecting residents, local businesses, and council members across Hertfordshire.

## What's in this repo

| File | Description |
|------|-------------|
| `schema.sql` | Full database schema - tables, relationships, triggers, and seed data |
| `queries.sql` | Analytical SQL queries covering joins, aggregations, subqueries, and window functions |
| `analysis.ipynb` | Python notebook with data visualisations and business insights |

## Database Overview

The database covers 13 tables across the platform:

- **Users & Roles** - Residents, SMEs, Council Members, Admins
- **Areas** - 6 Hertfordshire zones with location data
- **Listings** - Cultural services and products listed by SME businesses
- **Categories** - Visual Arts, Music, Performing Arts, Creative Media, and more
- **Bookings & Orders** - Service bookings and product purchases by residents
- **Reviews** - Customer ratings and feedback on listings
- **Polls & Votes** - Community engagement and decision making

## SQL Query Topics

1. Basic SELECT and filtering
2. Multi-table JOINs
3. Aggregations with GROUP BY and HAVING
4. Subqueries
5. Business insight queries for revenue, bookings and area activity

## Analysis Highlights

1. User distribution by role and area
2. Most booked and highest rated categories
3. Monthly revenue and booking trends
4. SME approval rates
5. Customer satisfaction breakdown

## Tech Stack

1. MySQL 
2. Python (pandas)
