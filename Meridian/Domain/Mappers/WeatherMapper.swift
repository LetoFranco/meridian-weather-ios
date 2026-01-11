import Foundation

// MARK: - WeatherMapper
/// A utility to map data from the network DTO to a domain-specific model.
enum WeatherMapper {
    
    /// Converts a DTO object into a `WeatherModel` for UI consumption.
    /// - Parameter dto: The `OpenWeatherDTO` received from the network layer.
    /// - Returns: A `WeatherModel` with processed and formatted data.
    static func map(dto: OpenWeatherDTO) -> WeatherModel {
        
        // Determine if it's daytime based on current time vs sunrise/sunset
        let now = Date()
        let sunrise = Date(timeIntervalSince1970: dto.sys.sunrise)
        let sunset = Date(timeIntervalSince1970: dto.sys.sunset)
        let isDayTime = (now > sunrise && now < sunset)

        /// TODO: Needs to be reviewed
        let iconURL = URL(string: "https://openweathermap.org/img/wn/\(dto.weather.first?.icon ?? "")@2x.png")
        
        return WeatherModel(
            cityName: dto.name,
            description: (dto.weather.first?.description ?? "No description").capitalized,
            iconURL: iconURL,
            currentTemperature: format(temperature: dto.main.temp),
            minTemperature: "L: \(format(temperature: dto.main.tempMin))",
            maxTemperature: "H: \(format(temperature: dto.main.tempMax))",
            isDayTime: isDayTime
        )
    }
    
    /// Converts a temperature from Kelvin (Double) to a formatted Celsius string.
    /// - Parameter kelvin: The temperature in Kelvin.
    /// - Returns: A string representing the temperature in Celsius, e.g., "10°".
    private static func format(temperature kelvin: Double) -> String {
        let celsius = kelvin - 273.15
        return String(format: "%.0f°", celsius)
    }
}
