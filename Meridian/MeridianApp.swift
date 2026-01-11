//
//  MeridianApp.swift
//  Meridian
//
//  Created by Franco Ezequiel Leto on 10/01/2026.
//

import SwiftUI

@main
struct MeridianApp: App {
    // Instantiate top-level dependencies here
    @StateObject private var locationManager = LocationManager()
    private let weatherService: WeatherService = MockWeatherService()
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
