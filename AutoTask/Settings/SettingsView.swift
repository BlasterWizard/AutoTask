//
//  SettingsView.swift
//  AutoTask
//
//  Created by Justin Wong on 5/27/22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: Text("Tasks")) {
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.green)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Image(systemName: "checklist")
                                .foregroundColor(.white)
                            )
                        Text("Tasks")
                    }
                }
            }
            .navigationTitle("Settings")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
