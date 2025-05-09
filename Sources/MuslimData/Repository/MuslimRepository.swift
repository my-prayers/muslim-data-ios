//
//  MuslimRepository.swift
//  MuslimData
//
//  Created by Kosrat Ahmed on 18/03/2024.
//

import Foundation

public class MuslimRepository: Repository {

    public init () {}

    /// Search for locations in the database by location name and it will return a list of Location object.
    /// 
    /// - Parameters:
    ///   - locationName: location name
    /// - Returns: List of [Location]?
    public func searchLocation(locationName: String) async throws -> [Location]? {
        return try await DBHelper.shared.searchLocation(locationName)
    }

    /// Geocoding location information based on the provided country code and location name.
    /// 
    /// - Parameters:
    ///   - countryCode: Country code
    ///   - locationName: Location name
    /// - Returns: Geocoded location
    public func geocoder(countryCode: String, locationName: String) async throws -> Location? {
        return try await DBHelper.shared.geocoder(countryCode: countryCode, locationName: locationName)
    }

    /// Reverse geocoding location information based on the provided latitude and longitude.
    /// 
    /// - Parameters:
    ///   - latitude: Location's latitude.
    ///   - longitude: Location's longitude.
    /// - Returns: Reverse geocoded location
    public func reverseGeocoder(latitude: Double, longitude: Double) async throws -> Location? {
        return try await DBHelper.shared.reverseGeocoder(latitude: latitude, longitude: longitude)
    }

    /// Get prayer times for the specified location, date, and prayer attribute.
    /// 
    /// - Parameters:
    ///   - location: Location object
    ///   - date: Prayer times date
    ///   - attribute: Prayer times' attribute
    ///   - attributes: Prayer attribute
    /// - Returns: PrayerTime
    public func getPrayerTimes(location: Location,
                               date: Date,
                               attributes: PrayerAttribute) async throws -> PrayerTime? {
        do {
            var prayerTime: PrayerTime?
            if location.hasFixedPrayerTime {
                prayerTime = try await DBHelper.shared.prayerTimes(location: location, date: date)
                prayerTime?.applyDST()
            } else {
                prayerTime = Prayer.getPrayerTimes(location: location, date: date, attributes: attributes)
            }
            
            prayerTime?.applyOffsets(attributes.offsets)
            return prayerTime
        } catch {
            return nil
        }
    }

    /// Get names of Allah for the specified language.
    /// 
    /// - Parameters:
    ///   - language: Language for translating names.
    /// - Returns: List of [Name]? of Allah
    public func getNamesOfAllah(language: Language) async throws -> [Name]? {
        return try await DBHelper.shared.names(language: language)
    }

    /// Get azkar categories for the specified language.
    /// 
    /// - Parameters:
    ///   - language: Language of the azkar categories.
    /// - Returns: List of [AzkarCategory]?
    public func getAzkarCategories(language: Language) async throws -> [AzkarCategory]? {
        return try await DBHelper.shared.azkarCategories(language: language)
    }

    /// Get azkar chapters from the database for the specified language and category id.
    /// 
    /// - Parameters:
    ///   - language: Language of the azkar chapters.
    ///   - categoryId: Optional category id
    /// - Returns: List of [AzkarChapter]?
    public func getAzkarChapters(language: Language, categoryId: Int = -1) async throws -> [AzkarChapter]? {
        return try await DBHelper.shared.azkarChapters(language: language, categoryId: categoryId)
    }

    /// Get azkar chapters from the database for the specified language and category id.
    /// 
    /// - Parameters:
    ///   - language: Language of the azkar chapters.
    ///   - categoryId: Optional category id
    /// - Returns: List of [AzkarChapter]?
    public func getAzkarChapters(language: Language, chapterIds: [Int]) async throws -> [AzkarChapter]? {
        return try await DBHelper.shared.azkarChapters(language: language, chapterIds: chapterIds)
    }

    /// Get azkar items for specific azkar chapter from database which is localized by the given language.
    /// 
    /// - Parameters:
    ///   - chapterId: Chapter id for the azkar items.
    ///   - language: Language of the chapter.
    /// - Returns: List of [AzkarItem]?
    public func getAzkarItems(chapterId: Int, language: Language) async throws -> [AzkarItem]? {
        return try await DBHelper.shared.azkarItems(language: language, chapterId: chapterId)
    }
}
