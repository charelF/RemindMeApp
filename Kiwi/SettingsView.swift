//
//  SettingsView.swift
//  Kiwi
//
//  Created by Charel Felten on 02/07/2021.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var config: Config
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("General")) {
                    
                    Toggle(isOn: $config.nightBreak.animation()) {
                        Text("Sleep mode")
                    }
                    
                    if config.nightBreak {
                        HStack {
                            DatePicker(selection: $config.nightStart, displayedComponents: .hourAndMinute) {
                                Text("From").frame(maxWidth: .infinity, alignment: .leading)
                            }
                            DatePicker(selection: $config.nightEnd, displayedComponents: .hourAndMinute) {
                                Text("until").frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        
                    }
                }
                
                ForEach(0..<3) { i in
                
                    Section(header: Text(config.priorityDescriptions[i]).foregroundColor(Color.secondary)) {

                        Picker(selection: $config.priorityIntervals[i], label: Text("Notification interval")) {
                            ForEach(Interval.allCases, id: \.self) { value in
                                Text(value.rawValue).tag(value)
                            }
                        }

                        switch config.priorityIntervals[i] {
                        case .ten_minutes, .thirty_minutes, .hour, .never:
                            EmptyView()
                        default:
                            DatePicker("First reminder at", selection: $config.priorityDates[i], displayedComponents: [.hourAndMinute])
                        }
                    }
                    .foregroundColor(priorityToColor(priority: i))
                    .listRowBackground(priorityToColor(priority: i).opacity(0.05))
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            config: Config()
        )
    }
}
