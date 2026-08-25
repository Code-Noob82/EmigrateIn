//
//  AppTabView.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//

import SwiftUI

// MARK: - AppTabView (Hauptansicht nach Login)
struct AppTabView: View {
    @State private var selectedTab: TabSelection = .home
    
    let backgroundGradient = AppStyles.backgroundGradient
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.stackedLayoutAppearance.normal.badgePositionAdjustment.horizontal = 5
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 16.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                Tab("Start", systemImage: "house.fill", value: .home) {
                    InfoCategoryListView()
                }
                Tab("Checklisten", systemImage: "checklist.checked", value: .checklists) {
                    ChecklistCategoryListView()
                }
                Tab("Botschaft", systemImage: "building.columns.fill", value: .embassy) {
                    EmbassyInfoView()
                }
                Tab("Profil", systemImage: "person.crop.circle.fill", value: .profile) {
                    ProfileView(selectedTab: $selectedTab)
                }
                Tab("Einstellungen", systemImage: "gearshape.fill", value: .settings) {
                    SettingsView()
                }
            }
            .toolbarColorScheme(.light, for: .tabBar)
        }
    }
}

#Preview("AppTabView") {
    AppTabView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(UserProfileViewModel())
        .environmentObject(AccountDeletionViewModel())
}
