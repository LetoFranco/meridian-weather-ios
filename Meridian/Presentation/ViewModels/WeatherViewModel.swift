import Foundation
import Combine

@MainActor
final class WeatherViewModel: ObservableObject {
    // MARK: - State Management
    enum ViewState {
        case loading
        case success([WeatherModel])
        case error(String)
    }
    
    @Published var viewState: ViewState = .loading
    
    // MARK: - Dependencies
    private let weatherService: WeatherServiceProtocol
    
    // MARK: - Properties
    private let cities = ["London", "Montevideo", "Buenos Aires"]
    // TODO: Add logic for current location
    
    init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
    }

    // MARK: - Functions
    func loadWeatherData() {
        self.viewState = .loading
        
        Task {
            do {
                let weatherData = try await fetchWeatherForAllCities()
                self.viewState = .success(weatherData)
            } catch {
                self.viewState = .error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private Functions
    private func fetchWeatherForAllCities() async throws -> [WeatherModel] {
        try await withThrowingTaskGroup(of: WeatherModel.self) { group in
            var results = [WeatherModel]()
            
            // TODO: Add Current Location fetch
            
            for city in cities {
                group.addTask {
                    try await self.weatherService.fetchWeather(for: city)
                }
            }
            
            for try await weatherModel in group {
                results.append(weatherModel)
            }

            return results
        }
    }
}
