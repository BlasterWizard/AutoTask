//
//  TaskActionNode.swift
//  AutoTask
//
//  Created by Justin Wong on 5/27/22.
//

import SwiftUI
import SwiftEntryKit

struct TaskActionNode: View {
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var taskAction: TaskAction
    @ObservedObject var task: Task
    
    var taskActionUI: TaskActionConditionalUI.TaskActionConditionalUIData
    
    let notificationManager: NotificationManager = NotificationManager.shared
    
    @State private var dateAndTime: Date
    @State private var showDoneButton = false
    
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
            if showDoneButton {
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
            Text(taskAction.nickName == "" ? taskActionUI.taskName : taskAction.nickName)
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
            Button(role: .destructive, action: {
                task.removeFromTaskActions_(taskAction)
                notificationManager.deleteSpecificPendingNotifications(for: [taskAction.identifier])
                try? context.save()
            }, label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            })
            
            Button(action: {
                //allow user to assign nickname to Task Action
                var attributes = EKAttributes()
                attributes.name = "Hello"
                attributes.windowLevel = .normal
                attributes.position = .center
                attributes.displayDuration = .infinity
                attributes.entryBackground = .color(color: .standardContent)
                attributes.screenBackground = .color(color: EKColor(UIColor(white: 0.5, alpha: 0.5)))
                attributes.roundCorners = .all(radius: 20)
                attributes.entryInteraction = .absorbTouches
                
                SwiftEntryKit.display(entry:
                    UIHostingController(rootView: TaskActionEditNicknameOverlay(taskAction: taskAction)), using: attributes)
            }) {
                HStack {
                    VStack {
                        Text("Set Nickname")
                        Text("hello")
                        Text(taskAction.nickName)
                            .foregroundColor(.secondary)
                    }
                    Image(systemName: "lanyardcard")
   
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
                    showDoneButton = true
                }
            }
            .datePickerStyle(CompactDatePickerStyle())
            .disabled(taskAction.isConfirmed)
    }
    
    var doneButton: some View {
        HStack {
            Spacer()
            Button(action: {
                withAnimation {
                    showDoneButton = false
                    taskAction.dateAndTime = dateAndTime
                    try? context.save()
                }
                notificationManager.scheduleNotificationforReminderOrDeadline(for: taskAction, in: task)
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
}

struct TaskActionEditNicknameOverlay: View {
    @ObservedObject var taskAction: TaskAction
    
    var body: some View {
        VStack {
            Text("Edit Task Action Nickname")
                .bold()
            TextField("New Nickname", text: $taskAction.nickName)
                .textFieldStyle(.roundedBorder)
            HStack {
                Spacer()
                closeButton
                Spacer()
                saveButton
                Spacer()
            }
           
        }
        .padding()
    }
    
    var closeButton: some View {
        Button(action: {
            SwiftEntryKit.dismiss(.displayed)
        }) {
            Text("Close")
                .foregroundColor(.white)
        }
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .background(.red)
        .cornerRadius(10)
    }
    
    var saveButton: some View {
        Button(action: {
            SwiftEntryKit.dismiss(.displayed)
            do {
                try PersistenceController.shared.container.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }

        }) {
            Text("Save")
                .foregroundColor(.white)
        }
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .background(.blue)
        .cornerRadius(10)
    }
}

//MARK: - TaskActionNode_Previews
struct TaskActionNode_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Wash the Dishes"
        task.timestamp = Date()
        
        let taskActionReminder = TaskAction(context: context)
        taskActionReminder.actionType = .Reminder
        taskActionReminder.isConfirmed = true
        
        let taskActionDeadline = TaskAction(context: context)
        taskActionDeadline.actionType = .Deadline

        return Group {
            TaskActionNode(task: task, taskAction: taskActionReminder)
                .previewDisplayName("Reminder")
            TaskActionNode(task: task, taskAction: taskActionDeadline)
                .previewDisplayName("Deadline")
            TaskActionEditNicknameOverlay(taskAction: taskActionReminder)
                .previewDisplayName("TaskActionEditNicknameOverlay")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

