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
    
    public init(_ date: Foundation.Date) {
      self.foundationDate = Temporal
        .iso8601Calendar
        .startOfDay(for: date)
    }
    
    // Inherits documentation from `TemporalSpec`
    public init(date: Foundation.Date) {
      self.init(date)
      localTimezone = TimeZone(iso8601String: DateFormatter.isoFormatter.string(from: foundationDate))
    }
  }
}

// Allow date unit operations on `Temporal.Date`
extension Temporal.Date: DateUnitOperable {}
extension TimeZone {
  
  init?(iso8601String: String) {
    var timeZone: TimeZone?
    let supportedTimeZoneModifiers = ["+hh:mm", "-hh:mm", "Z"]
    
    guard let timeZoneSliceSize = supportedTimeZoneModifiers.map(\.count).max() else {
      return nil
    }
    
    let timeZoneSlice = iso8601String.suffix(timeZoneSliceSize)
    
    if timeZoneSlice.contains("Z") {
      timeZone = TimeZone(secondsFromGMT: 0)
    } else {
      let signCharacter = timeZoneSlice.first
      let time = timeZoneSlice.dropFirst()
      let hours = time.prefix(2)
      let minutes = time.suffix(2)
      let sign: Int? = signCharacter == "+" ? +1 : (signCharacter == "-" ? -1 : nil)
      
      if let hours = Int(hours), let minutes = Int(minutes), let sign = sign {
        let minutesInSeconds = minutes * 60
        let hoursInSeconds = hours * 3600
        let shiftInSeconds = sign * (minutesInSeconds + hoursInSeconds)
        timeZone = TimeZone(secondsFromGMT: shiftInSeconds)
      }
    }
    if let timeZone = timeZone {
      self = timeZone
    } else {
      return nil
    }
  }
  
}
