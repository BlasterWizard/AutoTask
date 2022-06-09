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
    var actionType: TaskType?
    var conditionalType: TaskConditionals?
    
    var select: () -> Void
    
    var body: some View {
        Button(action: {
            self.select()
            presentationMode.wrappedValue.dismiss()
        }) {
            if actionType != nil {
                actionTypeNode
            } else {
                controlFlowTypeNode
            }
        }
    }
    
    var actionTypeNode: some View {
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
    
    var controlFlowTypeNode: some View {
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
        task.timestamp = Date()
        
        return TaskActionsSheetNode(name: "If Statement", systemName: "arrow.triangle.branch", description: nil, tintColor: .secondary, conditionalType: .If, select: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
