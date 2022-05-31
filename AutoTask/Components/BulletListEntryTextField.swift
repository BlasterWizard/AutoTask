//
//  CustomTextField.swift
//  AutoTask
//
//  Created by Justin Wong on 5/30/22.
//

import UIKit
import SwiftUI

struct BulletListEntryTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var taskSubEntry: TaskSubEntry
    var bulletListEntry: BulletListEntry
    
    func makeUIView(context: Context) -> CustomUIKitTextField {
        let textField = CustomUIKitTextField(taskSubEntry: taskSubEntry, bulletListEntry: bulletListEntry)
        textField.placeholder = placeholder
        return textField
    }
    
    func updateUIView(_ uiView: CustomUIKitTextField, context: Context) {
        uiView.text = text
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    class CustomUIKitTextField: UITextField, UITextFieldDelegate {
        var taskSubEntry: TaskSubEntry
        var bulletListEntry: BulletListEntry

        init (taskSubEntry: TaskSubEntry, bulletListEntry: BulletListEntry) {
            self.taskSubEntry = taskSubEntry
            self.bulletListEntry = bulletListEntry
            super.init(frame: .zero)
            self.delegate = self
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func deleteBackward() {
            if text == "" {
                taskSubEntry.removeFromBulletListEntries_(bulletListEntry)
                coreDataSave()
            }
            super.deleteBackward()
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            let newBulletListEntry = BulletListEntry(context: PersistenceController.shared.container.viewContext)
            newBulletListEntry.order = Int32(bulletListEntry.order + 1)
            //update other bulletlist entries' orders
            for entry in taskSubEntry.bulletListEntries.filter({ $0.order >= newBulletListEntry.order}) {
                entry.order += 1
            }
            
            taskSubEntry.addToBulletListEntries_(newBulletListEntry)
            coreDataSave()
            return true
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            bulletListEntry.text = textField.text
            coreDataSave()
        }
        
        private func coreDataSave() {
            try? PersistenceController.shared.container.viewContext.save()
        }
    }
}
