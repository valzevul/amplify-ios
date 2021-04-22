//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct Temporal {

    /// This struct is used as a namespace to all temporal types. It should
    /// not be directly instantiated.
    ///
    /// - seealso: Temporal.Date
    /// - seealso: Temporal.DateTime
    /// - seealso: Temporal.Time
    /// - seealso: Temporal.TimeStamp
    private init() {}
}

/// The `TemporalSpec` protocol defines an [ISO-8601](https://www.iso.org/iso-8601-date-and-time-format.html)
/// formatted Date value. Types that conform to this protocol are responsible for providing
/// the parsing and formatting logic with the correct granularity.
public protocol TemporalSpec {

    /// A static builder that return an instance that represent the current point in time.
    static func now() -> Self

    /// The underlying `Date` object. All `TemporalSpec` implementations must be backed
    /// by a Foundation `Date` instance.
    var foundationDate: Foundation.Date { get }

    /// The ISO-8601 formatted string in the UTC `TimeZone`.
    /// - seealso: iso8601FormattedString(TemporalFormat, TimeZone) -> String
    var iso8601String: String { get }
  
    /// The underlying `TimeZone` object. Specifies the format of converted ISO-8601 string.
    /// - seealso: iso8601FormattedString(TemporalFormat, TimeZone) -> String
    var localTimezone: TimeZone? { get set }

    /// Parses an ISO-8601 `String` into a `TemporalSpec`.
    ///
    /// - Note: if no timezone is present in the string, `.autoupdatingCurrent` is used.
    ///
    /// - Parameter iso8601String: the string in the ISO8601 format
    /// - Throws: `DataStoreError.decodeError`in case the provided string is not
    /// formatted as expected by the scalar type.
    init(iso8601String: String) throws

    /// Constructs a `TemporalSpec` from a `Date` object.
    /// - Parameter date: the `Date` instance that will be used as the reference of the
    /// `TemporalSpec` instance.
    init(_ date: Foundation.Date)

    /// A string representation of the underlying date formatted using ISO8601 rules.
    ///
    /// - Parameters:
    ///   - format: the desired format
    ///   - timeZone: the target `TimeZone`
    /// - Returns: the ISO8601 formatted string in the requested format
    func iso8601FormattedString(format: TemporalFormat, timeZone: TimeZone) -> String

}

/// Extension to add default implementation to generic members of `TemporalSpec`.
extension TemporalSpec {

    static var iso8601Calendar: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .utc
        return calendar
    }

    /// Utility used to created an ISO8601 with a pre-defined timezone `DateFormatter`.
    ///
    /// - Parameters:
    ///   - format: the desired format
    ///   - timeZone: the target `TimeZone`
    static func iso8601DateFormatter(format: TemporalFormat,
                                     timeZone: TimeZone = .utc) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = iso8601Calendar
        formatter.dateFormat = format.getFormat(for: Self.self)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        return formatter
    }

    static func iso8601Date(from iso8601String: String) -> Foundation.Date? {
        var date: Foundation.Date?
        for format in TemporalFormat.sortedCasesForParsing {
            let formatter = Self.iso8601DateFormatter(format: format)
            if let convertedDate = formatter.date(from: iso8601String) {
                date = convertedDate
                break
            }
        }
        return date
    }

    public func iso8601FormattedString(format: TemporalFormat,
                                       timeZone: TimeZone = .utc) -> String {
        let formatter = Self.iso8601DateFormatter(format: format, timeZone: timeZone)
        return formatter.string(from: foundationDate)
    }

    /// The ISO8601 representation of the scalar using `.full` as the format and either a local timezone if set, or `.utc` as default for `TimeZone`.
    /// - seealso: iso8601FormattedString(TemporalFormat, TimeZone)
    public var iso8601String: String {
      iso8601FormattedString(format: .full, timeZone: localTimezone ?? .utc)
    }
}

extension TimeZone {

    /// Utility UTC ("Coordinated Universal Time") TimeZone instance.
    public static var utc: TimeZone {
        TimeZone(abbreviation: "UTC")!
    }
}

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
