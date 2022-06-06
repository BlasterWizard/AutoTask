//
//  TaskActionConditionalUI.swift
//  AutoTask
//
//  Created by Justin Wong on 6/5/22.
//

import SwiftUI

//MARK: - TaskActionUI Struct

struct TaskActionConditionalUI {
    static func returnTaskActionUI(for taskType: TaskType) -> TaskActionConditionalUI.TaskActionConditionalUIData {
        switch (taskType) {
        case .Reminder:
            return reminder
        case .Deadline:
            return deadline
        case .If:
            return ifConditional
        default:
            break
        }
        return reminder
    }

    static var reminder = TaskActionConditionalUIData(taskName: "Reminder", systemImage: "bell", backgroundColor: Color(r: 255, g: 247, b: 161).opacity(0.7))
    
    static var deadline = TaskActionConditionalUIData(taskName: "Deadline", systemImage: "clock.badge.exclamationmark", backgroundColor: Color(r: 240, g: 173, b: 183).opacity(0.7))

    static var ifConditional = TaskActionConditionalUIData(taskName: "If", systemImage: "arrow.triangle.branch", backgroundColor: Color(r: 201, g: 198, b: 195))
    
    static var placeholder = TaskActionConditionalUIData(taskName: "", systemImage: "", backgroundColor: .white)
    
    struct TaskActionConditionalUIData {
        var taskName: String
        var systemImage: String
        var backgroundColor: Color
    }
}


