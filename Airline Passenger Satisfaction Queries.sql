CREATE DATABASE IF NOT EXISTS airline_project;
USE airline_project;

DROP TABLE IF EXISTS airline_satisfaction;

CREATE TABLE airline_satisfaction (
    id                              INT PRIMARY KEY,
    gender                          VARCHAR(10),
    customer_type                   VARCHAR(20),
    age                             TINYINT UNSIGNED,
    type_of_travel                  VARCHAR(20),
    `class`                         VARCHAR(20),
    flight_distance                 SMALLINT UNSIGNED,
    inflight_wifi_service           TINYINT UNSIGNED,
    departure_arrival_time_convenient TINYINT UNSIGNED,
    ease_of_online_booking          TINYINT UNSIGNED,
    gate_location                   TINYINT UNSIGNED,
    food_and_drink                  TINYINT UNSIGNED,
    online_boarding                 TINYINT UNSIGNED,
    seat_comfort                    TINYINT UNSIGNED,
    inflight_entertainment          TINYINT UNSIGNED,
    onboard_service                 TINYINT UNSIGNED,
    leg_room_service                TINYINT UNSIGNED,
    baggage_handling                TINYINT UNSIGNED,
    checkin_service                 TINYINT UNSIGNED,
    inflight_service                TINYINT UNSIGNED,
    cleanliness                     TINYINT UNSIGNED,
    departure_delay_in_minutes      SMALLINT UNSIGNED,
    arrival_delay_in_minutes        SMALLINT UNSIGNED,
    satisfaction                    VARCHAR(30),
    age_group                       VARCHAR(20),
    distance_group                  VARCHAR(30),
    total_delay_minutes             SMALLINT UNSIGNED,
    is_delayed                      TINYINT(1),
    is_satisfied                    TINYINT(1),
    avg_service_rating              DECIMAL(4,2)
);

USE airline_project;
SET SESSION sql_mode = '';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/airline_satisfaction_clean.csv'
INTO TABLE airline_satisfaction
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, gender, customer_type, age, type_of_travel, `class`, flight_distance,
 inflight_wifi_service, departure_arrival_time_convenient, ease_of_online_booking,
 gate_location, food_and_drink, online_boarding, seat_comfort,
 inflight_entertainment, onboard_service, leg_room_service, baggage_handling,
 checkin_service, inflight_service, cleanliness, departure_delay_in_minutes,
 arrival_delay_in_minutes, satisfaction, age_group, distance_group,
 total_delay_minutes, is_delayed, is_satisfied, avg_service_rating);
 
 SELECT COUNT(*) FROM airline_satisfaction;
-- Should show: 129,880 ✅

SELECT * FROM airline_satisfaction LIMIT 5;

CREATE INDEX idx_class           ON airline_satisfaction(`class`);
CREATE INDEX idx_customer_type   ON airline_satisfaction(customer_type);
CREATE INDEX idx_travel_type     ON airline_satisfaction(type_of_travel);
CREATE INDEX idx_satisfaction    ON airline_satisfaction(satisfaction);
CREATE INDEX idx_age_group       ON airline_satisfaction(age_group);
CREATE INDEX idx_distance_group  ON airline_satisfaction(distance_group);

-- Query 1 — Overall KPIs:
SELECT
    COUNT(*)                                    AS total_passengers,
    SUM(is_satisfied)                           AS satisfied_count,
    ROUND(AVG(is_satisfied)*100, 2)            AS satisfaction_rate_pct,
    ROUND(AVG(age), 1)                          AS avg_age,
    ROUND(AVG(flight_distance), 0)              AS avg_flight_distance,
    ROUND(AVG(avg_service_rating), 2)          AS avg_service_rating,
    SUM(is_delayed)                             AS delayed_flights,
    ROUND(AVG(is_delayed)*100, 2)              AS delayed_pct
FROM airline_satisfaction;

-- Query 2 — Satisfaction by Class:
SELECT
    `class`,
    COUNT(*)                                    AS total_passengers,
    SUM(is_satisfied)                           AS satisfied_count,
    ROUND(AVG(is_satisfied)*100, 2)            AS satisfaction_rate_pct,
    ROUND(AVG(avg_service_rating), 2)          AS avg_service_rating
FROM airline_satisfaction
GROUP BY `class`
ORDER BY satisfaction_rate_pct DESC;

-- Query 3 — Satisfaction by Customer Type & Travel Type:
SELECT
    customer_type,
    type_of_travel,
    COUNT(*)                                    AS total_passengers,
    ROUND(AVG(is_satisfied)*100, 2)            AS satisfaction_rate_pct
FROM airline_satisfaction
GROUP BY customer_type, type_of_travel
ORDER BY satisfaction_rate_pct DESC;

-- Query 4 — Satisfaction by Age Group:
SELECT
    age_group,
    COUNT(*)                                    AS total_passengers,
    ROUND(AVG(is_satisfied)*100, 2)            AS satisfaction_rate_pct,
    ROUND(AVG(avg_service_rating), 2)          AS avg_service_rating
FROM airline_satisfaction
GROUP BY age_group
ORDER BY age_group;

-- Query 5 — Service Rating Driver Analysis (which factors matter most):
SELECT
    'Inflight Wifi'        AS service_factor, ROUND(AVG(inflight_wifi_service),2) AS avg_rating_overall,
    ROUND(AVG(CASE WHEN satisfaction='satisfied' THEN inflight_wifi_service END),2) AS avg_rating_satisfied,
    ROUND(AVG(CASE WHEN satisfaction!='satisfied' THEN inflight_wifi_service END),2) AS avg_rating_dissatisfied
FROM airline_satisfaction
UNION ALL
SELECT 'Online Boarding', ROUND(AVG(online_boarding),2),
    ROUND(AVG(CASE WHEN satisfaction='satisfied' THEN online_boarding END),2),
    ROUND(AVG(CASE WHEN satisfaction!='satisfied' THEN online_boarding END),2)
FROM airline_satisfaction
UNION ALL
SELECT 'Inflight Entertainment', ROUND(AVG(inflight_entertainment),2),
    ROUND(AVG(CASE WHEN satisfaction='satisfied' THEN inflight_entertainment END),2),
    ROUND(AVG(CASE WHEN satisfaction!='satisfied' THEN inflight_entertainment END),2)
FROM airline_satisfaction
UNION ALL
SELECT 'Seat Comfort', ROUND(AVG(seat_comfort),2),
    ROUND(AVG(CASE WHEN satisfaction='satisfied' THEN seat_comfort END),2),
    ROUND(AVG(CASE WHEN satisfaction!='satisfied' THEN seat_comfort END),2)
FROM airline_satisfaction
UNION ALL
SELECT 'Onboard Service', ROUND(AVG(onboard_service),2),
    ROUND(AVG(CASE WHEN satisfaction='satisfied' THEN onboard_service END),2),
    ROUND(AVG(CASE WHEN satisfaction!='satisfied' THEN onboard_service END),2)
FROM airline_satisfaction
UNION ALL
SELECT 'Cleanliness', ROUND(AVG(cleanliness),2),
    ROUND(AVG(CASE WHEN satisfaction='satisfied' THEN cleanliness END),2),
    ROUND(AVG(CASE WHEN satisfaction!='satisfied' THEN cleanliness END),2)
FROM airline_satisfaction
ORDER BY avg_rating_satisfied DESC;

-- Query 6 — Delay Impact on Satisfaction:
SELECT
    is_delayed,
    COUNT(*)                                    AS total_passengers,
    ROUND(AVG(is_satisfied)*100, 2)            AS satisfaction_rate_pct,
    ROUND(AVG(total_delay_minutes), 1)         AS avg_delay_minutes
FROM airline_satisfaction
GROUP BY is_delayed;

-- Query 7 — Create Analytical VIEW:
CREATE OR REPLACE VIEW vw_airline_summary AS
SELECT
    `class`,
    customer_type,
    type_of_travel,
    age_group,
    distance_group,
    gender,
    satisfaction,
    COUNT(*)                                    AS passenger_count,
    ROUND(AVG(is_satisfied)*100, 2)            AS satisfaction_rate_pct,
    ROUND(AVG(avg_service_rating), 2)          AS avg_service_rating,
    ROUND(AVG(total_delay_minutes), 1)         AS avg_delay_minutes,
    ROUND(AVG(flight_distance), 0)              AS avg_flight_distance
FROM airline_satisfaction
GROUP BY `class`, customer_type, type_of_travel, age_group,
         distance_group, gender, satisfaction;