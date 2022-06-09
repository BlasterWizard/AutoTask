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

extension Color {
    init(r: Double, g: Double, b: Double) {
        self.init(red: r / 255, green: g / 255, blue: b / 255)
    }
}

//MARK: - Custom View Modifiers
struct SectionHeader: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
                .foregroundColor(.primary)
                .font(.title2)
            Spacer()
        }
    }
}

struct ConditionalNodeStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(r: 201, g: 198, b: 195))
            .cornerRadius(10)
            .foregroundColor(.white)
            .font(.headline)
    }
}

struct BadgeStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5))
            .background(.thinMaterial)
            .cornerRadius(10)
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
    
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeader())
    }
    
    func conditionalNodeStyle() -> some View {
        modifier(ConditionalNodeStyle())
    }
    
    func badgeStyle() -> some View {
        modifier(BadgeStyle())
    }
}

