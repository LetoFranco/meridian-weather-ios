import Foundation
import CoreLocation

// MARK: - GeocodingService
/// Defines the contract for a service that performs reverse geocoding.
protocol GeocodingService {
    /// Reverse geocodes a given location to find its placemark,
    /// specifically extracting the city name.
    /// - Parameter location: The `CLLocation` to geocode.
    /// - Returns: The city name as a String, or `nil` if not found.
    /// - Throws: An error if geocoding fails.
    func reverseGeocode(location: CLLocation) async throws -> String?
}

// MARK: - CLGeocodingService
/// An implementation of `GeocodingService` using Apple's `CLGeocoder`.
final class CLGeocodingService: GeocodingService {
    private let geocoder: CLGeocoder
    
    init(geocoder: CLGeocoder = CLGeocoder()) {
        self.geocoder = geocoder
    }
    
    func reverseGeocode(location: CLLocation) async throws -> String? {        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)

            return placemarks.first?.locality ?? placemarks.first?.subLocality ?? placemarks.first?.administrativeArea
        } catch {
            throw GeocodingError.geocodingFailed(error)
        }
    }
}

// MARK: - GeocodingError
enum GeocodingError: Error, LocalizedError {
    case notAvailable
    case geocodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Geocoding service is not available on this device."
        case .geocodingFailed(let error):
            return "Geocoding failed: \(error.localizedDescription)"
        }
    }
}
