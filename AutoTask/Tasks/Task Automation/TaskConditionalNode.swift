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
    var taskAction: TaskAction?
    @ObservedObject var task: Task
    
    var taskActionUI: TaskActionConditionalUI.TaskActionConditionalUIData
    
    @State private var showTaskActionInfoSheet = false
    @State private var taskConditionalStatus: TAConditions = .none
    @State private var showMoreConditionals = false
    
    
    init(taskConditional: TaskConditional, task: Task) {
        _taskConditional = ObservedObject(wrappedValue: taskConditional)
        _task = ObservedObject(wrappedValue: task)
        print(taskConditional.identifier)
        self.taskAction = task.taskActions.filter { $0.identifier == taskConditional.identifier }.first ?? nil
        self.taskActionUI = TaskActionConditionalUI.returnTaskActionUI(for: taskConditional.conditionalType)
        _taskConditionalStatus = State(wrappedValue: taskConditional.status)
    }
    
    var body: some View {
        VStack {
            ifConditionalNode
                .zIndex(1)
            
            if showMoreConditionals {
                Group {
                    //Have variable nodes pertaining to if
                    elseConditionalNode
                    //Have variable nodes pertaining to else
                    endConditionalNode
                }
                .transition(.asymmetric(insertion: .scale, removal: .scale))
                .zIndex(0)
            }
        }
    }
    
    var ifConditionalNode: some View {
        VStack {
            HStack {
                if #available(iOS 16.0, *) {
                    VStack {
                        ViewThatFits(in: .horizontal) {
                            HStack {
                                Text(taskActionUI.taskName)
                                    .fixedSize()
                                    .bold()
                                conditionButton
                                conditionalStatusPicker
                            }
                            VStack{
                                conditionButton
                                conditionalStatusPicker
                            }
                        }
                    }
                } else {
                    Text(taskActionUI.taskName)
                        .bold()
                        .fixedSize()
                    conditionButton
                    conditionalStatusPicker
                }

                Spacer()
                deleteConditionalButton
            }
            HStack {
                Spacer()
                Button(action: {
                    withAnimation() {
                        showMoreConditionals.toggle()
                    }
                 }) {
                    Image(systemName: "chevron.right")
                        .rotationEffect(showMoreConditionals ? .degrees(90) : .degrees(0))
                }
            }
        }
        
        .conditionalNodeStyle()
        .halfSheet(showSheet: $showTaskActionInfoSheet) {
            TaskActionInfoSheet(task: task, taskConditional: taskConditional)
                .padding()
        }
    }
    
    var elseConditionalNode: some View {
        HStack {
            Text("Else")
            Spacer()
        }
        .conditionalNodeStyle()
    }
    
    var endConditionalNode: some View {
        HStack {
            Text("End")
            Spacer()
        }
        .conditionalNodeStyle()
    }
    
    var conditionButton: some View {
        Button(action: {
            showTaskActionInfoSheet.toggle()
        }) {
            Text(taskAction?.nickName ?? "Condition")
                .padding(10)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)
        }
    }
    
    var conditionalStatusPicker: some View {
        Menu {
            Picker(selection: $taskConditional.status, label: Text("hello")) {
                ForEach(taskConditional.status.returnConditions(for: task.getTaskAction(for: taskConditional.identifier)?.actionType ?? .None), id: \.self) { conditionStatus in
                    Text(conditionStatus.returnStringName()).tag(conditionStatus)
                }
            }
            .onChange(of: taskConditional.status) { newValue in
                taskConditional.status = newValue
                try? context.save()
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
    var remindersTaskActions: [TaskAction]
    var deadlineTaskActions: [TaskAction]
    
    init(task: Task, taskConditional: TaskConditional) {
        _task = ObservedObject(wrappedValue: task)
        _taskConditional = ObservedObject(wrappedValue: taskConditional)
        remindersTaskActions = task.taskActions.filter { $0.actionType == .Reminder}.sorted(by: { $0.nickName < $1.nickName})
        deadlineTaskActions = task.taskActions.filter { $0.actionType == .Deadline}.sorted(by: { $0.nickName < $1.nickName})
    }
    
    @State private var remindersDGExpanded = false
    
    var body: some View {
        VStack {
            if remindersTaskActions.count > 0 {
                //Reminders
                Text("Reminders")
                    .bold()
                    .sectionHeaderStyle()

                
                ForEach(remindersTaskActions, id: \.self) { taskAction in
                    Button(action: {
                        print("TaskAction ID: " + taskAction.identifier)
                        taskConditional.identifier = taskAction.identifier
                        taskConditional.status = .none
                        try? PersistenceController.shared.container.viewContext.save()
                    }) {
                        HStack {
                            RoundedRectIcon(backgroundColor: TaskActionConditionalUI.returnTaskActionUI(for: taskAction.actionType).backgroundColor, systemImage: TaskActionConditionalUI.returnTaskActionUI(for: taskAction.actionType).systemImage, imageColor: .black)
                            TaskActionDetailInfoView(taskAction: taskAction, taskConditional: taskConditional)
                        }
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                }
            }
         
          
            
            if deadlineTaskActions.count > 0 {
                //Deadlines
                Text("Deadlines")
                    .bold()
                    .sectionHeaderStyle()
                
                ForEach(deadlineTaskActions, id: \.self) { taskAction in
                    Button(action: {
                        print("TaskAction ID: " + taskAction.identifier)
                        taskConditional.identifier = taskAction.identifier
                        taskConditional.status = .none
                        try? PersistenceController.shared.container.viewContext.save()
                    }) {
                        HStack {
                            RoundedRectIcon(backgroundColor: TaskActionConditionalUI.returnTaskActionUI(for: taskAction.actionType).backgroundColor, systemImage: TaskActionConditionalUI.returnTaskActionUI(for: taskAction.actionType).systemImage, imageColor: .black)
                            TaskActionDetailInfoView(taskAction: taskAction, taskConditional: taskConditional)
                        }
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                }
            }
            Spacer()
        }
    }
}

//MARK: - TaskActionDetailInfoView
struct TaskActionDetailInfoView: View {
    @ObservedObject var taskAction: TaskAction
    @ObservedObject var taskConditional: TaskConditional
    
    @State private var expandTaskActionDetail = false
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(taskAction.nickName == "" ? taskAction.actionType.returnStringName() : taskAction.nickName)
                        .bold()
                        .foregroundColor(.primary)
                    expandMoreInfoButton
                    Spacer()
                }
              
                
                if expandTaskActionDetail {
                    HStack {
                        Text(taskAction.dateAndTime_?.formatted() ?? "No Date & Time Available")
                        Spacer()
                    }
                    .foregroundColor(.primary)
                }
            }
            if taskConditional.identifier == taskAction.identifier {
                Image(systemName: "checkmark")
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
                .foregroundColor(.blue)
        }
    }
}

struct TaskConditionalNode_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Wash the Dishes"
        task.timestamp = Date()
        
        let newReminder = TaskAction(context: context)
        newReminder.actionType = .Reminder
        newReminder.identifier = UUID().uuidString
        newReminder.nickName = "Brush Teeth Reminder"
        newReminder.dateAndTime = Date()
        task.addToTaskActions_(newReminder)
        
        let newReminder2 = TaskAction(context: context)
        newReminder2.actionType = .Reminder
        newReminder2.identifier = UUID().uuidString
        newReminder2.nickName = "Eat Breakfast"
        newReminder2.dateAndTime = Date()
        task.addToTaskActions_(newReminder2)
        
        let newDeadline = TaskAction(context: context)
        newDeadline.actionType = .Deadline
        newDeadline.identifier = UUID().uuidString
        newDeadline.nickName = "Deadline"
        task.addToTaskActions_(newDeadline)
        
        let ifConditional = TaskConditional(context: context)
        ifConditional.conditionalType = .If
        ifConditional.identifier = newReminder.identifier
        
        return Group {
            TaskConditionalNode(taskConditional: ifConditional, task: task)
            TaskActionInfoSheet(task: task, taskConditional: ifConditional)
                .previewDisplayName("TaskActionInfoSheet")
        }
        .padding()
        .previewLayout(.sizeThatFits)
       
    }
}
