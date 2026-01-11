import Foundation
import CoreLocation

// MARK: - OpenMeteoWeatherService
/// An implementation of `WeatherService` that fetches weather data from Open-Meteo API.
final class OpenMeteoWeatherService: WeatherService {
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    private let urlSession: URLSession
    private let geocodingService: GeocodingService
    private let logger: LoggerService
    
    init(urlSession: URLSession = .shared, geocodingService: GeocodingService, logger: LoggerService) {
        self.urlSession = urlSession
        self.geocodingService = geocodingService
        self.logger = logger
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        var finalCityName = "Unknown Location"
        let location = CLLocation(latitude: latitude, longitude: longitude)
        logger.debug("Starting geocoding for \(latitude), \(longitude)")
        do {
            if let geocodedName = try await geocodingService.reverseGeocode(location: location) {
                finalCityName = geocodedName
                print("OpenMeteoWeatherService: Geocoding successful for \(latitude), \(longitude): \(finalCityName)")
            } else {
                logger.warning("Geocoding returned nil for location \(latitude), \(longitude). Falling back to 'Unknown Location'.")
            }
        } catch {
            logger.error("Geocoding failed for location \(latitude), \(longitude) with error: \(error.localizedDescription). Falling back to 'Unknown Location'.")
        }
        
        guard var urlComponents = URLComponents(string: baseURL) else {
            logger.error("Invalid base URL: \(baseURL)")
            throw WeatherServiceError.invalidURL
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "current", value: "temperature_2m,weather_code,is_day"),
            URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "1")
        ]
        
        guard let url = urlComponents.url else {
            logger.error("Failed to construct URL from components: \(urlComponents)")
            throw WeatherServiceError.invalidURL
        }
        
        logger.debug("Fetching from URL: \(url)")
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Invalid response type: \(response)")
            throw WeatherServiceError.invalidServerResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            logger.error("Server returned status code: \(httpResponse.statusCode)")
            throw WeatherServiceError.invalidServerResponse
        }
        
        do {
            let openMeteoResponse = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            logger.debug("Successfully decoded response for \(finalCityName).")
            return WeatherMapper.map(dto: openMeteoResponse, cityName: finalCityName)
        } catch {
            logger.error("Decoding error: \(error.localizedDescription). Data: \(String(data: data, encoding: .utf8) ?? "N/A")")
            throw WeatherServiceError.decodingError(error)
        }
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
