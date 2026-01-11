import SwiftUI
import Combine

struct ContentView: View {
    
    @StateObject private var viewModel: WeatherViewModel
    @State private var selectedTab: Int = 0
    
    private let currentLocationTabID = "__current_location__"
    
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
                TabView(selection: $selectedTab) {
                    CurrentLocationView(viewModel: viewModel)
                        .tag(0)
                    
                    ForEach(fixedCityModels.indices, id: \.self) { index in
                        WeatherCardView(model: fixedCityModels[index])
                            .tag(index + 1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .onReceive(viewModel.$viewState) { viewState in
                    if case .success(let models) = viewState {
                        let lastID = PersistenceManager.getLastSelectedCityID() ?? currentLocationTabID
                        
                        var allTabIDs = [currentLocationTabID]
                        allTabIDs.append(contentsOf: models.map { $0.cityID })
                        
                        if let savedIndex = allTabIDs.firstIndex(of: lastID) {
                            self.selectedTab = savedIndex
                        }
                    }
                }
                .onChange(of: selectedTab) { newIndex in
                    if case .success(let models) = viewModel.viewState {
                        var allTabIDs = [currentLocationTabID]
                        allTabIDs.append(contentsOf: models.map { $0.cityID })
                        
                        if allTabIDs.indices.contains(newIndex) {
                            let idToSave = allTabIDs[newIndex]
                            PersistenceManager.saveLastSelected(cityID: idToSave)
                        }
                    }
                }
                
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
        let successVM = WeatherViewModel(weatherService: MockWeatherService(), locationManager: LocationManager())
        successVM.viewState = .success([
            WeatherModel(cityID: "london", cityName: "London", description: "Cloudy", iconURL: nil, currentTemperature: "10°", minTemperature: "8°", maxTemperature: "12°", isDayTime: true)
        ])

        return ContentView(viewModel: successVM)
            .previewDisplayName("Success State")
    }
}
