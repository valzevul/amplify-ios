//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

// AmplifyXcode.main()

let dump1 = CLICommandImportConfig.dump()
let dump2 = CLICommandImportModels.dump()

let encoder = JSONEncoder()
let data = try encoder.encode(dump1)
print(String(data: data, encoding: .utf8)!)
