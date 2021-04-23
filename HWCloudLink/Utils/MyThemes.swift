//
//  MyThemes.swift
//  PlistDemo
//


import Foundation
import SwiftTheme

private let lastThemeIndexKey = "lastedThemeIndex"
private let defaults = UserDefaults.standard

enum MyThemes: Int {
    
    case light = 0
    case dark = 1
    
    // MARK: -
    
    static var current: MyThemes { return MyThemes(rawValue: ThemeManager.currentThemeIndex)! }
    
    // MARK: - Switch Theme
    
    static func switchTo(theme: MyThemes) {
        ThemeManager.setTheme(index: theme.rawValue)
    }
    
    // MARK: - Switch Night
    
    static func switchNight(isToNight: Bool) {
        switchTo(theme: isToNight ? .dark : .light)
    }
    
    static func isNight() -> Bool {
        return current == .dark
    }
    
    // MARK: - Save & Restore
    
    static func restoreLastTheme() {
        switchTo(theme: MyThemes(rawValue: defaults.integer(forKey: lastThemeIndexKey))!)
    }
    
    static func saveLastTheme() {
        defaults.set(ThemeManager.currentThemeIndex, forKey: lastThemeIndexKey)
    }
    
}
