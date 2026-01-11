import Foundation

// MARK: - WeatherMapper
/// A utility to map data from the network DTO to a domain-specific model.
enum WeatherMapper {
    
    /// Converts an `OpenMeteoResponse` DTO object into a `WeatherModel` for UI consumption.
    /// - Parameters:
    ///   - dto: The `OpenMeteoResponse` received from the network layer.
    ///   - cityName: The name of the city, obtained via geocoding or predefined.
    /// - Returns: A `WeatherModel` with processed and formatted data.
    static func map(dto: OpenMeteoResponse, cityName: String) -> WeatherModel {
        
        let currentTemp = dto.current.temperature2m
        let minTemp = dto.daily.temperature2mMin.first ?? currentTemp
        let maxTemp = dto.daily.temperature2mMax.first ?? currentTemp
        let weatherCode = dto.current.weatherCode
        let isDay = dto.current.isDay == 1
        
        return WeatherModel(
            cityID: cityName.lowercased().replacingOccurrences(of: " ", with: "_"),
            cityName: cityName,
            description: "Weather Code \(weatherCode)",
            iconUrl: nil,
            iconName: weatherCode.toSFSymbol(isDay: isDay),
            currentTemperature: String(format: "%.0f°", currentTemp),
            minTemperature: String(format: "L: %.0f°", minTemp),
            maxTemperature: String(format: "H: %.0f°", maxTemp),
            isDayTime: isDay
        )
    }
    
    /// Converts an `OpenWeatherResponse` DTO object into a `WeatherModel` for UI consumption.
    /// - Parameter dto: The `OpenWeatherResponse` received from the network layer.
    /// - Returns: A `WeatherModel` with processed and formatted data.
    static func map(dto: OpenWeatherDTO) -> WeatherModel {
        let currentTemp = dto.main.temp
        let minTemp = dto.main.tempMin
        let maxTemp = dto.main.tempMax
        let weatherDescription = dto.weather.first?.description ?? "No description"
        let iconCode = dto.weather.first?.icon ?? ""
        let isDay = (Date().timeIntervalSince1970 > dto.sys.sunrise && Date().timeIntervalSince1970 < dto.sys.sunset)
        
        let iconURL = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"

        let genericSFSymbol: String
        switch iconCode {
        case "01d", "01n": genericSFSymbol = isDay ? "sun.max.fill" : "moon.stars.fill"
        case "02d", "02n": genericSFSymbol = isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case "03d", "03n": genericSFSymbol = "cloud.fill"
        case "04d", "04n": genericSFSymbol = "smoke.fill"
        case "09d", "09n": genericSFSymbol = "cloud.drizzle.fill"
        case "10d", "10n": genericSFSymbol = isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case "11d", "11n": genericSFSymbol = "cloud.bolt.fill"
        case "13d", "13n": genericSFSymbol = "cloud.snow.fill"
        case "50d", "50n": genericSFSymbol = "cloud.fog.fill"
        default: genericSFSymbol = "questionmark.circle.fill"
        }
        
        return WeatherModel(
            cityID: dto.name.lowercased().replacingOccurrences(of: " ", with: "_"),
            cityName: dto.name,
            description: weatherDescription.capitalized,
            iconUrl: iconURL,
            iconName: genericSFSymbol,
            currentTemperature: String(format: "%.0f°", convertKelvinToCelsius(kelvin: currentTemp)),
            minTemperature: String(format: "L: %.0f°", convertKelvinToCelsius(kelvin: minTemp)),
            maxTemperature: String(format: "H: %.0f°", convertKelvinToCelsius(kelvin: maxTemp)),
            isDayTime: isDay
        )
    }
    
    private static func convertKelvinToCelsius(kelvin: Double) -> Double {
        kelvin - 273.15
    }
}
