//
//  PreviousSessions.swift
//  Tend
//
//  Created by Liam Arbuckle on 15/7/2025.
//

import SwiftUI

struct PreviousSessionsSheetView: View {
    @Binding var isPresented: Bool
    
    @AppStorage("previousSessions") private var previousSessionsData: Data = Data()
    @State private var sessions: [FocusSession] = []
    
    var body: some View {
        NavigationView {
            List {
                Section("Today's Focus Sessions") {
                    let today = Calendar.current.startOfDay(for: Date())
                    ForEach(sessions.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }) { session in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Date: \(session.date.formatted(date: .abbreviated, time: .shortened))")
                                .fontWeight(.semibold)
                            Text("Categories time:")
                            ForEach(session.categoryTimes.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                Text("\(key.capitalized): \(formatTime(value))")
                            }
                            Text("Break time: \(formatTime(session.breakTime))")
                            Text("Todos completed: \(session.completedTodos.count)")
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Previous Sessions")
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
            .onAppear(perform: loadSessionsFromStorage)
        }
    }
    
    private func loadSessionsFromStorage() {
        if let decoded = try? JSONDecoder().decode([FocusSession].self, from: previousSessionsData) {
            sessions = decoded
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let intSec = Int(interval)
        let m = intSec / 60
        let s = intSec % 60
        return String(format: "%02d:%02d", m, s)
    }
}
