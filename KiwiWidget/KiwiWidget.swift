//
//  KiwiWidget.swift
//  KiwiWidget
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
            notes: []
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            notes: []
        )
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        var notes: [Note] = []
        
        let containerURL = PersistenceController.containerURL
        let storeURL = containerURL.appendingPathComponent(PersistenceController.SQLiteStoreAppendix)
        let description = NSPersistentStoreDescription(url: storeURL)
        let container = NSPersistentCloudKitContainer(name: "Kiwi")
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        let context = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        do {
            let result = try context.fetch(request)
            // is there a nicer way to do it?
            if let tmp = result as? [Note] {
                notes = tmp
            }
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(
                date: entryDate,
                configuration: configuration,
                notes: notes)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    var notes: [Note]
}

struct KiwiWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        WidgetView(notes: entry.notes)
    }
}

@main
struct KiwiWidget: Widget {
    let kind: String = "KiwiWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            KiwiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct KiwiWidget_Previews: PreviewProvider {
    static var previews: some View {
        KiwiWidgetEntryView(
            entry: SimpleEntry(
                date: Date(),
                configuration: ConfigurationIntent(),
                notes: []
            )
        ).previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
