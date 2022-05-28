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
    }

    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
            Spacer()
            if taskSubEntry.typeStatus == .BulletList {
                VStack {
                    BulletListEntry()
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                }
               
            } else {
                TextField("Notes", text: $textContent)
                    .onChange(of: textContent) {newValue in
                        //save to coreData
                        taskSubEntry.text = newValue
                        try? context.save()
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
            if taskSubEntry.typeStatus != .BulletList {
                Button(action: {
                    withAnimation {
                        taskSubEntry.typeStatus = .BulletList
                        try? context.save()
                    }
                }) {
                    HStack {
                        Text("Bullet List")
                        Image(systemName: "list.bullet")

                    }
                }
                Button(action: {
                    taskSubEntry.task?.removeFromSubEntries_(taskSubEntry)
                    try? context.save()
                }) {
                    HStack {
                        Text("Delete")
                        Image(systemName: "trash")
                    }
                }
            }
            
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
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.secondary)
        }
    }
}

struct BulletListEntry: View {
    @State private var text = ""
    
    var body: some View {
        HStack {
            Circle()
                .strokeBorder(Color.black, lineWidth: 2)
                .frame(width: 20, height: 20)
            TextField("", text: $text)
                .onSubmit {
                    //create new sub bullet entry
                }
            Spacer()
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
        
        return TaskSubEntryView(taskSubEntry: newTaskSubEntry)
            .environment(\.managedObjectContext, context)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
