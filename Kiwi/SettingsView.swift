//
//  SettingsView.swift
//  Kiwi
//
//  Created by Charel Felten on 02/07/2021.
//

import SwiftUI

enum Interval: String, Equatable, CaseIterable {
    case month = "Month"
    case week = "Week"
    case day = "Day"
    case hour = "Hour"
    case minute = "Minute"
}

struct SettingsView: View {
    
    @State var nightBreak: Bool = true
    
    @State var priority0: Bool = true
    @State var priority1: Bool = true
    @State var priority2: Bool = true
    @State var priority3: Bool = true
    
    @State var nightBreakStart = Date()
    @State var interval: Interval = .day
    @State var amount: Int = 2
    
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
            
            Section(header: Text("No notification")) {
                Toggle(isOn: $priority0) {
                    Text("No notification notes")
                }
            }
            
            Section(header: Text("Low Priority")) {
                Toggle(isOn: $priority1.animation()) {
                    Text("Low priority notes")
                }
                
                if priority1 {
                    
                    Stepper(value: $amount, in: 1...30) {
                        Text("Number of reminders")
                    }

                    
                    
                    Picker(selection: $interval, label: Text("per")) {
                        ForEach(Interval.allCases, id: \.self) { value in
                            Text(value.rawValue).tag(value)
                        }
                    }
//                    .pickerStyle(SegmentedPickerStyle())
                    
                    DatePicker("First reminder at", selection: $nightBreakStart, displayedComponents: .hourAndMinute)
                    
                }
            }
            
        }.listStyle(GroupedListStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
