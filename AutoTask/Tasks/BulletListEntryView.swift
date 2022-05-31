//
//  BulletListEntryView.swift
//  AutoTask
//
//  Created by Justin Wong on 5/30/22.
//

import SwiftUI

struct BulletListEntryView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var taskSubEntry: TaskSubEntry
    var bulletListEntry: BulletListEntry
    var order: Int //Order starts increasing from 0 
    
    @State private var text = ""
    @State private var isCompleted = false
    
    init (taskSubEntry: TaskSubEntry, bulletListEntry: BulletListEntry, order: Int) {
        _taskSubEntry = ObservedObject(wrappedValue: taskSubEntry)
        self.bulletListEntry = bulletListEntry
        self.order = order
        //"load data" from Core Data
        _isCompleted = State(wrappedValue: bulletListEntry.isCompleted)
        _text = State(wrappedValue: bulletListEntry.text ?? "")
    }
    
    var body: some View {
        HStack {
            Text("\(bulletListEntry.order)")
            Button(action: {
                isCompleted.toggle()
                bulletListEntry.isCompleted = isCompleted
                try? context.save()
            }) {
                isCompletedIndicator
            }
            BulletListEntryTextField(text: $text, placeholder: "", taskSubEntry: taskSubEntry, bulletListEntry: bulletListEntry)
            Spacer()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(5)
    }
    
    var isCompletedIndicator: some View {
        Group {
            if isCompleted {
                Circle()
                    .fill(.blue)
                    .frame(width: BLEVConstants.circleWidthAndHeight, height: BLEVConstants.circleWidthAndHeight)
            } else {
                Circle()
                    .strokeBorder(.black, lineWidth: BLEVConstants.circleLineWidth)
                    .frame(width: BLEVConstants.circleWidthAndHeight, height: BLEVConstants.circleWidthAndHeight)
            }
        }
        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
    }
}
struct BLEVConstants {
    static var completedFillColor: Color = Color(red: 166 / 255, green: 221 / 255, blue: 245 / 255).opacity(0.7)
    static var circleWidthAndHeight: CGFloat = 10
    static var circleLineWidth: CGFloat = 1
}

struct BulletListEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        let newTaskSubEntry = TaskSubEntry(context: context)
        newTaskSubEntry.order = 0
        newTaskSubEntry.typeStatus = .Text
        newTaskSubEntry.text = "Hello!"
        newTaskSubEntry.typeStatus = .BulletList
        let newBulletListEntry = BulletListEntry(context: context)
        newTaskSubEntry.addToBulletListEntries_(newBulletListEntry)
        
        return BulletListEntryView(taskSubEntry: newTaskSubEntry, bulletListEntry: newBulletListEntry, order: 1)
            .environment(\.managedObjectContext, context)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
