//
//  ModernTabTheme.swift
//  Beam
//
//  Created by Claude Code on 27/08/2025.
//

import SwiftUI
import BeamCore

struct ModernTabTheme {
    // MARK: - Dimensions
    static let tabHeight: CGFloat = 32
    static let tabMinWidth: CGFloat = 120
    static let tabMaxWidth: CGFloat = 260
    static let tabCornerRadius: CGFloat = 8
    static let tabSpacing: CGFloat = 2
    static let closeButtonSize: CGFloat = 16
    
    // MARK: - Colors
    struct Colors {
        // Active Tab
        static let activeBackground = Color(NSColor.controlBackgroundColor)
        static let activeBorder = Color(NSColor.separatorColor)
        static let activeText = Color(NSColor.controlTextColor)
        
        // Inactive Tab
        static let inactiveBackground = Color(NSColor.controlBackgroundColor).opacity(0.6)
        static let inactiveBorder = Color(NSColor.separatorColor).opacity(0.5)
        static let inactiveText = Color(NSColor.secondaryLabelColor)
        
        // Hover
        static let hoverBackground = Color(NSColor.controlBackgroundColor).opacity(0.8)
        static let hoverBorder = Color(NSColor.separatorColor).opacity(0.7)
        
        // Close Button
        static let closeButtonNormal = Color(NSColor.tertiaryLabelColor)
        static let closeButtonHover = Color(NSColor.controlTextColor)
        static let closeButtonBackground = Color(NSColor.quaternaryLabelColor).opacity(0.5)
        
        // Tab Groups
        static let groupColors: [Color] = [
            .blue, .green, .orange, .purple, .pink, .red, .yellow, .gray
        ]
    }
    
    // MARK: - Animations
    struct Animations {
        static let tabHover = Animation.easeInOut(duration: 0.15)
        static let tabSelection = Animation.easeInOut(duration: 0.2)
        static let closeButton = Animation.easeInOut(duration: 0.1)
        static let groupCollapse = Animation.easeInOut(duration: 0.3)
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let activeTab = Color.black.opacity(0.1)
        static let tabBar = Color.black.opacity(0.05)
    }
}

// MARK: - Tab Visual States
enum TabVisualState {
    case active
    case inactive
    case hover
    
    var backgroundColor: Color {
        switch self {
        case .active: return ModernTabTheme.Colors.activeBackground
        case .inactive: return ModernTabTheme.Colors.inactiveBackground
        case .hover: return ModernTabTheme.Colors.hoverBackground
        }
    }
    
    var borderColor: Color {
        switch self {
        case .active: return ModernTabTheme.Colors.activeBorder
        case .inactive: return ModernTabTheme.Colors.inactiveBorder
        case .hover: return ModernTabTheme.Colors.hoverBorder
        }
    }
    
    var textColor: Color {
        switch self {
        case .active: return ModernTabTheme.Colors.activeText
        case .inactive, .hover: return ModernTabTheme.Colors.inactiveText
        }
    }
}