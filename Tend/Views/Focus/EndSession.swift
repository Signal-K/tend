//
//  EndSession.swift
//  Tend
//
//  Created by Liam Arbuckle on 15/7/2025.
//

import SwiftUI

struct EndSessionSheetView: View {
    @Binding var elapsedFocusTime: TimeInterval
    @Binding var elapsedBreakTime: TimeInterval
    @Binding var todos: [String]
    @Binding var completedTasks: [String]
    @Binding var newCompletedTask: String
    
    @AppStorage("persistedTodos", store: .standard) private var persistedTodosData: Data = Data()
    @AppStorage("completedTodos", store: .standard) private var completedTodosData: Data = Data()
    
    let endSessionAction: () -> Void
    
    @State private var selectedTasks: Set<String> = []

    private var allPersistedTodos: [String] {
        (try? JSONDecoder().decode([String].self, from: persistedTodosData)) ?? []
    }

    private var completedSet: Set<String> {
        Set((try? JSONDecoder().decode([String].self, from: completedTodosData)) ?? [])
    }

    private var incompletePersistedTodos: [String] {
        allPersistedTodos.filter { !completedSet.contains($0) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Text("Session Summary")
                    .font(.headline)
                    .padding(.top)
                
                Text("Focus Time: \(formatTime(elapsedFocusTime))")
                    .foregroundColor(.primaryColor)
                Text("Break Time: \(formatTime(elapsedBreakTime))")
                    .foregroundColor(.secondaryColor)
                
                List {
                    Section("Tasks from This Session") {
                        ForEach(todos, id: \.self) { todo in
                            Text(todo)
                        }
                    }
                    
                    Section("Mark Completed Tasks") {
                        if incompletePersistedTodos.isEmpty {
                            Text("No incomplete tasks to mark.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(incompletePersistedTodos, id: \.self) { task in
                                Button(action: {
                                    toggleTask(task)
                                }) {
                                    HStack {
                                        Image(systemName: selectedTasks.contains(task) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedTasks.contains(task) ? .green : .gray)
                                        Text(task)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Button(action: {
                    completedTasks = Array(selectedTasks)
                    saveCompletedTasks()
                    endSessionAction()
                }) {
                    Text("Save Session")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryColor)
                        .foregroundColor(Color.primaryForeground)
                        .cornerRadius(20)
                        .neuomorphicStyle(cornerRadius: 20)
                }
                .padding()
            }
            .onAppear {
                selectedTasks = Set(completedTasks)
            }
            .navigationTitle("End Focus Session")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func toggleTask(_ task: String) {
        if selectedTasks.contains(task) {
            selectedTasks.remove(task)
        } else {
            selectedTasks.insert(task)
        }
    }

    private func saveCompletedTasks() {
        var existingCompleted = (try? JSONDecoder().decode([String].self, from: completedTodosData)) ?? []
        existingCompleted.append(contentsOf: selectedTasks.filter { !existingCompleted.contains($0) })

        if let encoded = try? JSONEncoder().encode(existingCompleted) {
            completedTodosData = encoded
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let intSec = Int(interval)
        let m = intSec / 60
        let s = intSec % 60
        return String(format: "%02d:%02d", m, s)
    }
}
