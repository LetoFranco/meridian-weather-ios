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
    private let geocodingService: GeocodingService
    private let weatherService: WeatherService
    private let persistenceService: PersistenceService
    private let trackerService: TrackerService

    init() {
        let logger = ConsoleLoggerService()
        let geocodingService = CLGeocodingService(logger: logger)
        let weatherService = OpenMeteoWeatherService(geocodingService: geocodingService, logger: logger)
        let persistenceService = UserDefaultsPersistenceService()
        let trackerService = AnalyticsTrackerService(logger: logger)
        
        self.loggerService = logger
        self.geocodingService = geocodingService
        self.weatherService = weatherService
        self.persistenceService = persistenceService
        self.trackerService = trackerService
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: WeatherViewModel(
                weatherService: weatherService,
                persistenceService: persistenceService,
                locationManager: locationManager,
                logger: loggerService,
                trackerService: trackerService
            ))
        }
    }
}
