-- creating the DimDate table using format provided on src code through class GitHub
CREATE TABLE IF NOT EXISTS `sakila`.`DimDate` (
   `DateKey` INT NOT NULL,
   `Date` DATE NOT NULL,
   `Day` TINYINT NOT NULL,
   `DaySuffix` CHAR(2) NOT NULL,
   `Weekday` TINYINT NOT NULL,
   `WeekDayName` VARCHAR(10) NOT NULL,
   `WeekDayName_Short` CHAR(3) NOT NULL,
   `WeekDayName_FirstLetter` CHAR(1) NOT NULL,
   `DOWInMonth` TINYINT NOT NULL,
   `DayOfYear` SMALLINT NOT NULL,
   `WeekOfMonth` TINYINT NOT NULL,
   `WeekOfYear` TINYINT NOT NULL,
   `Month` TINYINT NOT NULL,
   `MonthName` VARCHAR(10) NOT NULL,
   `MonthName_Short` CHAR(3) NOT NULL,
   `MonthName_FirstLetter` CHAR(1) NOT NULL,
   `Quarter` TINYINT NOT NULL,
   `QuarterName` VARCHAR(6) NOT NULL,
   `Year` INT NOT NULL,
   `MMYYYY` CHAR(6) NOT NULL,
   `MonthYear` CHAR(7) NOT NULL,
   `IsWeekend` BIT NOT NULL,
   `IsHoliday` BIT NOT NULL,
   `HolidayName` VARCHAR(20) NULL,
   `SpecialDays` VARCHAR(20) NULL,
   `FinancialYear` INT NULL,
   `FinancialQuater` INT NULL,
   `FinancialMonth` INT NULL,
   `FirstDateofYear` DATE NULL,
   `LastDateofYear` DATE NULL,
   `FirstDateofQuater` DATE NULL,
   `LastDateofQuater` DATE NULL,
   `FirstDateofMonth` DATE NULL,
   `LastDateofMonth` DATE NULL,
   `FirstDateofWeek` DATE NULL,
   `LastDateofWeek` DATE NULL,
   `CurrentYear` SMALLINT NULL,
   `CurrentQuater` SMALLINT NULL,
   `CurrentMonth` SMALLINT NULL,
   `CurrentWeek` SMALLINT NULL,
   `CurrentDay` SMALLINT NULL,
   PRIMARY KEY (`DateKey`)
);

-- creating and populating DimDate procedure
DELIMITER //

CREATE PROCEDURE PopulateDimDate()
BEGIN
    DECLARE CurrentDate DATE;
    DECLARE EndDate DATE;

    SET CurrentDate = '2000-01-01';
    SET EndDate = '2010-12-31';

    WHILE CurrentDate <= EndDate DO
        INSERT INTO `sakila`.`DimDate` (
            `DateKey`,
            `Date`,
            `Day`,
            `DaySuffix`,
            `Weekday`,
            `WeekDayName`,
            `WeekDayName_Short`,
            `WeekDayName_FirstLetter`,
            `DOWInMonth`,
            `DayOfYear`,
            `WeekOfMonth`,
            `WeekOfYear`,
            `Month`,
            `MonthName`,
            `MonthName_Short`,
            `MonthName_FirstLetter`,
            `Quarter`,
            `QuarterName`,
            `Year`,
            `MMYYYY`,
            `MonthYear`,
            `IsWeekend`,
            `IsHoliday`,
            `HolidayName`,
            `SpecialDays`,
            `FinancialYear`,
            `FinancialQuater`,
            `FinancialMonth`,
            `FirstDateofYear`,
            `LastDateofYear`,
            `FirstDateofQuater`,
            `LastDateofQuater`,
            `FirstDateofMonth`,
            `LastDateofMonth`,
            `FirstDateofWeek`,
            `LastDateofWeek`,
            `CurrentYear`,
            `CurrentQuater`,
            `CurrentMonth`,
            `CurrentWeek`,
            `CurrentDay`
        )
        VALUES (
            YEAR(CurrentDate) * 10000 + MONTH(CurrentDate) * 100 + DAY(CurrentDate),
            CurrentDate,
            DAY(CurrentDate),
            CASE
                WHEN DAY(CurrentDate) IN (1, 21, 31) THEN 'st'
                WHEN DAY(CurrentDate) IN (2, 22) THEN 'nd'
                WHEN DAY(CurrentDate) IN (3, 23) THEN 'rd'
                ELSE 'th'
            END,
            DAYOFWEEK(CurrentDate),
            DAYNAME(CurrentDate),
            UPPER(LEFT(DAYNAME(CurrentDate), 3)),
            LEFT(DAYNAME(CurrentDate), 1),
            DAY(CurrentDate),
            DAYOFYEAR(CurrentDate),
            WEEK(CurrentDate, 1),
            WEEK(CurrentDate, 3),
            MONTH(CurrentDate),
            MONTHNAME(CurrentDate),
            UPPER(LEFT(MONTHNAME(CurrentDate), 3)),
            LEFT(MONTHNAME(CurrentDate), 1),
            QUARTER(CurrentDate),
            CASE QUARTER(CurrentDate)
                WHEN 1 THEN 'First'
                WHEN 2 THEN 'Second'
                WHEN 3 THEN 'Third'
                WHEN 4 THEN 'Fourth'
            END,
            YEAR(CurrentDate),
            CONCAT(RIGHT(CONCAT('0', MONTH(CurrentDate)), 2), YEAR(CurrentDate)),
            CONCAT(YEAR(CurrentDate), UPPER(LEFT(MONTHNAME(CurrentDate), 3))),
            IF(DAYOFWEEK(CurrentDate) IN (1, 7), 1, 0),
            IF(MONTH(CurrentDate) = 12 AND DAY(CurrentDate) = 25, 1, 0),
            IF(MONTH(CurrentDate) = 2 AND DAY(CurrentDate) = 14, 'Valentines Day', NULL),
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            YEAR(CURRENT_DATE()),
            QUARTER(CURRENT_DATE()),
            MONTH(CURRENT_DATE()),
            WEEK(CURRENT_DATE(), 1),
            DAYOFYEAR(CURRENT_DATE())
        );

        SET CurrentDate = DATE_ADD(CurrentDate, INTERVAL 1 DAY);
    END WHILE;
END //

DELIMITER ;

-- call to populate the DimDate table
CALL PopulateDimDate();
