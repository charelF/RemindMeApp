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
        return Color.blue
    default:
        return Color.gray
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
