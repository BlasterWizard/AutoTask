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
                NavigationLink(destination: SettingsTasksView()) {
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
    @EnvironmentObject var settingsVM: SettingsViewModel
    
    var body: some View {
        List {
            Toggle("Show Task Actions Icons", isOn: $settingsVM.settings.showTaskActionDisplayIcons)
                .onChange(of: settingsVM.settings.showTaskActionDisplayIcons) { value in
                //save changes to showTasksActionsIcons to UserDefaults
                settingsVM.updateShowTaskActionDisplayIcons(to: value)
            }
            NavigationLink(destination: DefaultSubEntryView()) {
                HStack {
                    Text("Default Task SubEntry Type")
                    Spacer()
                    Text(settingsVM.settings.defaultTaskSubEntryType.returnStringVersion())
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DefaultSubEntryView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    
    var body: some View {
        List {
            Section(content: {
                Button(action: {
                    settingsVM.updateDefaultTaskSubEntryType(to: .Text)
                }) {
                    HStack {
                        Text("Text")
                            .foregroundColor(.primary)
                        Spacer()
                        if settingsVM.settings.defaultTaskSubEntryType == .Text {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                Button(action: {
                    settingsVM.updateDefaultTaskSubEntryType(to: .BulletList)
                }) {
                    HStack {
                        Text("Bullet List")
                            .foregroundColor(.primary)
                        Spacer()
                        if settingsVM.settings.defaultTaskSubEntryType == .BulletList {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }, footer: {
                Text("When creating a new Task SubEntry, select a default type")
            })
        }
        .navigationTitle("Default SubEntry Type")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            SettingsView()
//                .environmentObject(SettingsViewModel())
            DefaultSubEntryView()
                .environmentObject(SettingsViewModel())
        }
    }
}
