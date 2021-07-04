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
    case never = "Never"
}
//
//enum Weekday: String, Equatable, CaseIterable {
//    case monday = "Mon"
//    case tuesday = "Tue"
//    case wednesday = "Wed"
//    case thursday = "Thu"
//    case friday = "Fri"
//    case saturday = "Sat"
//    case sunday = "Sun"
//}

struct SettingsView: View {
    
    @State var nightBreak: Bool = true
    @State var nightStart: Date = createTime(hour: 22, minute: 00) ?? Date()
    @State var nightEnd: Date = createTime(hour: 07, minute: 59) ?? Date()
    
    
    @State var priority0Interval: Interval = .hour
    @State var priority0Date: Date = createTime(hour: 08, minute: 00) ?? Date()
    
    @State var priority1Interval: Interval = .hour
    @State var priority2Interval: Interval = .hour
    
//    @State var weekday: Weekday = .monday
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("General")) {
                    
                    Toggle(isOn: $nightBreak.animation()) {
                        Text("Sleep mode")
                    }
                    
                    if nightBreak {
                        HStack {
                            DatePicker(selection: $nightStart, displayedComponents: .hourAndMinute) {
                                Text("From").frame(maxWidth: .infinity, alignment: .leading)
                            }
                            DatePicker(selection: $nightEnd, displayedComponents: .hourAndMinute) {
                                Text("until").frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        
                    }
                }
                
                
                
                Section(header: Text("Low Priority").foregroundColor(Color.secondary)) {
                        
                    Picker(selection: $priority0Interval, label: Text("Notification interval")) {
                        ForEach(Interval.allCases, id: \.self) { value in
                            Text(value.rawValue).tag(value)
                        }
                    }
                        
                    switch priority0Interval {
                    case .ten_minutes, .thirty_minutes, .hour, .never:
                        EmptyView()
                    case .week, .month:
                        DatePicker("First reminder on", selection: $priority0Date, displayedComponents: [.date, .hourAndMinute])
//                        Picker(selection: $weekday, label: Text("Reminder on")) {
//                            ForEach(Weekday.allCases, id: \.self) { value in
//                                Text(value.rawValue).tag(value)
//                            }
//                        }
//                        .pickerStyle(SegmentedPickerStyle())
                    default:
                        DatePicker("First reminder per day at", selection: $priority0Date, displayedComponents: [.hourAndMinute])
                    }
                }
                .foregroundColor(priorityToColor(priority: 0))
                .listRowBackground(priorityToColor(priority: 0).opacity(0.05))
            }
            .listStyle(GroupedListStyle())
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
