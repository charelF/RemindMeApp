//
//  Config.swift
//  Kiwi
//
//  Created by Charel Felten on 05/07/2021.
//

import Foundation

enum Interval: String, Equatable, CaseIterable {
    case ten_minutes = "Every 10 minutes"
    case thirty_minutes = "Every 30 minutes"
    case hour = "Hourly"
    case three_hours = "Every 3 hours"
    case six_hours = "Every 6 hours"
    case twelve_hours = "Twice a day"
    case day = "Daily"
    case two_days = "Every other day"
    case week = "Weekly"
    case month = "Monthly"
    case year = "Yearly"
    case never = "Never"
}

class Config: ObservableObject {
    
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
    
    init() {
        // default initialiser to be used in content view providers and for first run
        self.nightBreak = true
        self.nightStart = createTime(hour: 22, minute: 00) ?? Date()
        self.nightEnd = createTime(hour: 22, minute: 00) ?? Date()
        
        self.priorityDates  = [
            createTime(hour: 08, minute: 00) ?? Date(),
            createTime(hour: 08, minute: 00) ?? Date(),
            createTime(hour: 08, minute: 00) ?? Date(),
        ]
        
        self.priorityIntervals = [
            Interval.week,
            Interval.day,
            Interval.hour
        ]
    }
    
    static func firstLaunch() -> Config {
        // on first launch, we use the default values from initialiser
        let config = Config()
        
        // we then save them to userdefaults for subsequent launches
        config.save()
        return config
    }
    
    static func save(config: Config) {
        return config.save()
    }
    
    func save() {
        // saves the current state of the config object in userdefaults
        UserDefaults.standard.set(priorityDates, forKey: "priorityDates")
        
        let stringPriorityIntervals: [String] = priorityIntervals.map { $0.rawValue }
        UserDefaults.standard.set(stringPriorityIntervals, forKey: "priorityIntervals")
        
        UserDefaults.standard.set(nightBreak, forKey: "nightBreak")
        UserDefaults.standard.set(nightStart, forKey: "nightStart")
        UserDefaults.standard.set(nightEnd, forKey: "nightEnd")
    }
    
    static func load() -> Config {
        // first initialise the object
        let config = Config()
        
        // then we load the saved settings from userdefaults
        if let priorityDatesAnyOpt = UserDefaults.standard.array(forKey: "priorityDates") {
            if let priorityDatesAny = priorityDatesAnyOpt as? [Date] {
                config.priorityDates = priorityDatesAny
            }
        }
            
        if let priorityIntervalsAnyOpt = UserDefaults.standard.array(forKey: "priorityIntervals") {
            if let priorityIntervalsAny = priorityIntervalsAnyOpt as? [String] {
                config.priorityIntervals = priorityIntervalsAny.map { Interval(rawValue: $0) ?? .day }
            }
        }
            
        config.nightBreak = UserDefaults.standard.bool(forKey: "nightBreak")
        if let nightStart = UserDefaults.standard.object(forKey: "nightStart") as? Date {
            config.nightStart = nightStart
        }
        if let nightEnd = UserDefaults.standard.object(forKey: "nightEnd") as? Date {
            config.nightEnd = nightEnd
        }
        
        return config
    }
}
