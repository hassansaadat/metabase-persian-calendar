# Persian Calendar Model for Metabase

A Metabase model that converts Gregorian dates to the Persian (Jalali) calendar system, providing additional calendar features like seasons, week numbers, and Persian month names.

## Overview
This model creates a persistent calendar table in Metabase that converts Gregorian dates to Persian (Jalali) calendar dates. It's designed to be used as a model that other queries can join with to get Persian date information.

## Setup in Metabase

1. Create New Model:
  - Go to New > Model in Metabase
  - Select "Native query" as the model type
  - Give your model a descriptive name (e.g., "Persian Calendar")

2. Add the SQL Code:
  - Copy the entire SQL code provided in this repository
  - Paste it into the query editor in Metabase

3. Configure Model Settings:
  - Set "Refresh periodically" based on your needs:
    * For date range ending at current date: Recommended to refresh daily
    * For fixed date ranges: Can be set to refresh less frequently
  - Add a description for your model (optional but recommended)

4. Save:
  - Click "Save" to create your model
  - Note the model ID from the URL (you'll need this for queries)

5. Test Your Model:
  - Go to New > SQL query
  - Run a simple query to verify the installation
  - Use the test query provided in the Testing section

## Features
- Converts Gregorian dates to Persian dates
- Handles leap years in both calendars
- Provides month names in Persian (فارسی)
- Includes season information
- Calculates week numbers
- Configurable date range based on your needs
## Usage Examples

### Basic Date Conversion
```sql
SELECT 
    t.created_at,
    pc.persian_year || '/' || 
    LPAD(pc.persian_month::text, 2, '0') || '/' ||
    LPAD(pc.persian_day::text, 2, '0') as persian_date
FROM your_table t
JOIN {{#YOUR_MODEL_ID}} pc ON DATE_TRUNC('day', t.created_at) = pc.day_start;
```

### Monthly Reports
```sql
-- Count records by Persian month
SELECT 
    pc.persian_year,
    pc.persian_month,
    pc.persian_month_name,
    COUNT(*) as record_count
FROM your_table t
JOIN {{#YOUR_MODEL_ID}} pc ON DATE_TRUNC('day', t.created_at) = pc.day_start
GROUP BY 
    pc.persian_year,
    pc.persian_month,
    pc.persian_month_name
ORDER BY 
    pc.persian_year,
    pc.persian_month;
```

### Seasonal Analysis
```sql
-- Analyze data by season
SELECT 
    pc.persian_year,
    pc.persian_season,
    pc.persian_season_number,
    AVG(t.amount) as avg_amount,
    COUNT(*) as transaction_count
FROM transactions t
JOIN {{#YOUR_MODEL_ID}} pc ON DATE_TRUNC('day', t.created_at) = pc.day_start
GROUP BY 
    pc.persian_year,
    pc.persian_season,
    pc.persian_season_number
ORDER BY 
    pc.persian_year,
    pc.persian_season_number;
```
### Weekly Trends
```sql
-- Weekly data analysis
SELECT 
    pc.persian_year,
    pc.persian_month,
    pc.persian_week_number,
    COUNT(*) as weekly_count
FROM events t
JOIN {{#YOUR_MODEL_ID}} pc ON DATE_TRUNC('day', t.event_date) = pc.day_start
GROUP BY 
    pc.persian_year,
    pc.persian_month,
    pc.persian_week_number
ORDER BY 
    pc.persian_year,
    pc.persian_month,
    pc.persian_week_number;
```

### Date Filtering
```sql
-- Filter data for a specific Persian month
SELECT *
FROM your_table t
JOIN {{#YOUR_MODEL_ID}} pc ON DATE_TRUNC('day', t.created_at) = pc.day_start
WHERE 
    pc.persian_year = 1402 
    AND pc.persian_month = 6  -- Shahrivar
    AND pc.persian_day BETWEEN 1 AND 15;  -- First half of month
```

## Output Columns
| Column Name | Type | Description |
|------------|------|-------------|
| date | date | Original Gregorian date |
| day_start | timestamp | Start of the day (truncated timestamp) |
| persian_year | integer | Year in Persian calendar |
| persian_month | integer | Month number in Persian calendar (1-12) |
| persian_day | integer | Day of month in Persian calendar |
| persian_month_name | text | Persian month name in Persian script |
| persian_season | text | Season name in Persian script |
| persian_season_number | integer | Season number (1-4) |
| persian_week_number | integer | Week number in the Persian year |
## Limitations
- Default date range:
  - Starts from March 21, 2022 (1401/01/01)
  - Ends 7 days after the current date
  - You can modify these in the `date_range` CTE:
    ```sql
    WITH date_range AS (
      SELECT generate_series(
        '2022-03-21'::date,  -- Change this to your desired start date
        DATE_TRUNC('day', NOW() + INTERVAL '7 day'),  -- Modify the interval based on your needs
        '1 day'::interval
      ) AS date
    )
    ```
- Persian text requires proper UTF-8 encoding support

## Finding Your Model ID
After creating the model in Metabase:
1. Open the model
2. Look at the URL in your browser
3. The number after `/model/` is your model ID
4. Use this ID in your queries like `{{#YOUR_MODEL_ID}}`

## Testing
You can test the model with the following query:
```sql
WITH test_dates AS (
    SELECT
      gregorian_date::date,
      jalali_year,
      jalali_month,
      jalali_day,
      description
    FROM (VALUES
        ('2024-03-19'::date, 1402, 12, 29, 'End of year 1402'),
        ('2024-03-20'::date, 1403, 1, 1, 'Start of year 1403'),
        ('2024-12-24'::date, 1403, 10, 4, 'Sample winter day')
    ) AS test_data(gregorian_date, jalali_year, jalali_month, jalali_day, description)
)
SELECT
    t.gregorian_date,
    t.jalali_year AS expected_year,
    t.jalali_month AS expected_month,
    t.jalali_day AS expected_day,
    pc.persian_year AS calculated_year,
    pc.persian_month AS calculated_month,
    pc.persian_day AS calculated_day
FROM test_dates t
JOIN {{#YOUR_MODEL_ID}} pc ON DATE_TRUNC('day', t.gregorian_date) = pc.day_start;
```

## Credits

- **SQL Development**: Navid Behrangi
- **Project Repository**: [https://github.com/navidb/metabase-persian-calendar](url)
- **License**: MIT

**If you find this project useful, please consider giving it a star on GitHub.**

For issues, suggestions, or contributions, please visit the GitHub repository.
