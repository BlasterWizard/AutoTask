//
//  TaskActionDisplayIcon.swift
//  AutoTask
//
//  Created by Justin Wong on 5/28/22.
//

import SwiftUI

struct TaskActionDisplayIcons: View {
    @ObservedObject var task: Task
    
    var body: some View {
        HStack {
            //Reminders
            ForEach([TaskType.Reminder, TaskType.Deadline], id: \.self) { taskTypeEnum in
                if task.taskActions.filter { $0.actionType == taskTypeEnum }.count > 0 {
                    TaskActionDisplayIcon(task: task, taskType: taskTypeEnum)
                }
            }
        }
        .font(.system(size: 20))
    }
}

struct TaskActionDisplayIcon: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var task: Task
    var taskType: TaskType
    
    var body: some View {
        Image(systemName: TaskActionConditionalUI.returnTaskActionUI(for: taskType).systemImage)
        Circle()
            .fill(.ultraThinMaterial)
            .overlay(
                Circle()
                    .strokeBorder(colorScheme == .dark ? .white : .black, lineWidth: 1)
                    .overlay(
                        Text("\(task.taskActions.filter { $0.actionType == taskType}.count)")
                        .font(.system(size: 10))
                    )
            )
            .frame(width: 15, height: 15)
            .offset(x: -20, y: -9)
    }
}

struct TaskActionDisplayIcons_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Wash the Dishes"
        task.content = "First clean up the table"
        task.timestamp = Date()
        
        return TaskActionDisplayIcons(task: task)
            .preferredColorScheme(.dark)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
