//
//  RemindMeWidget.swift
//  RemindMeWidget
//
//  Created by Charel Felten on 05/07/2021.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData



struct Provider: IntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(
      date: Date(),
      configuration: ConfigurationIntent(),
      notes: Note.previewNotes,
      realFamily: context.family
    )
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(
      date: Date(),
      configuration: configuration,
      notes: Note.previewNotes,
      realFamily: context.family
    )
    completion(entry)
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    
    print("get timeline is called")
    
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
      // is there a nicer way to do it?
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
    
    let entry = SimpleEntry(
      date: Date(),
      configuration: configuration,
      notes: notes,
      realFamily: context.family
    )
    print("hey")
    let timeline = Timeline(entries: [entry], policy: .atEnd)
    completion(timeline)
  }
}



struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
  var notes: [Note]
  var realFamily: WidgetFamily
}



struct RemindMeWidgetEntryView : View {
  var entry: Provider.Entry
  
  var body: some View {
    WidgetView(notes: entry.notes, realFamily: entry.realFamily)
  }
}



@main
struct RemindMeWidget: Widget {
  let kind: String = "RemindMeWidget"
  
  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
      RemindMeWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("My Widget")
    .description("This is an example widget.")
  }
}



struct RemindMeWidget_Previews: PreviewProvider {
  static var previews: some View {
    RemindMeWidgetEntryView(
      entry: SimpleEntry(
        date: Date(),
        configuration: ConfigurationIntent(),
        notes: Note.previewNotes,
        realFamily: .systemSmall
      )
    ).previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}
