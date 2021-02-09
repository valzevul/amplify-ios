//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import ArgumentParser

struct CLICommandDump: Encodable {
    let name: String
    let abstract: String
    let parameters: [CLICommandDumpParameter]
}

// MARK: - CLICommandDumpParameter
enum CLICommandDumpParameter: Equatable {
    case argument(String)
    case option(String)
    case flag(String)
}

// MARK: - CLICommandDumpParameter: Encodable
extension CLICommandDumpParameter: Encodable {
    enum CodingKeys: CodingKey {
        case type
        case name
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .argument(let name):
            try container.encode("argument", forKey: .type)
            try container.encode(name, forKey: .name)
        case .option(let name):
            try container.encode("option", forKey: .type)
            try container.encode(name, forKey: .name)
        case .flag(let name):
            try container.encode("flag", forKey: .type)
            try container.encode(name, forKey: .name)
        }
    }
}

// MARK: - ParsableCommand+Dump
extension ParsableCommand {
    private static func sanitizeParameterPropertyName(_ name: String?) -> String {
        guard let name = name else {
            fatalError()
        }
        // property wrappers prefix wrapped value with a _
        return String(name.dropFirst())
    }

    static func dump() -> CLICommandDump? {
        guard let commandName = Self.configuration.commandName else {
            print("Couldn't find command name in configuration")
            return nil
        }

        let abstract = Self.configuration.abstract
        var parameters: [CLICommandDumpParameter] = []
        let mirror = Mirror(reflecting: Self())
        for child in mirror.children {
            let childType = "\(type(of: child.value))"
            let childLabel = sanitizeParameterPropertyName(child.label)
            if childType.hasPrefix("Option<") {
                parameters.append(.option(childLabel))
            }

            if childType.hasPrefix("Argument<") {
                parameters.append(.argument(childLabel))
            }

            if childType.hasPrefix("Flag<") {
                parameters.append(.flag(childLabel))
            }
        }

        return CLICommandDump(name: commandName, abstract: abstract, parameters: parameters)
    }
}
