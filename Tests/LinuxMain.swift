import XCTest

import TimeIntervalTimetableTests

var tests = [XCTestCaseEntry]()
tests += TimeIntervalTimetableTests.allTests()
tests += TimeIntervalTimetableCustomStringConvertibleTests.allTests()
tests += TimeIntervalTimetableWebAPITests.allTests()
XCTMain(tests)
