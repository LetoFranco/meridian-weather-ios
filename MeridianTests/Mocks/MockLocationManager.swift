import Foundation
import CoreLocation
import Combine
@testable import Meridian

final class MockLocationManager: LocationService {
    @Published var currentLocation: CLLocation?
    var currentLocationPublisher: AnyPublisher<CLLocation?, Never> {
        $currentLocation.eraseToAnyPublisher()
    }
    
    @Published var authorizationStatus: CLAuthorizationStatus?
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus?, Never> {
        $authorizationStatus.eraseToAnyPublisher()
    }
    
    var requestLocationAuthorizationCalled = false
    var startUpdatingLocationCalled = false
    var stopUpdatingLocationCalled = false
    
    init(currentLocation: CLLocation? = nil, authorizationStatus: CLAuthorizationStatus? = nil) {
        self.currentLocation = currentLocation
        self.authorizationStatus = authorizationStatus
    }
    
    func requestLocationAuthorization() {
        requestLocationAuthorizationCalled = true
        if authorizationStatus == .notDetermined {
            authorizationStatus = .authorizedWhenInUse
        }
    }
    
    func startUpdatingLocation() {
        startUpdatingLocationCalled = true
    }
    
    func stopUpdatingLocation() {
        stopUpdatingLocationCalled = true
    }
    
    func simulateLocationUpdate(location: CLLocation) {
        currentLocation = location
    }
    
    func simulateAuthorizationStatus(status: CLAuthorizationStatus) {
        authorizationStatus = status
    }
    
    func reset() {
        currentLocation = nil
        authorizationStatus = nil
        requestLocationAuthorizationCalled = false
        startUpdatingLocationCalled = false
        stopUpdatingLocationCalled = false
    }
}
