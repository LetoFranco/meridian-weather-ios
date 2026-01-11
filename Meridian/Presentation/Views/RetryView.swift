import SwiftUI

/// A reusable view that displays an error message and a retry button.
struct RetryView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Text("Something Went Wrong")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                retryAction()
            }
            .padding()
            .background(Color.blue)
            .clipShape(Capsule())
        }
        .padding()
        .foregroundColor(.white)
    }
}

struct RetryView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.edgesIgnoringSafeArea(.all)
            RetryView(message: "Failed to load weather data.") {
                print("Retry tapped!")
            }
        }
    }
}
