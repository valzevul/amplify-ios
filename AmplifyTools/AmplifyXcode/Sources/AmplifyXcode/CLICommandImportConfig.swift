//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import ArgumentParser
import AmplifyXcodeCore

/// CLI command invoking `CommandImportConfig`.
struct CLICommandImportConfig: ParsableCommand, CommandExecutable, CLICommandReportable, CLICommandRepresentable {
    static let configuration = CommandConfiguration(
        commandName: "import-config",
        abstract: CommandImportConfig.description
    )

    @Option(name: .shortAndLong, help: "Project base path")
    private var path: String = Process().currentDirectoryPath

    var environment: AmplifyCommandEnvironment {
        CommandEnvironment(basePath: path, fileManager: FileManager.default)
    }

    func run() throws {
        let output = exec(command: CommandImportConfig())
        report(result: output)
        if case .failure = output {
            throw ExitCode.failure
        }
    }
}

enum CLIParameter: Equatable {
    case option(String)
    case flag(String)
    case argument(String)
}

protocol CLICommandRepresentable where Self: ParsableCommand {
    associatedtype CodingKeys: RawRepresentable, CodingKey, CaseIterable
    func representableCodingKeys() -> [CLIParameter]
}

extension CLICommandRepresentable {
    /// Property wrappers prefix wrapped value with a _, this function returns the original property name
    private static func sanitizeParameterPropertyName(_ name: String?) -> String {
        guard let name = name else {
            fatalError("Invalid property name provided for \(type(of: self))")
        }
        return String(name.dropFirst())
    }

    func keyForParameter(named: String) -> CLIParameter {
        let keys = CodingKeys.allCases
        let mirror = Mirror(reflecting: Self())
        
        let paramsProperties:[String] = mirror.children.compactMap {
            let childType = "\(type(of: $0.value))"
            let childLabel = Self.sanitizeParameterPropertyName($0.label)
            
            guard childType.starts(with: "Option<") || childType.starts(with: "Argument<") || childType.starts(with: "Flag<") else {
                return nil
            }
            return childLabel
        }
        
        var parameters: [CLIParameter] = []
        for (i, key) in keys.enumerated() {
            guard paramsProperties[i] != key.stringValue else {
                fatalError("Couldn't find a key for \(paramsProperties[i]) in following set \(keys)")
            }
        }
    }
}
