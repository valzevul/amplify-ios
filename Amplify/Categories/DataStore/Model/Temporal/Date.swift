//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension Temporal {
  
  /// `Temporal.Date` represents a `Date` with specific allowable formats.
  ///
  ///  * `.short` => `yyyy-MM-dd`
  ///  * `.medium` => `yyyy-MM-ddZZZZZ`
  ///  * `.long` => `yyyy-MM-ddZZZZZ`
  ///  * `.full` => `yyyy-MM-ddZZZZZ`
  ///
  ///  - Note: `.medium`, `.long`, and `.full` are the same date format.
  public struct Date: TemporalSpec {
    // Inherits documentation from `TemporalSpec`
    public let foundationDate: Foundation.Date
    
    public var localTimezone: TimeZone?
    
    public init(iso8601String: String) throws {
      guard let date = Temporal.Date.iso8601Date(from: iso8601String) else {
        throw DataStoreError.invalidDateFormat(iso8601String)
      }
      
      self.init(date)
      localTimezone = TimeZone(iso8601String: iso8601String)
    }
    
    // Inherits documentation from `TemporalSpec`
    public static func now() -> Self {
      Temporal.Date(Foundation.Date())
    }
    
    // Inherits documentation from `TemporalSpec`
    public init(_ date: Foundation.Date) {
      self.foundationDate = Temporal
        .iso8601Calendar
        .startOfDay(for: date)
    }
  }
}

// Allow date unit operations on `Temporal.Date`
extension Temporal.Date: DateUnitOperable {}
