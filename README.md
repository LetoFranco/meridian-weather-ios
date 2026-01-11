# Meridian

Meridian is a modern iOS weather application built with SwiftUI, designed to provide users with current weather conditions for their location and pre-defined cities. It emphasizes a clean architecture, robust concurrency management, and testability.

## Features

*   **Current Location Weather:** Automatically fetches and displays weather information for the user's current geographical location.
*   **Fixed City Weather:** Allows users to view weather forecasts for a selection of pre-defined cities.
*   **Location Management:** Integrates with CoreLocation to handle location authorization and updates.
*   **Weather Data Persistence:** Remembers the last selected city tab for a seamless user experience.
*   **Logging & Monitoring (Planned):** Implements foundational logging capabilities with plans to integrate more comprehensive monitoring and tracking tools for analytics and error reporting.

## Architecture & Design

Meridian is built adhering to principles of clean architecture and uses modern Swift features:

*   **MVVM-C (Model-View-ViewModel-Coordinator):** While not explicitly using a Coordinator in this scope, the project structure implies a separation of concerns with `Views`, `ViewModels`, and `Domain` (Models) layers.
*   **Swift Concurrency:** Leverages `async/await`, `TaskGroup`, and `actor` for efficient, safe, and readable asynchronous operations.
*   **Dependency Injection:** Services are injected into ViewModels, promoting modularity, testability, and easier maintenance.

## Technology Stack

*   **Swift:** The primary programming language.
*   **SwiftUI:** For building the declarative user interface.
*   **Combine:** Used for reactive programming, especially for handling asynchronous data flows from `LocationManager` and UI state changes.
*   **CoreLocation:** For location services, including requesting authorization and fetching current coordinates.

## Key Design Decisions & Notes

### Weather Data Source
The application currently utilizes **Open-Meteo API** for fetching weather data. This decision was largely driven by practical considerations:
*   **OpenWeather API Issues:** During initial development, the OpenWeather API presented functionality and reliability issues, leading us to seek an alternative.
*   **API Key Management:** Unlike Open-Meteo, many APIs (including OpenWeather) require sensitive API keys. For a production-ready application, such keys should **never** be hardcoded or stored directly in the client-side bundle. A robust solution would involve:
    *   **Environment Variables:** Loading keys via build configurations (e.g., Xcode schemes, `.xcconfig` files).
    *   **Secure Storage:** Utilizing Keychain or other secure enclave technologies for device-side storage.
    *   **Backend Proxy:** Ideally, sensitive API calls should be proxied through a secure backend service to prevent exposure of keys to the client.
Our architecture is designed to allow easy switching between different weather providers (e.g., OpenWeather, AccuWeather) by implementing the `WeatherService` protocol, providing flexibility for future integrations.

### Geocoding Service
A custom `CLGeocodingService` (implemented as an `actor`) serializes requests to Apple's `CLGeocoder`. This approach ensures robustness and prevents potential rate-limiting or internal issues when `CLGeocoder` is accessed concurrently. For optimal resource management and to prevent potential concurrency errors from multiple `CLGeocoder` instances, `CLGeocodingService` should ideally be managed as a **singleton** throughout the application's lifecycle.

### Dependency Injection for Testability
All core services (`WeatherService`, `PersistenceService`, `LocationService`, `LoggerService`, `TrackerService`) are provided through protocols and injected into `WeatherViewModel`. This design greatly facilitates unit testing by allowing mock implementations to be swapped in during tests.

### Fault Tolerance
For robust network operations, implementing fault tolerance patterns like the **Circuit Breaker** is crucial. This would prevent the application from continuously attempting requests to an unresponsive API, thus saving resources and improving the user experience during outages. This is a planned enhancement for future iterations.

### Swift 6 Concurrency Compliance
Special attention has been given to ensuring `Sendable` conformance and proper actor isolation to prevent data races and ensure thread safety, in anticipation of stricter Swift 6 compiler checks. This was notably addressed in the `MockLoggerService` to correctly handle mutable state across concurrent tasks.

### Testing & Quality Assurance Strategy
*   **Unit Tests:** While foundational unit tests are in place, full test coverage was constrained by time. We aim to achieve comprehensive unit test coverage for all critical business logic and view models.
*   **Snapshot Testing:** Implementing snapshot tests for SwiftUI views is a planned enhancement to ensure UI consistency and prevent unintended visual regressions across different devices and iOS versions.
*   **A/B Testing:** The modular architecture and dependency injection facilitate the future integration of A/B testing frameworks, allowing for data-driven decisions on features and UI variations.

### User Interface (UI)
The current user interface is intentionally basic. Its primary purpose is to demonstrate the application's core functionality and architectural patterns rather than providing a polished, production-ready aesthetic. There are numerous potential UI/UX improvements and enhancements planned for future iterations to elevate the user experience.

## Quality, Performance & Strategic Considerations

Meridian's underlying architecture and development practices align with key considerations crucial for building high-quality, reliable, and performant applications across various domains:

*   **Performance & Responsiveness:** The application leverages Swift Concurrency (`async/await`, `TaskGroup`) to fetch data in parallel, ensuring a highly responsive user experience and minimizing load times. This focus on efficient resource utilization and quick feedback loops is paramount for maintaining user satisfaction and operational efficiency.
*   **Reliability & Fault Tolerance:** Our commitment to a robust architecture includes plans for fault tolerance mechanisms like the Circuit Breaker pattern. This ensures the application remains stable and available even when external services (e.g., APIs) experience issues, preventing cascading failures and ensuring continuous operation.
*   **Modularity & Testability:** The extensive use of Dependency Injection and protocol-oriented programming ensures a modular and highly testable codebase. This facilitates rapid, secure development and allows for thorough verification of all components, which is essential for maintaining accuracy and integrity in any critical application.



To run the Meridian project:

1.  Clone the repository.
2.  Open the `Meridian.xcodeproj` file in Xcode.
3.  Select a target simulator or device.
4.  Build and run the project.

This README provides an overview of the Meridian application. For detailed implementation specifics, please refer to the source code.
