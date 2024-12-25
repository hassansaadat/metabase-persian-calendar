/*
Persian (Jalali) Calendar Model for Metabase
===========================================

Created by Navid Behrangi
Website: https://www.navidbehrangi.com/
LinkedIn: https://www.linkedin.com/in/navidbehrangi/

As a product person working with Metabase, I’ve always needed a reliable way to convert Gregorian dates to the Persian (Jalali) calendar in my reports.
Since neither Metabase nor the community offered a built-in solution, I decided to create this model myself.
I hope it helps others who want to view or analyze data using Persian dates in Metabase.


This model converts Gregorian dates to the Persian (Jalali) calendar system.
The implementation is based on a precise astronomical calculation method.

Features:
- Converts Gregorian to Persian dates
- Handles leap years in both calendars
- Provides Persian month names, seasons, and week numbers

Date Range:
- Start date: March 21, 2022 (1401/01/01)
- End date: Current date + 7 days
 You can modify these dates in the date_range CTE based on your needs:
   - Change '2022-03-21' to your desired start date
   - Change 'INTERVAL '7 day'' to your desired future range
*/

WITH RECURSIVE persian_calendar AS (
 -- Generate date series from Persian year 1401 (March 21, 2022)
 WITH date_range AS (
   SELECT generate_series(
     '2022-03-21'::date, 
     DATE_TRUNC('day', NOW() + INTERVAL '7 day'),
     '1 day'::interval
   ) AS date
 ),
 -- Basic date information and day of year calculation
 base_calculations AS (
   SELECT 
     date,
     DATE_TRUNC('day', date) as day_start,
     EXTRACT(YEAR FROM date) AS g_year,
     EXTRACT(MONTH FROM date) AS g_month,
     EXTRACT(DAY FROM date) AS g_day,
     -- Calculate day of year using month offset array
     CASE EXTRACT(MONTH FROM date)::integer
       WHEN 1 THEN 0    -- Start from 0 (January)
       WHEN 2 THEN 31   -- February
       WHEN 3 THEN 59   -- March
       WHEN 4 THEN 90   -- April
       WHEN 5 THEN 120  -- May
       WHEN 6 THEN 151  -- June
       WHEN 7 THEN 181  -- July
       WHEN 8 THEN 212  -- August
       WHEN 9 THEN 243  -- September
       WHEN 10 THEN 273 -- October
       WHEN 11 THEN 304 -- November
       WHEN 12 THEN 334 -- December
     END + EXTRACT(DAY FROM date) AS doy_g,
     -- Leap year calculation parameters
     EXTRACT(YEAR FROM date) % 4 AS d_4,
     FLOOR(((EXTRACT(YEAR FROM date) - 16) % 132) * 0.0305) AS d_33
   FROM date_range
 ),
 -- Calculate Persian calendar conversion parameters
 persian_conversion AS (
   SELECT 
     *,
     -- Calculate parameter 'a' for year conversion
     CASE 
       WHEN (d_33 = 3 OR d_33 < (d_4 - 1) OR d_4 = 0) THEN 286
       ELSE 287
     END AS a,
     -- Calculate parameter 'b' for year conversion
     CASE 
       WHEN (d_33 = 1 OR d_33 = 2) AND (d_33 = d_4 OR d_4 = 1) THEN 78
       WHEN d_33 = 3 AND d_4 = 0 THEN 80
       ELSE 79
     END AS b,
     -- Adjust day of year for Gregorian leap years
     CASE 
       WHEN g_month > 2 AND d_4 = 0 THEN doy_g + 1
       ELSE doy_g
     END AS doy_g_adj
   FROM base_calculations
 ),
 -- Calculate basic Persian date components
 final_date AS (
   SELECT 
     date,
     day_start,
     -- Calculate Persian year
     CASE 
       WHEN doy_g_adj > b THEN g_year - 621
       ELSE g_year - 622
     END AS persian_year,
     -- Calculate day of Persian year
     CASE 
       WHEN doy_g_adj > b THEN doy_g_adj - b
       ELSE doy_g_adj + a
     END AS doy_j
   FROM persian_conversion
 )
 SELECT 
   date,
   day_start,
   persian_year,
   -- Calculate Persian month (1-12)
   CASE 
     WHEN doy_j < 187
     THEN FLOOR((doy_j - 1) / 31) + 1  -- First 6 months (31 days each)
     ELSE FLOOR((doy_j - 187) / 30) + 7 -- Last 6 months (30 days each)
   END AS persian_month,
   -- Calculate Persian day of month
   CASE 
     WHEN doy_j < 187
     THEN doy_j - (FLOOR((doy_j - 1) / 31) * 31)
     ELSE doy_j - 186 - (FLOOR((doy_j - 187) / 30) * 30)
   END AS persian_day,
   -- Persian month names
   CASE CASE 
     WHEN doy_j < 187
     THEN FLOOR((doy_j - 1) / 31) + 1
     ELSE FLOOR((doy_j - 187) / 30) + 7
   END
     WHEN 1 THEN 'فروردین'
     WHEN 2 THEN 'اردیبهشت'
     WHEN 3 THEN 'خرداد'
     WHEN 4 THEN 'تیر'
     WHEN 5 THEN 'مرداد'
     WHEN 6 THEN 'شهریور'
     WHEN 7 THEN 'مهر'
     WHEN 8 THEN 'آبان'
     WHEN 9 THEN 'آذر'
     WHEN 10 THEN 'دی'
     WHEN 11 THEN 'بهمن'
     WHEN 12 THEN 'اسفند'
   END AS persian_month_name,
   -- Calculate Persian seasons
   CASE 
     WHEN doy_j < 94 THEN 'بهار'
     WHEN doy_j < 187 THEN 'تابستان'
     WHEN doy_j < 277 THEN 'پاییز'
     ELSE 'زمستان'
   END AS persian_season,
   -- Calculate season number (1-4)
   CASE 
     WHEN doy_j < 94 THEN 1
     WHEN doy_j < 187 THEN 2
     WHEN doy_j < 277 THEN 3
     ELSE 4
   END AS persian_season_number,
   -- Calculate week number in Persian year
   FLOOR((doy_j - 1) / 7) + 1 AS persian_week_number
 FROM final_date
)
SELECT * FROM persian_calendar;