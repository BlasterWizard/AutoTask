//
//  AutoTaskApp.swift
//  AutoTask
//
//  Created by Justin Wong on 5/25/22.
//

import SwiftUI

@main
struct AutoTaskApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
