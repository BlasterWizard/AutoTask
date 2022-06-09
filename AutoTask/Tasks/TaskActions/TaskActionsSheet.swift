//
//  TaskActionsSheet.swift
//  AutoTask
//
//  Created by Justin Wong on 5/25/22.
//

import SwiftUI
import UserNotifications

struct TaskActionsSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var task: Task
    
    let taskActionsManager: TaskActionsManager = TaskActionsManager.shared
    @State private var presentNameTaskTitleAlert = false
    
    var body: some View {
        List {
            Section("Actions") {
                //Reminder
                TaskActionsSheetNode(name: "Add Reminder", systemName: "bell", description: "Creates a scheduled reminder at specific date and time", tintColor: .yellow, actionType: .Reminder) {
                    taskActionsManager.addReminder(for: task)
                    presentationMode.wrappedValue.dismiss()
                }
                
                //Deadline
                TaskActionsSheetNode(name: "Add Deadline", systemName: "clock.badge.exclamationmark", description: "Specifies date and time for task to be finished", tintColor: .red, actionType: .Deadline) {
                    taskActionsManager.addDeadline(for: task)
                    presentationMode.wrappedValue.dismiss()
                }
                
                //Add Task
                TaskActionsSheetNode(name: "Add Task", systemName: "clock.badge.exclamationmark", description: "Specifies date and time for task to be finished", tintColor: .green, actionType: .AddTask) {
                    //prompt user to customize title name
                    presentNameTaskTitleAlert = true
                    presentationMode.wrappedValue.dismiss()
                }
                .alert(isPresented: $presentNameTaskTitleAlert, TextAlert(title: "Name Task", action: {
                    print("Callback \($0 ?? "<cancel>")")
                }))
            }
            Section("Conditionals") {
                TaskActionsSheetNode(name: "If Statement", systemName: "arrow.triangle.branch", description: nil, tintColor: .gray, conditionalType: .If) {
                    taskActionsManager.addIfConditional(for: task)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct TaskActionsSheet_Previews: PreviewProvider {
    
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Wash the Dishes"
        task.timestamp = Date()
        
        return
            TaskActionsSheet(task: task)
    }
}
