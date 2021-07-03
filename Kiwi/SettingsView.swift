//
//  SettingsView.swift
//  Kiwi
//
//  Created by Charel Felten on 02/07/2021.
//

import SwiftUI

enum Interval: String, Equatable, CaseIterable {
    case ten_minutes = "Every 10 minutes"
    case thirty_minutes = "Every 30 minutes"
    case hour = "Hourly"
    case three_hours = "Every 3 hours"
    case six_hours = "Every 6 hours"
    case twelve_hours = "Twice a day"
    case day = "Daily"
    case two_days = "Every other day"
    case week = "Weekly"
    case month = "Monthly"
}

enum Weekday: String, Equatable, CaseIterable {
    case monday = "Mon"
    case tuesday = "Tue"
    case wednesday = "Wed"
    case thursday = "Thu"
    case friday = "Fri"
    case saturday = "Sat"
    case sunday = "Sun"
}

struct SettingsView: View {
    
    @State var nightBreak: Bool = true
    
    @State var priority0: Bool = true
    @State var priority1: Bool = true
    @State var priority2: Bool = true
    @State var priority3: Bool = true
    
    @State var nightBreakStart = Date()
    @State var interval: Interval = .hour
    @State var weekday: Weekday = .monday
    
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
                    
                    Picker(selection: $interval, label: Text("per")) {
                        ForEach(Interval.allCases, id: \.self) { value in
                            Text(value.rawValue).tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    
                    switch interval {
                    case .ten_minutes, .thirty_minutes, .hour, .three_hours:
                        EmptyView()
                    case .week, .month:
                        Picker(selection: $weekday, label: Text("Reminder on")) {
                            ForEach(Weekday.allCases, id: \.self) { value in
                                Text(value.rawValue).tag(value)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        DatePicker("First reminder at", selection: $nightBreakStart, displayedComponents: [.hourAndMinute])
                    default:
                        DatePicker("First reminder at", selection: $nightBreakStart, displayedComponents: [.hourAndMinute])
                    }
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
