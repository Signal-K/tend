//
//  BottomNavigation.swift
//  Tend
//
//  Created by Liam Arbuckle on 17/6/2025.
//

import SwiftUI

struct BottomNavigation: View {
    var body: some View {
        TabView {
//            HomeView()
            ArchiveTasksView()
                .tabItem {
                    Label("Tasks", systemImage: "house.fill")
                }

            FocusSessionView()
                .tabItem {
                    Label("Focus", systemImage: "note.text")
                }

            ArchiveView()
                .tabItem {
                    Label("Archive", systemImage: "archivebox.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
//        .accentColor(.gardenGreen)
    }
}

#Preview {
    BottomNavigation()
}
