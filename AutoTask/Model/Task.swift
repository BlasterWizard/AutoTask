//
//  Task.swift
//  AutoTask
//
//  Created by Justin Wong on 5/25/22.
//

import Foundation
import CoreData
import SwiftUI

//MARK: - Task
extension Task {
    var content: String {
        get { content_ ?? "" }
        set { content_ = newValue }
    }
    
    var taskActions: [TaskAction] {
        get { Array(taskActions_ as? Set<TaskAction> ?? []) }
        set { taskActions_ = Set(newValue) as NSSet }
    }
    
    var subEntries: [TaskSubEntry] {
        get { Array(subEntries_ as? Set<TaskSubEntry> ?? []) }
        set { subEntries_ = Set(newValue) as NSSet }
    }
    
    static func filterTasks(for tasks: FetchedResults<Task>, with filterStatus: CompletedTaskStatus) -> [Task] {
        if filterStatus == .Completed {
            return tasks.filter { $0.isCompleted == true}
        }
        return tasks.filter { $0.isCompleted == false }
    }
}

//MARK: - Task Action
enum TaskType: Int, CaseIterable {
    case Reminder = 0
    case AddTask = 1
    case DeleteTask = 2
    case Deadline = 3
    case If = 4
    case And = 5
}

extension TaskAction {
    var actionType: TaskType {
        get {
            TaskType(rawValue: Int(taskType)) ?? .Reminder
        }
        set {
            taskType = Int32(newValue.rawValue)
        }
    }
}

enum CompletedTaskStatus: String, CaseIterable, Identifiable {
    case Available = "Available"
    case Completed = "Completed"
    
    var id: Self { self }
}

//MARK: - TaskSubEntry
enum SubTaskType: Int {
    case Text = 0
    case BulletList = 1
}

extension TaskSubEntry {
    var typeStatus: SubTaskType {
        get {
            SubTaskType(rawValue: Int(type)) ?? .Text
        }
        set {
            type = Int32(newValue.rawValue)
        }
    }
    
    var bulletListEntries: [BulletListEntry] {
        get { Array(bulletListEntries_ as? Set<BulletListEntry> ?? []) }
        set { bulletListEntries_ = Set(newValue) as NSSet }
    }
}

