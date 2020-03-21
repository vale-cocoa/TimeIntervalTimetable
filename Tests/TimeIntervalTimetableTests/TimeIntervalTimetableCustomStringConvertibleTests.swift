//
// TimeIntervalTimetableTests
// TimeIntervalTimetableCustomStringConvertibleTests.swift
//  
//  Created by Valeriano Della Longa on 21/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import TimeIntervalTimetable

final class TimeIntervalTimetableCustomStringConvertibleTests: XCTestCase
{
    func test_description_returnsExpectedValue() {
        // given
        let rate: TimeInterval = 3600.0
        let duration: TimeInterval = 900.0
        let timetable = try! TimeIntervalTimetable(rate: rate, duration: duration)
        let expectedResult = "Rate: \(TimeIntervalTimetable._formatter.string(from: rate)!) - Duration: \(TimeIntervalTimetable._formatter.string(from: duration)!)"
        
        // when
        // then
        XCTAssertEqual(timetable.description, expectedResult)
        
    }
    
    static var allTests = [
        ("test_description_returnsExpectedValue", test_description_returnsExpectedValue),
        
    ]
    
}
