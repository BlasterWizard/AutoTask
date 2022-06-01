//
//  TaskTitleTextField.swift
//  AutoTask
//
//  Created by Justin Wong on 5/31/22.
//

import UIKit
import SwiftUI

struct TaskEntryTitleTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isEditable: Bool
    var task: Task
    
    func makeUIView(context: Context) -> UIKitTaskEntryTitleTextField {
        let textField = UIKitTaskEntryTitleTextField(for: task)
        return textField
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
        
        init(for task: Task) {
            self.task = task
            super.init(frame: .zero)
            self.delegate = self
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            task.title = textField.text ?? ""
            try? PersistenceController.shared.container.viewContext.save()
        }
    }
}
