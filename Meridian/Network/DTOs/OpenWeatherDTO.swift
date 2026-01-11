import Foundation

// MARK: - OpenWeatherDTO

/// Represents the top-level JSON response from the OpenWeatherMap API.
struct OpenWeatherDTO: Decodable {
    let coord: CoordDTO
    let weather: [WeatherInfoDTO]
    let main: MainInfoDTO
    let sys: SysInfoDTO
    let name: String
}

// MARK: - CoordDTO

/// Represents the geographical coordinates.
struct CoordDTO: Decodable {
    let lon: Double
    let lat: Double
}

// MARK: - WeatherInfoDTO
/// Represents the description of the weather conditions.
struct WeatherInfoDTO: Decodable {
    let main: String
    let description: String
    let icon: String
}

// MARK: - MainInfoDTO
/// Represents the main weather data like temperature.
struct MainInfoDTO: Decodable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

// MARK: - SysInfoDTO
/// Represents system data like sunrise and sunset times.
struct SysInfoDTO: Decodable {
    let sunrise: TimeInterval
    let sunset: TimeInterval
}
