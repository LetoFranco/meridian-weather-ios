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
            
            switch viewModel.viewState {
            case .loading:
                ProgressView("Loading Cities...")
                    .progressViewStyle(CircularProgressViewStyle())
            
            case .success(let fixedCityModels):
                TabView(selection: $selectedTab) {
                    CurrentLocationView(viewModel: viewModel)
                        .tag(0)
                    
                    ForEach(fixedCityModels.indices, id: \.self) { index in
                        WeatherCardView(model: fixedCityModels[index])
                            .tag(index + 1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .onChange(of: selectedTab) { newIndex in
                    PersistenceManager.saveLastCityIndex(index: newIndex)
                }
                
            case .error(let errorMessage):
                
                VStack {
                    Text("Failed to load city data")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.callout)
                    Button("Retry") {
                        viewModel.loadFixedCityData()
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
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
        let successVM = WeatherViewModel(weatherService: MockWeatherService(), locationManager: LocationManager())
        successVM.viewState = .success([
            WeatherModel(cityName: "London", description: "Cloudy", iconURL: nil, currentTemperature: "10°", minTemperature: "8°", maxTemperature: "12°", isDayTime: true)
        ])

        return ContentView(viewModel: successVM)
            .previewDisplayName("Success State")
    }
}
