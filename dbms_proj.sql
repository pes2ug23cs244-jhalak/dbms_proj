CREATE TABLE artist (
    artist_ID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100),
    DOB DATE
);

CREATE TABLE artwork (
    artwork_ID INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    year YEAR,
    type_of_artwork VARCHAR(100),
    price_in_inr DECIMAL(15,2),
    status ENUM('Not Sold', 'Sold', 'In Progress') DEFAULT 'Not Sold',
    artist_ID INT,
    FOREIGN KEY (artist_ID) REFERENCES artist(artist_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
ALTER TABLE artwork
CHANGE COLUMN price_in_inr price DECIMAL(15,2);
CREATE TABLE viewings (
    viewing_ID INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(150) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);
CREATE TABLE organizer (
    organizer_ID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(50)
);
ALTER TABLE viewings
ADD COLUMN organizer_ID INT,
ADD CONSTRAINT fk_viewings_organizer
    FOREIGN KEY (organizer_ID) REFERENCES organizer(organizer_ID)
    ON DELETE SET NULL
    ON UPDATE CASCADE;
CREATE TABLE auction (
    auction_ID INT AUTO_INCREMENT PRIMARY KEY,
    auction_date DATE NOT NULL,
    initial_price DECIMAL(15,2) NOT NULL,
    final_price DECIMAL(15,2)
);
ALTER TABLE auction
ADD COLUMN viewing_ID INT,
ADD CONSTRAINT fk_auction_viewing
    FOREIGN KEY (viewing_ID) REFERENCES viewings(viewing_ID)
    ON DELETE SET NULL
    ON UPDATE CASCADE;
ALTER TABLE auction
ADD COLUMN organizer_ID INT,
ADD CONSTRAINT fk_auction_organizer
    FOREIGN KEY (organizer_ID) REFERENCES organizer(organizer_ID)
    ON DELETE SET NULL
    ON UPDATE CASCADE;
ALTER TABLE artwork
ADD COLUMN exhibition_ID INT,
ADD CONSTRAINT fk_artwork_exhibition
    FOREIGN KEY (exhibition_ID) REFERENCES viewings(viewing_ID)
    ON DELETE SET NULL
    ON UPDATE CASCADE;
ALTER TABLE artwork
ADD COLUMN viewing_ID INT,
ADD CONSTRAINT fk_artwork_viewing
    FOREIGN KEY (viewing_ID) REFERENCES viewings(viewing_ID)
    ON DELETE SET NULL
    ON UPDATE CASCADE;
CREATE TABLE buyer (
    buyer_ID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(50)
);
CREATE TABLE buyer (
    buyer_ID INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    contact VARCHAR(50)
);
ALTER TABLE buyer
ADD COLUMN first_name VARCHAR(50) AFTER buyer_ID,
ADD COLUMN middle_name VARCHAR(50) AFTER first_name,
ADD COLUMN last_name VARCHAR(50) AFTER middle_name;
ALTER TABLE buyer
DROP COLUMN name;
ALTER TABLE artwork
ADD COLUMN buyer_ID INT DEFAULT NULL,
ADD CONSTRAINT fk_artwork_buyer
    FOREIGN KEY (buyer_ID) REFERENCES buyer(buyer_ID)
    ON DELETE SET NULL
    ON UPDATE CASCADE;
INSERT INTO artist (artist_ID, first_name, middle_name, last_name, country, DOB)
VALUES
(1, 'Aarav', NULL, 'Mehta', 'India', '1980-03-15'),
(2, 'Ishita', NULL, 'Kapoor', 'India', '1985-07-22'),
(3, 'Rohan', NULL, 'Deshmukh', 'India', '1978-11-09'),
(4, 'Kavya', NULL, 'Nair', 'India', '1990-01-30'),
(5, 'Aditya', NULL, 'Sharma', 'India', '1982-06-18'),
(6, 'Priya', NULL, 'Iyer', 'India', '1993-04-05'),
(7, 'Vikram', 'Singh', 'Joshi', 'India', '1975-09-12');
INSERT INTO artwork (artwork_ID, Title, year, type_of_artwork, price, status, artist_ID)
VALUES
(1, 'Whispers of the Monsoon', 2010, 'Oil on Canvas', 150000, 'Sold', 1),
(2, 'Sacred Banyan', 2012, 'Acrylic on Canvas', 120000, 'Not Sold', 2),
(3, 'Harmony in Red', 2015, 'Watercolor', 80000, 'In Progress', 3),
(4, 'Silent Ghats', 2009, 'Oil on Canvas', 175000, 'Sold', 4),
(5, 'Festival of Lights', 2018, 'Acrylic on Canvas', 220000, 'Not Sold', 5),
(6, 'Lotus Dreams', 2013, 'Mixed Media', 95000, 'Not Sold', 6),
(7, 'Echoes of Rajasthan', 2011, 'Oil on Canvas', 200000, 'Sold', 7),
(8, 'Urban Mirage', 2019, 'Digital Art', 65000, 'In Progress', 2),
(9, 'The Eternal River', 2014, 'Oil on Canvas', 180000, 'Not Sold', 1),
(10, 'Mystic Himalayas', 2020, 'Acrylic on Canvas', 250000, 'Not Sold', 3);
INSERT INTO organizer (organizer_ID, first_name, middle_name, last_name, contact)
VALUES
(1, 'Rahul', 'Kumar', 'Sharma', '9876543210'),
(2, 'Ananya', NULL, 'Iyer', '9123456780'),
(3, 'Meera', 'Rani', 'Patel', '9988776655'),
(4, 'Arjun', 'Pratap', 'Verma', '9090909090'),
(5, 'Kavita', NULL, 'Joshi', '9191919191');
-- Assigning viewing_ID and buyer_ID to artworks
UPDATE artwork SET viewing_ID = 1, buyer_ID = 1 WHERE artwork_ID = 1;  -- Sold
UPDATE artwork SET viewing_ID = 1, buyer_ID = NULL WHERE artwork_ID = 2;  -- Not Sold
UPDATE artwork SET viewing_ID = 2, buyer_ID = NULL WHERE artwork_ID = 3;  -- In Progress
UPDATE artwork SET viewing_ID = 2, buyer_ID = 2 WHERE artwork_ID = 4;  -- Sold
UPDATE artwork SET viewing_ID = 3, buyer_ID = NULL WHERE artwork_ID = 5;  -- Not Sold
UPDATE artwork SET viewing_ID = 3, buyer_ID = NULL WHERE artwork_ID = 6;  -- Not Sold
UPDATE artwork SET viewing_ID = 1, buyer_ID = 3 WHERE artwork_ID = 7;  -- Sold
UPDATE artwork SET viewing_ID = 2, buyer_ID = NULL WHERE artwork_ID = 8;  -- In Progress
UPDATE artwork SET viewing_ID = 3, buyer_ID = NULL WHERE artwork_ID = 9;  -- Not Sold
UPDATE artwork SET viewing_ID = 3, buyer_ID = NULL WHERE artwork_ID = 10;  -- Not Sold
INSERT INTO bid (buyer_ID, artwork_ID, amount, bid_date, auction_ID) VALUES
(1, 1, 150000.00, '2025-09-15 10:00:00', 1),  -- Sold
(2, 2, 115000.00, '2025-09-15 11:30:00', 1),  -- Not Sold
(3, 3, 85000.00, '2025-10-20 14:20:00', 2),   -- In Progress
(2, 4, 175000.00, '2025-10-20 16:00:00', 2),  -- Sold
(1, 5, 210000.00, '2025-11-20 12:15:00', 3),  -- Not Sold
(3, 6, 95000.00, '2025-11-20 09:45:00', 3),   -- Not Sold
(1, 7, 200000.00, '2025-11-20 13:30:00', 3),  -- Sold
(2, 8, 65000.00, '2025-11-20 15:00:00', 4),   -- In Progress
(3, 9, 180000.00, '2025-12-13 11:00:00', 5),  -- Not Sold
(1, 10, 250000.00, '2025-12-13 10:30:00', 5); -- Not Sold

-- PROCEDURE
DELIMITER //

CREATE PROCEDURE add_new_artist (
    IN p_first_name VARCHAR(50),
    IN p_middle_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_country VARCHAR(100),
    IN p_DOB DATE
)
BEGIN
    INSERT INTO artist (first_name, middle_name, last_name, country, DOB)
    VALUES (p_first_name, p_middle_name, p_last_name, p_country, p_DOB);
    
    SELECT CONCAT('Artist ', p_first_name, ' ', p_last_name, ' added successfully!') AS message;
END //

DELIMITER ;

-- FUNCTION
DELIMITER //

CREATE FUNCTION total_sold_artworks()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_sold INT;
    
    SELECT COUNT(*)
    INTO total_sold
    FROM artwork
    WHERE status = 'Sold';
    
    RETURN total_sold;
END //

DELIMITER ;

-- TRIGGER
DELIMITER //

CREATE TRIGGER before_artwork_insert
BEFORE INSERT ON artwork
FOR EACH ROW
BEGIN
    IF NEW.year > YEAR(CURDATE()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Artwork year cannot be in the future.';
    END IF;
END //

DELIMITER ;