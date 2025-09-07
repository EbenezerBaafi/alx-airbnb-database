-- =============================================
-- BOOKING TABLE PARTITIONING BY START_DATE
-- Implements partitioning for large Booking table
-- =============================================

-- Step 1: Create new partitioned Booking table
CREATE TABLE Booking_Partitioned (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    property_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled', 'completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    
    INDEX idx_booking_user_id (user_id),
    INDEX idx_booking_property_id (property_id),
    INDEX idx_booking_status (status),
    INDEX idx_booking_start_date (start_date)
)
PARTITION BY RANGE (YEAR(start_date)) (
    PARTITION p_2022 VALUES LESS THAN (2023),
    PARTITION p_2023 VALUES LESS THAN (2024),
    PARTITION p_2024 VALUES LESS THAN (2025),
    PARTITION p_2025 VALUES LESS THAN (2026),
    PARTITION p_2026 VALUES LESS THAN (2027),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Step 2: Copy data from original table to partitioned table
INSERT INTO Booking_Partitioned (
    booking_id, user_id, property_id, start_date, end_date, 
    total_price, status, created_at, updated_at
)
SELECT 
    booking_id, user_id, property_id, start_date, end_date, 
    total_price, status, created_at, updated_at
FROM Booking;

-- Step 3: Rename tables (swap old and new)
RENAME TABLE Booking TO Booking_Old, Booking_Partitioned TO Booking;

-- Step 4: Create partition maintenance procedure
DELIMITER //
CREATE PROCEDURE AddYearlyPartition(IN partition_year INT)
BEGIN
    SET @sql = CONCAT('ALTER TABLE Booking ADD PARTITION (PARTITION p_', 
                     partition_year, 
                     ' VALUES LESS THAN (', 
                     partition_year + 1, 
                     '))');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Step 5: Create event scheduler for automatic partition management
SET GLOBAL event_scheduler = ON;

CREATE EVENT yearly_partition_maintenance
ON SCHEDULE EVERY 1 YEAR
STARTS CONCAT(YEAR(CURDATE()) + 1, '-01-01 00:00:00')
DO
BEGIN
    CALL AddYearlyPartition(YEAR(CURDATE()) + 1);
END;

-- Step 6: Create procedure to drop old partitions
DELIMITER //
CREATE PROCEDURE DropOldPartitions(IN years_to_keep INT)
BEGIN
    DECLARE partition_name VARCHAR(64);
    DECLARE cutoff_year INT;
    DECLARE done INT DEFAULT FALSE;
    DECLARE partition_cursor CURSOR FOR
        SELECT PARTITION_NAME 
        FROM INFORMATION_SCHEMA.PARTITIONS 
        WHERE TABLE_NAME = 'Booking' 
        AND TABLE_SCHEMA = DATABASE()
        AND PARTITION_NAME IS NOT NULL
        AND PARTITION_NAME REGEXP '^p_[0-9]+$';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    SET cutoff_year = YEAR(CURDATE()) - years_to_keep;
    
    OPEN partition_cursor;
    read_loop: LOOP
        FETCH partition_cursor INTO partition_name;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        IF CAST(SUBSTRING(partition_name, 3) AS UNSIGNED) < cutoff_year THEN
            SET @sql = CONCAT('ALTER TABLE Booking DROP PARTITION ', partition_name);
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
    END LOOP;
    
    CLOSE partition_cursor;
END//
DELIMITER ;

-- Step 7: Verify partitioning setup
SELECT 
    TABLE_NAME,
    PARTITION_NAME,
    PARTITION_EXPRESSION,
    PARTITION_DESCRIPTION,
    TABLE_ROWS
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME = 'Booking'
AND TABLE_SCHEMA = DATABASE()
ORDER BY PARTITION_ORDINAL_POSITION;

-- Step 8: Test query performance with partitioning
EXPLAIN PARTITIONS
SELECT b.booking_id, b.start_date, b.end_date, b.total_price,
       u.first_name, u.last_name, p.name AS property_name
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE b.start_date BETWEEN '2024-01-01' AND '2024-12-31'
AND b.status = 'confirmed'
ORDER BY b.start_date DESC;

-- Cleanup old table after verification
-- DROP TABLE Booking_Old;