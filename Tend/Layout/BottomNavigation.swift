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
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
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
        .accentColor(.gardenGreen)
    }
}

#Preview {
    BottomNavigation()
}
