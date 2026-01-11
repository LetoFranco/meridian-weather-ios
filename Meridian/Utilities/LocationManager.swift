
import Foundation
import CoreLocation
import Combine

// MARK: - LocationManager
/// Manages device location services, including permission requests and
/// providing the current location.
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
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
        currentLocation = locations.last // Get the most recent location
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
