//
//  NotesLogic.swift
//  RemindMe
//
//  Created by Charel Felten on 02/07/2021.
//

import Foundation
import SwiftUI
import CoreData
import UserNotifications

enum ColorLocation: String {
    case primary = "p"
    case secondary = "s"
    case background = "b"
}

enum ColorTheme: String, CaseIterable {
    case defaultcolor = "Default"
    case grayscale = "Grayscale"
    case retro = "Retro"
}

extension Note {
    
    static func getColor(for note: Note, in location: ColorLocation) -> Color {
        return Note.getColor(for: Int(note.priority), in: location)
    }
    
    static func getColor(for priority: Int, in location: ColorLocation) -> Color {
        let config: Config = Config.shared
        let theme: ColorTheme = config.colorTheme
        switch theme {
//        case .retro:
//            let colorCode: String = "\(theme.rawValue.lowercased())_\(priority)\(location.rawValue)"
//            if let uicolor = UIColor(named: colorCode) {
//                return Color(uicolor)
//            } else {
//                fallthrough // if we cant find anything, we fall through to default
//            }
        case .retro:
            let colorCode: String = "\(theme.rawValue.lowercased())_\(priority)p"
            var color: Color
            if let uicolor = UIColor(named: colorCode) {
                color =  Color(uicolor)
                switch location {
                case .primary:
                    break
                case .secondary:
                    color = color.opacity(0.5)
                case .background:
                    color = color.opacity(0.05)
                }
                return color
            } else {
                fallthrough // if we cant find anything, we fall through to default
            }
        default:
            var color: Color
            switch priority {
            case 0:
                color = Color.green
            case 1:
                color = Color.orange
            case 2:
                color = Color.red
            case 3:
                color = Color.purple
            case 4:
                color = Color.blue
            default:
                color = Color.primary
            }
            
            switch location {
            case .primary:
                break
            case .secondary:
                color = color.opacity(0.5)
            case .background:
                color = color.opacity(0.05)
            }
            
            return color
        }
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let defaultPriority: Int = 0
    static let priorityCount: Int = 5
    static let datePriorityNumber: Int = 4
    
    func changePriority() {
        // legacy function
        changePriority(notifyOn: nil)
    }
    
    func changePriority(notifyOn date: Date?) {
        // check if the optional is nil or not
        if let _ = date {
            // as for now, date by default the last priority
            self.priority = Int16(Note.priorityCount - 1)
        } else {
            self.customDate = nil
            self.priority += 1
            // highest priority reserved for custom dates
            self.priority %= Int16(Note.priorityCount - 1)
        }
    }
    
    func getPrimaryColor() -> Color {
        return Note.getColor(for: self, in: .primary)
    }
    
    func getSecondaryColor() -> Color {
        return Note.getColor(for: self, in: .secondary)
    }
    
    func getBackgroundColor() -> Color {
        return Note.getColor(for: self, in: .background)
    }
    
    func describePriority() -> String {
        if self.priority == Int16(Note.priorityCount - 1) {
            if let date = self.customDate {
                return Note.dateFormatter.string(from: date)
            }
        }
        return Config.shared.priorityIntervals[Int(self.priority)].rawValue
    }
    
    convenience init(context: NSManagedObjectContext, content: String) {
        self.init(context: context)
        self.content = content
        self.timestamp = Date()
        self.id = UUID()
        self.priority = 0
        self.notificationids = []
        self.addNotifications()
    }
    
    func deleteNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: self.notificationids!)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: self.notificationids!)
    }
    
    func addNotifications() {
        // legacy function
        addNotifications(notifyOn: nil)
    }
    
    func addNotifications(notifyOn date: Date?) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = self.content ?? "Empty Note"
        content.sound = UNNotificationSound.default
        
        var notificationid: String
        var request: UNNotificationRequest
        let triggers: [UNNotificationTrigger]
        
        if let safeDate = date {
            self.customDate = safeDate
            let dateComponents: DateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: safeDate
            )
            triggers = [
                UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            ]
        } else {
            self.customDate = nil
            let interval = Config.shared.getInterval(priority: Int(self.priority))
            triggers = createNotificationTriggers(interval: interval)
        }
        
        for trigger in triggers {
            notificationid = "RemindMe_\(UUID().uuidString)"
            request = UNNotificationRequest(
                identifier: notificationid,
                content: content,
                trigger: trigger
            )
            notificationCenter.add(request) { (error) in
                if error != nil {
                    print(error!)
                }
            }
            self.notificationids!.append(notificationid)
        }
        
        // DEBUG
        /*
        notificationCenter.getPendingNotificationRequests(completionHandler: { (notifications) in
            print("Number of pending notifications \(notifications.count)")
            for request in notifications {
                if let tmp = request.trigger as? UNCalendarNotificationTrigger {
                    print(String(describing: tmp.nextTriggerDate()))
                }
                if let tmp = request.trigger as? UNTimeIntervalNotificationTrigger {
                    print(String(describing: tmp.nextTriggerDate()))
                }
            }
        })
        */
    }
    
    func createNotificationTriggers(interval: Interval) -> [UNNotificationTrigger] {
        var triggers: [UNNotificationTrigger] = []
        var firstNotificationTime = Date()
        
        
        var executed = false
        for i in 0..<Config.priorityCount {
            if Config.shared.priorityIntervals[i] == interval {
                firstNotificationTime = Config.shared.priorityDates[i]
                executed = true
            }
        }
        guard executed else {
            print("--- Could not create notification ---")
            print(interval)
            print(self.priority)
            return []
        }
        
        switch interval {
        
        case .ten_minutes:
            triggers.append(UNTimeIntervalNotificationTrigger(timeInterval: 60*10, repeats: true))
//            var dateComponents: DateComponents
//            for elapsedTime in [0, 10, 20, 30, 40, 50] {
//                dateComponents = Calendar.current.dateComponents(
//                    [.minute, .second],
//                    from: firstNotificationTime + TimeInterval(elapsedTime)
//                )
//                triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
//            }
            
        case .hour:
            let dateComponents: DateComponents = Calendar.current.dateComponents(
                [.minute, .second],
                from: firstNotificationTime
            )
            triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            
        case .three_hours:
            var dateComponents: DateComponents
            for elapsedTime in [0, 3*60*60, 6*60*60, 9*60*60, 12*60*60, 15*60*60, 18*60*60, 21*60*60] {
                dateComponents = Calendar.current.dateComponents(
                    [.minute, .hour, .second],
                    from: firstNotificationTime + TimeInterval(elapsedTime)
                )
                triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            }
            
        case .six_hours:
            var dateComponents: DateComponents
            for elapsedTime in [0, 6*60*60, 12*60*60, 18*60*60] {
                dateComponents = Calendar.current.dateComponents(
                    [.minute, .hour, .second],
                    from: firstNotificationTime + TimeInterval(elapsedTime)
                )
                triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            }
            
        case .twelve_hours:
            var dateComponents: DateComponents
            for elapsedTime in [0, 12*60*60] {
                dateComponents = Calendar.current.dateComponents(
                    [.minute, .hour, .second],
                    from: firstNotificationTime + TimeInterval(elapsedTime)
                )
                triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            }
            
        case .day:
            let dateComponents: DateComponents = Calendar.current.dateComponents(
                [.minute, .hour, .second],
                from: firstNotificationTime
            )
            triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            
        case .week:
            let dateComponents: DateComponents = Calendar.current.dateComponents(
                [.minute, .hour, .weekday, .second],
                from: firstNotificationTime
            )
            triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            
        case .month:
            let dateComponents: DateComponents = Calendar.current.dateComponents(
                [.minute, .hour, .day, .second],
                from: firstNotificationTime
            )
            triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            
        case .never:
            fallthrough
            
        default:
            triggers = []
        }
        return triggers
    }
    
    static let previewNotes: [Note] = {
        let pvc = PersistenceController.preview.container.viewContext
        var notes = [Note]()
        notes.append(Note(context: pvc, content: "Short note"))
        notes.append(Note(context: pvc, content: "This is a longer note with a higher priority, it may span 2 columns"))
        notes.append(Note(context: pvc, content: "Yet another note"))
        notes[0].priority = 0
        notes[1].priority = 1
        notes[2].priority = 2
        return notes
    }()
}








