//
//  SettingsView.swift
//  AutoTask
//
//  Created by Justin Wong on 5/27/22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: SettingsTasksView(settingsVM: settingsVM)) {
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.green)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Image(systemName: "checklist")
                                .foregroundColor(.white)
                            )
                        Text("Tasks")
                    }
                }
            }
            .navigationTitle("Settings")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct SettingsTasksView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    
    @State private var showTaskActionsIcons = true
    
    init(settingsVM: SettingsViewModel) {
        _settingsVM = ObservedObject(wrappedValue: settingsVM)
        _showTaskActionsIcons = State(wrappedValue: settingsVM.settings.showTaskActionDisplayIcons)
    }
    var body: some View {
        List {
            Toggle("Show Task Actions Icons", isOn: $showTaskActionsIcons)
            .onChange(of: showTaskActionsIcons) { value in
                //save changes to showTasksActionsIcons to UserDefaults
                settingsVM.updateShowTaskActionDisplayIcons(to: value)
            }
        }
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
