//
//  ModernTabBar.swift
//  Beam
//
//  Created by Claude Code on 27/08/2025.
//

import SwiftUI
import BeamCore

struct ModernTabBar: View {
    @StateObject private var controller = TabBarController()
    @EnvironmentObject var browserTabsManager: BrowserTabsManager
    @EnvironmentObject var state: BeamState
    @EnvironmentObject var windowInfo: BeamWindowInfo
    
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollContentSize: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: ModernTabTheme.tabSpacing) {
                        tabContent
                    }
                    .padding(.horizontal, 8)
                    .background(
                        GeometryReader { contentGeometry in
                            Color.clear.onAppear {
                                scrollContentSize = contentGeometry.size.width
                            }
                        }
                    )
                }
                .background(tabBarBackground)
                .overlay(tabBarBorder, alignment: .bottom)
                .frame(height: ModernTabTheme.tabHeight + 8)
                .clipped()
                .onAppear {
                    controller.setup(browserTabsManager: browserTabsManager, state: state)
                    setupWindowDragPrevention(geometry: geometry)
                }
                .onChange(of: controller.currentTab?.id) { _ in
                    scrollToActiveTab(scrollProxy: scrollProxy)
                }
            }
        }
        .frame(height: ModernTabTheme.tabHeight + 8)
    }
    
    // MARK: - Tab Content
    
    @ViewBuilder
    private var tabContent: some View {
        ForEach(organizedTabs, id: \.id) { item in
            switch item {
            case .tab(let tab, let group, let groupColor):
                tabView(for: tab, group: group, groupColor: groupColor)
                
            case .groupDivider(let color):
                GroupTabDivider(color: color)
                
            case .groupHeader(let group, let color, let tabCount, let isCollapsed):
                ModernTabGroup(
                    group: group,
                    color: color,
                    isCollapsed: isCollapsed,
                    tabCount: tabCount,
                    onToggle: { controller.toggleGroup(group) },
                    onTap: { /* Handle group tap */ }
                )
            }
        }
    }
    
    private func tabView(for tab: BrowserTab, group: TabGroup?, groupColor: Color?) -> some View {
        ModernTab(
            tab: tab,
            isActive: controller.isActive(tab),
            isHovered: controller.isHovered(tab),
            isDragged: controller.draggedTabID == tab.id,
            showCloseButton: controller.shouldShowCloseButton(tab),
            group: group,
            groupColor: groupColor,
            onTap: { controller.selectTab(tab) },
            onClose: { controller.closeTab(tab) },
            onHover: { hovering in
                controller.setHovered(hovering ? tab : nil)
            },
            onDragChanged: { gesture in
                if !controller.isDragging {
                    controller.startDrag(tab)
                }
                controller.updateDrag(offset: gesture.translation)
            },
            onDragEnded: { gesture in
                handleDragEnd(for: tab, gesture: gesture)
                controller.endDrag()
            }
        )
        .id(tab.id)
    }
    
    // MARK: - Tab Organization
    
    private enum TabItem {
        case tab(BrowserTab, group: TabGroup?, groupColor: Color?)
        case groupDivider(Color)
        case groupHeader(TabGroup, color: Color, tabCount: Int, isCollapsed: Bool)
    }
    
    private var organizedTabs: [TabItem] {
        var items: [TabItem] = []
        var processedGroups: Set<UUID> = []
        
        // Process tabs and their groups
        for tab in controller.tabs {
            let group = controller.getGroupForTab(tab)
            
            // If this tab belongs to a group we haven't processed yet
            if let group = group, !processedGroups.contains(group.id) {
                processedGroups.insert(group.id)
                
                let groupColor = controller.getGroupColor(group)
                let tabsInGroup = controller.tabs.filter { 
                    controller.getGroupForTab($0)?.id == group.id 
                }
                
                // Add group header
                items.append(.groupHeader(
                    group,
                    color: groupColor,
                    tabCount: tabsInGroup.count,
                    isCollapsed: group.collapsed
                ))
                
                // Add group divider
                items.append(.groupDivider(groupColor))
                
                // Add tabs in this group (if not collapsed)
                if !group.collapsed {
                    for tabInGroup in tabsInGroup {
                        items.append(.tab(tabInGroup, group: group, groupColor: groupColor))
                    }
                }
                
                // Add ending divider
                items.append(.groupDivider(groupColor))
            }
            // If tab doesn't belong to a group or group is already processed, add individual tab
            else if group == nil {
                items.append(.tab(tab, group: nil, groupColor: nil))
            }
        }
        
        return items
    }
    
    // MARK: - Styling
    
    private var tabBarBackground: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color(NSColor.windowBackgroundColor),
                        Color(NSColor.windowBackgroundColor).opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
    
    private var tabBarBorder: some View {
        Rectangle()
            .fill(Color(NSColor.separatorColor))
            .frame(height: 0.5)
    }
    
    // MARK: - Actions
    
    private func handleDragEnd(for tab: BrowserTab, gesture: DragGesture.Value) {
        let dragDistance = gesture.translation.x
        guard abs(dragDistance) > 20 else { return } // Minimum drag distance
        
        // Calculate new position based on drag distance
        if let currentIndex = controller.tabs.firstIndex(of: tab) {
            let tabWidth = ModernTabTheme.tabMinWidth + ModernTabTheme.tabSpacing
            let positionChange = Int(dragDistance / tabWidth)
            let newIndex = max(0, min(controller.tabs.count - 1, currentIndex + positionChange))
            
            if newIndex != currentIndex {
                controller.moveTab(from: currentIndex, to: newIndex)
            }
        }
    }
    
    private func scrollToActiveTab(scrollProxy: ScrollViewProxy) {
        if let activeTab = controller.currentTab {
            withAnimation(.easeInOut(duration: 0.3)) {
                scrollProxy.scrollTo(activeTab.id, anchor: .center)
            }
        }
    }
    
    private func setupWindowDragPrevention(geometry: GeometryProxy) {
        // Calculate tab bar area for window drag prevention
        let frame = geometry.frame(in: .global)
        let tabBarRect = CGRect(
            x: frame.origin.x,
            y: frame.origin.y,
            width: frame.width,
            height: ModernTabTheme.tabHeight + 8
        )
        
        DispatchQueue.main.async {
            windowInfo.undraggableWindowRects = [tabBarRect]
        }
    }
}

// MARK: - Extension for TabItem Identifiable
extension ModernTabBar.TabItem: Identifiable {
    var id: String {
        switch self {
        case .tab(let tab, _, _):
            return "tab-\(tab.id.uuidString)"
        case .groupDivider(let color):
            return "divider-\(color.description)"
        case .groupHeader(let group, _, _, _):
            return "group-\(group.id.uuidString)"
        }
    }
}