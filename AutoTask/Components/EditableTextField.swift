//
//  TaskTitleTextField.swift
//  AutoTask
//
//  Created by Justin Wong on 5/31/22.
//

import UIKit
import SwiftUI

struct EditableTextField: UIViewRepresentable {
    var text: String
    var isEditable: Bool
    var task: Task
    var tag: Tag?
    
    init(text: Binding<String>, isEditable: Binding<Bool>, task: Task) {
        self.text = text.wrappedValue
        self.isEditable = isEditable.wrappedValue
        self.task = task
    }
    
    init(text: Binding<String>, isEditable: EditMode, task: Task) {
        self.text = text.wrappedValue
        self.isEditable = isEditable == .active ? true : false
        self.task = task
    }
    
    init(text: Binding<String>, isEditable: EditMode, task: Task, tag: Tag) {
        self.text = text.wrappedValue
        self.isEditable = isEditable == .active ? true : false
        self.tag = tag
        self.task = task 
    }
    
    func makeUIView(context: Context) -> UIKitTaskEntryTitleTextField {
        if tag == nil {
            let textField = UIKitTaskEntryTitleTextField(for: task)
            return textField
        }
        
        return UIKitTaskEntryTitleTextField(task: task, tag: tag ?? Tag.placeholder)
    }
    
    func updateUIView(_ uiView: UIKitTaskEntryTitleTextField, context: Context) {
        uiView.text = text
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        if isEditable {
            uiView.isUserInteractionEnabled = true
        } else {
            uiView.isUserInteractionEnabled = false
        }
    }
    
    class UIKitTaskEntryTitleTextField: UITextField, UITextFieldDelegate {
        var task: Task
        var tagNode: Tag?
        
        init(for task: Task) {
            self.task = task
            super.init(frame: .zero)
            self.delegate = self
        }
        
        init(task: Task, tag: Tag) {
            self.task = task
            self.tagNode = tag
            super.init(frame: .zero)
            self.delegate = self
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            if tagNode == nil {
                task.title = textField.text ?? ""
            }
            
            if let tagNode = tagNode, let indexOfTagInTask = task.tags.firstIndex(of: tagNode) {
                task.tags[indexOfTagInTask].name = textField.text ?? ""
            }

            try? PersistenceController.shared.container.viewContext.save()
        }
    }
}
