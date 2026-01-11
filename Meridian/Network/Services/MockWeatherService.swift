import Foundation

// MARK: - MockWeatherService
/// A mock implementation of `WeatherServiceProtocol` for development and testing.
final class MockWeatherService: WeatherServiceProtocol {
    
    func fetchWeather(for city: String) async throws -> WeatherModel {
        try await Task.sleep(nanoseconds: .sleepDefaultDuration)
        let dummyDTO = createDummyDTO(for: city)

        return WeatherMapper.map(dto: dummyDTO)
    }
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        try await Task.sleep(nanoseconds: .sleepDefaultDuration)
        let dummyDTO = createDummyDTO(for: "Current Location")

        return WeatherMapper.map(dto: dummyDTO)
    }
    
    /// Creates a sample `OpenWeatherDTO` for a given city name.
    private func createDummyDTO(for city: String) -> OpenWeatherDTO {
        let weather: WeatherInfoDTO
        let main: MainInfoDTO
        
        switch city {
        case "London":
            weather = WeatherInfoDTO(main: "Clouds", description: "scattered clouds", icon: "03d")
            main = MainInfoDTO(temp: 285.3, tempMin: 283.15, tempMax: 287.15)
        case "Montevideo":
            weather = WeatherInfoDTO(main: "Clear", description: "clear sky", icon: "01n")
            main = MainInfoDTO(temp: 294.15, tempMin: 292.15, tempMax: 296.15)
        case "Buenos Aires":
            weather = WeatherInfoDTO(main: "Rain", description: "light rain", icon: "10d")
            main = MainInfoDTO(temp: 298.15, tempMin: 296.15, tempMax: 300.15)
        default: // Current Location
            weather = WeatherInfoDTO(main: "Sunny", description: "very sunny", icon: "01d")
            main = MainInfoDTO(temp: 300.15, tempMin: 298.15, tempMax: 302.15)
        }
        
        return OpenWeatherDTO(
            coord: CoordDTO(lon: 0, lat: 0),
            weather: [weather],
            main: main,
            sys: SysInfoDTO(sunrise: 1661834187, sunset: 1661882248),
            name: city
        )
    }
}
