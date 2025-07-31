//
//  Logger.swift
//  iConFinder
//

import Foundation
import os.log

struct Logger {
    
    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    private static var `default` = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Default")

    static func debug(_ message: String, log: OSLog = Logger.default) {
        guard !isRunningTests else { return }
        os_log("%{public}s", log: log, type: .debug, message)
    }
    
    static func info(_ message: String, log: OSLog = Logger.default) {
        guard !isRunningTests else { return }
        os_log("%{public}s", log: log, type: .info, message)
    }
    
    static func error(_ message: String, log: OSLog = Logger.default) {
        guard !isRunningTests else { return }
        os_log("%{public}s", log: log, type: .error, message)
    }
}
