//
//  WidgetView.swift
//  RemindMe
//
//  Created by Charel Felten on 06/07/2021.
//

import SwiftUI

struct WidgetView: View {
    
    var notes: [Note]
    var displayNotes: [Note] {
        get {
            let sortedPriorityNotes = notes.sorted(by: { $0.priority > $1.priority })
            switch family {
                
            case .systemLarge:
                guard notes.count > 10 else {
                    return notes
                }
                return sortedPriorityNotes[0...9].sorted(by: { $0.timestamp!.timeIntervalSince1970 < $1.timestamp!.timeIntervalSince1970 })
            
            case .systemSmall, .systemMedium:
                fallthrough
            
            case .systemExtraLarge:
                fallthrough
                
            @unknown default:
                guard notes.count > 4 else {
                    return notes
                }
                return sortedPriorityNotes[0...3].sorted(by: { $0.timestamp!.timeIntervalSince1970 < $1.timestamp!.timeIntervalSince1970 })
            }
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family
    
    // Notes
    // - List not supported, so we have to use Vstack
    
    
    
    var body: some View {
        Color.secondary.opacity(0.2).overlay(
        ZStack(alignment: .top) {
//            Color.secondary.opacity(0.2)
            VStack(spacing: 0) {
                Divider()
                ForEach(displayNotes, id: \.self) { note in
//                    LazyVStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("\(note.content ?? "empty")")
                            .lineLimit(
                                notes.count > 2 ? 1 : 2
                            )
                            .foregroundColor(note.getPrimaryColor())
                            .padding(.horizontal, 8)
                            .padding(.top, 4.5)
                            .padding([.bottom], -1.5)
                            .font(.subheadline)
                        Divider()
                    }
//                    .background(note.getBackgroundColor())
//                    .background(getBackgroundColor()).opacity(1)
                    .background(
                        ZStack {
                            colorScheme == .dark ? Color.black : Color.white
                            note.getWidgetBackgroundColor()
                        }
                    )
                }
            }
        })
    }
    
//    private func getBackgroundColor() -> Color {
//        let darkBG = Color(red: 0.1, green: 0.1, blue: 0.1)
//        if colorScheme == .dark {
//            return darkBG
//        } else {
//            return Color.white
//        }
//    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(
            notes: Note.previewNotes
        ).previewLayout(.fixed(width: 160, height: 160))
    }
}
