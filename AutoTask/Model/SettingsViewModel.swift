//
//  SettingsViewModel.swift
//  AutoTask
//
//  Created by Justin Wong on 5/28/22.
//

import SwiftUI

struct Preferences {
    var showTaskActionDisplayIcons: Bool = true
    var defaultTaskSubEntryType: SubTaskType = SubTaskType.Text
    
    init() {
        showTaskActionDisplayIcons = UserDefaults.standard.bool(forKey: UserDefaultsKeys.showTaskActionsIcons)
        defaultTaskSubEntryType = SubTaskType(rawValue: UserDefaults.standard.integer(forKey: UserDefaultsKeys.defaultTaskSubEntryType)) ?? .Text
    }
    
    struct UserDefaultsKeys {
        static var showTaskActionsIcons = "ShowTaskActionsIcons"
        static var defaultTaskSubEntryType = "DefaultTaskSubEntryType"
    }
}

class SettingsViewModel: ObservableObject {
    typealias UserDefaultKeys = Preferences.UserDefaultsKeys
    let defaults = UserDefaults.standard
    
    @Published var settings = Preferences()
    
    func updateShowTaskActionDisplayIcons(to newValue: Bool) {
        defaults.set(newValue, forKey: UserDefaultKeys.showTaskActionsIcons)
        settings.showTaskActionDisplayIcons = newValue
    }
    
    func updateDefaultTaskSubEntryType(to taskSubEntryType: SubTaskType) {
        defaults.set(taskSubEntryType.rawValue, forKey: UserDefaultKeys.defaultTaskSubEntryType)
        settings.defaultTaskSubEntryType = taskSubEntryType
    }
}

