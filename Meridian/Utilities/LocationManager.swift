
import Foundation
import CoreLocation
import Combine

// MARK: - LocationService Protocol
/// Defines the contract for a service that manages location updates.
protocol LocationService: ObservableObject {
    var objectWillChange: ObservableObjectPublisher { get }
    
    var currentLocation: CLLocation? { get }
    var currentLocationPublisher: AnyPublisher<CLLocation?, Never> { get } // Explicit publisher for Combine
    
    var authorizationStatus: CLAuthorizationStatus? { get }
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus?, Never> { get } // Explicit publisher for Combine
    
    func requestLocationAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

// MARK: - LocationManager
/// Manages device location services, including permission requests and
/// providing the current location.
final class LocationManager: NSObject, LocationService, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager
    
    let objectWillChange = ObservableObjectPublisher()
    
    @Published var currentLocation: CLLocation? {
        willSet { objectWillChange.send() }
    }
    var currentLocationPublisher: AnyPublisher<CLLocation?, Never> { // Conformance
        $currentLocation.eraseToAnyPublisher()
    }
    
    @Published var authorizationStatus: CLAuthorizationStatus? {
        willSet { objectWillChange.send() }
    }
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus?, Never> { // Conformance
        $authorizationStatus.eraseToAnyPublisher()
    }

    
    override init() {
        self.locationManager = CLLocationManager() // Instantiate here
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
    }
    
    /// Requests "When In Use" authorization for location services.
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Starts updating the device's location.
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    /// Stops updating the device's location.
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error.localizedDescription)")
        // TODO: We need to notify the ViewModel about errors
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            // TODO: Handle denied or restricted access, e.g., show an alert
            stopUpdatingLocation()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
