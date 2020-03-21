//
//  TimeIntervalTimetableTests
//  TimeIntervalTimetableWebAPITests.swift
//  
//  Created by Valeriano Della Longa on 21/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
import WebAPICodingOptions
@testable import TimeIntervalTimetable

final class TimeIntervalTimetableWebAPITests: XCTestCase {
    var sut: TimeIntervalTimetable!
    
    // MARK: - test lifecycle
    override func setUp() {
        super.setUp()
        
        sut = try! TimeIntervalTimetable(rate: 3600.0, duration: 900.0)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testCodable_Encode_NoThrow() {
        // given
        let encoder = JSONEncoder()
        
        // when
        // then
        XCTAssertNoThrow(try encoder.encode(self.sut))
    }
    
    func testWebAPI_Encode_NoThrow() {
        // given
        let encoder = JSONEncoder()
        
        // when
        encoder.userInfo = [WebAPICodingOptions.key : (WebAPICodingOptions(version: .v1) as Any)]
        
        // then
        XCTAssertNoThrow(try encoder.encode(self.sut))
    }
    
    func testCodable_Decode_NoThrow() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // when
        let data = try! encoder.encode(self.sut)
        
        // then
        XCTAssertNoThrow(try decoder.decode(TimeIntervalTimetable.self, from: data))
    }
    
    func testWebAPI_Decode_NoThrow() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // when
        encoder.userInfo = [WebAPICodingOptions.key : (WebAPICodingOptions(version: .v1) as Any)]
        decoder.userInfo = [WebAPICodingOptions.key : (WebAPICodingOptions(version: .v1) as Any)]
        let data = try! encoder.encode(self.sut)
        
        // then
        XCTAssertNoThrow(try decoder.decode(TimeIntervalTimetable.self, from: data))
    }
    
    func testCodable_EncodeDecode() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // when
        let data = try! encoder.encode(self.sut)
        let result = try! decoder.decode(TimeIntervalTimetable.self, from: data)
        
        // then
        XCTAssertEqual(self.sut.rate, result.rate)
        XCTAssertEqual(self.sut.duration, result.duration)
    }
    
    func testWebAPI_EncodeDecode() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        encoder.userInfo = [WebAPICodingOptions.key : (WebAPICodingOptions(version: .v1) as Any)]
        decoder.userInfo = [WebAPICodingOptions.key : (WebAPICodingOptions(version: .v1) as Any)]
        
        // when
        let data = try! encoder.encode(self.sut)
        let result = try! decoder.decode(TimeIntervalTimetable.self, from: data)
        
        // then
        XCTAssertEqual(self.sut.rate, result.rate)
        XCTAssertEqual(self.sut.duration, result.duration)
    }
    
    static var allTests = [
        ("testCodable_Encode_NoThrow", testCodable_Encode_NoThrow),
        ("testWebAPI_Encode_NoThrow", testWebAPI_Encode_NoThrow),
        ("testCodable_Decode_NoThrow", testCodable_Decode_NoThrow),
        ("testWebAPI_Decode_NoThrow", testWebAPI_Decode_NoThrow),
        ("testCodable_EncodeDecode", testCodable_EncodeDecode),
        ("testWebAPI_EncodeDecode", testWebAPI_EncodeDecode)
    ]
    
}
