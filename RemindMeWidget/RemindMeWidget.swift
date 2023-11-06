//
//  RemindMeWidget.swift
//  RemindMeWidget
//
//  Created by Charel Felten on 05/07/2021.
//

import WidgetKit
import SwiftUI
import CoreData

struct MyWidgetProvider: TimelineProvider {
  typealias Entry = MyWidgetEntry
  
  func placeholder(in context: Context) -> MyWidgetEntry {
    MyWidgetEntry(date: Date(), notes: [])
  }
  
  func getSnapshot(in context: Context, completion: @escaping (MyWidgetEntry) -> Void) {
    let entry = MyWidgetEntry(date: Date(), notes: fetchNotes())
    completion(entry)
  }
  
  func getTimeline(in context: Context, completion: @escaping (Timeline<MyWidgetEntry>) -> Void) {
    let entry = MyWidgetEntry(date: Date(), notes: fetchNotes())
    let timeline = Timeline(entries: [entry], policy: .atEnd)
    completion(timeline)
  }
  
  private func fetchNotes() -> [Note] {
    var notes: [Note] = []
    let containerURL = PersistenceController.containerURL
    let storeURL = containerURL.appendingPathComponent(PersistenceController.SQLiteStoreAppendix)
    let description = NSPersistentStoreDescription(url: storeURL)
    let container = NSPersistentCloudKitContainer(name: PersistenceController.containerName)
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    let viewContext = PersistenceController.shared.container.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
    do {
      let result = try viewContext.fetch(request)
      if let tmp = result as? [Note] {
        notes = tmp
      }
    } catch {
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    notes = notes.sorted { (lhs, rhs) in
      if lhs.int16priority == rhs.int16priority {
        return lhs.timestamp! > rhs.timestamp!
      }
      return lhs.int16priority > rhs.int16priority
    }
    return notes
  }
}

struct MyWidgetEntry: TimelineEntry {
    let date: Date
    let notes: [Note]
}

@main
struct MyWidget: Widget {
    let kind: String = "RemindMeWidget"
  @ObservedObject var config = Config.shared
  
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MyWidgetProvider()) { entry in
          WidgetView(entry: entry, config: config)
        }
        .configurationDisplayName("RemindMe Widget")
        .description("Your most important reminders at a glance.")
        .supportedFamilies([
          .systemSmall,
          .systemMedium,
          .systemLarge,
          .systemExtraLarge,
          .accessoryCircular,
          .accessoryRectangular,
          .accessoryInline,
      ])
        .contentMarginsDisabled()
    }
}
