//
//  Extensions.swift
//  AutoTask
//
//  Created by Justin Wong on 5/31/22.
//

import SwiftUI

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension View {
    //Half Sheet Modifier
    func halfSheet<SheetView: View>(showSheet: Binding<Bool>, @ViewBuilder sheetView: @escaping () -> SheetView) -> some View {
        return self
            .background(
                HalfSheetHelper(sheetView: sheetView(), showSheet: showSheet)
            )
    }
}

extension Color {
    init(r: Double, g: Double, b: Double) {
        self.init(red: r / 255, green: g / 255, blue: b / 255)
    }
}
