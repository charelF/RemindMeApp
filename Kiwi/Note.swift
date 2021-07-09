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
}








