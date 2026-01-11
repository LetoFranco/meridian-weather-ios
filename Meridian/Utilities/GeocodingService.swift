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
/// An implementation of `GeocodingService` using Apple's `CLGeocoder`
/// that serializes requests to prevent overloading the underlying geocoder.
actor CLGeocodingService: GeocodingService {
    private let geocoder = CLGeocoder() // To avoid issue with swift 6, this should become a factory to be inyected.
    private let logger: LoggerService
    private var requestQueue: [GeocodingRequest] = []
    private var processingTask: Task<Void, Never>?

    init(logger: LoggerService) {
        self.logger = logger
    }
    
    func reverseGeocode(location: CLLocation) async throws -> String? {
        return try await withCheckedThrowingContinuation { continuation in
            let request = GeocodingRequest(location: location, continuation: continuation)
            requestQueue.append(request)

            if processingTask == nil {
                startProcessing()
            }
        }
    }
    
    private func startProcessing() {
        processingTask = Task { [weak self] in
            await self?.processQueue()
        }
    }
    
    private func processQueue() async {
        while !requestQueue.isEmpty {
            let request = requestQueue.removeFirst()
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(request.location)
                let cityName = placemarks.first?.locality ?? placemarks.first?.subLocality ?? placemarks.first?.administrativeArea
                request.continuation.resume(returning: cityName)
            } catch {
                request.continuation.resume(throwing: GeocodingError.geocodingFailed(error))
            }
        }
        processingTask = nil
    }
    
    // MARK: - Private Helper Struct
    private struct GeocodingRequest {
        let location: CLLocation
        let continuation: CheckedContinuation<String?, Error>
    }
}

// MARK: - GeocodingError
enum GeocodingError: Error, LocalizedError {
    case geocodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .geocodingFailed(let error):
            return "Geocoding failed: \(error.localizedDescription)"
        }
    }
}
