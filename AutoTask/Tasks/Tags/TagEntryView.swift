//
//  TagEntryView.swift
//  AutoTask
//
//  Created by Justin Wong on 6/2/22.
//

import SwiftUI

struct TagEntryView: View {
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var tag: Tag
    @ObservedObject var task: Task
    @Binding var editModeStatus: EditMode
    
    @State var showColorPicker = false
    
    init(tag: Tag, task: Task, editModeStatus: Binding<EditMode>) {
        _tag = ObservedObject(wrappedValue: tag)
        _task = ObservedObject(wrappedValue: task)
        _editModeStatus = Binding(projectedValue: editModeStatus)
    }
    
    var body: some View {
        HStack {
            EditableTextField(text: $tag.name, isEditable: editModeStatus, task: task, tag: tag)
            
            if editModeStatus == .inactive {
                Button(action: {
                    print(task.title)
                    if task.tags.contains(tag) {
                        //remove tag from tags
                        print("remove tag")
                        task.removeFromTags_(tag)
                    } else {
                        //add tag to tags
                        print("add tag")
                        task.addToTags_(tag)
                    }
                    try? context.save()
                    print(task.tags.count)
                }) {
                    if task.tags.contains(tag) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct TagEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Wash the Dishes"

        task.timestamp = Date()
        
        let tag = Tag(context: context)
        tag.name = "School"
        
        return TagEntryView(tag: tag, task: task, editModeStatus: .constant(.active))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
