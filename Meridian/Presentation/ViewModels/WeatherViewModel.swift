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
    }
    
    enum CurrentLocationState {
        case idle
        case loading
        case success(WeatherModel)
        case denied
        case error(String)
    }
    
    @Published var viewState: ViewState = .loading
    @Published var currentLocationState: CurrentLocationState = .idle
    @Published var selectedTab: Int = 0
    
    // MARK: - Dependencies
    private let weatherService: WeatherService
    private let persistenceService: PersistenceService
    let locationManager: LocationManager
    private let logger: LoggerService
    
    // MARK: - Properties
    private let predefinedFixedCities = CityCoordinates.predefinedCities
    private let currentLocationTabID = "__current_location__"
    private var cancellables = Set<AnyCancellable>()

    init(
        weatherService: WeatherService,
        persistenceService: PersistenceService,
        locationManager: LocationManager,
        logger: LoggerService
    ) {
        self.weatherService = weatherService
        self.persistenceService = persistenceService
        self.locationManager = locationManager
        self.logger = logger
        
        setupBindings()
    }
    
    // MARK: - Public API
    func loadFixedCityData() {
        logger.info("Starting loadFixedCityData()")
        self.viewState = .loading
        
        Task {
            do {
                let weatherData = try await fetchWeatherForFixedCities()
                logger.info("Successfully fetched fixed city data.")
                self.viewState = .success(weatherData)
                restoreLastSelectedTab(fixedCityModels: weatherData)
            } catch {
                logger.error("Failed to fetch fixed city data with error: \(error.localizedDescription)")
                self.viewState = .error(error.localizedDescription)
            }
        }
    }
    
    func requestCurrentLocation() {
        locationManager.requestLocationAuthorization()
    }
    
    // MARK: - Private Setup and Helpers
    private func setupBindings() {
        $selectedTab
            .dropFirst()
            .sink { [weak self] newIndex in
                self?.saveSelectedTab(index: newIndex)
            }
            .store(in: &cancellables)

        locationManager.$authorizationStatus
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    self.currentLocationState = .loading
                    self.locationManager.startUpdatingLocation()
                case .denied, .restricted:
                    self.currentLocationState = .denied
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
        logger.info("Starting fetchWeatherForFixedCities() concurrently for \(predefinedFixedCities.count) cities.")
        return try await withThrowingTaskGroup(of: (Int, WeatherModel).self) { [weak self] group in
            guard let self else { throw CancellationError() }

            var results: [(Int, WeatherModel)] = []
            for (index, cityCoord) in self.predefinedFixedCities.enumerated() {
                group.addTask { [weak self] in
                    guard let self else { throw CancellationError() }

                    await self.logger.debug("Adding task for \(cityCoord.name) (\(cityCoord.latitude), \(cityCoord.longitude))")
                    let weatherModel = try await self.weatherService.fetchWeather(latitude: cityCoord.latitude, longitude: cityCoord.longitude)
                    await self.logger.debug("Task for \(cityCoord.name) completed.")
                    return (index, weatherModel)
                }
            }
            for try await (index, weatherModel) in group {
                results.append((index, weatherModel))
            }
            results.sort { $0.0 < $1.0 }
            logger.info("All fixed city weather fetched and sorted.")
            return results.map { $0.1 }
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
    
    private func restoreLastSelectedTab(fixedCityModels: [WeatherModel]) {
        let lastID = persistenceService.getLastSelectedCityID() ?? currentLocationTabID
        
        var allTabIDs = [currentLocationTabID]
        allTabIDs.append(contentsOf: fixedCityModels.map { $0.cityID })
        
        if let savedIndex = allTabIDs.firstIndex(of: lastID) {
            self.selectedTab = savedIndex
        }
    }
    
    private func saveSelectedTab(index: Int) {
        guard case .success(let models) = viewState else { return }
        
        var allTabIDs = [currentLocationTabID]
        allTabIDs.append(contentsOf: models.map { $0.cityID })
        
        if allTabIDs.indices.contains(index) {
            let idToSave = allTabIDs[index]
            persistenceService.saveLastSelected(cityID: idToSave)
        }
    }
}
