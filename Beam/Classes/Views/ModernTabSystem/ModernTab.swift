//
//  ModernTab.swift
//  Beam
//
//  Created by Claude Code on 27/08/2025.
//

import SwiftUI
import BeamCore

struct ModernTab: View {
    let tab: BrowserTab
    let isActive: Bool
    let isHovered: Bool
    let isDragged: Bool
    let showCloseButton: Bool
    let group: TabGroup?
    let groupColor: Color?
    
    let onTap: () -> Void
    let onClose: () -> Void
    let onHover: (Bool) -> Void
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    
    @State private var isCloseHovered = false
    
    private var visualState: TabVisualState {
        if isActive { return .active }
        if isHovered { return .hover }
        return .inactive
    }
    
    private var tabWidth: CGFloat {
        // Dynamic width based on content but within bounds
        let baseWidth = ModernTabTheme.tabMinWidth
        let maxWidth = ModernTabTheme.tabMaxWidth
        return min(maxWidth, max(baseWidth, baseWidth + CGFloat(tab.title.count) * 2))
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Favicon
            faviconView
            
            // Title
            titleView
            
            Spacer(minLength: 0)
            
            // Close Button
            if showCloseButton {
                closeButtonView
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .frame(width: tabWidth, height: ModernTabTheme.tabHeight)
        .background(tabBackground)
        .overlay(tabBorder)
        .overlay(groupIndicator, alignment: .bottom)
        .clipShape(TabShape())
        .shadow(
            color: isActive ? ModernTabTheme.Shadows.activeTab : .clear,
            radius: 2, x: 0, y: 1
        )
        .scaleEffect(isDragged ? 1.05 : 1.0)
        .zIndex(isActive ? 2 : (isHovered ? 1 : 0))
        .animation(ModernTabTheme.Animations.tabHover, value: isHovered)
        .animation(ModernTabTheme.Animations.tabSelection, value: isActive)
        .onTapGesture {
            withAnimation(ModernTabTheme.Animations.tabSelection) {
                onTap()
            }
        }
        .onHover { hovering in
            withAnimation(ModernTabTheme.Animations.tabHover) {
                onHover(hovering)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged(onDragChanged)
                .onEnded(onDragEnded)
        )
        .contextMenu {
            contextMenuContent
        }
    }
    
    // MARK: - Subviews
    
    private var faviconView: some View {
        Group {
            if let favicon = tab.favicon {
                Image(nsImage: favicon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "globe")
                    .foregroundColor(visualState.textColor.opacity(0.7))
            }
        }
        .frame(width: 16, height: 16)
    }
    
    private var titleView: some View {
        Text(tab.title.isEmpty ? "New Tab" : tab.title)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(visualState.textColor)
            .lineLimit(1)
            .truncationMode(.tail)
    }
    
    private var closeButtonView: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(
                    isCloseHovered 
                    ? ModernTabTheme.Colors.closeButtonHover 
                    : ModernTabTheme.Colors.closeButtonNormal
                )
                .frame(width: ModernTabTheme.closeButtonSize, height: ModernTabTheme.closeButtonSize)
                .background(
                    Circle()
                        .fill(
                            isCloseHovered 
                            ? ModernTabTheme.Colors.closeButtonBackground 
                            : Color.clear
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(ModernTabTheme.Animations.closeButton) {
                isCloseHovered = hovering
            }
        }
    }
    
    private var tabBackground: some View {
        RoundedRectangle(cornerRadius: ModernTabTheme.tabCornerRadius)
            .fill(
                LinearGradient(
                    colors: [
                        visualState.backgroundColor,
                        visualState.backgroundColor.opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
    
    private var tabBorder: some View {
        RoundedRectangle(cornerRadius: ModernTabTheme.tabCornerRadius)
            .stroke(visualState.borderColor, lineWidth: 0.5)
    }
    
    private var groupIndicator: some View {
        Group {
            if let groupColor = groupColor {
                Rectangle()
                    .fill(groupColor)
                    .frame(height: 2)
                    .padding(.horizontal, 8)
            }
        }
    }
    
    @ViewBuilder
    private var contextMenuContent: some View {
        Button("Close Tab", action: onClose)
        
        Divider()
        
        Button(tab.isPinned ? "Unpin Tab" : "Pin Tab") {
            // Handle pin/unpin
        }
        
        Button("Duplicate Tab") {
            // Handle duplicate
        }
        
        Button("Close Other Tabs") {
            // Handle close others
        }
    }
}

// MARK: - Custom Tab Shape
struct TabShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let cornerRadius = ModernTabTheme.tabCornerRadius
        let rect = rect
        
        // Start from bottom left
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        
        // Bottom line to bottom right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Right line up
        path.addLine(to: CGPoint(x: rect.maxX, y: cornerRadius))
        
        // Top right corner
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .zero,
            endAngle: .init(radians: -Double.pi / 2),
            clockwise: true
        )
        
        // Top line
        path.addLine(to: CGPoint(x: cornerRadius, y: 0))
        
        // Top left corner
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .init(radians: -Double.pi / 2),
            endAngle: .init(radians: Double.pi),
            clockwise: true
        )
        
        // Left line down to start
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        
        return path
    }
}

