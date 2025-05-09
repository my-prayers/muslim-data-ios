//
//  DBHelper.swift
//  GRDB.swift
//
//  Created by Kosrat D. Ahmad on 9/27/18.
//

import GRDB
import Foundation

class DBHelper {
    // MARK: - Properties

    private let dbName = "muslim_db_v2.5.0"
    var dbPool: DatabasePool?
    static let shared = DBHelper()

    var dbPath: String {
        #if SWIFT_PACKAGE
        // SPM Access
        return Bundle.module.path(forResource: dbName, ofType: "db")!
        #else
        // CocoaPods Access
        return Bundle(for: DBHelper.self).path(forResource: dbName, ofType: "db")!
        #endif
    }

    // MARK: - Life cycle

    private init() {
        var configuration = Configuration()
        configuration.readonly = true
        dbPool = try? DatabasePool(path: dbPath, configuration: configuration)
               
        dbPool?.releaseMemoryEventually()
    }

    // MARK: - Public Methods

    /// Get fixed prayer times from Muslim database.
    /// - Parameters:
    ///   - location: Location object
    ///   - date: Prayer date
    /// - Returns: PrayerTime instance.
    func prayerTimes(location: Location, date: Date) async throws -> PrayerTime? {
        do {
            return try await dbPool?.read { dbConnect in
                let result = try Row.fetchOne(dbConnect, sql: """
                SELECT * FROM prayer_time
                WHERE location_id = '\(location.prayerDependentId ?? location.id)'
                AND date = '\(date.toDBDate())'
                """)

                guard let row = result else {
                    print("Found nil while unwrapping result.")
                    return nil
                }

                // Getting data from columns
                guard let fajr = row["fajr"] as? String,
                      let sunrise = row["sunrise"] as? String,
                      let dhuhr = row["dhuhr"] as? String,
                      let asr = row["asr"] as? String,
                      let maghrib = row["maghrib"] as? String,
                      let isha = row["isha"] as? String
                else {
                    print("All columns are not found in the row.")
                    return nil
                }

                // Create PrayerTime object.
                return PrayerTime(fajr: fajr.toDate(date),
                                  sunrise: sunrise.toDate(date),
                                  dhuhr: dhuhr.toDate(date),
                                  asr: asr.toDate(date),
                                  maghrib: maghrib.toDate(date),
                                  isha: isha.toDate(date))
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }

    /// Get 99 names of Allah from database for the given language.
    ///
    /// - Parameters:
    ///   - language: Language of the translated names.
    /// - Returns: List of [name]? of Allah
    func names(language: Language) async throws -> [Name]? {
        do {
            return try await dbPool?.read { dbConnect in
                let names = try Name.fetchAll(dbConnect, sql: """
                SELECT name.name, transl.name AS translated
                FROM name
                INNER JOIN name_translation AS transl ON transl.name_id = name._id AND transl.language = '\(language)'
                """)
                return names
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }

    /// Get azkar categories from database which is localized by the given language.
    ///
    /// - Parameters:
    ///   - language: Language of the category.
    /// - Returns: List of [AzkarCategory]?
    func azkarCategories(language: Language) async throws -> [AzkarCategory]? {
        do {
            return try await dbPool?.read { dbConnect in
                let categories = try AzkarCategory.fetchAll(dbConnect, sql: """
                SELECT category._id, category_name
                FROM azkar_category AS category
                INNER JOIN azkar_category_translation AS transl ON transl.category_id = category._id
                AND language = '\(language)'
                """)
                return categories
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }

    /// Get azkar chapters from database which is localized by given language and filtered by category id.
    ///
    /// - Parameters:
    ///   - language: Language of the chapter.
    ///   - categoryId: Optional category id
    /// - Returns: List of [AzkarChapter]?
    func azkarChapters(language: Language, categoryId: Int = -1) async throws -> [AzkarChapter]? {
        let category = categoryId == -1 ? "" : " AND category_id = \(String(describing: categoryId))"

        do {
            return try await dbPool?.read { dbConnect in
                let chapters = try AzkarChapter.fetchAll(dbConnect, sql: """
                SELECT chapter._id, category_id, chapter_name
                FROM azkar_chapter AS chapter
                INNER JOIN azkar_chapter_translation AS transl ON transl.chapter_id = chapter._id
                AND language = '\(language)' \(category)
                """)
                return chapters
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }

    /// Get azkar chapters from database which is localized by given language and filtered by chapter ids.
    ///
    /// - Parameters:
    ///   - language: Language of the chapter.
    ///   - chapterIds: Array of chapter  ids
    /// - Returns: List of [AzkarChapter]?
    func azkarChapters(language: Language, chapterIds: [Int]) async throws -> [AzkarChapter]? {
        do {
            return try await dbPool?.read { dbConnect in
                let chapters = try AzkarChapter.fetchAll(dbConnect, sql: """
                SELECT chapter._id, category_id, chapter_name
                FROM azkar_chapter AS chapter
                INNER JOIN azkar_chapter_translation AS transl ON transl.chapter_id = chapter._id
                AND language = '\(language)' AND chapter._id IN (\(chapterIds.minimalDescription))
                """)
                return chapters
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }

    /// Get azkar items for specific azkar chapter from database which is localized by given language.
    /// 
    /// - Parameters:
    ///   - language: Language of the chapter.
    ///   - chapterId: Chapter id for the azkar items.
    /// - Returns: List of [AskarItem]?
    func azkarItems(language: Language, chapterId: Int) async throws -> [AzkarItem]? {
        do {
            return try await dbPool?.read { dbConnect in
                let items = try AzkarItem.fetchAll(dbConnect, sql: """
                SELECT item._id, item.chapter_id, item.item, transl.item_translation, ref_transl.reference
                FROM azkar_item AS item
                INNER JOIN azkar_item_translation AS transl ON transl.item_id = item._id
                AND transl.language = '\(language)' AND item.chapter_id = \(chapterId)
                INNER JOIN azkar_reference AS ref ON ref.item_id = item._id
                INNER JOIN azkar_reference_translation AS ref_transl ON ref_transl.reference_id = ref._id
                AND ref_transl.language = '\(language)'
                """)
                return items
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }

    /// Search for a location in the database
    ///
    /// - Parameters:
    ///   - locationName: location name
    ///   - callback: Callback that returns a Location object.
    /// - Returns: List of found locations
    func searchLocation(_ locationName: String) async throws -> [Location]? {
            do {
                return try await dbPool?.read { dbConnect in
                    let locations = try Location.fetchAll(dbConnect, sql: """
                    SELECT location._id AS _id, country.code AS country_code, country.name AS country_name,
                           location.name AS name, latitude, longitude, has_fixed_prayer_time, prayer_dependent_id
                    FROM location
                    INNER JOIN country ON country._id = location.country_id
                    WHERE location.name like '\(locationName)%'
                    """)
                    return locations
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                return nil
            }
    }

    /// Geocoder to find location by it's name.
    /// 
    /// - Parameters:
    ///   - countryCode: Country code
    ///   - locationName: location name
    /// - Returns: geocoded location
    func geocoder(countryCode: String, locationName: String) async throws -> Location? {
        do {
            return try await dbPool?.read { dbConnect in
                let location = try Location.fetchOne(dbConnect, sql: """
                SELECT location._id AS _id, country.code AS country_code, country.name AS country_name,
                       location.name AS name, latitude, longitude, has_fixed_prayer_time, prayer_dependent_id
                FROM location
                INNER JOIN country ON country._id = location.country_id
                WHERE country.code = '\(countryCode)' COLLATE NOCASE
                AND location.name = '\(locationName)' COLLATE NOCASE
                """)
                return location
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }

    /// Reverse geocoder to find location by it's latitude and longitude.
    /// 
    /// - Parameters:
    ///   - latitude: Location latitude.
    ///   - longitude: Location longitude.
    /// - Returns: reverse geocoded location
    func reverseGeocoder(latitude: Double, longitude: Double) async throws -> Location? {
        do {
            return try await dbPool?.read { dbConnect in
                let location = try Location.fetchOne(dbConnect, sql: """
                SELECT location._id AS _id, country.code AS country_code, country.name AS country_name,
                       location.name AS name, latitude, longitude, has_fixed_prayer_time, prayer_dependent_id
                FROM location
                INNER JOIN country ON country._id = location.country_id
                ORDER BY ABS(latitude - (\(latitude))) + ABS(longitude - (\(longitude)))
                LIMIT 1
                """)
                return location
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }

    /// Get all the locations that has fixed prayer times.
    /// - Returns: Location list
    func fixedPrayerTimesList() -> [Location]? {
        do {
            return try dbPool?.read { dbConnect in
                let locations = try Location.fetchAll(dbConnect, sql: """
                SELECT location._id AS _id, country.code AS country_code, country.name AS country_name,
                       location.name AS name, latitude, longitude, has_fixed_prayer_time, prayer_dependent_id
                FROM location
                INNER JOIN country ON country._id = location.country_id
                WHERE has_fixed_prayer_time = 1
                """)
               return locations
            }
        } catch {
            return nil
        }
    }
}
