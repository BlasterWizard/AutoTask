//
//  TaskConditionalNode.swift
//  AutoTask
//
//  Created by Justin Wong on 6/5/22.
//

import SwiftUI

struct TaskConditionalNode: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var taskConditional: TaskConditional
    @ObservedObject var task: Task
    
    var taskActionUI: TaskActionConditionalUI.TaskActionConditionalUIData
    
    @State private var showTaskActionInfoSheet = false
    @State private var taskConditionalStatus: TAConditions = .none
    
    init(taskConditional: TaskConditional, task: Task) {
        _taskConditional = ObservedObject(wrappedValue: taskConditional)
        _task = ObservedObject(wrappedValue: task)
        self.taskActionUI = TaskActionConditionalUI.returnTaskActionUI(for: taskConditional.conditionalType)
        _taskConditionalStatus = State(wrappedValue: taskConditional.status)
    }
    
    var body: some View {
        HStack {
            Text(taskActionUI.taskName)
                .bold()
            conditionButton
            conditionalStatusPicker
            Spacer()
            deleteConditionalButton
        }
        .padding()
        .background(taskActionUI.backgroundColor)
        .cornerRadius(10)
        .foregroundColor(.white)
        .font(.headline)
        .halfSheet(showSheet: $showTaskActionInfoSheet) {
            TaskActionInfoSheet(task: task, taskConditional: taskConditional)
        }
    }
    
    var conditionButton: some View {
        Button(action: {
            showTaskActionInfoSheet.toggle()
        }) {
            Text(task.getTaskAction(for: taskConditional.identifier)?.nickName ?? "Condition")
                .padding(10)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)
                .fixedSize()
        }
    }
    
    var conditionalStatusPicker: some View {
        Menu {
            Picker(selection: $taskConditional.status, label: Text("hello")) {
                ForEach(taskConditional.status.returnConditions(for: task.getTaskAction(for: taskConditional.identifier)?.actionType ?? .None), id: \.self) { conditionStatus in
                    Text(conditionStatus.returnStringName())
                }

            }
        } label: {
            HStack {
                Text(taskConditional.status.returnStringName())
                    .fixedSize()
                Image(systemName: "chevron.down")
            }
                .padding(10)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)
        }
    }
    
    var deleteConditionalButton: some View {
        Button(action: {
            withAnimation {
                task.removeFromTaskConditionals_(taskConditional)
                try? context.save()
            }
        }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
                .font(.system(size: 20))
        }
    }
}

//MARK: - TaskActionInfoSheet
struct TaskActionInfoSheet: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var task: Task
    @ObservedObject var taskConditional: TaskConditional
    
    var body: some View {
        List {
            ForEach(task.taskActions, id: \.self) { taskAction in
                Button(action: {
                    taskConditional.identifier = taskAction.identifier
                    taskConditional.status = .none
                    try? context.save()
                }) {
                    TaskActionDetailInfoView(taskAction: taskAction, taskConditional: taskConditional)
                }
            }
        }
    }
}

//MARK: - TaskActionDetailInfoView
struct TaskActionDetailInfoView: View {
    @ObservedObject var taskAction: TaskAction
    @ObservedObject var taskConditional: TaskConditional
    
    @State private var expandTaskActionDetail = false
    
    var body: some View {
        VStack {
            HStack {
                Text(taskAction.nickName == "" ? taskAction.actionType.returnStringName() : taskAction.nickName)
                    .bold()
                expandMoreInfoButton
                Spacer()
                if taskConditional.identifier == taskAction.identifier {
                    Image(systemName: "checkmark")
                }
            }
            
            if expandTaskActionDetail {
                HStack {
                    Text(taskAction.dateAndTime_?.formatted() ?? "No Date/Time")
                    Spacer()
                }
            }
        }
    }
    
    var expandMoreInfoButton: some View {
        Button(action: {
            withAnimation {
                expandTaskActionDetail.toggle()
            }
        }) {
            Image(systemName: "chevron.right.circle")
                .rotationEffect(expandTaskActionDetail ? .degrees(90) : .degrees(0))
        }
    }
}

struct TaskConditionalNode_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Wash the Dishes"
        task.content = "First clean up the table"
        task.timestamp = Date()
        
        let newReminder = TaskAction(context: context)
        newReminder.actionType = .Reminder
        newReminder.identifier = UUID().uuidString
        newReminder.nickName = "Brush Teeth Reminder"
        newReminder.dateAndTime = Date()
        task.addToTaskActions_(newReminder)
        
        let newDeadline = TaskAction(context: context)
        newDeadline.actionType = .Deadline
        newDeadline.identifier = UUID().uuidString
        newDeadline.nickName = "Deadline"
        task.addToTaskActions_(newDeadline)
        
        let ifConditional = TaskConditional(context: context)
        ifConditional.conditionalType = .If
        
        return Group {
            TaskConditionalNode(taskConditional: ifConditional, task: task)
            TaskActionInfoSheet(task: task, taskConditional: ifConditional)
        }
        .padding()
        .previewLayout(.sizeThatFits)
       
    }
}
