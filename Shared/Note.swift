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

extension Note {
  
  // MARK: static properties
  static let previewNotes: [Note] = {
    let pvc = PersistenceController.preview.container.viewContext
    var notes = [Note]()
    notes.append(Note(context: pvc, content: "Short note"))
    notes.append(Note(context: pvc, content: "This is a longer note with a higher priority, it may span 2 columns"))
    notes.append(Note(context: pvc, content: "Yet another note"))
    notes.append(Note(context: pvc, content: "note 4"))
    notes.append(Note(context: pvc, content: "note 5"))
    notes.append(Note(context: pvc, content: "note 6"))
    notes.append(Note(context: pvc, content: "note 7"))
    notes.append(Note(context: pvc, content: "note 8"))
    notes.append(Note(context: pvc, content: "note 9"))
    notes.append(Note(context: pvc, content: "note 10"))
    notes.append(Note(context: pvc, content: "note 11"))
    notes.append(Note(context: pvc, content: "note 12"))

    notes[0].priority = Priority.low
    notes[1].priority = Priority.medium
    notes[2].priority = Priority.high
    return notes
  }()
  
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
  }()
  
  // MARK: static methods
  static func add(content: String) {
    if content.isEmpty {
      return
    }
    let viewContext = PersistenceController.shared.container.viewContext
    _ = Note(context: viewContext, content: content)
    PersistenceController.shared.save()
  }
  
  // MARK: instance properties
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
        // Note: I think it is a good idea to leave the date in the priority. The note.customDate is optional, whereas the date
        // associated to the priority is not, so its safer to use.
      default:
        return .low
      }
    }
    set {
      self.int16priority = Int16(newValue.getIndex())
    }
  }
  
  // MARK: initialiser
  convenience init(context: NSManagedObjectContext, content: String) {
    self.init(context: context)
    self.content = content
    self.timestamp = Date()
    self.id = UUID()
    self.priority = .low
    self.notificationids = []
    self.addNotifications()
  }
  
  // MARK: instance methods
  func updatePriority(optionalDate: Date?) {
    self.deleteNotifications()
    if let date = optionalDate {
      self.priority = Priority.custom(date: date)  // we associate for easier usage
      self.customDate = date  // we store it here aswell in order to save changes when closing app
      // actually, self.customDate is only for the storage. But anyone accessing this date should always access it over the priority,
      // that is safer, as the one in the priority is not optional
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
  
  func getPrimaryColor() -> Color {
    return Config.shared.colorTheme.getColors().getColor(for: self, in: .primary)
  }
  
  func getSecondaryColor() -> Color {
    return Config.shared.colorTheme.getColors().getColor(for: self, in: .secondary)
  }
  
  func getBackgroundColor() -> Color {
    return Config.shared.colorTheme.getColors().getColor(for: self, in: .background)
  }
  
  func getWidgetBackgroundColor() -> Color {
    return Config.shared.colorTheme.getColors().getColor(for: self, in: .background)
  }
  
  func deleteNotifications() {
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.removePendingNotificationRequests(withIdentifiers: self.notificationids!)
    notificationCenter.removeDeliveredNotifications(withIdentifiers: self.notificationids!)
  }
  
  func addNotifications() {
    let notificationCenter = UNUserNotificationCenter.current()
    
    let content = UNMutableNotificationContent()
    content.title = "RemindMe"
    content.body = self.content ?? "."
    content.sound = UNNotificationSound.default
    // TODO: add badges, e.g. of messages that arrived since last time app was open
    // TODO: also add other fields, see UNMutableNotificationContent, plenty possibilities
    
    var notificationid: String
    var request: UNNotificationRequest
    let triggers: [UNNotificationTrigger]
    
    switch self.priority {
    case .custom(let date):
      // for custom notifactions we do reminders on the chosen date
      let dateComponents: DateComponents = Calendar.current.dateComponents(
        [.year, .month, .day, .hour, .minute],
        from: date
      )
      triggers = [UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)]
    default:
      // for other notes, we do reminders at specified intervals
      triggers = createNotificationTriggers()
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
  }
  
  func createNotificationTriggers() -> [UNNotificationTrigger] {
    var triggers: [UNNotificationTrigger] = []
    
    let intervalAndDate = Config.shared.getIntervalAndDate(for: self.priority)
    guard let intervalAndDate else { return [] }
    
    let interval = intervalAndDate.interval
    let firstNotificationTime = intervalAndDate.date
    
    var dateComponents: DateComponents
    
    switch interval {
      
    case .ten_minutes:
      triggers.append(UNTimeIntervalNotificationTrigger(timeInterval: 60*10, repeats: true))
      
    case .hour:
      dateComponents = Calendar.current.dateComponents([.minute, .second], from: firstNotificationTime)
      triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
      
    case .three_hours:
      for elapsedTime in [0, 3, 6, 9, 12, 15, 18, 21] {
        let triggerTime = firstNotificationTime + TimeInterval(elapsedTime * 60 * 60)
        dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: triggerTime)
        triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
      }
      
    case .six_hours:
      for elapsedTime in [0, 6, 12, 18] {
        let triggerTime = firstNotificationTime + TimeInterval(elapsedTime * 60 * 60)
        dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: triggerTime)
        triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
      }
      
    case .twelve_hours:
      for elapsedTime in [0, 12] {
        let triggerTime = firstNotificationTime + TimeInterval(elapsedTime * 60 * 60)
        dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: triggerTime)
        triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
      }
      
    case .day:
      dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: firstNotificationTime)
      triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
      
    case .week:
      dateComponents = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: firstNotificationTime)
      triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
      
    case .month:
      dateComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: firstNotificationTime)
      triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true))
      
    case .never:
      fallthrough
      
    default:
      break
    }
    
    return triggers
  }
  
  static func getAllNotes() -> [Note] {
    // how to do fetchrequests without @FetchRequest:
    // - https://www.advancedswift.com/fetch-requests-core-data-swift/#fetch-all-objects-of-one-entity
    
    let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
    let viewContext = PersistenceController.shared.container.viewContext
    var notes: [Note] = []
    
    do {
      notes = try viewContext.fetch(fetchRequest)
      print("Fetched \(notes.count) notes")
    } catch {
      print("Unexpected error, no Notes fetched: \(error)")
    }
    
    return notes
  }
  
  static func updateAllNotes() {
    let notes = Note.getAllNotes()
    
    for note in notes {
      switch note.priority {
      case .custom(_):
        continue
      default:
        note.deleteNotifications()
        note.addNotifications()
      }
      PersistenceController.shared.save()
    }
    print("Updated all notes") // set breakpoint here and verified that this is ran when app is left
  }
}








