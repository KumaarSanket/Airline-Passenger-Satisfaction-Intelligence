# Airline-Passenger-Satisfaction-Intelligence

# ✈️ Airline Passenger Satisfaction Dashboard

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Records](https://img.shields.io/badge/Records-129%2C880-0EA5E9?style=for-the-badge)
![Satisfaction](https://img.shields.io/badge/Satisfaction%20Rate-43.45%25-F97316?style=for-the-badge)

> Data Analytics · K.S. · Tools: Python → MySQL → Power BI

## ✈️ Airline Passenger Satisfaction Dashboard

![Airline Passenger Satisfaction Dashboard](Airline%20Passenger%20Satisfaction%20Dashboard.jpeg)

![Airline Passenger Satisfaction Dashboard 2](Airline%20Passenger%20Satisfaction%20Dashboard%20%282%29.jpeg)

![Airline Passenger Satisfaction Dashboard 3](Airline%20Passenger%20Satisfaction%20Dashboard%20%283%29.jpeg)

---

## 📌 Project Overview

Received 2 Kaggle ML files (train.csv + test.csv), identified zero ID overlap, confirmed both have identical columns — combined into one 129,880-row dataset. • Ran Python EDA and cleaning script performing 8 operations: combined files, dropped index column, standardised names, filled 393 nulls, fixed capitalisation, created 6 derived columns (age_group, distance_group, total_delay_minutes, is_delayed, is_satisfied, avg_service_rating). • Imported into MySQL in 3.157 seconds, created 6 indexes, ran 7 SQL queries. • Built 2-page Power BI dashboard (18 visuals, 14 DAX measures) revealing Business Class 69.44% vs Eco 18.77% satisfaction, Online Boarding as #1 driver, and Loyal Personal travelers as highest business-risk segment.

---

## 🎯 Problem Statement

An airline's 129,880 passenger satisfaction survey responses existed across 2 separate Kaggle ML files with no reporting layer — no visibility into which segments were most dissatisfied, which service factors most influenced satisfaction, or how delays affected the passenger experience.

---

## 🎯 Objectives

- Identify why 2 files exist, validate zero ID overlap, combine into unified dataset
- Clean and engineer 6 analytical derived columns in Python
- Import to MySQL, create indexes, execute 7 analytical queries + 1 VIEW
- Build 2-page Power BI dashboard with 14 measures and 18 visuals
- Surface top satisfaction drivers and highest business-risk segments

---

## 📁 Dataset

| Attribute | Detail |
|-----------|--------|
| **Name** | Airline Passenger Satisfaction |
| **Source** | [Kaggle — teejmahal20/airline-passenger-satisfaction](https://www.kaggle.com/datasets/teejmahal20/airline-passenger-satisfaction) |
| **Files** | train.csv (103,904 rows) + test.csv (25,976 rows) |
| **Why 2 Files** | Kaggle ML train/test split — both have identical 25 columns + satisfaction label |
| **ID Overlap** | **Zero** — confirmed safe to combine |
| **Combined Rows** | **129,880** |
| **Final Columns** | 30 (24 original + 6 derived by Python) |
| **Nulls After Cleaning** | Zero |
| **Duplicates** | Zero |

---

## 🛠️ Tools & Technologies

| Tool | Phase | Purpose |
|------|-------|---------|
| **Python 3.11** | Phase 1 | EDA, combine 2 files, cleaning, feature engineering, CSV export |
| **pandas** | Phase 1 | Data manipulation — concat, fillna, apply, str methods |
| **MySQL 8.0** | Phase 2 | Table, LOAD DATA INFILE, 6 indexes, 7 queries, 1 VIEW |
| **MySQL Workbench** | Phase 2 | Query execution and verification |
| **Power BI Desktop** | Phase 3 | Live MySQL connection, 14 DAX measures, 2-page dashboard |

---

## ⚙️ PHASE 1 — Python

### Why Python for This Project?
- 2 separate files needed to be combined (not doable in MySQL import directly)
- 6 derived columns needed row-level Python logic (age buckets, distance buckets)
- Column name standardisation needed before MySQL import
- 393 nulls needed intelligent handling (fill vs drop decision)

### Python Script — 8 Operations

```python
import pandas as pd
import numpy as np

# 1. Load and combine both files
train = pd.read_csv("train.csv")
test = pd.read_csv("test.csv")
df = pd.concat([train, test], ignore_index=True)

# 2. Drop Unnamed:0 index column
df = df.drop(columns=['Unnamed: 0'])

# 3. Standardise column names to lowercase_underscore
df.columns = df.columns.str.strip().str.replace(' ', '_').str.replace('/', '_').str.lower()

# 4. Fill 393 nulls in arrival delay with 0
df['arrival_delay_in_minutes'] = df['arrival_delay_in_minutes'].fillna(0).astype(int)

# 5. Fix capitalisation
df['customer_type'] = df['customer_type'].str.strip().replace({'disloyal Customer': 'Disloyal Customer'})

# 6. Create age_group (5 buckets)
def age_group(age):
    if age < 18: return '01-Under 18'
    elif age < 30: return '02-18 to 29'
    elif age < 45: return '03-30 to 44'
    elif age < 60: return '04-45 to 59'
    else: return '05-60 Plus'
df['age_group'] = df['age'].apply(age_group)

# 7. Create distance_group (4 buckets)
def distance_group(dist):
    if dist < 500: return '01-Short (Under 500mi)'
    elif dist < 1500: return '02-Medium (500-1499mi)'
    elif dist < 3000: return '03-Long (1500-2999mi)'
    else: return '04-Very Long (3000mi+)'
df['distance_group'] = df['flight_distance'].apply(distance_group)

# 8. Create remaining derived columns
df['total_delay_minutes'] = df['departure_delay_in_minutes'] + df['arrival_delay_in_minutes']
df['is_delayed'] = (df['total_delay_minutes'] > 0).astype(int)
df['is_satisfied'] = (df['satisfaction'] == 'satisfied').astype(int)
df['avg_service_rating'] = df[rating_cols].mean(axis=1).round(2)

# Export
df.to_csv("airline_satisfaction_clean.csv", index=False)
# Result: 129,880 rows, 30 columns, 0 nulls, 0 duplicates ✅
```

---

## ⚙️ PHASE 2 — MySQL

### Table Creation

```sql
CREATE DATABASE IF NOT EXISTS airline_project;
USE airline_project;

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
```

### Import

```sql
SET SESSION sql_mode = '';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/airline_satisfaction_clean.csv'
INTO TABLE airline_satisfaction
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, gender, customer_type, age, type_of_travel, `class`, flight_distance,
 inflight_wifi_service, departure_arrival_time_convenient, ease_of_online_booking,
 gate_location, food_and_drink, online_boarding, seat_comfort,
 inflight_entertainment, onboard_service, leg_room_service, baggage_handling,
 checkin_service, inflight_service, cleanliness, departure_delay_in_minutes,
 arrival_delay_in_minutes, satisfaction, age_group, distance_group,
 total_delay_minutes, is_delayed, is_satisfied, avg_service_rating);
-- Result: 129,880 rows · 3.157 seconds · 0 warnings ✅
```

### 7 Analytical Queries

```sql
-- Q1: Overall KPIs
SELECT COUNT(*) total_passengers, SUM(is_satisfied) satisfied_count,
       ROUND(AVG(is_satisfied)*100,2) satisfaction_rate_pct,
       ROUND(AVG(age),1) avg_age, ROUND(AVG(flight_distance),0) avg_distance,
       ROUND(AVG(avg_service_rating),2) avg_service_rating,
       SUM(is_delayed) delayed_flights, ROUND(AVG(is_delayed)*100,2) delayed_pct
FROM airline_satisfaction;
-- 129,880 · 56,428 satisfied (43.45%) · avg age 39.4 · 1,190mi · rating 3.24 · 54.19% delayed

-- Q2: Satisfaction by Class
SELECT `class`, COUNT(*) total, ROUND(AVG(is_satisfied)*100,2) satisfaction_rate_pct,
       ROUND(AVG(avg_service_rating),2) avg_service
FROM airline_satisfaction GROUP BY `class` ORDER BY satisfaction_rate_pct DESC;
-- Business 69.44% · Eco Plus 24.64% · Eco 18.77%

-- Q3: Satisfaction by Customer + Travel Type
SELECT customer_type, type_of_travel, COUNT(*) total,
       ROUND(AVG(is_satisfied)*100,2) satisfaction_rate_pct
FROM airline_satisfaction GROUP BY customer_type, type_of_travel ORDER BY satisfaction_rate_pct DESC;
-- Loyal+Business 70.62% · Disloyal+Business 24.04% · Disloyal+Personal 15.92% · Loyal+Personal 10.10%

-- Q4: Satisfaction by Age Group
SELECT age_group, COUNT(*) total, ROUND(AVG(is_satisfied)*100,2) satisfaction_rate_pct,
       ROUND(AVG(avg_service_rating),2) avg_service
FROM airline_satisfaction GROUP BY age_group ORDER BY age_group;
-- Under 18: 16.73% · 18-29: 34.86% · 30-44: 47.57% · 45-59: 57.53% · 60+: 27.07%

-- Q5: Service Driver Analysis (UNION ALL across 6 key factors)
SELECT 'Online Boarding' AS factor, ROUND(AVG(online_boarding),2) overall,
       ROUND(AVG(CASE WHEN satisfaction='satisfied' THEN online_boarding END),2) satisfied,
       ROUND(AVG(CASE WHEN satisfaction!='satisfied' THEN online_boarding END),2) dissatisfied
FROM airline_satisfaction
-- ... (UNION ALL for each factor)
-- Online Boarding gap: 4.03 vs 2.66 (+1.37) — #1 driver

-- Q6: Delay Impact
SELECT is_delayed, COUNT(*) total, ROUND(AVG(is_satisfied)*100,2) satisfaction_rate_pct,
       ROUND(AVG(total_delay_minutes),1) avg_delay
FROM airline_satisfaction GROUP BY is_delayed;
-- Delayed: 40.30% satisfaction · On-time: 47.17% satisfaction (-6.87pp penalty)

-- Q7: Create VIEW
CREATE OR REPLACE VIEW vw_airline_summary AS
SELECT `class`, customer_type, type_of_travel, age_group, distance_group, gender,
       satisfaction, COUNT(*) passenger_count,
       ROUND(AVG(is_satisfied)*100,2) satisfaction_rate_pct,
       ROUND(AVG(avg_service_rating),2) avg_service_rating,
       ROUND(AVG(total_delay_minutes),1) avg_delay,
       ROUND(AVG(flight_distance),0) avg_distance
FROM airline_satisfaction
GROUP BY `class`, customer_type, type_of_travel, age_group, distance_group, gender, satisfaction;
```

---

## 📐 DAX Measures (14 Total)

```dax
-- Core 8 Measures
Total Passengers = COUNTROWS('airline_project airline_satisfaction')  -- 129,880
Satisfied Count = SUM('airline_project airline_satisfaction'[is_satisfied])  -- 56,428
Satisfaction Rate = DIVIDE([Satisfied Count], [Total Passengers]) * 100  -- 43.45%
Avg Service Rating = AVERAGE('airline_project airline_satisfaction'[avg_service_rating])  -- 3.24
Avg Age = AVERAGE('airline_project airline_satisfaction'[age])  -- 39.4
Avg Flight Distance = AVERAGE('airline_project airline_satisfaction'[flight_distance])  -- 1,190
Delayed Count = SUM('airline_project airline_satisfaction'[is_delayed])  -- 70,382
Delayed Rate = DIVIDE([Delayed Count], [Total Passengers]) * 100  -- 54.19%

-- 6 Service Rating Measures
Avg Online Boarding = AVERAGE('airline_project airline_satisfaction'[online_boarding])  -- 3.25
Avg Seat Comfort = AVERAGE('airline_project airline_satisfaction'[seat_comfort])  -- 3.44
Avg Inflight Entertainment = AVERAGE('airline_project airline_satisfaction'[inflight_entertainment])  -- 3.36
Avg Onboard Service = AVERAGE('airline_project airline_satisfaction'[onboard_service])  -- 3.38
Avg Cleanliness = AVERAGE('airline_project airline_satisfaction'[cleanliness])  -- 3.29
Avg Inflight Wifi = AVERAGE('airline_project airline_satisfaction'[inflight_wifi_service])  -- 2.73
```

> ⚠️ **Boolean Fix Required:** MySQL `TINYINT(1)` columns (`is_satisfied`, `is_delayed`) auto-detect as Boolean in Power BI. Fix: Power Query → click column type → change to **Whole Number** → Replace current. Without this fix, all SUM-based measures show errors.

---

## 📊 2-Page Dashboard (18 Visuals)

### Page 1 — Satisfaction Overview (12 visuals)
| # | Visual | Key Insight |
|---|--------|-------------|
| 1-6 | 6 KPI Cards | 129,880 passengers · 43.45% satisfied · 3.24 rating · 39.4 avg age · 1,190mi · 54.19% delayed |
| 7 | Bar Chart: Satisfaction by Class | Business 69.44% vs Eco 18.77% — 3.70× gap |
| 8 | Column Chart: Customer + Travel Type | Loyal+Business 70.62% · Loyal+Personal only 10.10% |
| 9 | Line Chart: Satisfaction by Age | Peak at 45-59 (57.53%), low at Under-18 (16.73%) |
| 10 | Donut: Overall Split | 43.45% satisfied vs 56.55% not |
| 11-12 | Slicers | Class · Customer Type |

### Page 2 — Service Quality & Delay Impact (6 visuals)
| # | Visual | Key Insight |
|---|--------|-------------|
| 13 | Table: Service Drivers | Online Boarding biggest gap (4.03 vs 2.66) |
| 14 | Column: Delay Impact | Delayed 40.30% vs On-time 47.17% |
| 15 | Bar: Satisfaction by Distance | Short vs long haul comparison |
| 16 | Column: Avg Delay by Class | Which class experiences longest delays |
| 17-18 | Slicers | Age Group · Satisfaction |

---

## 📈 Key Insights & Results

### Overall Satisfaction
- **43.45% satisfied** (56,428) vs **56.55% dissatisfied** (73,452) — below 50% signals systemic issue
- Avg service rating: **3.24/5.00** · Delayed flights: **54.19%** · Avg delay: **54.9 min** (when delayed)

### Satisfaction by Class
| Class | Passengers | Satisfaction | Avg Rating |
|-------|-----------|-------------|-----------|
| **Business** | 62,160 | **69.44%** | 3.43 |
| Eco Plus | 9,411 | 24.64% | 3.06 |
| Eco | 58,309 | 18.77% | 3.07 |

### Satisfaction by Customer Segment
| Segment | Passengers | Satisfaction |
|---------|-----------|-------------|
| **Loyal + Business** | 66,114 | **70.62%** |
| Disloyal + Business | 23,579 | 24.04% |
| Disloyal + Personal | 201 | 15.92% |
| **Loyal + Personal** | **39,986** | **10.10%** ⚠️ High Risk |

### Satisfaction by Age Group
| Age Group | Passengers | Satisfaction |
|-----------|-----------|-------------|
| Under 18 | 9,847 | 16.73% |
| 18-29 | 28,512 | 34.86% |
| 30-44 | 41,064 | 47.57% |
| **45-59** | **38,242** | **57.53%** ← Peak |
| 60+ | 12,215 | 27.07% |

### Top Service Drivers (Satisfied vs Dissatisfied)
| Service Factor | Satisfied Avg | Dissatisfied Avg | Gap |
|----------------|--------------|-----------------|-----|
| **Online Boarding** | **4.03** | **2.66** | **+1.37** ← #1 Priority |
| Inflight Entertainment | 3.96 | 2.89 | +1.07 |
| Seat Comfort | 3.97 | 3.04 | +0.93 |
| Onboard Service | 3.86 | 3.02 | +0.84 |
| Cleanliness | 3.75 | 2.93 | +0.82 |
| Inflight Wifi | 3.16 | 2.40 | +0.76 (lowest overall: 2.73) |

---

## 📊 KPI Summary

| KPI | Value | KPI | Value |
|-----|-------|-----|-------|
| Total Passengers | **129,880** | Satisfied | 56,428 (43.45%) |
| Dissatisfied | 73,452 (56.55%) | Avg Service Rating | 3.24/5.00 |
| Avg Age | 39.4 years | Avg Distance | 1,190 miles |
| Delayed Flights | 70,382 (54.19%) | Avg Delay | 54.9 min |
| Business Satisfaction | **69.44%** | Eco Satisfaction | **18.77%** |
| Peak Age Group | 45-59 (57.53%) | #1 Service Driver | Online Boarding (gap 1.37) |
| Weakest Service | Inflight Wifi (2.73) | Delay Penalty | -6.87pp satisfaction |

---

## ⚡ Challenges & Solutions

**Challenge 1 — Why 2 Files?**
Both files have identical 25 columns + satisfaction label, zero ID overlap — Kaggle ML train/test split. Safe to combine. Result: 129,880 unified rows.

**Challenge 2 — on-board_service Hyphen**
MySQL can't handle hyphens in column names. Renamed to `onboard_service` in CREATE TABLE schema.

**Challenge 3 — Boolean Auto-Detection in Power BI**
MySQL TINYINT(1) → Power BI detects as Boolean → SUM() fails. Fixed: Power Query → Whole Number type for `is_satisfied` and `is_delayed`.

**Challenge 4 — 393 Arrival Delay Nulls**
Filled with 0 (not NULL) — departure delay was 0 for same rows, supporting interpretation as on-time flights with missing data collection. 0.30% impact — statistically negligible.

**Challenge 5 — class is MySQL Reserved Word**
Wrapped in backticks: `` `class` `` throughout all CREATE TABLE, SELECT, GROUP BY, and ORDER BY statements.

---

## 🎓 Skills Learned

- **Multi-File Dataset Identification** — Recognising Kaggle ML split; validating zero ID overlap before combining
- **Python Feature Engineering** — 6 derived columns transforming raw survey data into BI-ready features
- **MySQL Reserved Word Handling** — Backtick escaping for `class` keyword
- **Boolean vs Integer in Power BI** — TINYINT(1) auto-detection fix via Power Query type change
- **Service Factor Gap Analysis** — Computing satisfied vs dissatisfied rating differences to rank improvement priorities
- **Segment Risk Analysis** — Identifying large loyal-but-dissatisfied segments as highest business risk

---

## 🎨 Custom Theme

`Sky_Aviation_Airline_Theme.json` — Apply via **View → Themes → Browse for themes**

| Element | Color | Meaning |
|---------|-------|---------|
| Canvas | `#0A1929` — Deep Night Sky | Aviation/flight identity |
| Visuals | `#0D2137` — Dark Navy | Cockpit aesthetic |
| KPI Borders + Numbers | `#7DD3FC` — Sky Blue | Clear sky accent |
| Highlight Color | `#F97316` — Sunset Orange | Warm contrast |
| Data Color 1 | `#0EA5E9` — Aviation Blue | Primary series |

---

## 📂 Repository Structure

```
airline-satisfaction-dashboard/
│
├── 📊 Airline_Satisfaction_Dashboard.pbix
├── 📁 Dataset/
│   ├── train.csv                           # Kaggle source (103,904 rows)
│   └── test.csv                            # Kaggle source (25,976 rows)
├── 📁 Python/
│   └── clean_airline_data.py               # Cleaning + feature engineering script
├── 📁 Clean/
│   └── airline_satisfaction_clean.csv      # Python output (129,880 rows, 30 cols)
├── 📁 MySQL/
│   ├── create_table.sql
│   ├── load_data.sql
│   └── analytical_queries.sql
├── 📁 Theme/
│   └── Sky_Aviation_Airline_Theme.json
├── 📄 Airline_Satisfaction_Portfolio_Documentation.pdf
└── 📄 README.md
```

---

*Data Analytics · K.S.*
