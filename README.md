
# 🏪 Inventory and Order Management System

## 📘 Project Overview

The **Inventory and Order Management System** is a database-driven solution designed to help e-commerce companies efficiently manage products, customers, and orders. It ensures accurate tracking of stock levels, automates inventory updates during order placement, and provides valuable business insights such as sales summaries, customer spending patterns, and low-stock alerts.

This system supports daily operations such as:

* Managing products and stock levels
* Processing customer orders
* Tracking inventory changes and replenishments
* Generating business intelligence reports

---

## ⚙️ Project Phases

### **Phase 1: Database Design and Schema Implementation**

This phase establishes the foundation of the system by creating the database schema and enforcing data integrity.

#### **Tables Created**

1. **Products**

   * Attributes: `product_id`, `name`, `category`, `price`, `stock_quantity`, `reorder_level`
   * Tracks all product information and stock details.

2. **Customers**

   * Attributes: `customer_id`, `name`, `email`, `phone_number`
   * Stores customer contact and identification details.

3. **Orders**

   * Attributes: `order_id`, `customer_id`, `order_date`, `total_amount`
   * Links each order to a customer and maintains order totals.

4. **Order_Details**

   * Attributes: `order_detail_id`, `order_id`, `product_id`, `quantity`, `price`
   * Captures specific products included in each order.

5. **Inventory_Logs**

   * Attributes: `log_id`, `product_id`, `change_type`, `quantity_changed`, `log_date`, `remarks`
   * Records all inventory changes, including sales, returns, and replenishments.

#### **Data Integrity**

* **Foreign keys** link `Orders` to `Customers` and `Order_Details` to `Products`.
* **Constraints** prevent negative stock quantities.
* **Triggers** maintain automatic updates for inventory and order totals.

---

### **Phase 2: Order Placement and Inventory Management**

* When an order is placed:

  * The system deducts ordered quantities from product stock.
  * Calculates and stores the total order amount.
  * Updates `Order_Details` and `Inventory_Logs`.
* Handles multi-product orders efficiently.
* Maintains accurate audit logs for every stock change.

---

### **Phase 3: Monitoring and Reporting**

#### **Key Reports**

1. **Order Summaries**

   * View all orders placed by a customer, including order date, total amount, and number of items.

2. **Low Stock Alerts**

   * Identify products below their `reorder_level` and flag them for replenishment.

3. **Customer Insights**

   * Categorize customers based on total spending:

     * **Bronze:** < $500
     * **Silver:** $500–$2000
     * **Gold:** > $2000

4. **Bulk Discount Rules**

   * Apply discounts automatically based on quantity purchased.

---

### **Phase 4: Stock Replenishment and Automation**

* Automatically identifies and replenishes low-stock products.
* Updates inventory logs with every replenishment event.
* Uses triggers and stored procedures to:

  * Adjust stock levels after orders.
  * Calculate order totals.
  * Assign customer tiers dynamically.

---

### **Phase 5: Advanced Queries and Optimizations**

#### **Views Created**

1. **`VW_Order_Summary`**

   * Displays:

     * Customer name
     * Order date
     * Total order amount
     * Number of items per order

2. **`VW_Low_Stock_Products`**

   * Displays:

     * Product name
     * Current stock level
     * Reorder level
     * Status (“Reorder Needed” / “Sufficient Stock”)

#### **Optimizations**

* Indexed frequently queried fields (`product_id`, `customer_id`, `order_date`).
* Normalized schema to reduce redundancy.
* Added composite keys where necessary for faster lookups.

---

## 📂 Deliverables

| Deliverable                         | Description                                                                                        |
| ----------------------------------- | -------------------------------------------------------------------------------------------------- |
| **1. Database Schema (SQL Script)** | Contains `CREATE TABLE` statements with constraints and relationships.                             |
| **2. SQL Queries**                  | Demonstrates order placement, stock updates, inventory tracking, and customer tier categorization. |
| **3. Views (SQL Script)**           | Contains views for order summaries and low-stock products.                                         |
| **4. Replenishment System**         | Automated logic for detecting and replenishing low stock.                                          |
| **5. Reports and Summaries**        | SQL queries for generating insights into orders, customers, and stock status.                      |

---

## 🧩 Example SQL Components

### Create Tables

```sql
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    reorder_level INT DEFAULT 10
);
```

### Order Placement Trigger

```sql
CREATE TRIGGER trg_update_stock_after_order
AFTER INSERT ON Order_Details
FOR EACH ROW
BEGIN
    UPDATE Products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;

    INSERT INTO Inventory_Logs (product_id, change_type, quantity_changed, log_date, remarks)
    VALUES (NEW.product_id, 'SALE', -NEW.quantity, NOW(), 'Stock deducted after order');
END;
```

### Low Stock View

```sql
CREATE VIEW vw_low_stock_products AS
SELECT product_id, name, stock_quantity, reorder_level,
       CASE WHEN stock_quantity < reorder_level THEN 'Reorder Needed' ELSE 'Sufficient Stock' END AS status
FROM Products;
```

---

## 📊 Sample Reports

**Top Customers by Spending:**

```sql
SELECT c.name, SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC;
```

**Low Stock Products:**

```sql
SELECT * FROM vw_low_stock_products WHERE status = 'Reorder Needed';
```

**Customer Tier Categorization:**

```sql
SELECT name,
       CASE 
         WHEN SUM(total_amount) < 500 THEN 'Bronze'
         WHEN SUM(total_amount) BETWEEN 500 AND 2000 THEN 'Silver'
         ELSE 'Gold'
       END AS Customer_Tier
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;
```

---

## 🧠 Technologies Used

* **Database:** MySQL / PostgreSQL
* **SQL Features:** Views, Triggers, Stored Procedures, Indexing
* **Tools:** MySQL Workbench / pgAdmin
* **Reporting:** SQL-based analytical queries

---

## 🚀 Future Enhancements

* Integration with web front-end for live inventory tracking
* Implementation of role-based access control (Admin, Sales, Manager)
* Scheduled replenishment via automation scripts
* Dashboard visualization using BI tools (Power BI / Tableau)

---

## 👨‍💻 Author

📧 georgejunior.boadu@gmail.com
💼 Inventory and Order Management System Project — 2025

---
