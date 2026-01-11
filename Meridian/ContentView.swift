import SwiftUI
import CoreLocation

struct ContentView: View {
    
    @StateObject private var viewModel: WeatherViewModel
    @State private var selectedTab: Int

    init(viewModel: WeatherViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _selectedTab = State(initialValue: PersistenceManager.getLastCityIndex() ?? 0)
    }
    
    var body: some View {
        ZStack {
            if viewModel.locationPermissionAreDenied {
                VStack {
                    Text("Location access denied")
                        .font(.headline)
                    Text("Please enable location services in Settings to see current weather.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                switch viewModel.viewState {
                case .loading:
                    ProgressView("Fetching Weather...")
                        .progressViewStyle(CircularProgressViewStyle())
                
                case .success(let weatherModels):
                    if weatherModels.isEmpty {
                        ProgressView("Waiting for weather data...")
                    } else {
                        TabView(selection: $selectedTab) {
                            ForEach(weatherModels.indices, id: \.self) { index in
                                WeatherCardView(model: weatherModels[index])
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .onChange(of: selectedTab) { newIndex in
                            PersistenceManager.saveLastCityIndex(index: newIndex)
                        }
                    }
                    
                case .error(let errorMessage):
                    VStack {
                        Text("Something went wrong")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.callout)
                        Button("Retry") {
                            viewModel.loadWeatherData()
                        }
                        .padding()
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .task {
            viewModel.loadWeatherData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let successLocationManager = LocationManager()
        successLocationManager.authorizationStatus = .authorizedWhenInUse
        successLocationManager.currentLocation = CLLocation(latitude: 34.0522, longitude: -118.2437)
        let successVM = WeatherViewModel(
            weatherService: MockWeatherService(),
            locationManager: successLocationManager
        )

        let deniedLocationManager = LocationManager()
        deniedLocationManager.authorizationStatus = .denied
        let deniedVM = WeatherViewModel(
            weatherService: MockWeatherService(),
            locationManager: deniedLocationManager
        )

        return Group {
            ContentView(viewModel: successVM)
                .previewDisplayName("Success with Location")
            
            ContentView(viewModel: deniedVM)
                .previewDisplayName("Location Denied")
        }
    }
}
