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
    
    var body: some View {
        NavigationView {
            List {
                Section("Actions") {
                    //Reminder
                    TaskActionsSheetNode(name: "Add Reminder", systemName: "bell", description: "Creates a scheduled reminder at specific date and time", tintColor: .yellow, type: .Reminder, select: addReminder)
                    
                    //Deadline
                    TaskActionsSheetNode(name: "Add Deadline", systemName: "clock.badge.exclamationmark", description: "Specifies date and time for task to be finished", tintColor: .red, type: .Deadline, select: addDeadline)
                }
                Section("Control Flow") {
                    //If
                    TaskActionsSheetNode(name: "If Statement", systemName: "arrow.triangle.branch", description: nil, tintColor: .gray, type: .If, select: {})
                    //And
                    TaskActionsSheetNode(name: "And Statement", systemName: "arrow.triangle.merge", description: nil, tintColor: .gray, type: .And, select: {})
                }
            }
            .navigationTitle("Task Actions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 20))
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
    
    private func addReminder() {
        let newTaskReminder = TaskAction(context: context)
        newTaskReminder.actionType = .Reminder
        newTaskReminder.order = Int32(task.taskActions.count) + 1
        newTaskReminder.isConfirmed = false
        newTaskReminder.identifier = UUID().uuidString
        newTaskReminder.content = "Reminder to complete this task!"
        task.addToTaskActions_(newTaskReminder)

        try? context.save()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func addDeadline() {
        let newTaskDeadline = TaskAction(context: context)
        newTaskDeadline.actionType = .Deadline
        newTaskDeadline.order = Int32(task.taskActions.count) + 1
        newTaskDeadline.isConfirmed = false
        newTaskDeadline.identifier = UUID().uuidString
        newTaskDeadline.content = "Deadline to complete this task has passed!"
        task.addToTaskActions_(newTaskDeadline)
        
        try? context.save()
        presentationMode.wrappedValue.dismiss()
    }
}

struct TaskActionsSheet_Previews: PreviewProvider {
    
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Wash the Dishes"
        task.content = "First clean up the table"
        task.timestamp = Date()
        
        return
            TaskActionsSheet(task: task)
    }
}
