import Foundation

// MARK: - PersistenceService
/// Defines the contract for a service that persists user preferences.
protocol PersistenceService {
    /// Saves the ID of the last viewed city.
    /// - Parameter cityID: The stable ID of the city to save.
    func saveLastSelected(cityID: String)
    
    /// Retrieves the ID of the last viewed city.
    /// - Returns: The ID of the last viewed city, or `nil` if not found.
    func getLastSelectedCityID() -> String?
}

// MARK: - UserDefaultsPersistenceService
/// The default implementation of `PersistenceService` using `UserDefaults`.
final class UserDefaultsPersistenceService: PersistenceService {
    private let userDefaults: UserDefaults
    
    private let lastCityIDKey = "lastCityID"
    
    /// Initializes the service with a `UserDefaults` instance.
    /// - Parameter userDefaults: The `UserDefaults` instance to use for persistence. Defaults to `.standard`.
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveLastSelected(cityID: String) {
        userDefaults.set(cityID, forKey: lastCityIDKey)
    }
    
    func getLastSelectedCityID() -> String? {
        userDefaults.string(forKey: lastCityIDKey)
    }
}
