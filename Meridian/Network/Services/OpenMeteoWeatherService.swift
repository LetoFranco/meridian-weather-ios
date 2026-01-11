import Foundation
import CoreLocation

// MARK: - OpenMeteoWeatherService
/// An implementation of `WeatherService` that fetches weather data from Open-Meteo API.
final class OpenMeteoWeatherService: WeatherService {
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    private let urlSession: URLSession
    private let geocodingService: GeocodingService
    
    init(urlSession: URLSession = .shared, geocodingService: GeocodingService) {
        self.urlSession = urlSession
        self.geocodingService = geocodingService
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        var finalCityName = String()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        if let geocodedName = try? await geocodingService.reverseGeocode(location: location) {
            finalCityName = geocodedName
        } else {
            finalCityName = "Unknown Location"
        }
        
        guard var urlComponents = URLComponents(string: baseURL) else { throw WeatherServiceError.invalidURL }

        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "current", value: "temperature_2m,weather_code,is_day"),
            URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "1")
        ]
        
        guard let url = urlComponents.url else {
            throw WeatherServiceError.invalidURL
        }
        
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw WeatherServiceError.invalidServerResponse
        }
        
        let openMeteoResponse = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        
        return WeatherMapper.map(dto: openMeteoResponse, cityName: finalCityName)
    }
}

// MARK: - WeatherServiceError
enum WeatherServiceError: Error, LocalizedError {
    case invalidURL
    case invalidServerResponse
    case decodingError(Error)
    case cityNameNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL for the weather service was invalid."
        case .invalidServerResponse: return "The server returned an invalid response."
        case .decodingError(let error): return "Failed to decode weather data: \(error.localizedDescription)"
        case .cityNameNotFound: return "Could not find coordinates for the specified city name."
        }
    }
}
