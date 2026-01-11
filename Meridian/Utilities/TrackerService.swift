import Foundation

// MARK: - TrackerService Protocol
/// Defines the contract for a product tracking service.
protocol TrackerService {
    /// Tracks a page view event for a specific city.
    /// - Parameter cityID: The stable ID of the city being viewed.
    func trackPageView(cityID: String)
}

// MARK: - AnalyticsTrackerService
/// An implementation of `TrackerService` that outputs tracking events to the console,
/// simulating a remote analytics service.
final class AnalyticsTrackerService: TrackerService {
    private let logger: LoggerService
    
    init(logger: LoggerService) {
        self.logger = logger
    }

    /// In a real app, this would send data to an analytics SDK (e.g., Firebase Analytics, Amplitude, etc.)
    func trackPageView(cityID: String) {
        logger.info("Tracking: Page view for city ID: \(cityID)")
    }
}
