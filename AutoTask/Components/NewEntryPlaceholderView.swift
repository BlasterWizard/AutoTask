//
//  NewEntryPlaceholderView.swift
//  AutoTask
//
//  Created by Justin Wong on 6/1/22.
//

import SwiftUI

struct NewEntryPlaceholderView: View {
    @Environment(\.managedObjectContext) private var context
    @Binding var showTempNewEntry: Bool
    var placeholderText: String
    var submitFunction: (_ newEntryName: String) -> Void
    
    @State var newEntryNameState = ""
    var body: some View {
        HStack {
            TextField(placeholderText, text: $newEntryNameState)
                .onSubmit {
                    submitFunction(newEntryNameState)
                    newEntryNameState = ""
                }
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showTempNewEntry.toggle()
                    newEntryNameState = ""
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(10)
    }
}

//struct NewEntryPlaceholderView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewEntryPlaceholderView()
//    }
//}
