import Foundation
import Combine
import CoreLocation

@MainActor
final class WeatherViewModel: ObservableObject {
    
    // MARK: - State Management
    
    /// State for the fixed cities weather data.
    enum ViewState {
        case loading
        case success([WeatherModel])
        case error(String)
    }
    
    /// State for the user's current location weather.
    enum CurrentLocationState {
        case idle
        case loading
        case success(WeatherModel)
        case denied
        case error(String)
    }
    
    @Published var viewState: ViewState = .loading
    @Published var currentLocationState: CurrentLocationState = .idle
    
    // MARK: - Dependencies
    private let weatherService: WeatherServiceProtocol
    let locationManager: LocationManager
    
    // MARK: - Properties
    private let cityNames = ["London", "Montevideo", "Buenos Aires"]
    private var cancellables = Set<AnyCancellable>()

    init(weatherService: WeatherServiceProtocol, locationManager: LocationManager) {
        self.weatherService = weatherService
        self.locationManager = locationManager
        
        setupBindings()
    }
    
    // MARK: - Public API
    
    /// Loads weather data for the fixed list of cities.
    func loadFixedCityData() {
        self.viewState = .loading
        
        Task {
            do {
                let weatherData = try await fetchWeatherForFixedCities()
                self.viewState = .success(weatherData)
            } catch {
                self.viewState = .error(error.localizedDescription)
            }
        }
    }
    
    /// Initiates the process of getting the user's current location weather.
    func requestCurrentLocation() {
        locationManager.requestLocationAuthorization()
    }
    
    // MARK: - Private Setup and Helpers
    
    private func setupBindings() {
        locationManager.$authorizationStatus
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    self.currentLocationState = .loading
                    self.locationManager.startUpdatingLocation()
                case .denied, .restricted:
                    self.currentLocationState = .denied
                case .notDetermined:
                    self.currentLocationState = .idle
                default:
                    self.currentLocationState = .idle
                }
            }
            .store(in: &cancellables)

        locationManager.$currentLocation
            .compactMap { $0 }
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] location in
                self?.fetchWeather(for: location)
            }
            .store(in: &cancellables)
    }
    
    private func fetchWeatherForFixedCities() async throws -> [WeatherModel] {
        try await withThrowingTaskGroup(of: WeatherModel.self) { group in
            var results = [WeatherModel]()
            for city in cityNames {
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
    
    private func fetchWeather(for location: CLLocation) {
        if case .success = currentLocationState { return }
        
        self.currentLocationState = .loading
        Task {
            do {
                let weather = try await weatherService.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                self.currentLocationState = .success(weather)
            } catch {
                self.currentLocationState = .error(error.localizedDescription)
            }
        }
    }
}
