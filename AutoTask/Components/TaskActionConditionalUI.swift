//
//  TaskActionConditionalUI.swift
//  AutoTask
//
//  Created by Justin Wong on 6/5/22.
//

import SwiftUI

//MARK: - TaskActionUI Struct

struct TaskActionConditionalUI {
    static func returnTaskActionUI(for actionTaskType: TaskType) -> TaskActionConditionalUI.TaskActionConditionalUIData {
        switch actionTaskType {
        case .Reminder:
            return reminder
        case .Deadline:
            return deadline
        default:
            break
        }
        return reminder
    }
    
    static func returnTaskActionUI(for conditionalTaskType: TaskConditionals) -> TaskActionConditionalUI.TaskActionConditionalUIData {
        switch conditionalTaskType {
        case .If:
            return ifConditional
        default:
            break
        }
        return ifConditional 
    }

    static var reminder = TaskActionConditionalUIData(taskName: "Reminder", systemImage: "bell", backgroundColor: Color(r: 255, g: 247, b: 161).opacity(0.6))
    
    static var deadline = TaskActionConditionalUIData(taskName: "Deadline", systemImage: "clock.badge.exclamationmark", backgroundColor: Color(r: 240, g: 173, b: 183))

    static var ifConditional = TaskActionConditionalUIData(taskName: "If", systemImage: "arrow.triangle.branch", backgroundColor: Color(r: 201, g: 198, b: 195))
    
    static var placeholder = TaskActionConditionalUIData(taskName: "", systemImage: "", backgroundColor: .white)
    
    struct TaskActionConditionalUIData {
        var taskName: String
        var systemImage: String
        var backgroundColor: Color
    }
}

struct RoundedRectIcon: View {
    var backgroundColor: Color
    var systemImage: String
    var imageColor: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(backgroundColor)
            .frame(width: 30, height: 30)
            .overlay(
                Image(systemName: systemImage)
                .foregroundColor(imageColor)
            )
    }
}


