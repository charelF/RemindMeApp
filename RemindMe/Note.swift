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

enum Priority: Identifiable {
    
    case low
    case medium
    case high
    case custom(date: Date)
    
    mutating func next() {
        switch self {
        case .low:
            self = .medium
        case .medium:
            self = .high
        case .high:
            self = .low
        case .custom:
            self = .low
        }
    }
    
    func getIndex() -> Int {
        switch self {
        case .low:
            return 0
        case .medium:
            return 1
        case .high:
            return 2
        case .custom(_):
            return 3
        }
    }
    
    static var allRegularCases: [Priority] {
        return [.low, .medium, .high]
    }
    
    static var count: Int {
        return allRegularCases.count
    }
    
    func getDescription() -> String {
        switch self {
        case .low:
            return "Low Priority"
        case .medium:
            return "Mid Priority"
        case .high:
            return "High Priority"
        case .custom(_):
            return "Custom Priority"
        }
    }
    
    func getIntervalDescription() -> String {
        switch self {
        case .custom(let date):
            return Note.dateFormatter.string(from: date)
        default:
            return Config.shared.getInterval(priority: self).rawValue
        }
    }
    
    func isCustom() -> Bool {
        // this is needed because I cant compare just whether note.priority == .custom,
        // since .custom(date 1) is different from .custom(date 2), however both are custom
        switch self {
        case .custom(_):
            return true
        default:
            return false
        }
    }
    
    // for identifable protocol
    var id: Int { return self.getIndex() }
}

extension Note {
    var priority: Priority {
        // TODO: this could maybe be improved, potentially with an Int16 associatedCase in the Priority enum
        get {
            switch int16priority {
            case 0:
                return .low
            case 1:
                return .medium
            case 2:
                return .high
            case 3:
                return .custom(date: self.customDate!)
            default:
                return .low
            }
        }
        set {
            self.int16priority = Int16(newValue.getIndex())
        }
    }
}

extension Note {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    func updatePriority(optionalDate: Date?) {
        self.deleteNotifications()
        if let date = optionalDate {
            self.priority = Priority.custom(date: date)  // we associate for easier usage
            // TODO: see if its really better to use the associated value, because it creates the ugly situation of having
            // two dates in the app, instead of a single source of truth...
            self.customDate = date  // we store it here aswell in order to save changes when closing app
        } else {
            self.priority.next()
            self.customDate = nil
        }
        self.addNotifications()
        PersistenceController.shared.save()
    }
    
    func delete() {
        let viewContext = PersistenceController.shared.container.viewContext
        self.deleteNotifications()
        viewContext.delete(self)
        PersistenceController.shared.save()
    }
    
    static func add(content: String) {
        if content.isEmpty {
            return
        }
        let viewContext = PersistenceController.shared.container.viewContext
        _ = Note(context: viewContext, content: content)
        PersistenceController.shared.save()
    }
    
    func getPrimaryColor() -> Color {
        return Colors.getColor(for: self, in: .primary)
    }
    
    func getSecondaryColor() -> Color {
        return Colors.getColor(for: self, in: .secondary)
    }
    
    func getBackgroundColor() -> Color {
        return Colors.getColor(for: self, in: .background)
    }
    
    func getWidgetBackgroundColor() -> Color {
        return Colors.getColor(for: self, in: .widgetbackground)
    }
    
    convenience init(context: NSManagedObjectContext, content: String) {
        self.init(context: context)
        self.content = content
        self.timestamp = Date()
        self.id = UUID()
        self.priority = .low
        self.notificationids = []
        self.addNotifications()
    }
    
    func deleteNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: self.notificationids!)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: self.notificationids!)
    }
    
    func addNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = self.content ?? "Empty Note"
        content.sound = UNNotificationSound.default
        
        var notificationid: String
        var request: UNNotificationRequest
        let triggers: [UNNotificationTrigger]
        
        switch self.priority {
        case .custom(let date):
            let dateComponents: DateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: date
            )
            triggers = [
                UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            ]
        default:
            let interval = Config.shared.getInterval(priority: self.priority)
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
        for priority in Priority.allRegularCases {
            if Config.shared.priorityIntervals[priority.getIndex()] == interval {
                firstNotificationTime = Config.shared.priorityDates[priority.getIndex()]
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
        notes[0].priority = Priority.low
        notes[1].priority = Priority.medium
        notes[2].priority = Priority.high
        return notes
    }()
}








