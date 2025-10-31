# Task 1.1
-- See what CustomerIDs you already have
SELECT * FROM customers;

INSERT INTO customers (CustomerID, CustomerName, CustomerContact)
VALUES
  (1, 'Alice Johnson', 'alice@example.com'),
  (2, 'Ben Smith',     'ben@example.com'),
  (3, 'Cara Lee',      'cara@example.com');

-- Now your original insert will work
INSERT INTO Bookings (BookingID, `Date`, TableNumber, CustomerID)
VALUES 
(1, '2022-10-10', 5, 1),
(2, '2022-11-12', 3, 3),
(3, '2022-10-11', 2, 2),
(4, '2022-10-13', 2, 1);


# Task 1.2
-- create / replace the procedure
DROP PROCEDURE IF EXISTS CheckBooking;
DELIMITER //

CREATE PROCEDURE CheckBooking(
    IN p_date DATE,
    IN p_table INT
)
BEGIN
    DECLARE v_cnt INT;

    SELECT COUNT(*) INTO v_cnt
    FROM Bookings
    WHERE `Date` = p_date
      AND TableNumber = p_table;

    IF v_cnt > 0 THEN
        SELECT CONCAT('Table ', p_table, ' is already booked') AS `Booking status`;
    ELSE
        SELECT CONCAT('Table ', p_table, ' is available') AS `Booking status`;
    END IF;
END//
DELIMITER ;

CALL CheckBooking('2022-11-12', 3);


# Task 1.3
DROP PROCEDURE IF EXISTS AddValidBooking;
DELIMITER //

CREATE PROCEDURE AddValidBooking(
    IN p_date DATE,
    IN p_table INT
)
BEGIN
    DECLARE v_cnt INT;

    START TRANSACTION;

    -- Check whether table already booked for given date
    SELECT COUNT(*) INTO v_cnt
    FROM Bookings
    WHERE `Date` = p_date AND TableNumber = p_table
    FOR UPDATE;

    IF v_cnt > 0 THEN
        ROLLBACK;
        SELECT CONCAT('Table ', p_table, ' is already booked - booking cancelled') AS `Booking status`;
    ELSE
        -- Generate next BookingID manually
        INSERT INTO Bookings (BookingID, `Date`, TableNumber, CustomerID)
        VALUES (
            (SELECT COALESCE(MAX(b.BookingID), 0) + 1 FROM Bookings AS b),
            p_date,
            p_table,
            1
        );

        COMMIT;
        SELECT CONCAT('Table ', p_table, ' is booked successfully') AS `Booking status`;
    END IF;
END//
DELIMITER ;


CALL AddValidBooking('2022-12-17', 6);



# Task 2.1
DROP PROCEDURE IF EXISTS AddBooking;
DELIMITER //

CREATE PROCEDURE AddBooking(
    IN p_booking_id  INT,
    IN p_customer_id INT,
    IN p_date        DATE,
    IN p_table       INT
)
BEGIN
    INSERT INTO Bookings (BookingID, CustomerID, `Date`, TableNumber)
    VALUES (p_booking_id, p_customer_id, p_date, p_table);

    SELECT 'New booking added' AS Confirmation;
END//
DELIMITER ;

CALL AddBooking(9, 3, '2022-12-30', 4);


# Task 2.2
DROP PROCEDURE IF EXISTS UpdateBooking;
DELIMITER //

CREATE PROCEDURE UpdateBooking(
    IN p_booking_id INT,
    IN p_date DATE
)
BEGIN
    UPDATE Bookings
    SET `Date` = p_date
    WHERE BookingID = p_booking_id;

    SELECT CONCAT('Booking ', p_booking_id, ' updated') AS Confirmation;
END//
DELIMITER ;

CALL UpdateBooking(9, '2022-12-17');


# Task 2.3
DROP PROCEDURE IF EXISTS CancelBooking;
DELIMITER //

CREATE PROCEDURE CancelBooking(
    IN p_booking_id INT
)
BEGIN
    DELETE FROM Bookings
    WHERE BookingID = p_booking_id;

    SELECT CONCAT('Booking ', p_booking_id, ' cancelled') AS Confirmation;
END//
DELIMITER ;

CALL CancelBooking(9);



