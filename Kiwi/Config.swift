//
//  Config.swift
//  Kiwi
//
//  Created by Charel Felten on 05/07/2021.
//

import Foundation

enum Interval: String, Equatable, CaseIterable {
    case ten_minutes = "Every 10 minutes"
    case hour = "Hourly"
    case three_hours = "Every 3 hours"
    case six_hours = "Every 6 hours"
    case twelve_hours = "Twice a day"
    case day = "Daily"
    case week = "Weekly"
    case month = "Monthly"
    case never = "Never"
}

class Config: ObservableObject {
    
    // we do not use singleton since it is an ObservableObject
    
    // night break
    @Published var nightBreak: Bool
    @Published var nightStart: Date
    @Published var nightEnd: Date
    
    // priority settings
    @Published var priorityDates: [Date]
    @Published var priorityIntervals: [Interval]
    
    // constants
    let priorityDescriptions: [String] = [
        "Low priority",
        "Mid priority",
        "High priority",
    ]
    static var priorityCount: Int = 3
    static var defaultPriority: Int = 0
    
    // other settings
    @Published var showCreationTime: Bool
    @Published var showNotificationTime: Bool
    
    
    static let NUMPRIO = 3
    
    // static functions
    static func createTime(hour: Int, minute: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        let date: Date?
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        date = calendar.date(from: dateComponents)
        return date
    }
    
    init() {
        
        self.nightBreak = true
        self.nightStart = Config.createTime(hour: 22, minute: 00) ?? Date()
        self.nightEnd = Config.createTime(hour: 07, minute: 59) ?? Date()
        
        self.priorityDates  = [
            Config.createTime(hour: 08, minute: 00) ?? Date(),
            Config.createTime(hour: 08, minute: 00) ?? Date(),
            Config.createTime(hour: 08, minute: 00) ?? Date(),
        ]
        
        self.priorityIntervals = [
            Interval.week,
            Interval.day,
            Interval.hour
        ]
        
        self.showCreationTime = true
        self.showNotificationTime = true
        
        // on first launch, we write default config to user defaults
        // on subsequent launches, we overwrite default config from user defaults
        if !UserDefaults.standard.bool(forKey: "launchedBefore") {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            self.save()
        } else {
            self.load()
        }
    }
    
    func save() {
        // saves the current state of the config object in userdefaults
        UserDefaults.standard.set(priorityDates, forKey: "priorityDates")
        
        let stringPriorityIntervals: [String] = priorityIntervals.map { $0.rawValue }
        UserDefaults.standard.set(stringPriorityIntervals, forKey: "priorityIntervals")
        
        UserDefaults.standard.set(nightBreak, forKey: "nightBreak")
        UserDefaults.standard.set(nightStart, forKey: "nightStart")
        UserDefaults.standard.set(nightEnd, forKey: "nightEnd")
        
        UserDefaults.standard.set(showNotificationTime, forKey: "showNotificationTime")
        UserDefaults.standard.set(showCreationTime, forKey: "showCreationTime")
    }
    
    func load() {
        
        // then we load the saved settings from userdefaults
        if let priorityDatesAnyOpt = UserDefaults.standard.array(forKey: "priorityDates") {
            if let priorityDatesAny = priorityDatesAnyOpt as? [Date] {
                self.priorityDates = priorityDatesAny
            }
        }
            
        if let priorityIntervalsAnyOpt = UserDefaults.standard.array(forKey: "priorityIntervals") {
            if let priorityIntervalsAny = priorityIntervalsAnyOpt as? [String] {
                self.priorityIntervals = priorityIntervalsAny.map { Interval(rawValue: $0) ?? .day }
            }
        }
            
        self.nightBreak = UserDefaults.standard.bool(forKey: "nightBreak")
        if let nightStart = UserDefaults.standard.object(forKey: "nightStart") as? Date {
            self.nightStart = nightStart
        }
        if let nightEnd = UserDefaults.standard.object(forKey: "nightEnd") as? Date {
            self.nightEnd = nightEnd
        }
        
        self.showNotificationTime = UserDefaults.standard.bool(forKey: "showNotificationTime")
        self.showCreationTime = UserDefaults.standard.bool(forKey: "showCreationTime")
    }
}
