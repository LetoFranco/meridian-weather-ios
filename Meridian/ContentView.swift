import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel: WeatherViewModel
    
    init(viewModel: WeatherViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .loading:
                ProgressView("Fetching Weather...")
                    .progressViewStyle(CircularProgressViewStyle())
            
            case .success(let weatherModels):
                TabView {
                    ForEach(weatherModels) { model in
                        WeatherCardView(model: model)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
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
        .task {
            viewModel.loadWeatherData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let successVM = WeatherViewModel(weatherService: MockWeatherService())
        
        return ContentView(viewModel: successVM)
    }
}
