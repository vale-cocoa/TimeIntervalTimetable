import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(TimeIntervalTimetableTests.allTests),
        testCase(TimeIntervalTimetableCustomStringConvertibleTests.allTests),
        testCase(TimeIntervalTimetableWebAPITests.allTests),
        testCase(TimeIntervalTimetableScheduleTests.allTests),
        
    ]
}
#endif
