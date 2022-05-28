//
//  TaskActionNode.swift
//  AutoTask
//
//  Created by Justin Wong on 5/27/22.
//

import SwiftUI

struct TaskActionNode: View {
    @Environment(\.managedObjectContext) var context
    
    var taskAction: TaskAction
    @ObservedObject var task: Task
    
    var taskActionUI: TaskActionUI.TaskActionUIData
    @State var dateAndTime: Date = Date()
    
    
    init(task: Task, taskAction: TaskAction) {
        self.taskAction = taskAction
        _task = ObservedObject(wrappedValue: task)
        _dateAndTime = State(wrappedValue: taskAction.dateAndTime ?? Date())
        
        switch taskAction.actionType {
        case .Reminder:
            self.taskActionUI = TaskActionUI.reminder
        case .Deadline:
            self.taskActionUI = TaskActionUI.deadline
        default:
            self.taskActionUI = TaskActionUI.placeholder
        }
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            header
            nodeBody
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
            Text("\(taskAction.order)")
            Spacer()
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
            Button(action: {
                task.removeFromTaskActions_(taskAction)
                task.taskActionsCount -= 1
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
        DatePicker("", selection: $dateAndTime, in: Date()...)
            .onChange(of: dateAndTime) { newValue in
                //save selected date and time to CoreData
                print(newValue)
                if let index = task.taskActions.firstIndex(of: taskAction) {
                    task.taskActions[index].dateAndTime = newValue
                    do {
                        print("save")
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
    
                }
            }
            .datePickerStyle(CompactDatePickerStyle())
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

//MARK: - TaskActionUI Struct

struct TaskActionUI {
    static func returnTaskActionUI(for taskType: TaskType) -> TaskActionUI.TaskActionUIData {
        switch (taskType) {
        case .Reminder:
            return reminder
        case .Deadline:
            return deadline
        default:
            break
        }
        return reminder
    }
    
    static var reminder = TaskActionUIData(taskName: "Reminder", systemImage: "bell", backgroundColor: Color(red: 255 / 255, green: 247 / 255, blue: 161 / 255).opacity(0.7))
    
    static var deadline = TaskActionUIData(taskName: "Deadline", systemImage: "clock.badge.exclamationmark", backgroundColor: Color(red: 240 / 255, green: 173 / 255, blue: 183 / 255).opacity(0.7))
    
    static var placeholder = TaskActionUIData(taskName: "", systemImage: "", backgroundColor: .white)
    
    struct TaskActionUIData {
        var taskName: String
        var systemImage: String
        var backgroundColor: Color
    }
}


