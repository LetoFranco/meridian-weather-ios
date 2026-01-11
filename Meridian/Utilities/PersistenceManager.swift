
import Foundation

// MARK: - PersistenceManager
/// Manages the persistence of user preferences, such as the last viewed city index.
enum PersistenceManager {
    private static let lastCityIndexKey = "lastCityIndex"
    
    /// Saves the index of the last viewed city.
    /// - Parameter index: The index of the city to save.
    static func saveLastCityIndex(index: Int) {
        UserDefaults.standard.set(index, forKey: lastCityIndexKey)
    }
    
    /// Retrieves the index of the last viewed city.
    /// - Returns: The index of the last viewed city, or `nil` if not found.
    static func getLastCityIndex() -> Int? {
        UserDefaults.standard.object(forKey: lastCityIndexKey) as? Int
    }
}
