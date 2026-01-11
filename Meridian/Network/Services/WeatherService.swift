import Foundation

/// Defines the contract for a service that fetches weather data.
/// This protocol allows for interchangeable mock and real network services.
protocol WeatherService {

    /// Fetches weather data for a given latitude and longitude.
    /// - Parameters:
    ///   - latitude: The latitude.
    ///   - longitude: The longitude.
    /// - Returns: A `WeatherModel` containing the processed weather data.
    /// - Throws: An error if the data fetching fails.
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel
}
