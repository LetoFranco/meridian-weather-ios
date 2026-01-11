import SwiftUI
import Combine

struct ContentView: View {
    
    @StateObject private var viewModel: WeatherViewModel
    
    init(viewModel: WeatherViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .loading:
                ProgressView("Loading Cities...")
                    .progressViewStyle(CircularProgressViewStyle())
            
            case .success(let fixedCityModels):
                TabView(selection: $viewModel.selectedTab) {
                    CurrentLocationView(viewModel: viewModel)
                        .tag(0)
                    
                    ForEach(fixedCityModels.indices, id: \.self) { index in
                        WeatherCardView(model: fixedCityModels[index])
                            .tag(index + 1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
            case .error(let errorMessage):
                RetryView(message: errorMessage) {
                    viewModel.loadFixedCityData()
                }
            }
        }
        .task {
            viewModel.loadFixedCityData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let fixedCitiesSuccessVM = WeatherViewModel(
            weatherService: MockWeatherService(),
            persistenceService: UserDefaultsPersistenceService(),
            locationManager: LocationManager(),
            logger: ConsoleLoggerService()
        )
        fixedCitiesSuccessVM.viewState = .success([
            WeatherModel(cityID: "london", cityName: "London", description: "Cloudy", iconUrl: nil, iconName: "cloud.sun.fill", currentTemperature: "10°", minTemperature: "8°", maxTemperature: "12°", isDayTime: true)
        ])

        return ContentView(viewModel: fixedCitiesSuccessVM)
            .previewDisplayName("Success State")
    }
}
