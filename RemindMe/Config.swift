//
//  Config.swift
//  RemindMe
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
    
    // singleton despite ObservableObject, could be problematic
    static let shared = Config()
    
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
        "Very high priority",
    ]
    static var priorityCount: Int = 4
    static var defaultPriority: Int = 0
    @Published var colorTheme: ColorTheme = .retro
    
    // other settings
    @Published var showCreationTime: Bool
    @Published var showNotificationTime: Bool
    
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
    
    func getInterval(priority: Int) -> Interval {
        guard priority < Config.priorityCount && priority >= 0 else {
            print("Invalid priority")
            return .day
        }
        return self.priorityIntervals[priority]
    }
    
    init() {
        
        self.nightBreak = true
        self.nightStart = Config.createTime(hour: 22, minute: 00) ?? Date()
        self.nightEnd = Config.createTime(hour: 07, minute: 59) ?? Date()
        
        self.priorityDates  = [
            Config.createTime(hour: 08, minute: 00) ?? Date(),
            Config.createTime(hour: 08, minute: 00) ?? Date(),
            Config.createTime(hour: 08, minute: 00) ?? Date(),
            Config.createTime(hour: 08, minute: 00) ?? Date(),
        ]
        
        self.priorityIntervals = [
            Interval.never,
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
        
        // ugly code to check if the loaded data is still valid --> e.g. if number of priorities now different
        if (self.priorityDates.count != Note.priorityCount) {
            let difference = self.priorityDates.count - Note.priorityCount
            if (difference > 0) {
                // difference > 0 --> more priorityDates in UserDefaults then there are priorities --> decrease them
                self.priorityDates = self.priorityDates.dropLast(difference)
            } else {
                // difference < 0 --> less priorityDates in UD --> add them with array repeating method
                self.priorityDates += Array(repeating: Config.createTime(hour: 08, minute: 00) ?? Date(), count: -difference)
            }
        }
        
        if (self.priorityIntervals.count != Note.priorityCount) {
            let difference = self.priorityIntervals.count - Note.priorityCount
            if (difference > 0) {
                // difference > 0 --> more priorityDates in UserDefaults then there are priorities --> decrease them
                self.priorityIntervals = self.priorityIntervals.dropLast(difference)
            } else {
                // difference < 0 --> less priorityDates in UD --> add them with array repeating method
                self.priorityIntervals += Array(repeating: Interval.hour, count: -difference)
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
