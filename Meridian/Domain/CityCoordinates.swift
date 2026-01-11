import Foundation
import CoreLocation

// MARK: - CityCoordinates
/// Represents the geographical coordinates and name for a fixed city.
struct CityCoordinates {
    let name: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    
    /// A static array of predefined city coordinates.
    static let predefinedCities: [CityCoordinates] = [
        CityCoordinates(name: "London", latitude: 51.5074, longitude: -0.1278),
        CityCoordinates(name: "Montevideo", latitude: -34.9011, longitude: -56.1645),
        CityCoordinates(name: "Buenos Aires", latitude: -34.6037, longitude: -58.3816)
    ]
}
