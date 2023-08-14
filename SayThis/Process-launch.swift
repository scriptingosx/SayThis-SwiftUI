//
//  Process-launch.swift
//  SayThis
//
//  Created by Armin Briegel on 2023-08-14.
//  Copyright © 2023 Scripting OS X. All rights reserved.
//

import Foundation

extension Process {
  @discardableResult
  static func launch(
    path: String,
    arguments: [String] = [],
    terminationHandler: @escaping (Int, Data, Data) -> Void
  ) throws -> Process {
    let process = Process()
    let outPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outPipe
    process.standardError = errorPipe
    process.arguments = arguments
    process.launchPath = path
    process.terminationHandler = { process in
      let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
      let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
      let exitCode = Int(process.terminationStatus)
      terminationHandler(exitCode, outData, errorData)
    }
    try process.run()
    return process
  }

  @discardableResult
  static func launch(
    path: String,
    arguments: [String] = []
  ) async throws -> (exitCode: Int, standardOutput: Data, standardError: Data) {
    try await withCheckedThrowingContinuation { continuation in
      do {
        try launch(path: path, arguments: arguments) { exitCode, outData, errData in
          continuation.resume(returning: (exitCode, outData, errData))
        }
      } catch let error {
        continuation.resume(throwing: error)
      }
    }
  }
}
