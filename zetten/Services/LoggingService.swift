//
//  LoggingService.swift
//  zetten
//
//  Created by Peter Hrvola on 15/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import Willow

// From https://medium.com/joshtastic-blog/convenient-logging-in-swift-75e1adf6ba7c
// Copyright Joshua Brunhuber
var willowLogger: Logger?

enum LoggingConfiguration {
  static func configure() {
    willowLogger = LoggingConfiguration.buildDebugLogger(name: "Logger")
  }

  private static func buildDebugLogger(name: String) -> Logger {
    let consoleWriter = ConsoleWriter(modifiers: [TimestampModifier()])
    let osWriter = OSLogWriter(subsystem: "me.zetten", category: "testing")
    return Logger(
      logLevels: [.all], writers: [consoleWriter, osWriter],
      executionMethod: .synchronous(lock: .init()))
  }
}

var logger = LoggingProxy()

struct LoggingProxy {
  public func debug(
    _ message: String, file: String = #file, function: String = #function, line: Int = #line
  ) {
    willowLogger?.debugMessage(
      self.format(message: message, file: file, function: function, line: line))
  }

  public func info(
    _ message: String, file: String = #file, function: String = #function, line: Int = #line
  ) {
    willowLogger?.infoMessage(
      self.format(message: message, file: file, function: function, line: line))
  }

  public func event(
    _ message: String, file: String = #file, function: String = #function, line: Int = #line
  ) {
    willowLogger?.eventMessage(
      self.format(message: message, file: file, function: function, line: line))
  }

  public func warn(
    _ message: String, file: String = #file, function: String = #function, line: Int = #line
  ) {
    willowLogger?.warnMessage(
      self.format(message: message, file: file, function: function, line: line))
  }

  public func error(
    _ message: String, file: String = #file, function: String = #function, line: Int = #line
  ) {
    willowLogger?.errorMessage(
      self.format(message: message, file: file, function: function, line: line))
  }

  private func format(message: String, file: String, function: String, line: Int) -> String {
    #if DEBUG /* I use os_log in production where line numbers and functions are discouraged */
      return "[\(sourceFileName(filePath: file)) \(function):\(line)] \(message)"
    #else
      return message
    #endif
  }

  private func sourceFileName(filePath: String) -> String {
    let components = filePath.components(separatedBy: "/")
    return components.isEmpty ? "" : components.last!
  }
}
