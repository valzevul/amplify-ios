//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension DateFormatter {
  static let isoFormatter: DateFormatter = {
    $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    $0.calendar = Calendar(identifier: .iso8601)
    $0.timeZone = TimeZone.current
    return $0
  }(DateFormatter())
}


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
    
    public var localTimezone: TimeZone?
    
    // Inherits documentation from `TemporalSpec`
    public let foundationDate: Foundation.Date
    
    // Inherits documentation from `TemporalSpec`
    public static func now() -> Self {
      Temporal.Date(Foundation.Date())
    }
    
    // Inherits documentation from `TemporalSpec`
    public init(_ date: Foundation.Date) {
      self.foundationDate = Temporal
        .iso8601Calendar
        .startOfDay(for: date)
      
      // We don't care 'cause we aint supporting lower!!!!
      if #available(iOS 15.0, *) {
        localTimezone = TimeZone(iso8601: DateFormatter.isoFormatter.string(from: foundationDate))
      }
    }
  }
}

// Allow date unit operations on `Temporal.Date`
extension Temporal.Date: DateUnitOperable {}
extension TimeZone {
  init?(iso8601: String) {
    let tz = iso8601.dropFirst(19) // remove yyyy-MM-ddTHH:mm:ss part
    if tz == "Z" {
      self.init(secondsFromGMT: 0)
    } else if tz.count == 3 { // assume +/-HH
      if let hour = Int(tz) {
        self.init(secondsFromGMT: hour * 3600)
        return
      }
    } else if tz.count == 5 { // assume +/-HHMM
      if let hour = Int(tz.dropLast(2)), var min = Int(tz.dropFirst(3)) {
        min = (hour < 0) ? -1 * min : min
        self.init(secondsFromGMT: (hour * 60 + min) * 60)
        return
      }
    } else if tz.count == 6 { // assime +/-HH:MM
      let parts = tz.components(separatedBy: ":")
      if parts.count == 2 {
        if let hour = Int(parts[0]), var min = Int(parts[1]) {
          min = (hour < 0) ? -1 * min : min
          self.init(secondsFromGMT: (hour * 60 + min) * 60)
          return
        }
      }
    }
    return nil
  }
}
