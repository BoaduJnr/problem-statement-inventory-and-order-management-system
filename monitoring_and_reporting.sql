-- Customer Order Summary
SELECT 
    c.customer_id,
    c.customer_name,
    o.order_id,
    DATE(o.order_date) AS order_date,
    o.total_amount,
    COUNT(od.order_detail_id) AS number_of_items
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Details od ON o.order_id = od.order_id
GROUP BY c.customer_id, o.order_id
ORDER BY o.order_date DESC;


-- Low Stock Report
SELECT 
    product_id,
    product_name,
    stock_quantity,
    reorder_level,
    (reorder_level - stock_quantity) AS shortage
FROM Products
WHERE stock_quantity < reorder_level
ORDER BY shortage DESC;


-- Customer Spending Tier Report
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) AS total_spent,
    CASE 
        WHEN SUM(o.total_amount) >= 10000 THEN 'Gold'
        WHEN SUM(o.total_amount) BETWEEN 5000 AND 9999 THEN 'Silver'
        ELSE 'Bronze'
    END AS spending_tier
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC;

-- Apply bulk discount for all orders
UPDATE Order_Details
SET unit_price = unit_price * 
    CASE 
        WHEN quantity BETWEEN 5 AND 9 THEN 0.95
        WHEN quantity BETWEEN 10 AND 19 THEN 0.90
        WHEN quantity >= 20 THEN 0.85
        ELSE 1.00
    END;

-- Recalculate total amount for all orders
UPDATE Orders
SET total_amount = (
    SELECT SUM(quantity * unit_price)
    FROM Order_Details
    WHERE order_id = Orders.order_id
);