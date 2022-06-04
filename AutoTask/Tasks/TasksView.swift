//
//  TasksView.swift
//  AutoTask
//
//  Created by Justin Wong on 5/25/22.
//

import SwiftUI
import CoreData

struct TasksView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.timestamp, ascending: true)],
        animation: .default)
    
    private var tasks: FetchedResults<Task>
    
    @State private var tempNewTask = false
    @State private var showCompletedStatus: CompletedTaskStatus = .Available
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                taskStatusPicker
                
                VStack {
                    if tasks.count > 0 || tempNewTask{
                        List {
                            if tempNewTask {
                                NewEntryPlaceholderView(showTempNewEntry: $tempNewTask, placeholderText: "New Task Name") { newEntryName in
                                    let newTask = Task(context: viewContext)
                                    newTask.timestamp = Date()
                                    newTask.title = newEntryName
                                    try? viewContext.save()
                                    tempNewTask = false 
                                }
                                    .listRowSeparator(.hidden)
                                    .buttonStyle(PlainButtonStyle())
                            }

                            ForEach(Task.filterTasks(for: searchResults, with: showCompletedStatus), id: \.self) { task in
                                TaskEntryView(task: task)
                                    .listRowSeparator(.hidden)
                                    .buttonStyle(PlainButtonStyle())
                            }
                            .onDelete(perform: deleteTasks)
//                            .onMove(perform: move)
                            
                        }
                        .searchable(text: $searchText)
                    } else {
                        Spacer()
                        Text("No Tasks Available")
                        Spacer()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if tasks.count > 0 {
                            EditButton()
                        }
                    }
                    ToolbarItem {
                        if showCompletedStatus == .Available {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    tempNewTask = true
                                }}) {
                                Label("Add Task", systemImage: "plus")
                            }
                                .disabled(tempNewTask)
                        }
                    }
                }
                .navigationTitle("Tasks")
                .listStyle(PlainListStyle())
            }
        }
    }
    
    var taskStatusPicker: some View {
        Picker("Completed Status", selection: $showCompletedStatus) {
            Text("Available:" +   " \(Task.filterTasks(for: tasks.compactMap{$0 as Task}, with: .Available).count)").tag(CompletedTaskStatus.Available)
            Text("Logbook:" +   " \(Task.filterTasks(for: tasks.compactMap{$0 as Task}, with: .Completed).count)").tag(CompletedTaskStatus.Completed)
        }
        .pickerStyle(.segmented)
        .padding()
    }

    private func addTask() {
        withAnimation {
            let newTask = Task(context: viewContext)
            newTask.timestamp = Date()
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { tasks[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
//    private func move(from source: IndexSet, to destination: Int) {
//        Task.filterTasks(for: tasks, with: showCompletedStatus).move(fromOffsets: source, toOffset: destination)
//    }

    
    var searchResults: [Task] {
        let taskArray = tasks.compactMap { $0 as Task}
     
        if searchText.isEmpty {
            return taskArray
        }
        
        let directWordsSearchArray = taskArray.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        let tagsNameSearchArray = taskArray.filter {
            isTagNameInTask(for: searchText.lowercased(), in: $0)
        }
        
        return directWordsSearchArray + tagsNameSearchArray
    }
    
    private func isTagNameInTask(for searchText: String, in task: Task) -> Bool {
        for tag in task.tags {
            if tag.name.lowercased().contains(searchText) {
                return true
            }
        }
        return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(SettingsViewModel())
    }
}

