//
//  MeridianApp.swift
//  Meridian
//
//  Created by Franco Ezequiel Leto on 10/01/2026.
//

import CoreLocation
import SwiftUI

@main
struct MeridianApp: App {
    @StateObject private var locationManager = LocationManager()
    private let loggerService: LoggerService
    private let weatherService: WeatherService
    private let persistenceService: PersistenceService

    init() {
        let logger = ConsoleLoggerService()
        let geocodingService = CLGeocodingService(geocoder: CLGeocoder(), logger: logger)
        self.loggerService = logger
        self.weatherService = OpenMeteoWeatherService(geocodingService: geocodingService, logger: logger)
        self.persistenceService = UserDefaultsPersistenceService()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: WeatherViewModel(
                weatherService: weatherService,
                persistenceService: persistenceService,
                locationManager: locationManager,
                logger: loggerService
            ))
        }
    }
}
