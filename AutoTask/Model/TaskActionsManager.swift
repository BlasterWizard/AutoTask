//
//  TaskActionsManager.swift
//  AutoTask
//
//  Created by Justin Wong on 6/4/22.
//

import Foundation

class TaskActionsManager {
    static let shared: TaskActionsManager = TaskActionsManager()
    
    func addReminder(for task: Task) {
        let newTaskReminder = TaskAction(context: task.managedObjectContext!)
        newTaskReminder.actionType = .Reminder
        newTaskReminder.order = Int32(task.taskActions.count) + 1
        newTaskReminder.isConfirmed = false
        newTaskReminder.identifier = UUID().uuidString
        //TODO: Integrate with App Settings to assign default notification body
        newTaskReminder.content = "Don't forget to complete this task!"
        newTaskReminder.nickName = "Reminder \(Int32(newTaskReminder.order))"
        task.addToTaskActions_(newTaskReminder)

        try? PersistenceController.shared.container.viewContext.save()
    }
    
    func addDeadline(for task: Task) {
        let newTaskDeadline = TaskAction(context: task.managedObjectContext!)
        newTaskDeadline.actionType = .Deadline
        newTaskDeadline.order = Int32(task.taskActions.count) + 1
        newTaskDeadline.isConfirmed = false
        newTaskDeadline.identifier = UUID().uuidString
        newTaskDeadline.content = "Deadline to complete this task has passed!"
        newTaskDeadline.nickName = "Deadline \(Int32(newTaskDeadline.order))"
        task.addToTaskActions_(newTaskDeadline)
        
        try? PersistenceController.shared.container.viewContext.save()
    }
    
    func addTask(withTitle title: String) {
        let newTask = Task(context: PersistenceController.shared.container.viewContext)
        newTask.isCompleted = false
        newTask.title = title 
        newTask.timestamp = Date()
        
        try? PersistenceController.shared.container.viewContext.save()
    }
    
    func scheduleTask(for task: Task) {
        let newScheduledTask = TaskAction(context: task.managedObjectContext!)
        newScheduledTask.actionType = .AddTask
        newScheduledTask.order = Int32(task.taskActions.count) + 1
        newScheduledTask.isConfirmed = false
        newScheduledTask.identifier = UUID().uuidString
        newScheduledTask.content = "Added New Task!"
        newScheduledTask.nickName = "Deadline \(Int32(newScheduledTask.order))"
        task.addToTaskActions_(newScheduledTask)
        
        try? PersistenceController.shared.container.viewContext.save()
    }
    
    func addIfConditional(for task: Task) {
        let newIfConditional = TaskConditional(context: task.managedObjectContext!)
        newIfConditional.conditionalType = .If
        newIfConditional.order = Int32(task.taskConditionals.count) + 1
        task.addToTaskConditionals_(newIfConditional)
        
        try? PersistenceController.shared.container.viewContext.save()
    }
}
