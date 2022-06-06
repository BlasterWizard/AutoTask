//
//  TaskActionNode.swift
//  AutoTask
//
//  Created by Justin Wong on 5/27/22.
//

import SwiftUI

struct TaskActionNode: View {
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var taskAction: TaskAction
    @ObservedObject var task: Task
    
    var taskActionUI: TaskActionConditionalUI.TaskActionConditionalUIData
    
    let notificationManager: NotificationManager = NotificationManager.shared
    
    @State private var dateAndTime: Date
    
    init(task: Task, taskAction: TaskAction) {
        _taskAction = ObservedObject(wrappedValue: taskAction)
        _task = ObservedObject(wrappedValue: task)
        _dateAndTime = State(wrappedValue: taskAction.dateAndTime)
        print("TaskAction DateAndTime: " + "\(taskAction.dateAndTime)")
        
        self.taskActionUI = TaskActionConditionalUI.returnTaskActionUI(for: taskAction.actionType)
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            header
            nodeBody
            if !taskAction.isConfirmed {
                doneButton
            }
        }
        .padding(5)
        .background(taskActionUI.backgroundColor)
        .cornerRadius(10)
    }
    
    var header: some View {
        HStack {
            Image(systemName: taskActionUI.systemImage)
            Text(taskActionUI.taskName)
                .font(.caption)
                .foregroundColor(.secondary)
                .bold()
            Spacer()
            if taskAction.isConfirmed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 15))
            }
        }
    }
    
    var nodeBody: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
            if taskAction.actionType == .Reminder || taskAction.actionType == .Deadline {
                reminderAndDeadlineBody
            }
            Spacer()
            nodeMenu
        }
    }
    
    var nodeMenu: some View {
        Menu {
            //Delete Task Action
            Button(action: {
                task.removeFromTaskActions_(taskAction)
                notificationManager.deleteSpecificPendingNotifications(for: [taskAction.identifier])
                try? context.save()
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.secondary)
        }
    }
    
    var reminderAndDeadlineBody: some View {
        DatePicker("", selection: $dateAndTime)
            .onChange(of: dateAndTime) { newValue in
                withAnimation {
                    taskAction.isConfirmed = false
                }
            }
            .datePickerStyle(CompactDatePickerStyle())
    }
    
    var doneButton: some View {
        HStack {
            Spacer()
            Button(action: {
                withAnimation {
                    taskAction.isConfirmed = true
                    taskAction.dateAndTime = dateAndTime
                    try? context.save()
                }
                scheduleNotificationforReminderOrDeadline()
            }) {
                Text("Done")
                    .foregroundColor(.white)
                    .bold()
            }
            .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5))
            .background(.blue)
            .cornerRadius(10.0)
        }
        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
    }
    
    private func scheduleNotificationforReminderOrDeadline() {
        //create/schedule user notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        let components = taskAction.dateAndTime.get(.day, .month, .year)
        if let day = components.day, let month = components.month, let year = components.year {
            
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: taskAction.dateAndTime)
            let minute = calendar.component(.minute, from: taskAction.dateAndTime)
            
            var newDateComponent = DateComponents()
            newDateComponent.day = day
            newDateComponent.month = month
            newDateComponent.year = year
            newDateComponent.hour = hour
            newDateComponent.minute = minute
          
            notificationManager.scheduleUNCalendarNotificationTrigger(title: task.title, body: taskAction.content, dateComponents: newDateComponent, identifier: taskAction.identifier)
        }
    }
}

//MARK: - TaskActionNode_Previews
struct TaskActionNode_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Wash the Dishes"
        task.content = "First clean up the table"
        task.timestamp = Date()
        
        let taskActionReminder = TaskAction(context: context)
        taskActionReminder.actionType = .Reminder
        taskActionReminder.isConfirmed = true
        
        let taskActionDeadline = TaskAction(context: context)
        taskActionDeadline.actionType = .Deadline

        return Group {
            TaskActionNode(task: task, taskAction: taskActionReminder)
            .padding()
            .previewLayout(.sizeThatFits)
            TaskActionNode(task: task, taskAction: taskActionDeadline)
            .padding()
            .previewLayout(.sizeThatFits)
        }
    }
}

