//
//  MainTabView.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var discoverVM = DiscoverViewModel()
    @State private var selectedTab: Tab = .discover

    // 👇 THIS controls auto-opening Settings
    @State private var openSettingsFromDiscover = false

    enum Tab: Hashable {
        case discover
        case explore
        case matches
        case profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            DiscoverView(
                vm: discoverVM,
                onOpenSettings: {
                    openSettingsFromDiscover = true
                    selectedTab = .profile
                }
            )
            .tabItem {
                Image("discover_tab_icon")
                    .renderingMode(.template)
                Text("Discover")
            }
            .tag(Tab.discover)
            
            ExploreView()
                .tabItem { Label("Explore", systemImage: "safari.fill") }
                .tag(Tab.explore)

            MatchesListView()
                .tabItem { Label("Matches", systemImage: "bubble.left.and.bubble.right.fill") }
                .tag(Tab.matches)

            ProfileView(
                openSettings: $openSettingsFromDiscover
            )
            .tabItem { Label("Profile", systemImage: "person.fill") }
            .tag(Tab.profile)
        }
        .tint(Color(hex: "#a9054b"))   // ✅ ACTIVE tab color
    }
}

#Preview {
    MainTabView()
}
