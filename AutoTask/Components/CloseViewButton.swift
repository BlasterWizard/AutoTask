//
//  CloseViewButton.swift
//  AutoTask
//
//  Created by Justin Wong on 6/4/22.
//

import SwiftUI

struct CloseViewButton: View {
    @Binding var showView: Bool
    
    var body: some View {
        Button(action: { showView.toggle() }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
                .font(.system(size: 25))
        }
    }
}

struct CloseViewButton_Previews: PreviewProvider {
    static var previews: some View {
        CloseViewButton(showView: .constant(true))
    }
}
