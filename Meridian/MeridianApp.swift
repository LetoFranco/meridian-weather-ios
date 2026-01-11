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
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: WeatherViewModel(weatherService: MockWeatherService(), locationManager: locationManager))
        }
    }
}
