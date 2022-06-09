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
    var title: String {
        get { title_ ?? ""}
        set { title_ = newValue }
    }
    
    var taskActions: [TaskAction] {
        get { Array(taskActions_ as? Set<TaskAction> ?? []) }
        set { taskActions_ = Set(newValue) as NSSet }
    }
    
    var subEntries: [TaskSubEntry] {
        get { Array(subEntries_ as? Set<TaskSubEntry> ?? []) }
        set { subEntries_ = Set(newValue) as NSSet }
    }
    
    var tags: [Tag] {
        get { Array(tags_ as? Set<Tag> ?? []) }
        set { tags_ = Set(newValue) as NSSet }
    }
    
    var taskConditionals: [TaskConditional] {
        get { Array(taskConditionals_ as? Set<TaskConditional> ?? []) }
        set { taskConditionals_ = Set(newValue) as NSSet }
    }
    
    static func filterTasks(for tasks: [Task], with filterStatus: CompletedTaskStatus) -> [Task] {
        if filterStatus == .Completed {
            return tasks.filter { $0.isCompleted == true}
        }
        return tasks.filter { $0.isCompleted == false }
    }
    
    func getTaskAction(for identifier: String) -> TaskAction? {
        let availableTaskActions = taskActions.filter { $0.identifier == identifier }
        if availableTaskActions.isEmpty {
            return nil
        }
        return availableTaskActions.first!
    }
}

//MARK: - Task Action
enum TaskType: Int, CaseIterable {
    case Reminder = 0
    case AddTask = 1
    case DeleteTask = 2
    case Deadline = 3
    case None = 5
    
    func returnStringName() -> String {
        switch self {
        case .Reminder:
            return "Reminder"
        case .AddTask:
            return "Add Task"
        case .DeleteTask:
            return "Delete Task"
        case .Deadline:
            return "Deadline"
        default:
            return ""
        }
    }
}

extension TaskAction {
    var identifier: String {
        get { identifier_ ?? ""}
        set { identifier_ = newValue }
    }
    
    var nickName: String {
        get { nickName_ ?? "" }
        set { nickName_ = newValue }
    }
    
    var actionType: TaskType {
        get {
            TaskType(rawValue: Int(taskType)) ?? .None
        }
        set {
            taskType = Int32(newValue.rawValue)
        }
    }
    
    var dateAndTime: Date {
        get { dateAndTime_ ?? Date() }
        set { dateAndTime_ = newValue }
    }
    
    var content: String {
        get { content_ ?? "" }
        set { content_ = newValue }
    }
}

enum CompletedTaskStatus: String, CaseIterable, Identifiable {
    case Available = "Available"
    case Completed = "Completed"
    
    var id: Self { self }
}

//MARK: - TaskSubEntry
enum SubTaskType: Int, CaseIterable {
    case Text = 0
    case BulletList = 1
    
    func returnStringVersion() -> String {
        switch self.rawValue {
        case 0: return "Text"
        case 1: return "Bullet List"
        default: return ""
        }
    }
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

//MARK: - Tag

extension Tag {
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
    
    static var placeholder: Tag {
        Tag()
    }
}

enum TaskConditionals: Int {
    case If = 0
    case Repeat = 1
    case None = 2
}

enum TAConditions: Int {
    case hasTriggered = 0
    case notTriggered = 1
    case hasMet = 2
    case notMet = 3
    case none = 4
    
    func returnConditions(for actionType: TaskType) -> [TAConditions] {
        switch actionType {
        case .Reminder:
            return [.hasTriggered, .notTriggered]
        case .AddTask:
            return []
        case .DeleteTask:
            return []
        case .Deadline:
            return [.hasMet, .notMet]
        case .None:
            return [.none]
        }
    }
    
    func returnStringName() -> String {
        switch self {
        case .hasTriggered:
            return "Has Triggered"
        case .notTriggered:
            return "Not Triggered"
        case .hasMet:
            return "Has Met"
        case .notMet:
            return "Not Met"
        case .none:
            return "None"
        }
    }
}

extension TaskConditional {
    var conditionalType: TaskConditionals {
        get { TaskConditionals(rawValue: Int(conditionalType_)) ?? .None}
        set { conditionalType_ = Int32(newValue.rawValue) }
    }
    
    var identifier: String {
        get { identifier_ ?? "" }
        set { identifier_ = newValue }
    }
    
    var status: TAConditions {
        get { TAConditions(rawValue: Int(status_)) ?? .none}
        set { status_ = Int32(newValue.rawValue) }
    }
}

