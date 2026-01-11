//
//  MeridianApp.swift
//  Meridian
//
//  Created by Franco Ezequiel Leto on 10/01/2026.
//

import SwiftUI

@main
struct MeridianApp: App {
    @StateObject private var locationManager = LocationManager()
    private let geocodingService: GeocodingService = CLGeocodingService()
    private let weatherService: WeatherService = MockWeatherService()
    // private let weatherService: WeatherService = OpenMeteoWeatherService(geocodingService: CLGeocodingService())
    private let persistenceService = UserDefaultsPersistenceService()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: WeatherViewModel(
                weatherService: weatherService,
                persistenceService: persistenceService,
                locationManager: locationManager
            ))
        }
    }
}
