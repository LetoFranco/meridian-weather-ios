import Foundation

// MARK: - OpenMeteoResponse (DTO)
/// Represents the root JSON response from the Open-Meteo API.
struct OpenMeteoResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let current: CurrentWeatherResponse
    let daily: DailyWeatherResponse
}

// MARK: - CurrentWeatherResponse (DTO)
/// Represents the current weather data from Open-Meteo.
struct CurrentWeatherResponse: Decodable {
    let temperature2m: Double
    let weatherCode: Int
    let isDay: Int // 0 = night, 1 = day
    
    enum CodingKeys: String, CodingKey {
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
        case isDay = "is_day"
    }
}

// MARK: - DailyWeatherResponse (DTO)
/// Represents the daily weather data from Open-Meteo.
struct DailyWeatherResponse: Decodable {
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    
    enum CodingKeys: String, CodingKey {
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
    }
}

// MARK: - WeatherModel (Domain Model)
/// Represents the processed weather data ready for display in the UI.
/// This is a domain-specific model, independent of any single data provider.
struct WeatherModel: Identifiable {
    var id: String { cityID }
    let cityID: String
    
    let cityName: String
    let description: String
    let iconUrl: String?
    let iconName: String
    
    let currentTemperature: String
    let minTemperature: String
    let maxTemperature: String
    
    let isDayTime: Bool
}

// MARK: - WeatherCode Extension
extension Int {
    /// Converts an Open-Meteo weather code to an SF Symbol name.
    func toSFSymbol(isDay: Bool) -> String {
        let baseSymbol: String
        
        switch self {
        case 0: baseSymbol = "sun.max"
        case 1...3: baseSymbol = "cloud.sun"
        case 45, 48: baseSymbol = "cloud.fog"
        case 51...67: baseSymbol = "cloud.rain"
        case 71...77: baseSymbol = "cloud.snow"
        case 95...99: baseSymbol = "cloud.bolt.rain"
        default: return "questionmark.circle"
        }
        
        if !isDay && (baseSymbol.contains("sun") || baseSymbol.contains("clear")) {
            return baseSymbol.replacingOccurrences(of: "sun", with: "moon") + ".fill"
        }
        
        return baseSymbol + ".fill"
    }
}
