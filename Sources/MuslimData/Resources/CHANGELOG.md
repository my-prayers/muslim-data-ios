# Muslim Data DB Change Log

All notable changes to the MuslimData database will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [2.5.0] - 2025-04-29

Revert Kalar, IQ prayer times and bug fixes.

### Changed

- Revert back the fajr and sunrise prayer times of Kalar, IQ to the old timetable.
- Add Rovia, IQ location to the database.
- Fix incorrect Fajr prayer time for Chamchamal, IQ on 12 Aug.
- Fix incorrect Asr prayer time for Bardarash, IQ on 03 Nov.
- Fix some kurdish azkar translation typo.

## [2.4.0] - 2025-01-03

Change Qasre, IQ prayer times.

### Changed

- Changed prayer times in the Qasre, IQ based on their latest update.

## [2.3.2] - 2024-12-06

Fix some Kurdish Badini translation.

### Fixed

- Fix some Kurdish Badini translation in Azkars section.

## [2.3.1] - 2024-11-27

Fix some Kurdish Badini translation.

### Fixed

- Fix some Kurdish Badini translation in Azkars section.

## [2.3.0] - 2024-11-21

Change Kalar and Kifri, IQ prayer times.

### Changed

- Changed prayer times in the Kalar, IQ based on their latest update.
- Changed prayer times in the Kifri, IQ based on their latest update.

## [2.2.0] - 2024-10-30

Add Kurdish Badini dialect to the library.

### Added

- Add a new Kurdish dialect (Badini dialect as `ckb_BADINI` locale) to the MuslimData library.

## [2.1.0] - 2024-06-20

Change comma style in the Arabic azkars to be compatible with the Uthmanic HAFS font.

### Changed

- Changed comma style in the Arabic azkars to use english comma style as it is compatible with the Uthmanic HAFS font.

## [2.0.1] - 2024-05-22

Bug fixes

### Fixed

- Fix Halabja, IQ sunrise time at 21 Apr.

## [2.0.0] - 2024-03-09

Refactor database tables to improve table normalization and handle city mapper in the database level.

### Added

- `country_id` as a foreign key added to the `location` (or `city`) table to make a relation with `country` table.
- `prayer_dependent_id` field added to the `location` table to handle city mapper in the database level.
- `location_id` as a foreign key added to the `prayer_time` table to make a relation with `location` table.

### Changed

- `city` table name has been renamed to `location`.
- `country_code` has been removed in the `location` table and the `country_id` field is used for the relationship between `location` and `country` tables.
- The `city` field in the `location` table has been renamed to `name` as it holds different types of locations like governorate, city, sub-city, village, etc.
- `country` table fields have been refactored by removing the country suffix before the fields.
- `country_code` and `city` fields have been removed in the `prayer_time` table and used `location_id` to make the relationship between `prayer_time` and `location` tables.
- Database indices have been refactored as shown blow:
  - `country` table has `code_index` for indexing `code` column.
  - `location` table has has two indices as listed below:
    - `location_country_id_index` for indexing `country_id` column.
    - `location_prayer_dependent_id_index` for indexing `prayer_dependent_id` column.
    - `location_lat_long_index` for indexing `latitude` and `longitude` columns.
    - `location_name_index` for indexing `name` column.
  - `prayer_time` table has `prayer_index` for indexing `location_id`, `date` columns.
- Khanaqin, IQ prayer times has been updated.

## [1.5.0] - 2024-03-04

Update Chamchamal prayer times.

### Changed

- Chamchamal, IQ prayer times have been updated.

## [1.4.2] - 2024-03-01

Bug fixes.

### Fixed

- Fix Sanandaj, IR prayer time at 29 Feb which was added as 02-01.

## [1.4.1] - 2024-02-28

Bug fixes.

### Fixed

- Fix Chamchamal, IQ prayer time at 29 Feb which was added as 02-01.

## [1.4.0] - 2024-02-18

Update Sulaymaniyah governorate prayer times.

### Added

- Kalar, IQ prayer times have been added as a separate list with old Suli data.
- Hero, IQ added to the city table.
- Bngrd, IQ added to the city table.
- Dokan, IQ prayer times have been added to the prayer time table.
- Khanaqin, IQ prayer times have been added to the prayer time table.
- Penjwen, IQ prayer times have been added to the prayer time table.
- Gokhlan, IQ prayer times have been added to the prayer time table.

### Changed

- Sulaymaniyah, IQ prayer times have been updated.
- Qaladiza, IQ prayer times have been updated.
- Qadir Karam removed from fixed prayer times.
- Ranya, IQ prayer times have been updated.
- Darbandikhan, IQ prayer times have been udpated.

## [1.3.3] - 2024-02-17

Add Qasre location to the MuslimData library.

### Added

- Add Qasre location to the city table.
- Add Qasre prayer times to the prayer time table.

## [Sample Data] - yyyy-mm-dd

Here we write upgrading notes for brands. It's a team effort to make them as
straightforward as possible.

### Added

-
-

### Changed

-
-

### Fixed

-
-
