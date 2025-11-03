DELIMITER $$

CREATE PROCEDURE ReplenishStock()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE p_id INT;
    DECLARE reorder_qty INT;
    DECLARE cur CURSOR FOR 
        SELECT product_id, reorder_level - stock_quantity
        FROM Products
        WHERE stock_quantity < reorder_level;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO p_id, reorder_qty;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Replenish the stock by the difference between reorder level and current stock
        UPDATE Products
        SET stock_quantity = stock_quantity + reorder_qty
        WHERE product_id = p_id;

        -- Log the stock replenishment in the inventory logs
        INSERT INTO Inventory_Logs (product_id, change_type, quantity, remarks)
        VALUES (p_id, 'STOCK_REPLENISHED', reorder_qty, CONCAT('Replenished to reorder level for product ', p_id));
    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;

CALL ReplenishStock();


DELIMITER $$

CREATE TRIGGER UpdateCustomerSpendingTier
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    DECLARE total_spent DECIMAL(10,2);
    DECLARE tier VARCHAR(20);

    -- Calculate total spent by the customer
    SELECT SUM(total_amount)
    INTO total_spent
    FROM Orders
    WHERE customer_id = NEW.customer_id;

    -- Determine the spending tier
    IF total_spent >= 10000 THEN
        SET tier = 'Gold';
    ELSEIF total_spent BETWEEN 5000 AND 9999 THEN
        SET tier = 'Silver';
    ELSE
        SET tier = 'Bronze';
    END IF;

    -- Update the customer's spending tier in the Customers table
    UPDATE Customers
    SET spending_tier = tier
    WHERE customer_id = NEW.customer_id;
END $$

DELIMITER ;

