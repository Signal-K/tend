//
//  AppView.swift
//  Tend
//
//  Created by Liam Arbuckle on 17/6/2025.
//

import SwiftUI

struct AppView: View {
    @State var isAuthenticated = false

    var body: some View {
        Group {
            if isAuthenticated {
                BottomNavigation()
            } else {
//                AuthView()
                BottomNavigation()
            }
        }
        .task {
            for await state in supabase.auth.authStateChanges {
                if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                    isAuthenticated = state.session != nil
                }
            }
        }
    }
}

#Preview {
    AppView()
}
