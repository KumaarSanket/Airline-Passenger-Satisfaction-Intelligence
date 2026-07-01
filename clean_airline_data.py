import pandas as pd
import numpy as np

# ============================================
# STEP 1: LOAD AND COMBINE BOTH FILES
# ============================================
print("Loading train.csv and test.csv...")
train = pd.read_csv("train.csv")
test = pd.read_csv("test.csv")

print(f"Train shape: {train.shape}")
print(f"Test shape: {test.shape}")

# Combine into one dataset
df = pd.concat([train, test], ignore_index=True)

# Drop the useless index column
df = df.drop(columns=['Unnamed: 0'])

print(f"\nCombined shape: {df.shape}")

# ============================================
# STEP 2: STANDARDIZE COLUMN NAMES
# ============================================
df.columns = (
    df.columns
    .str.strip()
    .str.replace(' ', '_')
    .str.replace('/', '_')
    .str.lower()
)
print(f"\nStandardized columns:\n{df.columns.tolist()}")

# ============================================
# STEP 3: HANDLE NULLS IN ARRIVAL DELAY
# ============================================
null_count = df['arrival_delay_in_minutes'].isnull().sum()
print(f"\nNulls in arrival_delay_in_minutes: {null_count}")

# Fill nulls with 0 (these are likely cancelled/no-delay-recorded flights)
df['arrival_delay_in_minutes'] = df['arrival_delay_in_minutes'].fillna(0)

# Convert to integer (no more decimals needed)
df['arrival_delay_in_minutes'] = df['arrival_delay_in_minutes'].astype(int)

# ============================================
# STEP 4: STANDARDIZE TEXT VALUES
# ============================================
df['customer_type'] = df['customer_type'].str.strip().replace({
    'disloyal Customer': 'Disloyal Customer'
})

df['type_of_travel'] = df['type_of_travel'].str.strip()
df['gender'] = df['gender'].str.strip()
df['class'] = df['class'].str.strip()
df['satisfaction'] = df['satisfaction'].str.strip()

# ============================================
# STEP 5: CREATE DERIVED COLUMNS
# ============================================

# Age group buckets
def age_group(age):
    if age < 18: return '01-Under 18'
    elif age < 30: return '02-18 to 29'
    elif age < 45: return '03-30 to 44'
    elif age < 60: return '04-45 to 59'
    else: return '05-60 Plus'

df['age_group'] = df['age'].apply(age_group)

# Flight distance buckets
def distance_group(dist):
    if dist < 500: return '01-Short (Under 500mi)'
    elif dist < 1500: return '02-Medium (500-1499mi)'
    elif dist < 3000: return '03-Long (1500-2999mi)'
    else: return '04-Very Long (3000mi+)'

df['distance_group'] = df['flight_distance'].apply(distance_group)

# Total delay
df['total_delay_minutes'] = df['departure_delay_in_minutes'] + df['arrival_delay_in_minutes']

# Delayed flag
df['is_delayed'] = (df['total_delay_minutes'] > 0).astype(int)

# Satisfaction as binary flag (for easier averaging in SQL/Power BI)
df['is_satisfied'] = (df['satisfaction'] == 'satisfied').astype(int)

# Average service rating (across all 14 rating columns)
rating_cols = [
    'inflight_wifi_service', 'departure_arrival_time_convenient',
    'ease_of_online_booking', 'gate_location', 'food_and_drink',
    'online_boarding', 'seat_comfort', 'inflight_entertainment',
    'on-board_service', 'leg_room_service', 'baggage_handling',
    'checkin_service', 'inflight_service', 'cleanliness'
]

# Fix any column name mismatches dynamically
rating_cols = [c for c in df.columns if c in [
    'inflight_wifi_service','departure_arrival_time_convenient','ease_of_online_booking',
    'gate_location','food_and_drink','online_boarding','seat_comfort',
    'inflight_entertainment','on-board_service','onboard_service','on_board_service',
    'leg_room_service','baggage_handling','checkin_service','inflight_service','cleanliness'
]]

print(f"\nRating columns found: {rating_cols}")

df['avg_service_rating'] = df[rating_cols].mean(axis=1).round(2)

# ============================================
# STEP 6: FINAL DATA QUALITY CHECK
# ============================================
print(f"\n=== FINAL DATASET SUMMARY ===")
print(f"Total rows: {len(df):,}")
print(f"Total columns: {df.shape[1]}")
print(f"\nNull check:\n{df.isnull().sum()}")
print(f"\nDuplicate rows: {df.duplicated().sum()}")
print(f"\nFinal columns:\n{df.columns.tolist()}")
print(f"\nSatisfaction split:\n{df['satisfaction'].value_counts()}")

# ============================================
# STEP 7: EXPORT CLEAN CSV
# ============================================
output_file = "airline_satisfaction_clean.csv"
df.to_csv(output_file, index=False)
print(f"\n✅ Clean file saved as: {output_file}")
print(f"✅ Ready for MySQL import!")