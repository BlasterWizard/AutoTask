//
//  TaskEntryView.swift
//  AutoTask
//
//  Created by Justin Wong on 5/25/22.
//

import SwiftUI
import CoreData


struct TaskEntryView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.managedObjectContext) var context
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var task: Task
    @State private var isTaskExpanded = false
    @State private var showTaskActionsCM = false
    
    var body: some View {
        VStack {
            collapsedTaskView
            
            if isTaskExpanded {
                ForEach(task.subEntries.sorted(by: { $0.order < $1.order }), id: \.self) { taskSubEntry in
                    TaskSubEntryView(taskSubEntry: taskSubEntry)
                }
                expandedTaskView
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(10)
        .deleteDisabled(isTaskExpanded)
    }

    var collapsedTaskView: some View {
        HStack {
            checkbox
            HStack {
                Text(task.title ?? "")
                Spacer()
                if settingsVM.settings.showTaskActionDisplayIcons {
                    TaskActionDisplayIcons(task: task)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isTaskExpanded.toggle()
                }
            }

            if isTaskExpanded {
                Spacer()
                addSubEntryButton
            }
        }
    }
    
    var checkbox: some View {
        Button(action: {
            print(task.isCompleted)
            task.isCompleted.toggle()
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }

        }) {
            if !task.isCompleted {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(colorScheme == .dark ? .white : .black, lineWidth: 1)
                    .frame(width: 25, height: 25)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(colorScheme == .dark ? .white : .black, lineWidth: 1)
                    .frame(width: 25, height: 25)
                    .overlay(Image(systemName: "checkmark"))
            }
        }
    }
    
    var addSubEntryButton: some View {
        Button(action: {
            let newTaskSubEntry = TaskSubEntry(context: context)
            newTaskSubEntry.typeStatus = .Text
            newTaskSubEntry.order = Int32(task.subEntries.count)
            task.addToSubEntries_(newTaskSubEntry)
            
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }

        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    var expandedTaskView: some View {
        VStack {
            ForEach(task.taskActions.sorted(by: { $0.order < $1.order } ), id: \.self) { taskAction in
                TaskActionNode(task: task, taskAction: taskAction)
            }
            addTaskActionsButton
        }
    }
    
    var addTaskActionsButton: some View {
        HStack {
            Spacer()
            Button(action: {
                showTaskActionsCM.toggle()
            }) {
               Text("Add Task Action")
                    .foregroundColor(.white)
                    .bold()
            }
            .padding(5)
            .background(.green)
            .cornerRadius(5.0)
            .sheet(isPresented: $showTaskActionsCM) {
                TaskActionsSheet(task: task)
            }
            Spacer()
        }
        .padding(2)
    }
}

struct TaskView_Previews: PreviewProvider {

    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Wash the Dishes"
        task.content = "First clean up the table"
        task.timestamp = Date()
        
        let taskAction = TaskAction(context: context)
        taskAction.actionType = .Reminder
        
        return Group {
            TaskEntryView(task: task)
                .environment(\.managedObjectContext, context)
                .padding()
                .previewLayout(.sizeThatFits)
                .environmentObject(SettingsViewModel())
            TaskActionNode(task: task, taskAction: taskAction)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
