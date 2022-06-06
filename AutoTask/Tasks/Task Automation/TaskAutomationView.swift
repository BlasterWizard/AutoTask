//
//  TaskAutomationView.swift
//  AutoTask
//
//  Created by Justin Wong on 6/4/22.
//

import SwiftUI

struct TaskAutomationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var task: Task
    @Binding var isShowingAutomationView: Bool

    
    @State private var showTaskActionsSheet = false
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: true) {
                ForEach(task.taskActions.sorted(by: { $0.order < $1.order } ), id: \.self) { taskAction in
                    TaskActionNode(task: task, taskAction: taskAction)
                }
                ForEach(task.taskConditionals.sorted(by: { $0.order < $1.order }), id: \.self) { taskConditional in
                  TaskConditionalNode(taskConditional: taskConditional, task: task)
                }
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
    
    var header: some View {
        VStack {
            HStack {
                Spacer()
                Text(task.title)
                    .font(.title2)
                    .bold()
                Spacer()
//                Button(action: {
//                    withAnimation(.easeOut(duration: 1.0)) {
//                        isShowingAutomationView.toggle()
//                    }
//                }) {
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(.secondary)
//                        .font(.system(size: 25))
//                }
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
        task.content = "First clean up the table"
        task.timestamp = Date()
        
        return TaskAutomationView(task: task, isShowingAutomationView: .constant(true))
    }
}
