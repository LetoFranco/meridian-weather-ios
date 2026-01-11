import Foundation
@testable import Meridian

final class MockLoggerService: LoggerService, @unchecked Sendable {
    var loggedMessages = [(message: String, level: LogLevel)]()
    var trackedErrors = [(error: Error, message: String?)]()

    func log(_ message: String, level: LogLevel, file: String = #file, function: String = #function, line: Int = #line) {
        loggedMessages.append((message, level))
    }

    func trackError(_ error: Error, message: String?, file: String = #file, function: String = #function, line: Int = #line) {
        trackedErrors.append((error, message))
    }

    func reset() {
        loggedMessages.removeAll()
        trackedErrors.removeAll()
    }
}
