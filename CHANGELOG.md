# Changelog
All notable changes to Persian Calendar Model for Metabase will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-01-31

### Added
- Restructured to support multiple databases, starting with PostgreSQL
- Persian week start date (Saturday) calculation for accurate weekly reporting

### Changed  
- Season calculation method from day-of-year based to Persian month-based for simpler and more intuitive calculations

### Removed
- Deprecated `persian_week_number` in favor of `persian_week_start_date`

### Fixed
- Corrected Persian week boundaries to properly start from Saturday

This release focuses on improved accuracy in season calculations and better weekly reporting with explicit Persian calendar week boundaries, while laying the groundwork for supporting additional database systems.

## [1.0.0] - 2024-12-26

### Added
- Persian to Gregorian date conversion
- Persian month names (فارسی)
- Season calculation based on day of year
- Week number calculation
- Configurable date range with defaults:
 - Start: March 21, 2022 (1401/01/01)
 - End: Current date + 7 days
- Support for leap years in both calendars
- Example queries for common use cases:
 - Basic date conversion
 - Monthly reports
 - Seasonal analysis
 - Weekly trends
 - Date filtering
- Detailed documentation and usage guide
