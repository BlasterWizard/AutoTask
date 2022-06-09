//
//  TaskAutomationView.swift
//  AutoTask
//
//  Created by Justin Wong on 6/4/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct TaskAutomationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var task: Task
    @Binding var isShowingAutomationView: Bool

    
    @State private var showTaskActionsSheet = false
    @State var draggedTaskActionNode: TaskAction?
    
    @SceneStorage("currentTaskActionsOpened") var currentTaskActionsOpenedState = true
    @SceneStorage("currentConditionalNodesOpened") var currentConditionalNodesOpenedState = true

    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: true) {
                DisclosureGroup(isExpanded: $currentTaskActionsOpenedState,
                content: {
                    currentTaskActions
                }, label: {
                    HStack {
                        Text("Task Actions")
                            .bold()
                            .sectionHeaderStyle()
                        Spacer()
                        Text("\(task.taskActions.count)")
                            .badgeStyle()
                    }
                })
                .disabled(task.taskActions.count == 0)
               
               
                if task.taskActions.count > 0 {
                    Divider()
                }
                
                DisclosureGroup(isExpanded: $currentConditionalNodesOpenedState,
                    content: {
                    ForEach(task.taskConditionals.sorted(by: { $0.order < $1.order }), id: \.self) { taskConditional in
                        TaskConditionalNode(taskConditional: taskConditional, task: task)
                    }
                }, label: {
                    HStack {
                        Text("Control Flow")
                            .bold()
                            .sectionHeaderStyle()
                    }
                })
            }
            .padding(EdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0))
            .padding()
    
            VStack {
                header
                Spacer()
                addTaskActionButton
            }
        }
        .halfSheet(showSheet: $showTaskActionsSheet) {
            TaskActionsSheet(task: task)
        }
    }
    
    var currentTaskActions: some View {
        LazyVStack(spacing: 15) {
            ForEach(task.taskActions.sorted(by: { $0.order < $1.order }), id: \.self) { taskAction in
                TaskActionNode(task: task, taskAction: taskAction)
                    .onDrag{
                        draggedTaskActionNode = taskAction
                        return NSItemProvider(item: nil, typeIdentifier: draggedTaskActionNode?.identifier)
                    } preview: {
                        TaskActionNode(task: task, taskAction: taskAction)
                            .frame(width: 500, height: 100)
                    }
                    .onDrop(of: [UTType.text], delegate: TaskActionDelegate(taskAction: taskAction, taskActions: $task.taskActions, draggedTaskActionNode: $draggedTaskActionNode))
            }
        }
    }
    
    var header: some View {
        VStack {
            HStack {
                Spacer()
                Text(task.title)
                    .font(.title2)
                    .bold()
                Spacer()
                CloseViewButton(showView: $isShowingAutomationView)
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            Divider()
        }
        .background(.thickMaterial)

    }
    
    var addTaskActionButton: some View {
        Button(action: {
            showTaskActionsSheet.toggle()
        }) {
            Text("Add Task Action")
                .bold()
                .foregroundColor(.white)
        }
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .background(Color.green)
        .cornerRadius(10)
        .padding()
    }
}

struct TaskAutomationView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Wash the Dishes"
        task.timestamp = Date()
        
        return TaskAutomationView(task: task, isShowingAutomationView: .constant(true))
    }
}

struct TaskActionDelegate: DropDelegate {
    let taskAction: TaskAction
    
    @Binding var taskActions: [TaskAction]
    @Binding var draggedTaskActionNode: TaskAction?
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    
    
    func dropEntered(info: DropInfo) {
        guard let draggedTaskActionNode = self.draggedTaskActionNode else {
            return
        }
        
        if draggedTaskActionNode != taskAction {
            let from = taskActions.firstIndex(of: draggedTaskActionNode)!
            let to = taskActions.firstIndex(of: taskAction)!
            
//            //update taskactions persistent order in CoreData
//
//            for index in Int(from + 1)...Int(to) {
//                taskActions[index].order = index - 1
//            }
            
            withAnimation {
                taskActions.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
            
            for (idx, taskAction) in taskActions.enumerated() {
                taskAction.order = Int32(idx)
            }
            try? PersistenceController.shared.container.viewContext.save()
        }
    }
}
