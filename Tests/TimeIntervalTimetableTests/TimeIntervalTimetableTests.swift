//
//  TimeIntervalTimetableTests
//  TimeIntervalTimetableTests.swift
//
//  Created by Valeriano Della Longa on 21/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import TimeIntervalTimetable

final class TimeIntervalTimetableTests: XCTestCase {
    
    func test_init_returnsEmpty() {
        // given
        // when
        let timetable = TimeIntervalTimetable()
        
        // then
        XCTAssertEqual(timetable.rate, 0.0)
        XCTAssertEqual(timetable.duration, 0.0)
    }
    
    func test_init_whenDurationIsGreaterThanRate_throws() {
        // given
        let rate = TimeInterval.random(in: 1.0...60.0)
        let duration = rate + 1.0
        
        // when
        // then
        XCTAssertThrowsError(try TimeIntervalTimetable(rate: rate, duration: duration), "rate: \(rate) - duration: \(duration)")
    }

    func test_init_whenDurationIsLessThanOrEqualRate_doesntThrow()
    {
        // given
        let rate = TimeInterval.random(in: 1.0...60.0)
        let durationLessThanRate = rate - 1.0
        let durationEqualRate = rate
        
        // when
        // then
        XCTAssertNoThrow(try TimeIntervalTimetable(rate: rate, duration: durationEqualRate))
        XCTAssertNoThrow(try TimeIntervalTimetable(rate: rate, duration: durationLessThanRate))
    }
    
    func test_init_whenDoesntThrow_setsDurationandRateToRoundedValues()
    {
        // given
        let rate = TimeInterval.random(in: 1.0...60.0)
        let duration = rate - 1.0
        let expectedRate = rate.rounded(.toNearestOrAwayFromZero)
        let expectedDuration = duration.rounded(.toNearestOrAwayFromZero)
        
        // when
        let timetable = try! TimeIntervalTimetable(rate: rate, duration: duration)
        
        // then
        XCTAssertEqual(timetable.rate, expectedRate)
        XCTAssertEqual(timetable.duration, expectedDuration)
    }
    
    func test_validRateAndDurationFrom_whenRateIsSmallerThanDuration_throwsExpectedError()
    {
        // given
        let rateDC = DateComponents(hour: 1)
        let durationDC = DateComponents(day: 1)
        let expectedResult = TimeIntervalTimetable.Error.durationWiderThanRate as NSError
        
        do {
            // when
            _ = try TimeIntervalTimetable.validRateAndDurationFromDifferenceDateComponents(rateDC: rateDC, durationDC: durationDC)
            
            // then
            XCTFail("Didn't throw error: rateDC: \(rateDC), durationDC: \(durationDC)")
        } catch {
            // when
            let resultError = error as NSError
            
            // then
            XCTAssertEqual(resultError.domain, expectedResult.domain)
            XCTAssertEqual(resultError.code, expectedResult.code)
        }
        
    }
    
    func test_validRateAndDurationFrom_whenRateIsGreaterThanOrEqualDuration_doesntThrow()
    {
        // given
        // when
        let rateDC = DateComponents(hour: 1)
        let equalDurationDC = DateComponents(hour: 1)
        let smallerDurationDC = DateComponents(minute: 15)
        
        // then
        XCTAssertNoThrow(try TimeIntervalTimetable.validRateAndDurationFromDifferenceDateComponents(rateDC: rateDC, durationDC: equalDurationDC))
        XCTAssertNoThrow(try TimeIntervalTimetable.validRateAndDurationFromDifferenceDateComponents(rateDC: rateDC, durationDC: smallerDurationDC))
    }
    
    func test_validRateAndDurationFrom_whenRateIsGreaterThanOrEqualDuration_returnsEcpectedValues()
    {
        // given
        let expectedResultForEqual: (TimeInterval, TimeInterval) = (3600.0, 3600.0)
        let expectedResultForSmaller: (TimeInterval, TimeInterval) = (3600.0, 900.0)
        
        // when
        let rateDC = DateComponents(hour: 1)
        let equalDurationDC = DateComponents(hour: 1)
        let smallerDurationDC = DateComponents(minute: 15)
        
        let resultForEqual = try! TimeIntervalTimetable.validRateAndDurationFromDifferenceDateComponents(rateDC: rateDC, durationDC: equalDurationDC)
        let resultForSmaller = try! TimeIntervalTimetable.validRateAndDurationFromDifferenceDateComponents(rateDC: rateDC, durationDC: smallerDurationDC)
        
        // then
        XCTAssertEqual(resultForEqual.0, expectedResultForEqual.0)
        XCTAssertEqual(resultForEqual.1, expectedResultForEqual.1)
        XCTAssertEqual(resultForSmaller.0, expectedResultForSmaller.0)
        XCTAssertEqual(resultForSmaller.1, expectedResultForSmaller.1)
    }
    
    static var allTests = [
        ("test_init_returnsEmpty", test_init_returnsEmpty),
        ("test_init_whenDurationIsGreaterThanRate_throws", test_init_whenDurationIsGreaterThanRate_throws),
        ("test_init_whenDurationIsLessThanOrEqualRate_doesntThrow", test_init_whenDurationIsLessThanOrEqualRate_doesntThrow),
        ("test_init_whenDoesntThrow_setsDurationandRateToRoundedValues", test_init_whenDoesntThrow_setsDurationandRateToRoundedValues),
        ("test_validRateAndDurationFrom_whenRateIsSmallerThanDuration_throwsExpectedError", test_validRateAndDurationFrom_whenRateIsSmallerThanDuration_throwsExpectedError),
        ("test_validRateAndDurationFrom_whenRateIsGreaterThanOrEqualDuration_doesntThrow", test_validRateAndDurationFrom_whenRateIsGreaterThanOrEqualDuration_doesntThrow),
        ("test_validRateAndDurationFrom_whenRateIsGreaterThanOrEqualDuration_returnsEcpectedValues", test_validRateAndDurationFrom_whenRateIsGreaterThanOrEqualDuration_returnsEcpectedValues),
        
    ]
}
