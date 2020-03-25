//
//  TimeIntervalTimetable
//  TimeIntervalTimetable+Schedule.swift
//  
//  Created by Valeriano Della Longa on 22/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import Schedule
import VDLGCDHelpers

extension TimeIntervalTimetable: Schedule {
    /// The reference date.
    public static var refDate: Date { Date(timeIntervalSinceReferenceDate: 0) }
    
    public var isEmpty: Bool { return duration == 0.0 }
    
    public func contains(_ date: Date) -> Bool {
        guard
            !self.isEmpty
            else { return false }
        
        guard
            self.duration != self.rate
            else { return true }
        
        return element(on: date) != nil
    }
    
    public func schedule(matching date: Date, direction: CalendarCalculationMatchingDateDirection) -> Self.Element? {
        switch direction {
        case .on:
            
            return element(on: date)
        case .firstBefore:
            
            return element(firstBefore: date)
        case .firstAfter:
            
            return element(firstAfter: date)
        }
    }
    
    public func schedule(in dateInterval: DateInterval, queue: DispatchQueue?, then completion: @escaping (Result<[Self.Element], Swift.Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard !self.isEmpty else {
                let result: Result<Array<DateInterval>, Swift.Error> = .success([])
                dispatchResultCompletion(result: result, queue: queue, completion: completion)
                
                return
            }
            
            var result: Result<[DateInterval], Swift.Error>!
            
            // Case for when there could be just
            // one schedule element as result:
            if
                dateInterval.duration == self.duration
                ||
                dateInterval.duration <= self.rate
            {
                if
                    let scheduled = self.schedule(matching: dateInterval.start, direction: .on),
                    scheduled.start >= dateInterval.start,
                    scheduled.end <= dateInterval.end
                {
                    result = .success([scheduled])
                } else if
                    let scheduled = self.schedule(matching: dateInterval.start, direction: .firstAfter),
                    scheduled.start >= dateInterval.start,
                    scheduled.end <= dateInterval.end
                {
                    result = .success([scheduled])
                } else {
                    result = .success([])
                }
                dispatchResultCompletion(result: result, queue: queue, completion: completion)
                
                return
            }
            
            // Grab the first date in schedule of the given
            // date interval:
            var candidateStartDate: Date?
            if
                let effectiveStartDate = self.schedule(matching: dateInterval.start, direction: .on)?.start
            {
                candidateStartDate = effectiveStartDate >= dateInterval.start ? effectiveStartDate : self.schedule(matching: dateInterval.start, direction: .firstAfter)?.start
            } else {
                candidateStartDate = self.schedule(matching: dateInterval.start, direction: .firstAfter)?.start
            }
            guard
                let startDate = candidateStartDate
                else {
                    result = .failure(Error.dateCalculationError)
                    dispatchResultCompletion(result: result, queue: queue, completion: completion)
                    
                    return
            }
            
            // let's calculate how many results we'll have…
            // …We need to add 1 to the count
            // calculation in order to address a possible
            // misalignements occurring between
            // the last scheduled date interval result's
            // start date and the given date interval;
            // not a big deal, we might calculate
            // only one more result which will be discarded
            // in case it isn't entirely contained by the
            // given date interval:
            let distance = startDate.distance(to: dateInterval.end)
            let count = Int((distance / self.rate).rounded(.down)) + 1
            
            // let's calculate the schedule concurently…
            let scheduleRate = self.rate
            let elementDuration = self.duration
            concurrentResultsGenerator(
                countOfIterations: count,
                startingSeed: (rate: scheduleRate, date: startDate),
                iterationSeeder: { seed, iterationIdx -> Date in
                    let timeInterval = TimeInterval(iterationIdx) * seed.rate
                    
                    return seed.date.addingTimeInterval(timeInterval)
            },
                iterationGenerator: { date -> DateInterval? in
                    let iterationElement = DateInterval(start: date, duration: elementDuration)
                    guard
                        iterationElement.start < dateInterval.end,
                        iterationElement.end <= dateInterval.end
                        else { return nil }
                    
                    return iterationElement
            },
                completion: { operationResult in
                    switch operationResult {
                    case .success(let elementsToFlatten):
                        let elements = elementsToFlatten
                            .compactMap { $0 }
                        result = .success(elements)
                    case .failure(let error):
                        result = .failure(error)
                    }
                    dispatchResultCompletion(result: result, queue: queue, completion: completion)
            })
        }
    }
    
    // MARK: - Helpers
    func element(on date: Date) -> DateInterval? {
        guard
            let closestElementDistanceFromRefDate = self.distanceSinceRefDateForElementsStartDate(closestTo: date)
            else { return nil }
        
        let candidate = DateInterval(start: Date(timeInterval: closestElementDistanceFromRefDate, since: Self.refDate), duration: duration)
        
        return candidate.contains(date) ? candidate : nil
    }
    
    func element(firstBefore date: Date) -> DateInterval? {
        guard
            let closestElementDistanceFromRefDate = self.distanceSinceRefDateForElementsStartDate(closestTo: date)
            else { return nil }
        
        let candidate = DateInterval(start: Date(timeInterval: closestElementDistanceFromRefDate, since: Self.refDate), duration: duration)
        guard
            (candidate.contains(date) || date < candidate.start)
            else { return candidate }
        
        let previousElementDistanceFromRefDate = closestElementDistanceFromRefDate - rate
        
        return DateInterval(start: Date(timeInterval: previousElementDistanceFromRefDate, since: Self.refDate), duration: duration)
    }
    
    func element(firstAfter date: Date) -> DateInterval? {
        guard
            let closestElementDistanceFromRefDate = self.distanceSinceRefDateForElementsStartDate(closestTo: date)
            else { return nil }
        
        let candidate = DateInterval(start: Date(timeInterval: closestElementDistanceFromRefDate, since: Self.refDate), duration: duration)
        
        guard
            (candidate.contains(date) || date > candidate.end)
            else { return candidate }
        
        let nextElementDistanceFromRefDate = closestElementDistanceFromRefDate + rate
        
        return DateInterval(start: Date(timeInterval: nextElementDistanceFromRefDate, since: Self.refDate), duration: duration)
    }
    
    func distanceSinceRefDateForElementsStartDate(closestTo date: Date) -> TimeInterval?
    {
        guard !isEmpty else { return nil }
        
        let distanceFromRefDate = Self.refDate.distance(to: date)
        
        let rule: FloatingPointRoundingRule = duration == rate ? .down : .toNearestOrAwayFromZero
        
        let rateTimes = (distanceFromRefDate / rate).rounded(rule)
        
        return rate * rateTimes
    }
    
}
