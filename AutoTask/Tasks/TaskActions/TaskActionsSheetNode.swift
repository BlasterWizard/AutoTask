//
//  TaskActionsSheetNode.swift
//  AutoTask
//
//  Created by Justin Wong on 5/27/22.
//

import SwiftUI

struct TaskActionsSheetNode: View {
    @Environment(\.presentationMode) private var presentationMode
    
    var name: String
    var systemName: String
    var description: String?
    var tintColor: Color
    var type: TaskType
    
    var select: () -> Void
    
    var body: some View {
        Button(action: {
            self.select()
            presentationMode.wrappedValue.dismiss()
        }) {
            if type == .Reminder || type == .Deadline {
                actionType
            } else {
                controlFlowType
            }
        }
    }
    
    var actionType: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(name)
                    .bold()
                Spacer()
                Image(systemName: systemName)
            }
            .foregroundColor(tintColor)
            Text(description ?? "")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
    
    var controlFlowType: some View {
        HStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(.gray)
                .frame(width: 25, height: 25)
                .overlay(
                    Image(systemName: systemName)
                    .foregroundColor(.white)
                )
            Text(name)
                .bold()
                .foregroundColor(tintColor)
        }
    }
}

struct TaskActionsSheetNode_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Wash the Dishes"
        task.content = "First clean up the table"
        task.timestamp = Date()
        
        return TaskActionsSheetNode(name: "If Statement", systemName: "arrow.triangle.branch", description: nil, tintColor: .secondary, type: .If, select: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
