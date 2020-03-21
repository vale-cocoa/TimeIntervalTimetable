//
//  TimeIntervalTimetable
//  TimeIntervalTimetable+CustomStringConvertible.swift
//  
//  Created by Valeriano Della Longa on 21/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation

extension TimeIntervalTimetable: CustomStringConvertible {
    static let _formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar.current
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        
        return formatter
    }()
    
    public var description: String {
        return "Rate: \(Self._formatter.string(from: rate)!) - Duration: \(Self._formatter.string(from: duration)!)"
    }
    
}
