DELIMITER $$

CREATE PROCEDURE PlaceOrderFlexible(
    IN p_customer_id INT,
    IN p_order_items JSON   -- [{"product_id":1,"qty":2},{"product_id":2,"qty":1}]
)
BEGIN
    DECLARE v_order_id INT;
    DECLARE i INT DEFAULT 0;
    DECLARE n INT;
    DECLARE v_pid INT;
    DECLARE v_qty INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;

    -- Create new order
    INSERT INTO Orders (customer_id, order_date, total_amount)
    VALUES (p_customer_id, NOW(), 0);

    SET v_order_id = LAST_INSERT_ID();

    SET n = JSON_LENGTH(p_order_items);

    WHILE i < n DO
        -- Extract product_id and qty from JSON
        SET v_pid = JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', i, '].product_id')));
        SET v_qty = JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', i, '].qty')));

        -- Get current stock and price
        SELECT stock_quantity, price
        INTO v_stock, v_price
        FROM Products
        WHERE product_id = v_pid;

        -- Check stock availability
        IF v_stock IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = CONCAT('Product ID ', v_pid, ' does not exist');
        ELSEIF v_stock < v_qty THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = CONCAT('Not enough stock for Product ID ', v_pid);
        ELSE
            -- Insert order detail
            INSERT INTO Order_Details (OrderID, ProductID, Quantity, UnitPrice)
            VALUES (v_order_id, v_pid, v_qty, v_price);

            -- Deduct stock
            UPDATE Products
            SET stock_quantity = stock_quantity - v_qty
            WHERE product_id = v_pid;
        END IF;

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

-- Not needed anymore since stock is updated in the procedure

-- CREATE TRIGGER trg_update_stock
-- AFTER INSERT ON Order_Details
-- FOR EACH ROW
-- BEGIN
--     UPDATE Products
--     SET stock_quantity = stock_quantity - NEW.Quantity
--     WHERE product_id = NEW.ProductID;
-- END;

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
