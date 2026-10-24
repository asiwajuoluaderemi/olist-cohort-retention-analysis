
SELECT d.year, d.month,
       COUNT(DISTINCT o.order_id)           AS orders,
       COUNT(DISTINCT c.customer_unique_id) AS customers,
       ROUND(SUM(o.total_payment_value), 2) AS payment_value
FROM fact_orders o
JOIN dim_customers c ON o.customer_key = c.customer_key
JOIN dim_date d      ON o.order_date_key = d.date_key
WHERE o.order_status = 'delivered'
GROUP BY d.year, d.month
ORDER BY d.year, d.month;
