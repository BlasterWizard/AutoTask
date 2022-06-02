//
//  TagsView.swift
//  AutoTask
//
//  Created by Justin Wong on 6/1/22.
//

import SwiftUI
import CoreData

struct TagsView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var task: Task

    @FetchRequest(
       entity: Tag.entity(),
       sortDescriptors: [NSSortDescriptor(key: "name_", ascending: true)]
     )
    private var tags: FetchedResults<Tag>
    
    @State private var newTag = false
    @State private var newTagName = ""
    @State private var mode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                if tags.count > 0 {
                    List {
                        if newTag {
                            NewEntryPlaceholderView(showTempNewEntry: $newTag, placeholderText: "New Tag Name") { newEntryValue in
                                let newTagEntry = Tag(context: context)
                                newTagEntry.name = newEntryValue
                                try? context.save()
                            }
                        }
                        
                        ForEach(tags.sorted(by: { $0.name < $1.name }), id: \.self) { tag in
                            TagEntryView(tag: tag, task: task, editModeStatus: $mode)
                        }
                        .onDelete(perform: deleteTags)
                    }
                    .listStyle(.inset)
                } else {
                    Spacer()
                    Text("No Tags Available")
                    Spacer()
                }

                addTagButton
            }
            .padding()
            .navigationTitle("Tags (\(tags.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if task.tags.count > 0 {
                        EditButton()
                    }
         
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 20))
                    }
                }
            }
            .environment(\.editMode, $mode)
        }
    }
    
    var addTagButton: some View {
        HStack {
            Spacer()
            Button(action: {
                newTag = true
            }) {
                Text("Add Tag")
                    .bold()
            }
            .padding(10)
            .background(.thinMaterial)
            .cornerRadius(10)
            Spacer()
        }
    }
    
    private func deleteTags(offsets: IndexSet) {
        withAnimation {

            offsets.map { tags[$0] }.forEach(context.delete)

            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct TagEntryView: View {
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var tag: Tag
    @ObservedObject var task: Task
    @Binding var editModeStatus: EditMode

    
    init(tag: Tag, task: Task, editModeStatus: Binding<EditMode>) {
        print(tag.name)
        _tag = ObservedObject(wrappedValue: tag)
        _task = ObservedObject(wrappedValue: task)
        _editModeStatus = Binding(projectedValue: editModeStatus)
    }
    
    var body: some View {
        Button(action: {
            if task.tags.contains(tag) {
                //remove tag from tags
                task.removeFromTags_(tag)
            } else {
                //add tag to tags
                task.addToTags_(tag)
            }
            try? context.save()
        }) {
            HStack {
//                EditableTextField(text: $newTagEntryName, isEditable: editModeStatus, task: task)
                EditableTextField(text: $tag.name, isEditable: editModeStatus, task: task, tag: tag)
                Spacer()
                if task.tags.contains(tag) {
                    Image(systemName: "checkmark")
                }
            }
        }
       
    }
}

struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Wash the Dishes"
        task.content = "First clean up the table"
        task.timestamp = Date()
        
        return TagsView(task: task)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
