//
//  SettingsViewModel.swift
//  AutoTask
//
//  Created by Justin Wong on 5/28/22.
//

import SwiftUI

struct Preferences {
    var showTaskActionDisplayIcons: Bool = true
    
    init() {
        showTaskActionDisplayIcons = UserDefaults.standard.bool(forKey: UserDefaultsKeys.showTaskActionsIcons)
        print(showTaskActionDisplayIcons)
    }
    
    struct UserDefaultsKeys {
        static var showTaskActionsIcons = "ShowTaskActionsIcons"
    }
}

class SettingsViewModel: ObservableObject {
    typealias UserDefaultKeys = Preferences.UserDefaultsKeys
    
    @Published var settings = Preferences()
    
    func updateShowTaskActionDisplayIcons(to newValue: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(newValue, forKey: UserDefaultKeys.showTaskActionsIcons)
        settings.showTaskActionDisplayIcons = newValue
    }
}
