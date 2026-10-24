
DROP VIEW  IF EXISTS v_order_review;
DROP TABLE IF EXISTS fact_reviews;
DROP TABLE IF EXISTS fact_payments;
DROP TABLE IF EXISTS fact_orders;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_customers;

CREATE TABLE dim_customers (
    customer_key       INTEGER PRIMARY KEY,
    customer_unique_id TEXT NOT NULL UNIQUE,
    city TEXT, state TEXT, zip_prefix TEXT, cohort_month TEXT
);
CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date TEXT NOT NULL,
    year INTEGER, month INTEGER, month_start TEXT, day_name TEXT, is_weekend INTEGER
);
CREATE TABLE fact_orders (
    order_id TEXT PRIMARY KEY,
    customer_key       INTEGER NOT NULL REFERENCES dim_customers(customer_key),
    order_date_key     INTEGER NOT NULL REFERENCES dim_date(date_key),
    delivered_date_key INTEGER REFERENCES dim_date(date_key),
    estimated_date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    order_status TEXT, total_payment_value REAL, n_payment_rows INTEGER, max_installments INTEGER,
    delivery_days REAL, delay_days INTEGER
);
CREATE TABLE fact_payments (
    order_id TEXT NOT NULL REFERENCES fact_orders(order_id),
    payment_sequential INTEGER NOT NULL,
    customer_key INTEGER NOT NULL REFERENCES dim_customers(customer_key),
    date_key     INTEGER NOT NULL REFERENCES dim_date(date_key),
    payment_type TEXT, installments INTEGER, payment_value REAL,
    PRIMARY KEY (order_id, payment_sequential)
);
CREATE TABLE fact_reviews (
    review_id TEXT NOT NULL,
    order_id  TEXT NOT NULL REFERENCES fact_orders(order_id),
    customer_key    INTEGER NOT NULL REFERENCES dim_customers(customer_key),
    review_date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    review_score    INTEGER NOT NULL CHECK (review_score BETWEEN 1 AND 5),
    review_answered_at TEXT,
    PRIMARY KEY (review_id, order_id)
);
CREATE VIEW v_order_review AS
SELECT order_id, review_score
FROM (
    SELECT order_id, review_score,
           ROW_NUMBER() OVER (PARTITION BY order_id
                              ORDER BY review_answered_at DESC, review_id) AS rn
    FROM fact_reviews
)
WHERE rn = 1;
