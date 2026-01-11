import Foundation

// MARK: - MockWeatherService
/// A mock implementation of `WeatherService` for development and testing.
final class MockWeatherService: WeatherService {
    private let predefinedFixedCities = CityCoordinates.predefinedCities
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        try await Task.sleep(nanoseconds: .sleepDefaultDuration)
        
        var simulatedCityName: String?
        for cityCoord in predefinedFixedCities {
            let epsilon = 0.005
            if abs(cityCoord.latitude - latitude) < epsilon && abs(cityCoord.longitude - longitude) < epsilon {
                simulatedCityName = cityCoord.name
                break
            }
        }
        
        let finalCityName = simulatedCityName ?? "Uknown Location"

        return createDummyWeatherModel(for: finalCityName)
    }
    
    /// Creates a sample `WeatherModel` for a given city name.
    private func createDummyWeatherModel(for city: String) -> WeatherModel {
        let (description, iconName, currentTemp, minTemp, maxTemp, isDay) = mockData(for: city)
        
        return WeatherModel(
            cityID: city.lowercased().replacingOccurrences(of: " ", with: "_"),
            cityName: city,
            description: description,
            iconUrl: nil,
            iconName: iconName,
            currentTemperature: String(format: "%.0f°", currentTemp),
            minTemperature: String(format: "L: %.0f°", minTemp),
            maxTemperature: String(format: "H: %.0f°", maxTemp),
            isDayTime: isDay
        )
    }
    
    private func mockData(for city: String) -> (String, String, Double, Double, Double, Bool) {
        switch city {
        case "London":
            return ("Scattered Clouds", "cloud.sun.fill", 12, 8, 14, false)
        case "Montevideo":
            return ("Clear Sky", "sun.max.fill", 25, 20, 28, true)
        case "Buenos Aires":
            return ("Light Rain", "cloud.rain.fill", 22, 18, 25, true)
        default:
            return ("Sunny", "sun.max.fill", 28, 24, 32, true)
        }
    }
}
