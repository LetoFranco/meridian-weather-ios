
import SwiftUI

// MARK: - CurrentLocationView
/// A view dedicated to handling and displaying weather for the user's current location.
/// It manages its own UI based on the `CurrentLocationState` from the ViewModel.
struct CurrentLocationView: View {
    
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        ZStack {
            if case .success(let weather) = viewModel.currentLocationState {
                LinearGradient(
                    gradient: Gradient(colors: weather.isDayTime ? [.blue, .cyan] : [.black, .gray]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [.gray, .secondary]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            }
            
            content
        }
        .foregroundColor(.white)
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.currentLocationState {
        case .idle:
            IdleView(viewModel: viewModel)
        case .loading:
            ProgressView("Fetching your weather...")
        case .success(let weatherModel):
            WeatherCardView(model: weatherModel)
        case .denied:
            PermissionDeniedView()
        case .error(let message):
            RetryView(message: message) {
                viewModel.requestCurrentLocation()
            }
        }
    }
}

// MARK: - Helper Subviews

private struct IdleView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 60))
            Text("Your Current Weather")
                .font(.largeTitle)
                .fontWeight(.bold)
            Button("Get My Weather") {
                viewModel.requestCurrentLocation()
            }
            .padding()
            .background(Color.blue)
            .clipShape(Capsule())
        }
        .padding()
    }
}

private struct PermissionDeniedView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Text("Location Access Denied")
                .font(.headline)
            Text("To see the weather for your current location, please enable location services in your device settings.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding()
            .background(Color.blue)
            .clipShape(Capsule())
        }
        .padding()
    }
}



// MARK: - Previews
struct CurrentLocationView_Previews: PreviewProvider {
    static var previews: some View {
        let idleVM = WeatherViewModel(weatherService: MockWeatherService(), locationManager: LocationManager())
        idleVM.currentLocationState = .idle
        
        let loadingVM = WeatherViewModel(weatherService: MockWeatherService(), locationManager: LocationManager())
        loadingVM.currentLocationState = .loading
        
        let deniedVM = WeatherViewModel(weatherService: MockWeatherService(), locationManager: LocationManager())
        deniedVM.currentLocationState = .denied
        
        let successVM = WeatherViewModel(weatherService: MockWeatherService(), locationManager: LocationManager())
        let dummyWeather = WeatherModel(cityID: "cupertino", cityName: "Cupertino", description: "Sunny", iconURL: nil, currentTemperature: "25°", minTemperature: "20°", maxTemperature: "30°", isDayTime: true)
        successVM.currentLocationState = .success(dummyWeather)
        
        let errorVM = WeatherViewModel(weatherService: MockWeatherService(), locationManager: LocationManager())
        errorVM.currentLocationState = .error("Failed to fetch data.")
        
        return Group {
            CurrentLocationView(viewModel: idleVM)
                .previewDisplayName("Idle State")
            
            CurrentLocationView(viewModel: loadingVM)
                .previewDisplayName("Loading State")
            
            CurrentLocationView(viewModel: deniedVM)
                .previewDisplayName("Denied State")
            
            CurrentLocationView(viewModel: successVM)
                .previewDisplayName("Success State")
            
            CurrentLocationView(viewModel: errorVM)
                .previewDisplayName("Error State")
        }
    }
}
