//
//  AutoTaskApp.swift
//  AutoTask
//
//  Created by Justin Wong on 5/25/22.
//

import SwiftUI

@main
struct AutoTaskApp: App {
    @StateObject var settingsVM = SettingsViewModel()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                TasksView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(settingsVM)
                    .tabItem {
                        Image(systemName: "checklist")
                        Text("Tasks")
                    }
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .environmentObject(settingsVM)
            }
            
           
        }
    }
}
