CREATE VIEW VW_Order_Summary AS
SELECT 
    c.customer_name,
    o.order_id,
    DATE(o.order_date) AS order_date,
    o.total_amount,
    COUNT(od.order_detail_id) AS number_of_items
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Order_Details od ON o.order_id = od.order_id
GROUP BY o.order_id
ORDER BY o.order_date DESC;


CREATE VIEW VW_Low_Stock_Products AS
SELECT 
    p.product_id,
    p.product_name,
    p.stock_quantity,
    p.reorder_level,
    (p.reorder_level - p.stock_quantity) AS shortage
FROM Products p
WHERE p.stock_quantity < p.reorder_level
ORDER BY shortage DESC;

-- Indexes on Orders for customer_id and order_date
CREATE INDEX idx_customer_id ON Orders(customer_id);
CREATE INDEX idx_order_date ON Orders(order_date);

-- Indexes on Order_Details for order_id and product_id
CREATE INDEX idx_order_id ON Order_Details(order_id);
CREATE INDEX idx_product_id ON Order_Details(product_id);


 Index on Products for product_name and reorder_level
CREATE INDEX idx_product_name ON Products(product_name);
CREATE INDEX idx_reorder_level ON Products(reorder_level);