# CultureConnect — Database & Data Analysis

SQL database design and exploratory data analysis for CultureConnect, a community platform connecting residents, local businesses, and council members across Hertfordshire.

## What's in this repo

| File | Description |
|------|-------------|
| `schema.sql` | Full database schema — tables, relationships, triggers, and seed data |
| `queries.sql` | Analytical SQL queries covering joins, aggregations, subqueries, and window functions |
| `analysis.ipynb` | Python notebook with data visualisations and business insights |

## Database Overview

The database covers 13 tables across the platform:

- **Users & Roles** — Residents, SMEs, Council Members, Admins
- **Areas** — 6 Hertfordshire zones with location data
- **Listings** — Cultural services and products listed by SME businesses
- **Categories** — Visual Arts, Music, Performing Arts, Creative Media, and more
- **Bookings & Orders** — Service bookings and product purchases by residents
- **Reviews** — Customer ratings and feedback on listings
- **Polls & Votes** — Community engagement and decision making

## SQL Query Topics

- Basic SELECT and filtering
- Multi-table JOINs
- Aggregations with GROUP BY and HAVING
- Subqueries
- Business insight queries for revenue, bookings and area activity

## Analysis Highlights

- User distribution by role and area
- Most booked and highest rated categories
- Monthly revenue and booking trends
- SME approval rates
- Customer satisfaction breakdown

## How to Run the Notebook

Open `analysis.ipynb` in **Google Colab** or **Jupyter Notebook** and run all cells. No external data files needed — sample data is generated inside the notebook.

## Tech Stack

- MySQL / MariaDB
- Python, pandas, matplotlib, seaborn

## Author

Oyenike Alade
