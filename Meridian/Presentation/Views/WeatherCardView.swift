import SwiftUI

// MARK: - WeatherCardView
struct WeatherCardView: View {
    let model: WeatherModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text(model.cityName)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(model.description)
                .font(.headline)
                .fontWeight(.medium)

            AsyncImage(url: model.iconURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 100, height: 100)
            
            Text(model.currentTemperature)
                .font(.system(size: 70, weight: .thin))
            
            HStack {
                Text(model.maxTemperature)
                Text(model.minTemperature)
            }
            .font(.system(.headline).weight(.medium))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: model.isDayTime ? [.blue, .cyan] : [.black, .gray]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Preview
struct WeatherCardView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyModel = WeatherModel(
            cityName: "London",
            description: "Scattered Clouds",
            iconURL: URL(string: "https://openweathermap.org/img/wn/03d@2x.png"),
            currentTemperature: "12°",
            minTemperature: "L: 8°",
            maxTemperature: "H: 14°",
            isDayTime: true
        )
        WeatherCardView(model: dummyModel)
    }
}
