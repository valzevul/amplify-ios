//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import ArgumentParser

private struct TestCommandWithSingleArg: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "commandName",
        abstract: "abstract"
    )
    @Argument var name: String
}

private struct TestCommandWithMultipleArguments: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "commandName",
        abstract: "abstract"
    )
    @Argument var name: String
    @Argument var path: String
}

private struct TestCommandWithArgAndOptions: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "commandName",
        abstract: "abstract"
    )
    @Argument var argWithCompositeName: String
    @Option var option1: String = "default"
    @Option var option2: String
    @Flag var flag1 = false
}

class CLICommandDumpTests: XCTestCase {
    func testDumpWithSingleArgument() {
        let dump = TestCommandWithSingleArg.dump()
        XCTAssertEqual(dump?.name, TestCommandWithSingleArg.configuration.commandName)
        XCTAssertEqual(dump?.abstract, TestCommandWithSingleArg.configuration.abstract)
        XCTAssertEqual(dump?.parameters, [.argument("name")])
    }

    func testDumpWithMultipleArgument() {
        let dump = TestCommandWithMultipleArguments.dump()
        XCTAssertEqual(dump?.name, TestCommandWithSingleArg.configuration.commandName)
        XCTAssertEqual(dump?.abstract, TestCommandWithSingleArg.configuration.abstract)
        XCTAssertEqual(dump?.parameters.count, 2)
        XCTAssertEqual(dump?.parameters[0], .argument("name"))
        XCTAssertEqual(dump?.parameters[1], .argument("path"))
    }

    func testDumpWithArgumentAndOptions() {
        let dump = TestCommandWithArgAndOptions.dump()
        XCTAssertEqual(dump?.name, TestCommandWithArgAndOptions.configuration.commandName)
        XCTAssertEqual(dump?.abstract, TestCommandWithArgAndOptions.configuration.abstract)
        XCTAssertEqual(dump?.parameters.count, 4)
        XCTAssertEqual(dump?.parameters, [.argument("arg-with-composite-name"), .option("option1"), .option("option2"), .flag("flag1")])
    }
}
