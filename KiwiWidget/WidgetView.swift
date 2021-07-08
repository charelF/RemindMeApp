//
//  WidgetView.swift
//  Kiwi
//
//  Created by Charel Felten on 06/07/2021.
//

import SwiftUI

struct WidgetView: View {
    
    var notes: [Note]
    
    @Environment(\.colorScheme) var colorScheme
    
    // Notes
    // - List not supported, so we have to use Vstack
    
    var body: some View {
        Color.secondary.opacity(0.2).overlay(
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Divider()
                ForEach(notes, id: \.self) { note in
                    LazyVStack(alignment: .leading) {
                        Text("\(note.content ?? "empty")")
//                            .lineLimit(1)
                            .foregroundColor(priorityToColor(priority: Int(note.priority)))
                            .padding(.horizontal)
                            .padding(.top, 5)
                            .padding([.bottom], -1)
                        Divider()
                    }
                    .background(priorityToColor(priority: 0).opacity(0.05))
                    .background(getBackgroundColor()).opacity(1)
                }
            }
        })
    }
    
    private func getBackgroundColor() -> Color {
        let darkBG = Color(red: 0.1, green: 0.1, blue: 0.1)
        if colorScheme == .dark {
            return darkBG
        } else {
            return Color.white
        }
    }
    
    
    
//    var body: some View {
//        VStack(spacing: 0) {
//            ForEach(notes, id: \.self) { note in
//                VStack(
//                    alignment: .leading) {
//                    Divider()
//                    Text("\(note)")
////                        .padding([.bottom], -1)
////                        .padding([.top], 5)
//                        .padding(.horizontal)
//                    .lineLimit(1)
//                        .foregroundColor(priorityToColor(priority: 0))
////                    Divider()
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(priorityToColor(priority: 1).opacity(0.05))
////                .frame(maxWidth: .infinity)
//
//
//            }
////            Spacer()
//        }
////        .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
    
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(
            notes: []
//                "This is a long note test",
//                "s",
//                "short note",
//                "----",
//                "5",
//                "234234",
//                "aaa"
//            ]
        ).previewLayout(.fixed(width: 160, height: 160))
    }
}
