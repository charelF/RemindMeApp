//
//  SettingsView.swift
//  Kiwi
//
//  Created by Charel Felten on 02/07/2021.
//

import SwiftUI

struct SettingsView: View {
    
    @State var nightBreak: Bool = true
    @State var nightBreakStart = Date()
    
    var body: some View {
        List {
            Section(header: Text("General")) {
                Toggle(isOn: $nightBreak.animation()) {
                    Text("Sleep mode")
                }
                
                if nightBreak {
                    HStack {
                        DatePicker("from", selection: $nightBreakStart, displayedComponents: .hourAndMinute)
                        DatePicker("until", selection: $nightBreakStart, displayedComponents: .hourAndMinute)
                    }
                    
                }
            }
            
            Section(header: Text("High Priority")) {
                
                Text("1")
                Text("2")
                Text("3")
            }
        }.listStyle(GroupedListStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
