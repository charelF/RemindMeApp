//
//  WidgetView.swift
//  Kiwi
//
//  Created by Charel Felten on 06/07/2021.
//

import SwiftUI

struct WidgetView: View {
    
    var notes: [String] = ["1"]
    
    // Notes
    // - List not supported, so we have to use Vstack
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(notes, id: \.self) { note in
                VStack(
                    alignment: .leading) {
                    Text("\(note)")
                        .padding([.bottom], -3)
                        .padding([.top], 6)
                        .padding(.horizontal)
                    .lineLimit(1)
                        .foregroundColor(priorityToColor(priority: 1))
                    Divider()
                }
                
                .background(priorityToColor(priority: 1).opacity(0.05))
//                .frame(maxWidth: .infinity)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
//            Spacer()
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(
            notes: [
                "This is a long note test",
                "s",
                "short note",
                "----",
                "5",
//                "234234",
//                "aaa"
            ]
        ).previewLayout(.fixed(width: 160, height: 160))
    }
}
