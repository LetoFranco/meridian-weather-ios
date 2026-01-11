import Foundation

// MARK: - LoggerService Protocol
/// Defines the contract for a logging service.
protocol LoggerService {
    /// Logs a message at a specified level.
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
    
    /// Tracks an error, potentially sending it to an external service.
    func trackError(_ error: Error, message: String?, file: String, function: String, line: Int)
}

/// Defines the severity of a log message.
enum LogLevel: Comparable {
    case debug
    case info
    case warning
    case error
    case none
}

// MARK: - LoggerService Default Implementations (for convenience)
extension LoggerService {
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
}

// MARK: - ConsoleLoggerService
/// An implementation of `LoggerService` that outputs logs to the console.
final class ConsoleLoggerService: LoggerService {
    var minLogLevel: LogLevel
    
    init(minLogLevel: LogLevel = .debug) {
        self.minLogLevel = minLogLevel
    }
    
    func log(_ message: String, level: LogLevel, file: String = #file, function: String = #function, line: Int = #line) {
        guard level >= minLogLevel else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let timestamp = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        
        debugPrint("[\(timestamp)][\(level.emoji)] [\(fileName):\(line)] \(message)")
    }

    /// In a real app, integrate with an external tracking service here (e.g., Crashlytics, Sentry)
    func trackError(_ error: Error, message: String?, file: String = #file, function: String = #function, line: Int = #line) {
        let msg = message ?? error.localizedDescription
        log("Tracking Error: \(msg)", level: .error, file: file, function: function, line: line)
    }
}

extension LogLevel {
    var emoji: String {
        switch self {
        case .debug: return "🐛"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .none: return ""
        }
    }
}
