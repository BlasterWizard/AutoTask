//
//  TaskSubEntry.swift
//  AutoTask
//
//  Created by Justin Wong on 5/26/22.
//

import SwiftUI
import CoreData

struct TaskSubEntryView: View {
    @Environment(\.managedObjectContext) private var context
    
    @State private var textContent = ""
    @ObservedObject var taskSubEntry: TaskSubEntry
    
    init(taskSubEntry: TaskSubEntry) {
        _taskSubEntry = ObservedObject(wrappedValue: taskSubEntry)
        _textContent = State(wrappedValue: taskSubEntry.text ?? "")
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
            Spacer()
            if taskSubEntry.typeStatus == .BulletList {
                VStack {
                    ForEach(taskSubEntry.bulletListEntries.sorted(by: { $0.order < $1.order }), id: \.self) { bulletListEntry in
                        BulletListEntryView(taskSubEntry: taskSubEntry, bulletListEntry: bulletListEntry, order: Int(bulletListEntry.order))
                    }
                }
               
            } else {
                ZStack {
                    TextEditor(text: $textContent)
                        .onChange(of: textContent) {newValue in
                            //save to coreData
                            taskSubEntry.text = newValue
                            try? context.save()
                        }
                        .background(.ultraThinMaterial)
                    Text(textContent).opacity(0).padding(.all, 8)
                }
                
            }
            editButton
        }
        .padding(5)
        .background(.ultraThinMaterial)
        .cornerRadius(5)
        .onDrag {
            NSItemProvider(object: taskSubEntry as! NSItemProviderWriting)
        }
    }
    
    var editButton: some View {
        Menu {
            changeToBulletListButton
            changeToTextEditorButton
            deleteTaskSubEntryButton
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.secondary)
        }
    }
    
    var changeToBulletListButton: some View {
        Group {
            if taskSubEntry.typeStatus != .BulletList {
                Button(action: {
                    withAnimation {
                        taskSubEntry.typeStatus = .BulletList
                        let newBulletListEntry = BulletListEntry(context: context)
                        taskSubEntry.addToBulletListEntries_(newBulletListEntry)
                        try? context.save()
                    }
                }) {
                    HStack {
                        Text("Bullet List")
                        Image(systemName: "list.bullet")

                    }
                }
            }
        }
    }
    
    var changeToTextEditorButton: some View {
        Group {
            if taskSubEntry.typeStatus != .Text {
                Button(action: {
                    taskSubEntry.typeStatus = .Text
                    try? context.save()
                }) {
                    HStack {
                        Text("Text")
                        Image(systemName: "t.square")
                    }
                }
            }
        }
    }
    
    var deleteTaskSubEntryButton: some View {
        Button(role: .destructive, action: {
            taskSubEntry.task?.removeFromSubEntries_(taskSubEntry)
            try? context.save()
        }) {
            HStack {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}

struct TaskSubEntry_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
            
        let newTaskSubEntry = TaskSubEntry(context: context)
        newTaskSubEntry.order = 0
        newTaskSubEntry.typeStatus = .Text
        newTaskSubEntry.text = "Hello!"
        
        let newBulletListTaskSubEntry = TaskSubEntry(context: context)
        newTaskSubEntry.typeStatus = .BulletList
        let newBulletListEntry = BulletListEntry(context: context)
        newTaskSubEntry.addToBulletListEntries_(newBulletListEntry)
        
        return Group {
            TaskSubEntryView(taskSubEntry: newTaskSubEntry)
            TaskSubEntryView(taskSubEntry: newBulletListTaskSubEntry)
        }
            .environment(\.managedObjectContext, context)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
