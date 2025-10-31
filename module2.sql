# Task 1.1
CREATE VIEW OrdersView AS
SELECT 
    OrderID,
    Quantity,
    TotalCost AS Cost
FROM Orders
WHERE Quantity > 2;

SELECT * FROM OrdersView;


# Task 1.2
SELECT 
    c.CustomerID,
    c.CustomerName AS FullName,
    o.OrderID,
    o.TotalCost AS Cost,
    m.Cuisine AS MenuName,
    m.Course AS CourseName,
    m.Starter AS StarterName
FROM Customers AS c
JOIN Bookings AS b 
    ON c.CustomerID = b.CustomerID
JOIN Orders AS o 
    ON b.BookingID = o.BookingID
JOIN Menu AS m 
    ON o.MenuID = m.MenuID
WHERE o.TotalCost > 150
ORDER BY o.TotalCost ASC;


# Task 1.3 menu items with ANY order whose quantity > 2
SELECT DISTINCT
    m.Course AS MenuName           -- or m.Cuisine if your instructor expects cuisine
FROM Menu AS m
WHERE m.MenuID = ANY (
    SELECT o.MenuID
    FROM Orders AS o
    WHERE o.Quantity > 2
);


# Task 2.1
DELIMITER $$

CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT 
        MAX(Quantity) AS "Max Quantity in Order"
    FROM Orders;
END $$

DELIMITER ;

CALL GetMaxQuantity();

SHOW PROCEDURE STATUS WHERE Db = 'LittleLemonDB';


# Task 2.2
PREPARE GetOrderDetail FROM
'SELECT o.OrderID, o.Quantity, o.TotalCost AS Cost
 FROM Orders AS o
 JOIN Bookings AS b ON o.BookingID = b.BookingID
 JOIN Customers AS c ON b.CustomerID = c.CustomerID
 WHERE c.CustomerID = ?';

SET @id = 101;
EXECUTE GetOrderDetail USING @id;



# Task 2.3
DELIMITER $$

CREATE PROCEDURE CancelOrder(IN order_id INT)
BEGIN
    DELETE FROM Orders
    WHERE OrderID = order_id;

    SELECT CONCAT('Order ', order_id, ' is cancelled') AS Confirmation;
END $$

DELIMITER ;

SELECT * FROM Orders WHERE OrderID = 5;
CALL CancelOrder(5);
SELECT * FROM Orders WHERE OrderID = 5;
