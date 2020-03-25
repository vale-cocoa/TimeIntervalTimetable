# TimeIntervalTimetable

A concrete `Schedule` type which represent a schedule timetable whose elements are occurring at a fixed `rate` interval, each having the same `duration` value. 

## Introduction
This concrete `Schedule` type is used for representing those common schedule timetables whose events repeats at a fixed time interval in time. 
Each element can't overlap on any other one, hence the `rate` at which events occour has to be less than or equal the `duration` of the events. 
Both quantities are expressed in seconds and the timetable has a 1 second precision.
A reference element starts on `Date(timeIntervalSinceReferenceDate: 0)`; since there is no calendric reference for this kind of schedule timetable, this point in time is used for generating elements starting before and after that date. 

## Usage
Aside for canonical `Schedule` protocol operations —already described in the `Schedule` protocol package— this type provides the `init(rate: duration:)` initializer. 
The initializer gets two parameters, `rate` and `duration` both of type `TimeInterval`, hence quantities expressed in seconds. In case the value of `duration` exceeds the value for `rate`, the initializer fails throwing an `TimeIntervalTimetable.Error.durationWiderThanRate` error.
Moreover both values are rounded in case they have a fractional part, using `FloatingPointRoundingRule.toNearestOrAwayFromZero` rounding rule, effectively setting the precision of element generation to 1 second.

```swift 
// duration execeeds rate, hence this call will throw:
do {
    let timetable = try TimeIntervalTimetable(rate: 900, duration: 3600)
    // …throws!
} catch {
    // …error thrown handling here…
}

// duration equal to rate, hence it won't throw in this case:
do {
    let timetable = try TimeIntervalTimetable(rate: 900, duration: 900)
} catch {
    // …won't throw btw!
}

// using the init() initializer will set both rate and duration to 0:
let empty = TimeIntervalTimetable()

// same as:
do {
let timetable = try TimeIntervalTimetable(rate: 0, duration: 0)
} catch {
    // …won't throw btw!
}
```
Alternatively a static method `validRateAndDurationFromDifferenceDateComponents(rateDC: durationDC:)` is also provided, and it accepts two `DateComponents` values, eventually returning a tuple with valid `rate` and `duration` values based on these given parameters. This method also throws when provided values are not suitable to calculate valid `TimeInterval` corrssponding value or if the resulting `duration` value is greater than `rate` value —hence not suitable for initializing a new instance.

```swift
let rateDC = DateComponents(hour: 1, minute: 30)
let durationDC = DateComponents(minute: 15)
do {
    let rateAndDuration = try TimeIntervalTimetable
        .validRateAndDurationFromDifferenceDateComponents(
            rateDC: rateDC
            durationDC: durationDC
    )
    
    let timetable = try TimeIntervalTimetable(
        rate: rateAndDuration.rate, 
        duration: rateAndDuration.duration
    )
} catch {
    // …won't throw since values are valid
}
```


