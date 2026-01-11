import SwiftUI

// MARK: - WeatherCardView
struct WeatherCardView: View {
    let model: WeatherModel
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Text(model.cityName)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(model.description)
                .font(.headline)
                .fontWeight(.medium)

            if let iconUrlString = model.iconUrl, let url = URL(string: iconUrlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: model.iconName.isEmpty ? "questionmark.circle.fill" : model.iconName)
                            .font(.system(size: AppTheme.IconSize.large))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: AppTheme.IconSize.large, height: AppTheme.IconSize.large)
            } else {
                Image(systemName: model.iconName.isEmpty ? "questionmark.circle.fill" : model.iconName)
                    .font(.system(size: AppTheme.IconSize.large))
            }

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
            cityID: "london",
            cityName: "London",
            description: "Scattered Clouds",
            iconUrl: nil,
            iconName: "cloud.sun.fill",
            currentTemperature: "12°",
            minTemperature: "L: 8°",
            maxTemperature: "H: 14°",
            isDayTime: true
        )
        WeatherCardView(model: dummyModel)
    }
}
