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
    // TODO: to be added
//    case everyMonday = "Every Monday"
//    case everyTuesday = "Every Tuesday"
//    case everyWednesday = "Every Wednesday"
//    case everyThursday = "Every Thursday"
//    case everyFriday = "Every Friday"
//    case everySaturday = "Every Saturday"
//    case everySunday = "Every Sunday"
//    case weekdays = "On Weekdays"
//    case weekends = "On Weekends"
}






class Config: ObservableObject {
    
    // singleton despite ObservableObject, could be problematic
    static let shared = Config()
    
    // priority settings
    @Published var priorityDates: [Date]
    @Published var priorityIntervals: [Interval]
    
    // other settings
    @Published var showCreationTime: Bool
    @Published var showNotificationTime: Bool
    @Published var colorTheme: ColorTheme
    
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
    
    func getIntervalAndDate(for priority: Priority) -> (interval: Interval, date: Date)? {
        // TODO: maybe we can make some kind of Interval class, and then work with that instead of returning this named tuple
        switch priority {
        case .custom(_):
            return nil
        default:
            // TODO: maybe we can avoid this rather ugly arrays
            return (interval: self.priorityIntervals[priority.getIndex()], date: self.priorityDates[priority.getIndex()])
        }
    }
    
    init() {
        
        // some fucked up bug made me to this shit like this with these dumb pd and pi variables ????
        var pd = [Date]()
        var pi = [Interval]()
        
        for _ in Priority.allRegularCases {
            pd.append(Config.createTime(hour: 08, minute: 00) ?? Date())
        }
        
        for priority in Priority.allRegularCases {
            let interval: Interval
            switch priority {
            case .low:
                interval = Interval.never
            case .medium:
                interval = Interval.week
            case .high:
                interval = Interval.day
            default:
                interval = Interval.never
            }
            pi.append(interval)
        }
        
        self.priorityDates = pd
        self.priorityIntervals = pi
        
        self.showCreationTime = true
        self.showNotificationTime = true
        
        self.colorTheme = .defaultcolor
        
        // on first launch, we write default config to user defaults
        // on subsequent launches, we overwrite default config from user defaults
        if !UserDefaults.appGroup.bool(forKey: "launchedBefore") {
            UserDefaults.appGroup.set(true, forKey: "launchedBefore")
            self.save()
        } else {
            self.load()
        }
    }
    
    func save() {
        // saves the current state of the config object in userdefaults
        UserDefaults.appGroup.set(priorityDates, forKey: "priorityDates")
        
        let stringPriorityIntervals: [String] = priorityIntervals.map { $0.rawValue }
        UserDefaults.appGroup.set(stringPriorityIntervals, forKey: "priorityIntervals")
        
        UserDefaults.appGroup.set(showNotificationTime, forKey: "showNotificationTime")
        UserDefaults.appGroup.set(showCreationTime, forKey: "showCreationTime")
        UserDefaults.appGroup.set(colorTheme.rawValue, forKey: "colorTheme")
    }
    
    func load() {
        
        // then we load the saved settings from userdefaults
        if let priorityDatesAnyOpt = UserDefaults.appGroup.array(forKey: "priorityDates") {
            if let priorityDatesAny = priorityDatesAnyOpt as? [Date] {
                self.priorityDates = priorityDatesAny
            }
        }
        
        if let priorityIntervalsAnyOpt = UserDefaults.appGroup.array(forKey: "priorityIntervals") {
            if let priorityIntervalsAny = priorityIntervalsAnyOpt as? [String] {
                self.priorityIntervals = priorityIntervalsAny.map { Interval(rawValue: $0) ?? .day }
            }
        }
        
        // ugly code to check if the loaded data is still valid --> e.g. if number of priorities now different
        if (self.priorityDates.count != Priority.count) {
            let difference = self.priorityDates.count - Priority.count
            if (difference > 0) {
                // difference > 0 --> more priorityDates in UserDefaults then there are priorities --> decrease them
                self.priorityDates = self.priorityDates.dropLast(difference)
            } else {
                // difference < 0 --> less priorityDates in UD --> add them with array repeating method
                self.priorityDates += Array(repeating: Config.createTime(hour: 08, minute: 00) ?? Date(), count: -difference)
            }
        }
        
        if (self.priorityIntervals.count != Priority.count) {
            let difference = self.priorityIntervals.count - Priority.count
            if (difference > 0) {
                // difference > 0 --> more priorityDates in UserDefaults then there are priorities --> decrease them
                self.priorityIntervals = self.priorityIntervals.dropLast(difference)
            } else {
                // difference < 0 --> less priorityDates in UD --> add them with array repeating method
                self.priorityIntervals += Array(repeating: Interval.hour, count: -difference)
            }
        }
        
        self.showNotificationTime = UserDefaults.appGroup.bool(forKey: "showNotificationTime")
        self.showCreationTime = UserDefaults.appGroup.bool(forKey: "showCreationTime")
        
        if let colorThemeString = UserDefaults.appGroup.string(forKey: "colorTheme") {
            if let colorTheme = ColorTheme(rawValue: colorThemeString) {
                self.colorTheme = colorTheme
            } else {
                // read color theme but not valid string
                self.colorTheme = .defaultcolor
            }
        } else {
            // could not find colortheme in userdefaults
            self.colorTheme = .defaultcolor
        }
    }
}
