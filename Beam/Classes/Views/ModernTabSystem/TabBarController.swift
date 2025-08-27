//
//  TabBarController.swift
//  Beam
//
//  Created by Claude Code on 27/08/2025.
//

import SwiftUI
import BeamCore
import Combine

@MainActor
class TabBarController: ObservableObject {
    // MARK: - Published Properties
    @Published var hoveredTabID: UUID?
    @Published var draggedTabID: UUID?
    @Published var isDragging = false
    @Published var dragOffset: CGSize = .zero
    
    // MARK: - Dependencies
    private weak var browserTabsManager: BrowserTabsManager?
    private weak var state: BeamState?
    
    // MARK: - Initialization
    func setup(browserTabsManager: BrowserTabsManager, state: BeamState) {
        self.browserTabsManager = browserTabsManager
        self.state = state
    }
    
    // MARK: - Tab Data
    var tabs: [BrowserTab] {
        browserTabsManager?.tabs ?? []
    }
    
    var currentTab: BrowserTab? {
        browserTabsManager?.currentTab
    }
    
    var tabGroups: [TabGroup] {
        let groups = browserTabsManager?.listItems.allItems.compactMap { $0.group } ?? []
        return Array(Set(groups.map { $0.id })).compactMap { id in
            groups.first { $0.id == id }
        }
    }
    
    // MARK: - Tab Actions
    func selectTab(_ tab: BrowserTab) {
        print("🎯 ModernTab: Selecting tab - \(tab.title)")
        browserTabsManager?.setCurrentTab(tab)
        
        // If clicking the already selected tab, focus omnibox
        if tab == currentTab {
            state?.startFocusOmnibox(fromTab: true)
        }
    }
    
    func closeTab(_ tab: BrowserTab) {
        print("❌ ModernTab: Closing tab - \(tab.title)")
        if let tabIndex = tabs.firstIndex(of: tab) {
            state?.closeTab(tabIndex, allowClosingPinned: true)
        }
    }
    
    func pinTab(_ tab: BrowserTab) {
        print("📌 ModernTab: Pinning tab - \(tab.title)")
        browserTabsManager?.pinTab(tab)
    }
    
    func unpinTab(_ tab: BrowserTab) {
        print("📌 ModernTab: Unpinning tab - \(tab.title)")
        browserTabsManager?.unpinTab(tab)
    }
    
    // MARK: - Tab Group Actions
    func toggleGroup(_ group: TabGroup) {
        print("📁 ModernTab: Toggling group - \(group.title ?? "Untitled")")
        browserTabsManager?.toggleGroupCollapse(group)
    }
    
    func getGroupForTab(_ tab: BrowserTab) -> TabGroup? {
        return tabGroups.first { group in
            group.pageIds.contains { pageId in
                tab.browsingTree?.current.id.uuidString == pageId ||
                tab.browsingTree?.origin?.id.uuidString == pageId
            }
        }
    }
    
    func getGroupColor(_ group: TabGroup) -> Color {
        if let color = group.color {
            return Color(color)
        }
        // Fallback to predefined colors based on group ID
        let colorIndex = abs(group.id.hashValue) % ModernTabTheme.Colors.groupColors.count
        return ModernTabTheme.Colors.groupColors[colorIndex]
    }
    
    // MARK: - Hover Actions
    func setHovered(_ tab: BrowserTab?) {
        hoveredTabID = tab?.id
    }
    
    func isHovered(_ tab: BrowserTab) -> Bool {
        hoveredTabID == tab.id
    }
    
    // MARK: - Drag Actions
    func startDrag(_ tab: BrowserTab) {
        guard !isDragging else { return }
        print("🚀 ModernTab: Starting drag for - \(tab.title)")
        
        draggedTabID = tab.id
        isDragging = true
        dragOffset = .zero
        
        // Select the tab being dragged
        selectTab(tab)
    }
    
    func updateDrag(offset: CGSize) {
        guard isDragging else { return }
        dragOffset = offset
    }
    
    func endDrag() {
        guard isDragging else { return }
        print("🏁 ModernTab: Ending drag")
        
        // Reset drag state
        draggedTabID = nil
        isDragging = false
        dragOffset = .zero
    }
    
    func moveTab(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              sourceIndex >= 0, sourceIndex < tabs.count,
              destinationIndex >= 0, destinationIndex <= tabs.count else { return }
        
        print("📦 ModernTab: Moving tab from \(sourceIndex) to \(destinationIndex)")
        // Use the existing moveListItem method
        browserTabsManager?.moveListItem(atListIndex: sourceIndex, toListIndex: destinationIndex, changeGroup: nil, disableAnimations: false)
    }
    
    // MARK: - Utility
    func isActive(_ tab: BrowserTab) -> Bool {
        currentTab?.id == tab.id
    }
    
    func shouldShowCloseButton(_ tab: BrowserTab) -> Bool {
        isHovered(tab) || isActive(tab) || tabs.count == 1
    }
}