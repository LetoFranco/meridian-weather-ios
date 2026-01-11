import XCTest
import Combine
import CoreLocation
@testable import Meridian

@MainActor
final class WeatherViewModelTests: XCTestCase {

    var sut: WeatherViewModel!
    var mockWeatherService: MockWeatherService!
    var mockPersistenceService: MockPersistenceService!
    var mockLocationManager: MockLocationManager!
    var mockLoggerService: MockLoggerService!
    var mockTrackerService: MockTrackerService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() async throws {
        mockWeatherService = MockWeatherService()
        mockPersistenceService = MockPersistenceService()
        mockLocationManager = MockLocationManager()
        mockLoggerService = MockLoggerService()
        mockTrackerService = MockTrackerService()
        
        sut = WeatherViewModel(
            weatherService: mockWeatherService,
            persistenceService: mockPersistenceService,
            locationManager: mockLocationManager,
            logger: mockLoggerService,
            trackerService: mockTrackerService
        )
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() async throws {
        cancellables.removeAll()
        sut = nil
        await Task.yield()
        mockWeatherService = nil
        mockPersistenceService = nil
        mockLocationManager = nil
        mockLoggerService = nil
        mockTrackerService = nil
        cancellables = nil

        try await super.tearDown()
    }

    // MARK: - Fixed City Data Loading Tests
    
    func testLoadFixedCityData_Failure() async throws {
        let expectedError = WeatherServiceError.invalidServerResponse
        mockWeatherService.shouldThrowError = true

        let expectation = XCTestExpectation(description: "viewState becomes error")
        sut.$viewState
            .dropFirst()
            .sink { state in
                if case .error(let message) = state {
                    XCTAssertEqual(message, expectedError.localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadFixedCityData()

        await fulfillment(of: [expectation], timeout: 1.0)
        if case .error(let message) = sut.viewState {
            XCTAssertEqual(message, expectedError.localizedDescription)
        } else {
            XCTFail("Expected viewState to be in .error state, but was \(sut.viewState)")
        }
    }

    // MARK: - Tab Persistence and Tracking Tests
    
    func testInitialTabSelection_NoSavedID() async throws {
        // Given
        mockPersistenceService.savedCityID = nil // No saved ID
        mockWeatherService.mockFixedCityWeatherModels = [
            WeatherModel(cityID: "london", cityName: "London", description: "Cloudy", iconUrl: nil, iconName: "cloud.sun.fill", currentTemperature: "10°", minTemperature: "8°", maxTemperature: "12°", isDayTime: true)
        ]
        
        let expectation = XCTestExpectation(description: "Initial tab set to current location")
        sut.$selectedTab
            .sink { tab in // No dropFirst()
                XCTAssertEqual(tab, 0) // Expect 0 for "Current Location"
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.loadFixedCityData()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testInitialTabSelection_WithSavedID() async throws {
        // Given
        mockPersistenceService.savedCityID = "montevideo"
        mockWeatherService.mockFixedCityWeatherModels = [
            WeatherModel(cityID: "london", cityName: "London", description: "Cloudy", iconUrl: nil, iconName: "cloud.sun.fill", currentTemperature: "10°", minTemperature: "8°", maxTemperature: "12°", isDayTime: true),
            WeatherModel(cityID: "montevideo", cityName: "Montevideo", description: "Sunny", iconUrl: nil, iconName: "sun.max.fill", currentTemperature: "25°", minTemperature: "20°", maxTemperature: "28°", isDayTime: true),
            WeatherModel(cityID: "buenos_aires", cityName: "Buenos Aires", description: "Rainy", iconUrl: nil, iconName: "cloud.rain.fill", currentTemperature: "18°", minTemperature: "15°", maxTemperature: "20°", isDayTime: true)
        ]
        
        let expectation = XCTestExpectation(description: "Initial tab set to saved city")
        sut.$selectedTab
            .dropFirst()
            .sink { tab in
                XCTAssertEqual(tab, 2) // "Montevideo" is at index 2 (after Current Location and London)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.loadFixedCityData()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertTrue(mockTrackerService.trackedPageViews.contains("montevideo"))
    }
    
    // MARK: - Current Location Tests
    
    func testRequestCurrentLocation_AuthorizationGranted() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Current location weather fetched")
        mockLocationManager.simulateAuthorizationStatus(status: .authorizedWhenInUse)
        mockLocationManager.simulateLocationUpdate(location: CLLocation(latitude: 1.0, longitude: 2.0))
        mockWeatherService.mockCurrentLocationWeatherModel = WeatherModel(cityID: "test_city", cityName: "Test City", description: "Clear", iconUrl: nil, iconName: "sun.max.fill", currentTemperature: "20°", minTemperature: "15°", maxTemperature: "25°", isDayTime: true)
        
        sut.$currentLocationState
            .dropFirst() // Ignore initial .idle
            .sink { state in
                if case .success(let model) = state {
                    XCTAssertEqual(model.cityName, "Test City")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        sut.requestCurrentLocation()
        
        // Then
        XCTAssertTrue(mockLocationManager.requestLocationAuthorizationCalled)
        XCTAssertTrue(mockLocationManager.startUpdatingLocationCalled)
        await fulfillment(of: [expectation], timeout: 2.0) // Increased timeout for async operations
    }
}

// MARK: - Mock Weather Service (for specific weather models)
final class MockWeatherService: WeatherService {
    var mockFixedCityWeatherModels: [WeatherModel] = []
    var mockCurrentLocationWeatherModel: WeatherModel?
    var shouldThrowError = false
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        if shouldThrowError {
            throw WeatherServiceError.invalidServerResponse
        }
        
        // Basic logic to return specific mock for specific coordinates
        let epsilon = 0.001
        if abs(latitude - 51.5074) < epsilon && abs(longitude + 0.1278) < epsilon { // London
            return try findWeather(ofCityId: "london")
        } else if abs(latitude + 34.9011) < epsilon && abs(longitude + 56.1645) < epsilon { // Montevideo
            return try findWeather(ofCityId: "montevideo")
        } else if abs(latitude + 34.6037) < epsilon && abs(longitude + 58.3816) < epsilon { // Buenos Aires
            return try findWeather(ofCityId: "buenos_aires")
        } else if latitude == 1.0 && longitude == 2.0 { // Generic mock for currentLocation
            if let mockCurrentLocationWeatherModel {
                return mockCurrentLocationWeatherModel
            }
            throw WeatherServiceError.cityNameNotFound
        } else {
            if let model = mockFixedCityWeatherModels.first {
                return model
            }
            throw WeatherServiceError.cityNameNotFound
        }
    }

    private func findWeather(ofCityId cityId: String) throws -> WeatherModel {
        guard
            let weatherModel = mockFixedCityWeatherModels.first(where: { $0.cityID == cityId })
        else { throw WeatherServiceError.cityNameNotFound }

        return weatherModel
    }
}
