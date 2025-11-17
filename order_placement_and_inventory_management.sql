DELIMITER $$

CREATE PROCEDURE PlaceOrderFlexible(
    IN p_customer_id INT,
    IN p_order_items JSON   -- [{"product_id":1,"qty":2},{"product_id":2,"qty":1}]
)
BEGIN
    DECLARE v_order_id INT;

    -- Create new order
    INSERT INTO Orders (customer_id, order_date, total_amount)
    VALUES (p_customer_id, NOW(), 0);

    SET v_order_id = LAST_INSERT_ID();

    -- Loop through JSON array of products
    DECLARE i INT DEFAULT 0;
    DECLARE n INT;

    SET n = JSON_LENGTH(p_order_items);

    WHILE i < n DO
        SET @pid = JSON_EXTRACT(p_order_items, CONCAT('$[', i, '].product_id'));
        SET @qty = JSON_EXTRACT(p_order_items, CONCAT('$[', i, '].qty'));

        INSERT INTO Order_Details (OrderID, ProductID, Quantity, UnitPrice)
        VALUES (
            v_order_id,
            @pid,
            @qty,
            (SELECT price FROM Products WHERE product_id = @pid)
        );

        SET i = i + 1;
    END WHILE;

    -- Update total amount
    UPDATE Orders
    SET total_amount = (
        SELECT SUM(quantity * unit_price)
        FROM Order_Details
        WHERE order_id = v_order_id
    )
    WHERE order_id = v_order_id;

END$$

DELIMITER ;

CREATE TRIGGER trg_update_stock
AFTER INSERT ON Order_Details
FOR EACH ROW
BEGIN
    UPDATE Products
    SET stock_quantity = stock_quantity - NEW.Quantity
    WHERE product_id = NEW.ProductID;
END;

CREATE TRIGGER trg_inventory_log
AFTER INSERT ON Order_Details
FOR EACH ROW
BEGIN
    INSERT INTO Inventory_Logs (product_id, change_type, quantity_changed, remarks)
    VALUES (
        NEW.ProductID,
        'ORDER_PLACED',
        -NEW.Quantity,
        CONCAT('Order #', NEW.OrderID)
    );
END;
