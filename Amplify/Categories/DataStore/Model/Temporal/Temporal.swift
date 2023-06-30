//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// `Temporal` is namespace to all temporal types and basic date operations. It can
/// not be directly instantiated.
///
///  Available `Temporal` `Specs`
/// - Temporal.Date
/// - Temporal.DateTime
/// - Temporal.Time
public enum Temporal {}

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
    /// - SeeAlso: `iso8601FormattedString(TemporalFormat, TimeZone) -> String`
    var iso8601String: String { get }
  
    /// The underlying `TimeZone` object. Specifies the format of converted ISO-8601 string.
    /// - seealso: iso8601FormattedString(TemporalFormat, TimeZone) -> String
    var localTimezone: TimeZone? { get set }

    /// Parses an ISO-8601 `String` into a `TemporalSpec`.
    ///
    /// - Note: if no timezone is present in the string, `.autoupdatingCurrent` is used.
    ///
    /// - Parameters
    ///  - iso8601String: the string in the ISO8601 format
    /// - Throws: `DataStoreError.decodeError` in case the provided string is not
    /// formatted as expected by the scalar type.
    /// - Important: This will cycle through all available formats for the concrete type.
    /// If you know the format, use `init(iso8601String:format:) throws` instead.
    init(iso8601String: String) throws

    /// Parses an ISO-8601 `String` into a `TemporalSpec`.
    ///
    /// - Note: if no timezone is present in the string, `.autoupdatingCurrent` is used.
    ///
    /// - Parameters
    ///  - iso8601String: the string in the ISO8601 format
    ///  - format: The `TemporalFormat` of the `iso8601String`
    /// - Throws: `DataStoreError.decodeError` in case the provided string is not
    /// formatted as expected by the scalar type.
    init(iso8601String: String, format: TemporalFormat) throws

    /// Constructs a `TemporalSpec` from a `Date` object.
    /// - Parameter date: The `Date` instance that will be used as the reference of the
    /// `TemporalSpec` instance.
    init(_ date: Foundation.Date)

    /// A string representation of the underlying date formatted using ISO8601 rules.
    ///
    /// - Parameters:
    ///   - format: the desired `TemporalFormat`.
    ///   - timeZone: the target `TimeZone`
    /// - Returns: the ISO8601 formatted string in the requested format
    func iso8601FormattedString(format: TemporalFormat, timeZone: TimeZone) -> String
}

extension TemporalSpec {

    /// Create an iso8601 `String` with the desired format option for this spec.
    /// - Parameters:
    ///   - format: Format to use for `Date` -> `String` conversion.
    ///   - timeZone: `TimeZone` that the `DateFormatter` will use in conversion.
    ///   Default is `.utc` a.k.a. `TimeZone(abbreviation: "UTC")`
    /// - Returns: A `String` formatted according to the `format` and `timeZone` arguments.
    public func iso8601FormattedString(
        format: TemporalFormat,
        timeZone: TimeZone = .utc
    ) -> String {
        Temporal.string(
            from: foundationDate,
            with: format(for: Self.self),
            in: timeZone
        )
    }


    /// The ISO8601 representation of the scalar using `.full` as the format and `.utc` as `TimeZone`.
    /// - SeeAlso: `iso8601FormattedString(format:timeZone:)`
    public var iso8601String: String {
      iso8601FormattedString(format: .full, timeZone: localTimezone ?? .utc)
    }

    @inlinable
    public init(iso8601String: String, format: TemporalFormat) throws {
        let date = try SpecBasedDateConverting<Self>()
            .convert(iso8601String, format)

        self.init(date)
    }

    @inlinable
    public init(
        iso8601String: String
    ) throws {
        let date = try SpecBasedDateConverting<Self>()
            .convert(iso8601String, nil)

        self.init(date)
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
