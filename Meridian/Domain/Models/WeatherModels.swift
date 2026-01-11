import Foundation

// MARK: - WeatherModel
/// Represents the processed weather data ready for display in the UI.
/// This is a domain-specific model, independent of any single data provider.
struct WeatherModel: Identifiable {
    var id: String { cityID }
    let cityID: String
    
    let cityName: String
    let description: String
    let iconURL: URL?
    
    let currentTemperature: String
    let minTemperature: String
    let maxTemperature: String
    
    let isDayTime: Bool
}
