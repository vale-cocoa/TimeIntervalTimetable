//
//  TimeIntervalTimetable
//  TimeIntervalTimetable.swift
//  
//  Created by Valeriano Della Longa on 21/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import WebAPICodingOptions

extension TimeIntervalTimetable: Codable {
    public enum CodingKeys: String, CodingKey {
        case rate
        case duration
    }
    
    public func encode(to encoder: Encoder) throws {
        if let codingOptions = encoder.userInfo[WebAPICodingOptions.key] as? WebAPICodingOptions {
            switch codingOptions.version {
            case .v1:
                let webAPI = _WebAPITimeIntervalTimetable(self)
                try webAPI.encode(to: encoder)
            }
        } else {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.rate, forKey: .rate)
            try container.encode(self.duration, forKey: .duration)
        }
    }
    
    public init(from decoder: Decoder) throws {
        if let codingOptions = decoder.userInfo[WebAPICodingOptions.key] as? WebAPICodingOptions {
            switch codingOptions.version {
            case .v1:
                let webAPI = try _WebAPITimeIntervalTimetable(from: decoder)
                let validRateAndDuration = try Self.validRateAndDurationFromDifferenceDateComponents(rateDC: webAPI.dateComponents.rate, durationDC: webAPI.dateComponents.duration)
                self = try Self(rate: validRateAndDuration.rate, duration: validRateAndDuration.duration)
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let rate = try container.decode(Double.self, forKey: .rate)
            let duration = try container.decode(Double.self, forKey: .duration)
            self = try Self(rate: rate, duration: duration)
        }
    }
    
    fileprivate static var _dateComponentsSet: Set<Calendar.Component> {
        
        return Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second])
    }
    
    fileprivate var _dateComponents: (rate: DateComponents, duration: DateComponents) {
        let refDate = Date(timeIntervalSinceReferenceDate: 0)
        let toRateDate = Date.init(timeIntervalSinceReferenceDate: self.rate)
        let toDurationDate = Date.init(timeIntervalSinceReferenceDate: self.duration)
        let rateDC = Calendar.current.dateComponents(Self._dateComponentsSet, from: refDate, to: toRateDate)
        let durationDC = Calendar.current.dateComponents(Self._dateComponentsSet, from: refDate, to: toDurationDate)
        
        return (rateDC, durationDC)
    }
}

fileprivate struct _WebAPITimeIntervalTimetable: Codable {
    let rate: [String : Int]
    let duration: [String : Int]
    var dateComponents: (rate: DateComponents, duration: DateComponents) {
        let rateDC = Self._dictToDateComponents(dictionary: self.rate)
        let durationDC = Self._dictToDateComponents(dictionary: self.duration)
        
        return (rateDC, durationDC)
    }
    
    init(_ timetable: TimeIntervalTimetable) {
        self.rate = Self._dateComponentsToDict(timetable._dateComponents.rate)
        self.duration = Self._dateComponentsToDict(timetable._dateComponents.duration)
    }
    
    private enum _DictionaryCodingKeys: String {
        case years
        case months
        case days
        case hours
        case minutes
        case seconds
    }
    
    private static func _dateComponentsToDict(_ dc: DateComponents) -> [String:Int] {
        var dict = [String : Int]()
        
        for component in TimeIntervalTimetable._dateComponentsSet {
            var key: String? = nil
            
            switch component {
            case .year:
                key = _DictionaryCodingKeys.years.rawValue
            case .month:
                key = _DictionaryCodingKeys.months.rawValue
            case .day:
                key = _DictionaryCodingKeys.days.rawValue
            case .hour:
                key = _DictionaryCodingKeys.hours.rawValue
            case .minute:
                key = _DictionaryCodingKeys.minutes.rawValue
            case .second:
                key = _DictionaryCodingKeys.seconds.rawValue
            default:
                break
            }
            
            if let key = key, let value = dc.value(for: component), value > 0 {
                dict[key] = value
            }
        }
        
        return dict
    }
    
    private static func _dictToDateComponents(dictionary: [String:Int]) -> DateComponents {
        var dc = DateComponents()
        dc.calendar = Calendar.current
        for key in dictionary.keys {
            var component: Calendar.Component!
            guard let dictionaryKey = _DictionaryCodingKeys(rawValue: key) else { continue }
            
            switch dictionaryKey {
            case .years:
                component = .year
            case .months:
                component = .month
            case .days:
                component = .day
            case .hours:
                component = .hour
            case .minutes:
                component = .minute
            case .seconds:
                component = .second
            }
            dc.setValue(dictionary[key], for: component)
        }
        
        return dc
    }
}
