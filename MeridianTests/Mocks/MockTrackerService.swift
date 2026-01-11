import Foundation
@testable import Meridian

final class MockTrackerService: TrackerService {
    var trackedPageViews = [String]()
    
    func trackPageView(cityID: String) {
        trackedPageViews.append(cityID)
    }
    
    func reset() {
        trackedPageViews.removeAll()
    }
}
