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
    @Binding var isShowingAutomationView: Bool
    @Binding var taskToAutomate: Task?
    
    @State private var isTaskExpanded = false
    @State private var showTaskActionsCM = false
    @State private var showTagsView = false
    
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
        .sheet(isPresented: $showTagsView) {
            TagsView(task: task)
        }
    }

    var collapsedTaskView: some View {
        HStack {
            checkbox
            HStack {
                EditableTextField(text: $task.title, isEditable: $isTaskExpanded, task: task)
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
           createNewTaskSubEntry()
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
            taskTagsView
            HStack {
                Spacer()
                //show Tags View Button
                Button(action: {
                    //Add tag to task - > bring up sheet
                    showTagsView.toggle()
                }) {
                   Image(systemName: "tag")
                }
                
                //show Automation View
                Button(action: {
                    isShowingAutomationView.toggle()
                    taskToAutomate = task
                }) {
                    Image(systemName: "curlybraces")
                }
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    var taskTagsView: some View {
        HStack {
            ForEach(task.tags.sorted(by: { $0.name < $1.name}), id: \.self) { tag in
                TagNode(tag: tag)
            }
            Spacer()
        }
    }
    
    private func createNewTaskSubEntry() {
        let newTaskSubEntry = TaskSubEntry(context: context)
        if settingsVM.settings.defaultTaskSubEntryType == .Text {
            newTaskSubEntry.typeStatus =  .Text
        } else {
            newTaskSubEntry.typeStatus =  .BulletList
            let newBulletListEntry = BulletListEntry(context: context)
            newTaskSubEntry.addToBulletListEntries_(newBulletListEntry)
        }
       
        newTaskSubEntry.order = Int32(task.subEntries.count)
        task.addToSubEntries_(newTaskSubEntry)
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

//MARK: - TagNode
struct TagNode: View {
    @ObservedObject var tag: Tag
    
    var body: some View {
        Text(tag.name)
            .padding(EdgeInsets(top: TagNodeUIConstants.topBottomPadding, leading: TagNodeUIConstants.leftRightPadding, bottom: TagNodeUIConstants.topBottomPadding, trailing: TagNodeUIConstants.leftRightPadding))
            .background(Color.blue)
            .cornerRadius(TagNodeUIConstants.cornerRadius)
            .foregroundColor(Color.white)
    }
    
    struct TagNodeUIConstants {
        static var topBottomPadding: CGFloat = 5
        static var leftRightPadding: CGFloat = 10
        static var cornerRadius: CGFloat = 20
    }
}

struct TaskView_Previews: PreviewProvider {

    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Wash the Dishes"
        task.timestamp = Date()
        
        let taskAction = TaskAction(context: context)
        taskAction.actionType = .Reminder
        
        let tag = Tag(context: context)
        tag.name = "School"
        
        return Group {
//            TaskEntryView(task: task, isShowingAutomationView: .constant(false))
//                .environment(\.managedObjectContext, context)
//                .padding()
//                .previewLayout(.sizeThatFits)
//                .environmentObject(SettingsViewModel())
            TaskActionNode(task: task, taskAction: taskAction)
                .padding()
                .previewLayout(.sizeThatFits)
            TagNode(tag: tag)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
