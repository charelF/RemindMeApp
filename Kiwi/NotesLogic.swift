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

func priorityToColor(note: Note) -> Color? {
    return priorityToColor(priority: Int(note.priority))
}

func priorityToColor(priority: Int) -> Color? {
    switch priority {
    case 0:
        return Color.green
    case 1:
        return Color.orange
    case 2:
        return Color.red
    case 3:
        return Color.purple
    default:
        return Color.gray
    }
}

func describePriority(_ note: Note) -> String {
    switch note.priority {
    case 1:
        return "Weekly"
    case 2:
        return "Daily"
    case 3:
        return "Hourly"
    case 4:
        return "Every 5 Minutes"
    case 5:
        return "DEBUG"
    default:
        return "Never"
    }
}

func updateNotifications(_ note: Note) {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    // first remove the current Notifications
    if let noteUUID = note.id { // unwrap optional
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [noteUUID.uuidString])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [noteUUID.uuidString])
        
        let content = UNMutableNotificationContent()
        content.title = note.content ?? "Empty Note"
        content.sound = UNNotificationSound.default
        
        let trigger: UNTimeIntervalNotificationTrigger
        switch note.priority {
        case 1:
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*60*24*5, repeats: true)
        case 2:
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*60*24, repeats: true)
        case 3:
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*60, repeats: true)
        case 4:
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*5, repeats: true)
        case 5:
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        case 0:
            return
        default:
            return
        }
        
        let request = UNNotificationRequest(identifier: noteUUID.uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if error != nil {
                // TODO: handle error
            }
        }
    } else {
        print("Note has no id")
        return
    }
}

let noteDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()


func createTime(hour: Int, minute: Int) -> Date? {
    let calendar = Calendar(identifier: .gregorian)
    let date: Date?
    var dateComponents = DateComponents()
    dateComponents.hour = hour
    dateComponents.minute = minute
    date = calendar.date(from: dateComponents)
    return date
}
