import Foundation
import Combine
import CoreLocation

@MainActor
final class WeatherViewModel: ObservableObject {
    // MARK: - State Management
    enum ViewState {
        case loading
        case success([WeatherModel])
        case error(String)

        var isLoading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }
    }
    
    @Published var viewState: ViewState = .loading
    
    // MARK: - Dependencies
    private let weatherService: WeatherServiceProtocol
    private let locationManager: LocationManager
    
    // MARK: - Properties
    private var cityNames = ["London", "Montevideo", "Buenos Aires"]
    private var cancellables = Set<AnyCancellable>()
    private var fetchedFixedCityWeather: [WeatherModel] = []
    private var fetchedCurrentLocationWeather: WeatherModel? = nil

    var locationPermissionAreDenied: Bool {
        locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted
    }

    init(
        weatherService: WeatherServiceProtocol,
        locationManager: LocationManager
    ) {
        self.weatherService = weatherService
        self.locationManager = locationManager

        self.locationManager.$currentLocation
            .sink { [weak self] location in
                self?.handleLocationUpdate(location)
            }
            .store(in: &cancellables)

        self.locationManager.$authorizationStatus
            .sink { [weak self] status in
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self?.locationManager.startUpdatingLocation()
                } else if status == .denied || status == .restricted {
                    self?.fetchedCurrentLocationWeather = nil
                    self?.loadWeatherData()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Functions
    func loadWeatherData() {
        self.viewState = .loading

        locationManager.requestLocationAuthorization()
        
        Task {
            do {
                fetchedFixedCityWeather = try await fetchWeatherForFixedCities()

                if let location = locationManager.currentLocation,
                   (locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways) {
                    fetchedCurrentLocationWeather = try await weatherService.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                } else {
                    fetchedCurrentLocationWeather = nil
                }
                
                updateViewState()
            } catch {
                self.viewState = .error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private Functions
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
    
    private func handleLocationUpdate(_ location: CLLocation?) {
        guard let location = location,
              (locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways) else {

            if fetchedCurrentLocationWeather != nil {
                fetchedCurrentLocationWeather = nil
                updateViewState()
            }
            return
        }

        Task {
            do {
                let newWeather = try await weatherService.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                if newWeather.cityName != fetchedCurrentLocationWeather?.cityName || newWeather.currentTemperature != fetchedCurrentLocationWeather?.currentTemperature {
                    fetchedCurrentLocationWeather = newWeather
                    updateViewState()
                }
            } catch {
                print("Failed to fetch weather for current location: \(error.localizedDescription)")
                if fetchedCurrentLocationWeather != nil {
                    fetchedCurrentLocationWeather = nil
                    updateViewState()
                }
            }
        }
    }
    
    private func updateViewState() {
        var allWeatherModels = [WeatherModel]()
        if let currentWeather = fetchedCurrentLocationWeather {
            allWeatherModels.append(currentWeather)
        }
        allWeatherModels.append(contentsOf: fetchedFixedCityWeather)
        
        if allWeatherModels.isEmpty && !viewState.isLoading {
            self.viewState = .error("No weather data available. Please check permissions or try again.")
        } else if !allWeatherModels.isEmpty {
            self.viewState = .success(allWeatherModels)
        }
    }
}
