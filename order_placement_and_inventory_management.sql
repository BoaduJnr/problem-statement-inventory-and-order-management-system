
START TRANSACTION;


-- This SQL script places a new order for a customer with ID 1.
INSERT INTO Orders (customer_id, order_date, total_amount)
VALUES (1, NOW(), 0);

-- Add order details for the products being ordered.
SET @order_id = LAST_INSERT_ID();

-- Update the total amount in the Orders table.
INSERT INTO Order_Details (OrderID, ProductID, Quantity, UnitPrice)
VALUES 
(@order_id, 1, 2, (SELECT price FROM Products WHERE product_id = 1)),
(@order_id, 2, 1, (SELECT price FROM Products WHERE product_id = 2));



UPDATE Products 
SET stock_quantity = stock_quantity - 2
WHERE product_id = 1;

UPDATE Products 
SET stock_quantity = stock_quantity - 1
WHERE product_id = 2;


INSERT INTO Inventory_Logs (product_id, change_type, quantity_changed, remarks)
VALUES
(1, 'ORDER_PLACED', -2, CONCAT('Order #', @order_id)),
(2, 'ORDER_PLACED', -1, CONCAT('Order #', @order_id));



UPDATE Orders
SET TotalAmount = (
    SELECT SUM(quantity * unit_price)
    FROM Order_Details
    WHERE order_id = @order_id
)
WHERE order_id = @order_id;


COMMIT;