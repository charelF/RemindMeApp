//
//  NotesLogic.swift
//  Kiwi
//
//  Created by Charel Felten on 02/07/2021.
//

import Foundation
import SwiftUI
import CoreData
import UserNotifications

extension Note {
    
    static func priorityToColor(note: Note) -> Color? {
        return priorityToColor(priority: Int(note.priority))
    }
    
    static func priorityToColor(priority: Int) -> Color? {
        switch priority {
        case 0:
            return Color.green
        case 1:
            return Color.orange
        case 2:
            return Color.red
        case 3:
            return Color.blue
        default:
            return Color.gray
        }
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let defaultPriority: Int = 0
    static let priorityCount: Int = 3
    
    func changePriority() {
        self.priority += 1
        self.priority %= Int16(Note.priorityCount)
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
        let interval = Config.shared.getInterval(priority: Int(self.priority))
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = self.content ?? "Empty Note"
        content.sound = UNNotificationSound.default
        
        let triggers: [UNNotificationTrigger] = createNotificationTriggers(interval: interval)
        
        
        var notificationid: String
        var request: UNNotificationRequest
        
        for trigger in triggers {
            notificationid = "Kiwi_\(UUID().uuidString)"
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
    }
    
    
    func createNotificationTriggers(interval: Interval) -> [UNNotificationTrigger] {
        var trigger: [UNNotificationTrigger] = []
        var firstNotificationTime = Date()
        
        // TODO: below code is very ugly ---
        var executed = false
        for i in 0..<Config.NUMPRIO {
            if Config.shared.priorityIntervals[i] == interval {
                firstNotificationTime = Config.shared.priorityDates[i]
                executed = true
            }
        }
        guard executed else {
            print("--- Could not create notification")
            return []
        }
        // TODO ---
        
        switch interval {
        
        case .ten_minutes:
            trigger.append(UNTimeIntervalNotificationTrigger(timeInterval: 60*10, repeats: true))
            
        case .hour:
            let dateComponents: DateComponents = Calendar.current.dateComponents(
                [.minute, .second],
                from: firstNotificationTime
            )
            trigger.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            
        case .three_hours:
            var dateComponents: DateComponents
            for interval in [0, 3*60*60, 6*60*60, 9*60*60, 12*60*60, 15*60*60, 18*60*60, 21*60*60] {
                dateComponents = Calendar.current.dateComponents(
                    [.minute, .hour, .second],
                    from: firstNotificationTime + TimeInterval(interval)
                )
                trigger.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            }
            
        case .six_hours:
            var dateComponents: DateComponents
            for interval in [0, 6*60*60, 12*60*60, 18*60*60] {
                dateComponents = Calendar.current.dateComponents(
                    [.minute, .hour, .second],
                    from: firstNotificationTime + TimeInterval(interval)
                )
                trigger.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            }
            
        case .twelve_hours:
            var dateComponents: DateComponents
            for interval in [0, 12*60*60] {
                dateComponents = Calendar.current.dateComponents(
                    [.minute, .hour, .second],
                    from: firstNotificationTime + TimeInterval(interval)
                )
                trigger.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            }
            
        case .day:
            let dateComponents: DateComponents = Calendar.current.dateComponents(
                [.minute, .hour, .second],
                from: firstNotificationTime
            )
            trigger.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            
        case .week:
            let dateComponents: DateComponents = Calendar.current.dateComponents(
                [.minute, .hour, .weekday, .second],
                from: firstNotificationTime
            )
            trigger.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            
        case .month:
            let dateComponents: DateComponents = Calendar.current.dateComponents(
                [.minute, .hour, .day, .second],
                from: firstNotificationTime
            )
            trigger.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
            
        case .never:
            fallthrough
            
        default:
            trigger = []
        }
        
        return trigger
    }
}








