//
//  TimeIntervalTimetableTests
//  TimeIntervalTimetableScheduleTests.swift
//  
//  Created by Valeriano Della Longa on 22/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import TimeIntervalTimetable

final class TimeIntervalTimetableScheduleTests: XCTestCase {
    var sut: TimeIntervalTimetable!
    
    let refDate = Date(timeIntervalSinceReferenceDate: 0)
    let oneHour: TimeInterval = 60*60
    let fifteenMinutes: TimeInterval = 15*60
    let fiveMinutes: TimeInterval = 5*60
    
    // MARK: - Tests lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    
    func givenRandomWideDateInterval() -> DateInterval
    {
        let randomMinutes = Int.random(in: 5...60)
        let randomShiftDivider = Int.random(in: 1...3)
        let randomTimes = Int.random(in: 0..<100_000)
        let randomDurationTimes = Int.random(in: 10_000..<100_000)
        let shift = TimeInterval(randomMinutes / randomShiftDivider)
        let startDistance = TimeInterval(randomTimes * randomMinutes)
        let duration = TimeInterval(randomMinutes * randomDurationTimes)
        let start = Bool.random() ? Date(timeIntervalSinceReferenceDate: -startDistance - shift) : Date(timeIntervalSinceReferenceDate: startDistance - shift)
        
        return DateInterval(start: start, duration: duration)
    }
    
    // MARK: - When
    func whenRateIsEqualToZero() {
        sut = try! TimeIntervalTimetable(rate: 0.0, duration: 0.0)
    }
    
    func whenRateIsGreaterThanZeroAndEqualDuration() {
        sut = try! TimeIntervalTimetable(rate: oneHour, duration: oneHour)
    }
    
    func whenRateIsGreaterThanZeroAndGreaterThanDuration() {
        sut = try! TimeIntervalTimetable(rate: oneHour, duration: fifteenMinutes)
    }
    
    func whenNotEmpty_cases() -> [() -> Void] {
        return [
            self.whenRateIsGreaterThanZeroAndEqualDuration,
            self.whenRateIsGreaterThanZeroAndGreaterThanDuration
        ]
    }
    
    func whenDateInRandomElement() -> Date {
        whenRateIsGreaterThanZeroAndGreaterThanDuration()
        
        let randomTimes = Int.random(in: 0..<100_000)
        let rateTimes = Bool.random() ? TimeInterval(-randomTimes) : TimeInterval(randomTimes)
        
        let distance = (sut.rate * rateTimes) + (sut.duration * 2/3)
        
        return refDate.addingTimeInterval(distance)
    }
    
    func whenDateNotInRandomElement() -> Date {
        whenRateIsGreaterThanZeroAndGreaterThanDuration()
        
        let randomTimes = Int.random(in: 0..<100_000)
        let rateTimes = Bool.random() ? TimeInterval(-randomTimes) : TimeInterval(randomTimes)
        
        let distance = (sut.rate * rateTimes) - (sut.duration / 3)
        
        return refDate.addingTimeInterval(distance)
    }
    
    func whenElementStartingOnRefDate() -> DateInterval {
        whenRateIsGreaterThanZeroAndGreaterThanDuration()
        
        return DateInterval(start: refDate, duration: sut.duration)
    }
    
    func whenDateIntervalDurationIsEqualDurationStartsOnElementStart() -> DateInterval
    {
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = sut.rate * TimeInterval(randomTimes)
        let start = Bool.random() ? refDate.addingTimeInterval(-distance) : refDate.addingTimeInterval(distance)
        
        return DateInterval(start: start, duration: sut.duration)
    }
    
    func whenDateIntervalDurationIsEqualDurationStartsBeforeElementStart() -> DateInterval
    {
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = sut.rate * TimeInterval(randomTimes)
        let shift = sut.duration / 3
        let start = Bool.random() ? refDate.addingTimeInterval(-distance - shift) : refDate.addingTimeInterval(distance - shift)
        
        return DateInterval(start: start, duration: sut.duration)
    }
    
    func whenDateIntervalDurationIsEqualDurationStartsAfterElementStart() -> DateInterval
    {
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = sut.rate * TimeInterval(randomTimes)
        let shift = sut.duration / 3
        let start = Bool.random() ? refDate.addingTimeInterval(-distance + shift) : refDate.addingTimeInterval(distance + shift)
        
        return DateInterval(start: start, duration: sut.duration)
    }
    
    func whenDateIntervalDurationIsEqualRateStartsOnElementStart() -> DateInterval
    {
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = sut.rate * TimeInterval(randomTimes)
        let start = Bool.random() ? refDate.addingTimeInterval(-distance) : refDate.addingTimeInterval(distance)
        
        return DateInterval(start: start, duration: sut.rate)
    }
    
    func whenDateIntervalDurationIsEqualRatePossibilyContainigAnElement() -> DateInterval
    {
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = sut.rate * TimeInterval(randomTimes)
        let shift = sut.duration / 3
        let start = Bool.random() ? refDate.addingTimeInterval(-distance - shift) : refDate.addingTimeInterval(distance - shift)
        
        return DateInterval(start: start, duration: sut.rate)
    }
    
    func whenDateIntervalDurationIsEqualRateNotContainigAnElement() -> DateInterval
    {
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = sut.rate * TimeInterval(randomTimes)
        let shift = sut.duration / 3
        let start = Bool.random() ? refDate.addingTimeInterval(-distance + shift) : refDate.addingTimeInterval(distance + shift)
        
        return DateInterval(start: start, duration: sut.rate)
    }
    
    // MARK: - Tests
    // MARK: - isEmpty() tests
    func test_isEmpty_whenRateIsEqualToZero_returnsTrue()
    {
        // given
        // when
        whenRateIsEqualToZero()
        
        // then
        XCTAssertTrue(sut.isEmpty)
    }
    
    func test_isEmpty_whenRateIsGreaterThanZero_returnsFalse()
    {
        // given
        for whenCase in whenNotEmpty_cases()
        {
            // when
            whenCase()
            
            // then
            XCTAssertFalse(sut.isEmpty)
        }
    }
    
    // MARK: - contains(_:) tests
    func test_contains_whenIsEmtpy_returnsFalse()
    {
        // given
        let randomDistance = TimeInterval.random(in: 1.0..<24.0*oneHour)
        let randomAfterRefDate = Date(timeIntervalSinceReferenceDate: randomDistance)
        let randomBeforeRefDate = Date(timeIntervalSinceReferenceDate: -randomDistance)
        
        // when
        whenRateIsEqualToZero()
        
        // then
        XCTAssertFalse(sut.contains(refDate))
        XCTAssertFalse(sut.contains(randomAfterRefDate))
        XCTAssertFalse(sut.contains(randomBeforeRefDate))
    }
    
    func test_contains_whenDurationIsEqualToRate_returnsTrue() {
        // given
        let randomDistance = TimeInterval.random(in: 1.0..<24.0*oneHour)
        let randomAfterRefDate = Date(timeIntervalSinceReferenceDate: randomDistance)
        let randomBeforeRefDate = Date(timeIntervalSinceReferenceDate: -randomDistance)
        
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        
        // then
        XCTAssertTrue(sut.contains(refDate))
        XCTAssertTrue(sut.contains(randomAfterRefDate))
        XCTAssertTrue(sut.contains(randomBeforeRefDate))
    }
    
    func test_contains_whenDateContainedInElement_returnsTrue()
    {
        // given
        // when
        let date = whenDateInRandomElement()
        
        // then
        XCTAssertTrue(sut.contains(date))
    }
    
    func test_contains_whenDateNotContainedInElement_returnsFalse()
    {
        // given
        // when
        let date = whenDateNotInRandomElement()
        
        // then
        XCTAssertFalse(sut.contains(date))
    }
    
    // MARK: - schedule(matching:direction:) tests
    func test_scheduleMatching_whenEmpty_returnsNil()
    {
        // given
        // when
        whenRateIsEqualToZero()
        
        let randomTimeInterval = TimeInterval.random(in: 0..<100_000)
        let distance = Bool.random() ? -randomTimeInterval : randomTimeInterval
        let date = Date(timeIntervalSinceReferenceDate: distance)
        
        // then
        XCTAssertNil(sut.schedule(matching: date, direction: .on))
        XCTAssertNil(sut.schedule(matching: date, direction: .firstAfter))
        XCTAssertNil(sut.schedule(matching: date, direction: .firstBefore))
    }
    
    func test_scheduleMatching_on_whenDateNotInElement_returnsNil()
    {
        // given
        // when
        let date = whenDateNotInRandomElement()
        
        XCTAssertNil(sut.schedule(matching: date, direction: .on))
    }
    
    func test_scheduleMatching_on_whenDateInElement_doesntReturnNil()
    {
        // given
        // when
        let date = whenDateInRandomElement()
        
        // then
        XCTAssertNotNil(sut.schedule(matching: date, direction: .on))
    }
    
    func test_scheduleMatching_on_whenDateInElement_returnsElementContainigIt()
    {
        // given
        // when
        let date = whenDateInRandomElement()
        let result = sut.schedule(matching: date, direction: .on)!
        
        // then
        XCTAssertLessThanOrEqual(result.start, date)
        XCTAssertGreaterThanOrEqual(result.end, date)
    }
    
    func test_scheduleMatching_firstAfter_whenDateInElement_doesntReturnNil()
    {
        // given
        // when
        let date = whenDateInRandomElement()
        
        // then
        XCTAssertNotNil(sut.schedule(matching: date, direction: .firstAfter))
    }
    func test_scheduleMatching_firstAfter_whenDateInElement_returnsNextElement()
    {
        // given
        // when
        let date = whenDateInRandomElement()
        let result = sut.schedule(matching: date, direction: .firstAfter)!
        let resultOnDate = sut.schedule(matching: date, direction: .on)!
        
        // then
        XCTAssertGreaterThanOrEqual(result.start, resultOnDate.end)
    }
    
    func test_scheduleMatching_firstAfter_whenDateNotInElement_doesntReturnNil()
    {
        // given
        // when
        let date = whenDateNotInRandomElement()
        
        // then
        XCTAssertNotNil(sut.schedule(matching: date, direction: .firstAfter))
    }
    
    func test_scheduleMatching_firstAfter_whenDateNotInElement_returnsFirstElementStartingAfterDate()
    {
        // given
        // when
        let date = whenDateNotInRandomElement()
        let result = sut.schedule(matching: date, direction: .firstAfter)!
        let elementBeforeResult = DateInterval(start: result.start.addingTimeInterval(-sut.rate), duration: sut.duration)
        
        // then
        XCTAssertGreaterThan(date, elementBeforeResult.end)
        XCTAssertLessThan(date, result.start)
    }
    
    func test_scheduleMatching_firstBefore_whenDateInElement_doesntReturnNil()
    {
        // given
        // when
        let date = whenDateInRandomElement()
        
        // then
        XCTAssertNotNil(sut.schedule(matching: date, direction: .firstBefore))
    }
    
    func test_scheduleMatching_firstBefore_whenDateInElement_returnsPreviousElement()
    {
        // given
        // when
        let date = whenDateInRandomElement()
        let result = sut.schedule(matching: date, direction: .firstBefore)!
        let resultOnDate = sut.schedule(matching: date, direction: .on)!
        
        // then
        XCTAssertLessThanOrEqual(result.end, resultOnDate.start)
    }
    
    func test_scheduleMatching_firstBefore_whenDateNotInElement_doesntReturnNil()
    {
        // given
        // when
        let date = whenDateNotInRandomElement()
        
        // then
        XCTAssertNotNil(sut.schedule(matching: date, direction: .firstBefore))
    }
    
    func test_scheduleMatching_firstBefore_whenDateNotInElementElement_returnsFirstElementStartingBeforeDate()
    {
        // given
        // when
        let date = whenDateNotInRandomElement()
        let result = sut.schedule(matching: date, direction: .firstBefore)!
        let elementAfterResult = DateInterval(start: result.start.addingTimeInterval(sut.rate), duration: sut.duration)
        
        // then
        XCTAssertLessThan(date, elementAfterResult.start)
        XCTAssertGreaterThanOrEqual(date, result.end, "result: \(result) - date: \(date) - elementAfterResult: \(elementAfterResult)")
    }
    
    func test_scheduleMatching_on_whenRateEqaulDuration_doesntReturnNil()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = TimeInterval(randomTimes) * sut.rate
        let date = Bool.random() ? refDate.addingTimeInterval(-distance - (sut.duration / 3)) : refDate.addingTimeInterval(distance - (sut.duration / 3))
        
        // then
        XCTAssertNotNil(sut.schedule(matching: date, direction: .on))
    }
    
    func test_scheduleMatching_on_whenRateEqualDuration_returnsElementContainigIt()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = TimeInterval(randomTimes) * sut.rate
        let date = Bool.random() ? refDate.addingTimeInterval(-distance - (sut.duration / 3)) : refDate.addingTimeInterval(distance - (sut.duration / 3))
        let result = sut.schedule(matching: date, direction: .on)!
        
        // then
        XCTAssertGreaterThanOrEqual(date, result.start)
        XCTAssertLessThan(date, result.end)
    }
    
    
    func test_scheduleMatching_on_whenRateEqualDurationDateIsElementStartDate_returnsElement()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        
        let randomTimes = Int.random(in: 0..<100_000)
        let times: TimeInterval = Bool.random() ? TimeInterval(-randomTimes) : TimeInterval(randomTimes)
        let distance = times * sut.rate
        let date = refDate.addingTimeInterval(distance)
        let result = sut.schedule(matching: date, direction: .on)!
        
        // then
        XCTAssertGreaterThanOrEqual(date, result.start)
        XCTAssertLessThan(date, result.end)
    }
    
    func test_scheduleMatching_on_whenRateEqualDurationDateIsEndOfElement_returnsNextElement()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        
        let randomTimes = Int.random(in: 0..<100_000)
        let times: TimeInterval = Bool.random() ? TimeInterval(-randomTimes) : TimeInterval(randomTimes)
        let distance = times * sut.rate
        let date = refDate
            .addingTimeInterval(distance)
            .addingTimeInterval(sut.duration)
        let result = sut.schedule(matching: date, direction: .on)!
        
        // then
        XCTAssertEqual(date, result.start)
        XCTAssertLessThan(date, result.end)
    }
    
    func test_scheduleMatching_firstBefore_whenRateEqualDuration_doesntReturnNil()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = TimeInterval(randomTimes) * sut.rate
        let date = Bool.random() ? refDate.addingTimeInterval(-distance - (sut.duration / 3)) : refDate.addingTimeInterval(distance - (sut.duration / 3))
        
        // then
        XCTAssertNotNil(sut.schedule(matching: date, direction: .firstBefore))
    }
    
    func test_scheduleMatching_firstBefore_whenRateEqualDuration_returnsElementBeforeElementContainigDate()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = TimeInterval(randomTimes) * sut.rate
        let date = Bool.random() ? refDate.addingTimeInterval(-distance - (sut.duration / 3)) : refDate.addingTimeInterval(distance - (sut.duration / 3))
        let result = sut.schedule(matching: date, direction: .firstBefore)!
        let resultOn = sut.schedule(matching: date, direction: .on)!
        
        // then
        XCTAssertEqual(result.end, resultOn.start)
    }
    
    func test_scheduleMatching_firstBefore_whenRateEqualDurationDateIsElementStart_returnsElementBefore()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = TimeInterval(randomTimes) * sut.rate
        let date = Bool.random() ? refDate.addingTimeInterval(-distance) : refDate.addingTimeInterval(distance)
        let result = sut.schedule(matching: date, direction: .firstBefore)!
        let resultOn = sut.schedule(matching: date, direction: .on)!
        
        // then
        XCTAssertEqual(result.end, resultOn.start)
    }
    
    func test_scheduleMatching_firstBefore_whenRateEqualDurationDateIsEndOfElement_returnsElement()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = TimeInterval(randomTimes) * sut.rate
        let date = Bool.random() ? refDate.addingTimeInterval(-distance + sut.duration) : refDate.addingTimeInterval(distance + sut.duration)
        let result = sut.schedule(matching: date, direction: .firstBefore)!
        
        // then
        XCTAssertEqual(result.end, date)
        XCTAssertEqual(result.start, date.addingTimeInterval(-sut.duration))
    }
    
    func test_scheduleMatching_firstAfter_whenRateEqaulDuration_doenstReturnNil()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = TimeInterval(randomTimes) * sut.rate
        let date = Bool.random() ? refDate.addingTimeInterval(-distance - (sut.duration / 3)) : refDate.addingTimeInterval(distance - (sut.duration / 3))
        
        // then
        XCTAssertNotNil(sut.schedule(matching: date, direction: .firstAfter))
    }
    
    
    func test_scheduleMatching_firstAfter_whenRateEqualDuration_returnsElementAfterElementContaningDate()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = TimeInterval(randomTimes) * sut.rate
        let date = Bool.random() ? refDate.addingTimeInterval(-distance - (sut.duration / 3)) : refDate.addingTimeInterval(distance - (sut.duration / 3))
        let result = sut.schedule(matching: date, direction: .firstAfter)!
        let resultOn = sut.schedule(matching: date, direction: .on)!
        
        // then
        XCTAssertEqual(result.start, resultOn.end)
    }
    
    func test_scheduleMatching_firstAfter_whenRateEqualDurationDateIsElementStart_returnsElementAfter()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = TimeInterval(randomTimes) * sut.rate
        let date = Bool.random() ? refDate.addingTimeInterval(-distance) : refDate.addingTimeInterval(distance)
        let result = sut.schedule(matching: date, direction: .firstAfter)!
        let resultOn = sut.schedule(matching: date, direction: .on)!
        
        // then
        XCTAssertEqual(result.start, resultOn.end)
    }
    
    func test_scheduleMatching_firstAfter_whenRateEqualDurationDateIsElementEnd_returnsElementAfter()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        let randomTimes = Int.random(in: 0..<100_000)
        let distance = TimeInterval(randomTimes) * sut.rate
        let date = Bool.random() ? refDate.addingTimeInterval(-distance + sut.duration) : refDate.addingTimeInterval(distance + sut.duration)
        let result = sut.schedule(matching: date, direction: .firstAfter)!
        let resultOn = sut.schedule(matching: date, direction: .on)!
        
        // then
        XCTAssertEqual(result.start, resultOn.end)
        XCTAssertEqual(date, resultOn.start)
    }
    
    // MARK: - schedule(in:queue:then) tests
    func test_scheduleIn_completionExecutes()
    {
        // given
        // when
        whenRateIsEqualToZero()
        let dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
        let exp = expectation(description: "completion executes")
        var completionExecuted = false
        sut.schedule(in: dateInterval, queue: nil, then: { _ in
            completionExecuted = true
            exp.fulfill()
        })
        
        // then
        wait(for: [exp], timeout: 0.2)
        XCTAssertTrue(completionExecuted)
    }
    
    func test_scheduleIn_whenQueueIsNil_completionDoesntExecutesOnMainThread()
    {
        // given
        // when
        whenRateIsEqualToZero()
        let dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
        let exp = expectation(description: "completion executes")
        var thread: Thread!
        sut.schedule(in: dateInterval, queue: nil, then: { _ in
            thread = .current
            exp.fulfill()
        })
        
        // then
        wait(for: [exp], timeout: 0.2)
        XCTAssertNotEqual(thread, .main)
    }
    
    func test_scheduleIn_whenQueueIsNotNil_completionExecutesOnQueue()
    {
        // given
        // when
        whenRateIsEqualToZero()
        let dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
        let exp = expectation(description: "completion executes")
        var thread: Thread!
        sut.schedule(in: dateInterval, queue: .main, then: { _ in
            thread = .current
            exp.fulfill()
        })
        
        // then
        wait(for: [exp], timeout: 0.2)
        XCTAssertEqual(thread, .main)
    }
    
    func test_scheduleIn_whenIsEmpty_returnsSuccessWithEmptyElements()
    {
        // given
        // when
        whenRateIsEqualToZero()
        let dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
        let exp = expectation(description: "completion executes")
        var result: Result<[DateInterval], Swift.Error>!
        sut.schedule(in: dateInterval, queue: nil, then: {
            result = $0
            exp.fulfill()
        })
        
        // then
        wait(for: [exp], timeout: 0.2)
        guard
            case .success(let elements) = result
            else {
               XCTFail("Returned .failure")
                
                return
        }
        
        XCTAssertTrue(elements.isEmpty)
    }
    
    func test_scheduleIn_whenRateGreaterThanDurationDateIntervalEqualDurationOrLessThanEqualRate_returnsSuccess()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndGreaterThanDuration()
        let dateIntervals = [
            whenDateIntervalDurationIsEqualRateStartsOnElementStart(),
            whenDateIntervalDurationIsEqualDurationStartsBeforeElementStart(),
            whenDateIntervalDurationIsEqualDurationStartsAfterElementStart(),
            whenDateIntervalDurationIsEqualRatePossibilyContainigAnElement(),
            whenDateIntervalDurationIsEqualRateStartsOnElementStart(),
            whenDateIntervalDurationIsEqualRateNotContainigAnElement()
        ]
        for dateInterval in dateIntervals
        {
            var result: Result<[DateInterval], Swift.Error>!
            let exp = expectation(description: "completion executes")
            sut.schedule(in: dateInterval, queue: nil, then: {
                result = $0
                exp.fulfill()
            })
            
            // then
            wait(for: [exp], timeout: 0.2)
            guard case .success(_) = result else {
                XCTFail("Returned .failure")
                
                return
            }
        }
    }
    
    func test_scheduleIn_whenRateEqualDurationDateIntervalEqualDurationOrLessThanEqualRate_returnsSuccess()
    {
        // given
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        let dateIntervals = [
            whenDateIntervalDurationIsEqualRateStartsOnElementStart(),
            whenDateIntervalDurationIsEqualDurationStartsBeforeElementStart(),
            whenDateIntervalDurationIsEqualDurationStartsAfterElementStart(),
            whenDateIntervalDurationIsEqualRatePossibilyContainigAnElement(),
            whenDateIntervalDurationIsEqualRateStartsOnElementStart(),
            whenDateIntervalDurationIsEqualRateNotContainigAnElement()
        ]
        for dateInterval in dateIntervals
        {
            var result: Result<[DateInterval], Swift.Error>!
            let exp = expectation(description: "completion executes")
            sut.schedule(in: dateInterval, queue: nil, then: {
                result = $0
                exp.fulfill()
            })
            
            // then
            wait(for: [exp], timeout: 0.2)
            guard case .success(_) = result else {
                XCTFail("Returned .failure")
                
                return
            }
        }
    }
    
    func test_scheduleIn_whenRateGreaterThanDuration_returnsSuccessWithExpectedElements()
    {
        // given
        let randomWideDateInterval = givenRandomWideDateInterval()
        
        // when
        whenRateIsGreaterThanZeroAndGreaterThanDuration()
        
        let dateIntervals = [
            whenDateIntervalDurationIsEqualRateStartsOnElementStart(),
            whenDateIntervalDurationIsEqualDurationStartsBeforeElementStart(),
            whenDateIntervalDurationIsEqualDurationStartsAfterElementStart(),
            whenDateIntervalDurationIsEqualRatePossibilyContainigAnElement(),
            whenDateIntervalDurationIsEqualRateStartsOnElementStart(),
            whenDateIntervalDurationIsEqualRateNotContainigAnElement(),
            randomWideDateInterval
        ]
        for dateInterval in dateIntervals
        {
            let expectedElements = Array(sut.generate(start: dateInterval.start, end: dateInterval.end))
            var result: Result<[DateInterval], Swift.Error>!
            let exp = expectation(description: "completion executes")
            sut.schedule(in: dateInterval, queue: nil, then: {
                result = $0
                exp.fulfill()
            })
            
            // then
            wait(for: [exp], timeout: 2.0)
            guard case .success(let resultElements) = result else {
                XCTFail("Returned .failure")
                
                return
            }
            XCTAssertEqual(resultElements, expectedElements, "DateInterval: \(dateInterval)")
        }
    }
    
    func test_scheduleIn_whenRateEqualDuration_returnsSuccessWithExpectedElements()
    {
        // given
        let randomWideDateInterval = givenRandomWideDateInterval()
        
        // when
        whenRateIsGreaterThanZeroAndEqualDuration()
        
        let dateIntervals = [
            whenDateIntervalDurationIsEqualRateStartsOnElementStart(),
            whenDateIntervalDurationIsEqualDurationStartsBeforeElementStart(),
            whenDateIntervalDurationIsEqualDurationStartsAfterElementStart(),
            whenDateIntervalDurationIsEqualRatePossibilyContainigAnElement(),
            whenDateIntervalDurationIsEqualRateStartsOnElementStart(),
            whenDateIntervalDurationIsEqualRateNotContainigAnElement(),
            randomWideDateInterval
        ]
        for dateInterval in dateIntervals
        {
            let expectedElements = Array(sut.generate(start: dateInterval.start, end: dateInterval.end))
            var result: Result<[DateInterval], Swift.Error>!
            let exp = expectation(description: "completion executes")
            sut.schedule(in: dateInterval, queue: nil, then: {
                result = $0
                exp.fulfill()
            })
            
            // then
            wait(for: [exp], timeout: 2.0)
            guard case .success(let resultElements) = result else {
                XCTFail("Returned .failure")
                
                return
            }
            XCTAssertEqual(resultElements, expectedElements, "DateInterval: \(dateInterval)")
        }
    }
    
    static var allTests = [
        ("test_isEmpty_whenRateIsEqualToZero_returnsTrue", test_isEmpty_whenRateIsEqualToZero_returnsTrue),
        ("test_isEmpty_whenRateIsGreaterThanZero_returnsFalse", test_isEmpty_whenRateIsGreaterThanZero_returnsFalse),
        ("test_contains_whenIsEmtpy_returnsFalse", test_contains_whenIsEmtpy_returnsFalse),
        ("test_contains_whenDurationIsEqualToRate_returnsTrue", test_contains_whenDurationIsEqualToRate_returnsTrue),
        ("test_contains_whenDateContainedInElement_returnsTrue", test_contains_whenDateContainedInElement_returnsTrue),
        ("test_contains_whenDateNotContainedInElement_returnsFalse", test_contains_whenDateNotContainedInElement_returnsFalse),
        ("test_scheduleMatching_whenEmpty_returnsNil", test_scheduleMatching_whenEmpty_returnsNil),
        ("test_scheduleMatching_on_whenDateNotInElement_returnsNil", test_scheduleMatching_on_whenDateNotInElement_returnsNil),
        ("test_scheduleMatching_on_whenDateInElement_doesntReturnNil", test_scheduleMatching_on_whenDateInElement_doesntReturnNil),
        ("test_scheduleMatching_on_whenDateInElement_returnsElementContainigIt", test_scheduleMatching_on_whenDateInElement_returnsElementContainigIt),
        ("test_scheduleMatching_firstAfter_whenDateInElement_doesntReturnNil", test_scheduleMatching_firstAfter_whenDateInElement_doesntReturnNil),
        ("test_scheduleMatching_firstAfter_whenDateInElement_returnsNextElement", test_scheduleMatching_firstAfter_whenDateInElement_returnsNextElement),
        ("test_scheduleMatching_firstAfter_whenDateNotInElement_doesntReturnNil", test_scheduleMatching_firstAfter_whenDateNotInElement_doesntReturnNil),
        ("test_scheduleMatching_firstAfter_whenDateNotInElement_returnsFirstElementStartingAfterDate", test_scheduleMatching_firstAfter_whenDateNotInElement_returnsFirstElementStartingAfterDate),
        ("test_scheduleMatching_firstBefore_whenDateInElement_doesntReturnNil", test_scheduleMatching_firstBefore_whenDateInElement_doesntReturnNil),
        ("test_scheduleMatching_firstBefore_whenDateInElement_returnsPreviousElement", test_scheduleMatching_firstBefore_whenDateInElement_returnsPreviousElement),
        ("test_scheduleMatching_firstBefore_whenDateNotInElement_doesntReturnNil", test_scheduleMatching_firstBefore_whenDateNotInElement_doesntReturnNil),
        ("test_scheduleMatching_firstBefore_whenDateNotInElementElement_returnsFirstElementStartingBeforeDate", test_scheduleMatching_firstBefore_whenDateNotInElementElement_returnsFirstElementStartingBeforeDate),
        ("test_scheduleMatching_on_whenRateEqualDuration_returnsElementContainigIt", test_scheduleMatching_on_whenRateEqualDuration_returnsElementContainigIt),
        ("test_scheduleMatching_on_whenRateEqualDurationDateIsElementStartDate_returnsElement", test_scheduleMatching_on_whenRateEqualDurationDateIsElementStartDate_returnsElement),
        ("test_scheduleMatching_on_whenRateEqualDurationDateIsEndOfElement_returnsNextElement", test_scheduleMatching_on_whenRateEqualDurationDateIsEndOfElement_returnsNextElement),
        ("test_scheduleMatching_firstBefore_whenRateEqualDuration_doesntReturnNil", test_scheduleMatching_firstBefore_whenRateEqualDuration_doesntReturnNil),
        ("test_scheduleMatching_firstBefore_whenRateEqualDuration_returnsElementBeforeElementContainigDate", test_scheduleMatching_firstBefore_whenRateEqualDuration_returnsElementBeforeElementContainigDate),
        ("test_scheduleMatching_firstBefore_whenRateEqualDurationDateIsElementStart_returnsElementBefore", test_scheduleMatching_firstBefore_whenRateEqualDurationDateIsElementStart_returnsElementBefore),
        ("test_scheduleMatching_firstBefore_whenRateEqualDurationDateIsEndOfElement_returnsElement", test_scheduleMatching_firstBefore_whenRateEqualDurationDateIsEndOfElement_returnsElement),
        ("test_scheduleMatching_firstAfter_whenRateEqaulDuration_doenstReturnNil", test_scheduleMatching_firstAfter_whenRateEqaulDuration_doenstReturnNil),
        ("test_scheduleMatching_firstAfter_whenRateEqualDuration_returnsElementAfterElementContaningDate", test_scheduleMatching_firstAfter_whenRateEqualDuration_returnsElementAfterElementContaningDate),
        ("test_scheduleMatching_firstAfter_whenRateEqualDurationDateIsElementStart_returnsElementAfter", test_scheduleMatching_firstAfter_whenRateEqualDurationDateIsElementStart_returnsElementAfter),
        ("test_scheduleMatching_firstAfter_whenRateEqualDurationDateIsElementEnd_returnsElementAfter", test_scheduleMatching_firstAfter_whenRateEqualDurationDateIsElementEnd_returnsElementAfter),
        ("test_scheduleIn_completionExecutes", test_scheduleIn_completionExecutes),
    
        ("test_scheduleIn_whenQueueIsNil_completionDoesntExecutesOnMainThread", test_scheduleIn_whenQueueIsNil_completionDoesntExecutesOnMainThread),
        ("test_scheduleIn_whenQueueIsNotNil_completionExecutesOnQueue", test_scheduleIn_whenQueueIsNotNil_completionExecutesOnQueue),
        ("test_scheduleIn_whenIsEmpty_returnsSuccessWithEmptyElements", test_scheduleIn_whenIsEmpty_returnsSuccessWithEmptyElements),
        ("test_scheduleIn_whenRateGreaterThanDurationDateIntervalEqualDurationOrLessThanEqualRate_returnsSuccess", test_scheduleIn_whenRateGreaterThanDurationDateIntervalEqualDurationOrLessThanEqualRate_returnsSuccess),
     ("test_scheduleIn_whenRateEqualDurationDateIntervalEqualDurationOrLessThanEqualRate_returnsSuccess", test_scheduleIn_whenRateEqualDurationDateIntervalEqualDurationOrLessThanEqualRate_returnsSuccess),
       ("test_scheduleIn_whenRateGreaterThanDuration_returnsSuccessWithExpectedElements", test_scheduleIn_whenRateGreaterThanDuration_returnsSuccessWithExpectedElements),
       ("test_scheduleIn_whenRateEqualDuration_returnsSuccessWithExpectedElements", test_scheduleIn_whenRateEqualDuration_returnsSuccessWithExpectedElements),
        
    ]
}
