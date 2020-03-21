//
//  TimeIntervalTimetable
//  TimeIntervalTimetable.swift
//
//  Created by Valeriano Della Longa on 21/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation

/// A concrete `Schedule` type which represent a schedule timetable whose elements are occurring
///  at a fixed `rate` interval, each having the same `duration` value.
///
/// Each element of the schedule timetable occours starting from `referenceDate`; that is given a
/// `rate` value of `3600.0` and a `duration` value of `900.0`, there will be elements lasting
///  15 minutes each and starting every hour before, on and after
///   `Date(timeIntervalSinceReferenceDay: 0)`.
public struct TimeIntervalTimetable {
    /// Errors thrown by this type.
    public enum Error: Swift.Error {
        /// The given `duration` parameter was wider than the given `rate` one.
        case durationWiderThanRate
        
        /// Given date components are invalid for calculating the distance from reference date.
        case invalidDateComponents
    }
    
    /// The rate at which every element of the timetable occurs in time.
    public let rate: TimeInterval
    
    /// The duration of each scheduled event of the timetable.
    public let duration: TimeInterval
    
    /// Returns an instance of `TimeIntervalTimetable` with `rate` and `duration`
    ///  values both set to `0.0`.
    ///
    /// That is by using `init()` an empty timetable schedule is returned.
    public init() {
        self.rate = 0.0
        self.duration = 0.0
    }
    
    /// Returns a`TimeIntervalTimetable`instance  initalized to given parameters.
    ///
    ///
    /// - Parameter rate: The rate at which every elementof the timetable  occur.
    /// Must be greater than or equal 0.
    /// - Parameter duration: The duration of each schedule event of the timetable.
    /// Must be greater than or equal 0.
    /// - Returns: A `TimeIntervalTimetable`instance.
    /// - Throws: `Error.durationWiderThanRate` when given `duration` param
    ///  exceeds given `rate` one.
    /// - Note: Both given parameters are rounded using
    ///  `FloatingPointRoundingRule.towardZero` rounding rule. Thus precision of the
    ///  timetable is to seconds.
    public init(rate: TimeInterval, duration: TimeInterval) throws
    {
        let roundedRate = abs(rate.rounded(.towardZero))
        let roundedDuration = abs(duration.rounded(.towardZero))
        guard
            roundedDuration <= roundedRate
            else { throw Error.durationWiderThanRate }
        
        self.rate = roundedRate
        self.duration = roundedDuration
    }
    
    /// Returns valid `rate` and `duration` values from given `DateComponents` values,
    /// each representing the distance between `referenceDate` and the value to obtain.
    ///
    /// That is each value will be calculated by using the `DateComponents` parameter to
    /// calculate a corresponding `TimeInterval` value from
    ///  `Date(TimeIntervalSinceReferenceDate: 0)` date.
    /// - Parameter rateDC: The difference from reference date expressed in
    /// `DateComponents` for calculating the a valid `rate` value.
    /// - Parameter durationDC: The difference from reference date expressed in
    /// `DateComponents` for calculating a valid `duration` value.
    /// - Returns: a tuple containig both `rate` and `duration` valid for safely initialize a
    /// `TimeIntervalTable` instance.
    /// - Throws:`Error.invalidDateComponents` when it was impossible to extract a date
    /// from one or both given parameters. `Error.durationWiderThanRate` when calculated
    /// and rounded values are not valid in respect of `duration` less than or equal `rate`.
    public static func validRateAndDurationFromDifferenceDateComponents(
        rateDC: DateComponents,
        durationDC: DateComponents
    ) throws
        -> (rate: TimeInterval, duration: TimeInterval)
    {
        let refDate = Date(timeIntervalSinceReferenceDate: 0)
        guard
            let rateDate = Calendar.current.date(byAdding: rateDC, to: refDate),
            let durationDate = Calendar.current.date(byAdding: durationDC, to: refDate)
            else { throw Error.invalidDateComponents }
        
        let rate = abs(refDate.distance(to: rateDate))
            .rounded(.towardZero)
        let duration = abs(refDate.distance(to: durationDate))
            .rounded(.towardZero)
        guard
            duration <= rate
            else { throw Error.durationWiderThanRate }
        
        return (rate, duration)
    }
    
}
