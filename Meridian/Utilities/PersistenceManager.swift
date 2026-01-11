
import Foundation

// MARK: - PersistenceManager
/// Manages the persistence of user preferences, such as the last viewed city ID.
enum PersistenceManager {
    private static let lastCityIDKey = "lastCityID"
    
    /// Saves the ID of the last viewed city.
    /// - Parameter cityID: The stable ID of the city to save.
    static func saveLastSelected(cityID: String) {
        UserDefaults.standard.set(cityID, forKey: lastCityIDKey)
    }
    
    /// Retrieves the ID of the last viewed city.
    /// - Returns: The ID of the last viewed city, or `nil` if not found.
    static func getLastSelectedCityID() -> String? {
        UserDefaults.standard.string(forKey: lastCityIDKey)
    }
}
