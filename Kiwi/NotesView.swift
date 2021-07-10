//
//  NotesView.swift
//  Kiwi
//
//  Created by Charel Felten on 02/07/2021.
//

import SwiftUI
import WidgetKit

struct NotesView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var config: Config

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
        animation: .default)
    
    private var notes: FetchedResults<Note>
    @State private var noteContent: String = ""
    
    var body: some View {
        VStack {
            List {
                ForEach(notes) { note in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(note.content ?? "")")
                                .padding(.vertical, 0.2)
                            Spacer() // (1)
                        }
                        
                        if config.showCreationTime || config.showNotificationTime {
                            HStack {
                                if config.showCreationTime {
                                    Image(systemName: "calendar")
                                    Text("\(note.timestamp!, formatter: Note.dateFormatter)")
                                }
                                if config.showNotificationTime {
                                    Image(systemName: "bell")
                                    Text("\(config.priorityIntervals[Int(note.priority) % Config.NUMPRIO].rawValue)")
                                }
                                Spacer() // (1)
                            }
                            .font(.footnote)
                            .foregroundColor(Color.gray.opacity(0.6))
                            .padding(.bottom, 0.2)
                        }
                    }
                    .contentShape(Rectangle()) // This together with (1) makes whole area clickable
                    .foregroundColor(Note.priorityToColor(note: note))
                    .onTapGesture{
                        changePriority(note)
                        updateNotifications(note)
                    }
                    .listRowBackground(Note.priorityToColor(note: note).opacity(0.05))
                }
                .onDelete(perform: deleteNotes)

            TextField(
                "New Note",
                text: $noteContent,
                onCommit:addNote
            )}
            .listStyle(GroupedListStyle())
        }
    }
    
    private func addNote() {
        withAnimation {
            guard !noteContent.isEmpty else {
                return
            }
            
            _ = Note(
                context: viewContext,
                content: noteContent
            )
            PersistenceController.shared.save()
            
            noteContent = ""
        }
        
    }
    
    private func changePriority(_ note: Note) {
        note.changePriority()
        PersistenceController.shared.save()
    }

    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            print(offsets.first)
            offsets.map { notes[$0] }.forEach(viewContext.delete)
            
            // delete delivered and scheduled notifications for these notes
            for i in offsets {
                print(i)
                if let noteUUID = notes[i].id {
                    let notificationCenter = UNUserNotificationCenter.current()
                    notificationCenter.removePendingNotificationRequests(withIdentifiers: [noteUUID.uuidString])
                    notificationCenter.removeDeliveredNotifications(withIdentifiers: [noteUUID.uuidString])
                }
            }
            PersistenceController.shared.save()
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
            
            let triggers: [UNNotificationTrigger] = createNotificationTriggers(
                interval: self.config.priorityIntervals[Int(note.priority)]
            )

            var request: UNNotificationRequest
            
            for trigger in triggers {
                request = UNNotificationRequest(identifier: noteUUID.uuidString, content: content, trigger: trigger)
                notificationCenter.add(request) { (error) in
                    if error != nil {
                        // TODO: handle error
                        print(error!)
                    }
                }
            }
            
            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (notifications) in
                print("--- Number of pending notifications \(notifications.count)")
            })
            
        } else {
            print("--- Note has no id")
            return
        }
        
        UNUserNotificationCenter.current()
        .getPendingNotificationRequests(completionHandler: { requests in
          for (index, request) in requests.enumerated() {
            print("%%% notification: \(index) \(request.identifier) \(String(describing: request.trigger))")
            print("[][][] Next trigger date")
            if let tt = request.trigger as? UNCalendarNotificationTrigger {
                print(tt.nextTriggerDate())
            }
            if let tt = request.trigger as? UNTimeIntervalNotificationTrigger {
                print(tt.nextTriggerDate())
            }
            print("[][][]")
            
          }
          })
    }
    
    func createNotificationTriggers(interval: Interval) -> [UNNotificationTrigger] {
        var trigger: [UNNotificationTrigger] = []
        var firstNotificationTime = Date()
        
        // TODO: below code is very ugly
        var executed = false
        for i in 0..<Config.NUMPRIO {
            if config.priorityIntervals[i] == interval {
                firstNotificationTime = config.priorityDates[i]
                executed = true
            }
        }
        guard executed else {
            print("--- Could not create notification")
            return []
        }
        
        print("***")
        print(interval.rawValue)
        print(firstNotificationTime)
        print("***")
        
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
            // also used to handle case .never
            trigger = []
        }
        return trigger
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView(
            config: Config()
        ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
