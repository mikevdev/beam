//
//  ModernTabGroup.swift
//  Beam
//
//  Created by Claude Code on 27/08/2025.
//

import SwiftUI
import BeamCore

struct ModernTabGroup: View {
    let group: TabGroup
    let color: Color
    let isCollapsed: Bool
    let tabCount: Int
    
    let onToggle: () -> Void
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    private var groupWidth: CGFloat {
        isCollapsed ? 120 : 40
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Group indicator/icon
            groupIndicator
            
            if !isCollapsed {
                // Group title
                titleView
                
                Spacer(minLength: 0)
                
                // Tab count badge
                countBadge
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(width: groupWidth, height: ModernTabTheme.tabHeight - 4)
        .background(groupBackground)
        .overlay(groupBorder)
        .clipShape(RoundedRectangle(cornerRadius: ModernTabTheme.tabCornerRadius - 2))
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(ModernTabTheme.Animations.tabHover, value: isHovered)
        .animation(ModernTabTheme.Animations.groupCollapse, value: isCollapsed)
        .onTapGesture {
            if isCollapsed {
                onToggle()
            } else {
                onTap()
            }
        }
        .onHover { hovering in
            withAnimation(ModernTabTheme.Animations.tabHover) {
                isHovered = hovering
            }
        }
        .contextMenu {
            contextMenuContent
        }
    }
    
    // MARK: - Subviews
    
    private var groupIndicator: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .overlay(
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }
    
    private var titleView: some View {
        Text(group.title ?? "Untitled Group")
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(Color(NSColor.secondaryLabelColor))
            .lineLimit(1)
            .truncationMode(.tail)
    }
    
    private var countBadge: some View {
        Text("\(tabCount)")
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(color.opacity(0.8))
            )
    }
    
    private var groupBackground: some View {
        RoundedRectangle(cornerRadius: ModernTabTheme.tabCornerRadius - 2)
            .fill(
                LinearGradient(
                    colors: [
                        color.opacity(isHovered ? 0.15 : 0.08),
                        color.opacity(isHovered ? 0.12 : 0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
    
    private var groupBorder: some View {
        RoundedRectangle(cornerRadius: ModernTabTheme.tabCornerRadius - 2)
            .stroke(color.opacity(0.3), lineWidth: 0.5)
    }
    
    @ViewBuilder
    private var contextMenuContent: some View {
        Button(isCollapsed ? "Expand Group" : "Collapse Group", action: onToggle)
        
        Divider()
        
        Button("Rename Group") {
            // Handle rename
        }
        
        Button("Change Color") {
            // Handle color change
        }
        
        Divider()
        
        Button("Close Group Tabs") {
            // Handle close all tabs in group
        }
        
        Button("Remove from Group") {
            // Handle remove from group
        }
    }
}

// MARK: - Group Tab Divider
struct GroupTabDivider: View {
    let color: Color
    let height: CGFloat = ModernTabTheme.tabHeight - 8
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        color.opacity(0.3),
                        color.opacity(0.6),
                        color.opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 1, height: height)
    }
}