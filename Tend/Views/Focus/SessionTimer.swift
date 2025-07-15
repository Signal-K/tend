//
//  SessionTimer.swift
//  Tend
//
//  Created by Liam Arbuckle on 15/7/2025.
//

import SwiftUI

struct SessionTimerView: View {
    @Binding var currentCategory: String
    let categories: [String]
    let elapsedFocusTime: TimeInterval
    let elapsedBreakTime: TimeInterval
    let isOnBreak: Bool
    
    let toggleBreakAction: () -> Void
    let endSessionAction: () -> Void
    
    @AppStorage("persistedTodos") private var persistedTodosData: Data = Data()
    
    // Store completed todo IDs persistently
    @AppStorage("completedTodoIDs") private var completedTodoIDsData: Data = Data()
    
    // Local cache of completed todo IDs for UI
    @State private var completedTaskIDs: Set<UUID> = []
    
    // Decode all todos from storage
    private var allTodos: [Todo] {
        (try? JSONDecoder().decode([Todo].self, from: persistedTodosData)) ?? []
    }
    
    // Decode completed todo IDs from storage
    private func loadCompletedTaskIDs() -> Set<UUID> {
        guard !completedTodoIDsData.isEmpty else { return [] }
        if let ids = try? JSONDecoder().decode([UUID].self, from: completedTodoIDsData) {
            return Set(ids)
        }
        return []
    }
    
    // Save completed todo IDs back to storage
    private func saveCompletedTaskIDs() {
        let idsArray = Array(completedTaskIDs)
        if let encoded = try? JSONEncoder().encode(idsArray) {
            completedTodoIDsData = encoded
        }
    }
    
    // Filter todos for current category
    private var filteredTodos: [Todo] {
        allTodos.filter { $0.category.lowercased() == currentCategory.lowercased() }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Focus Session")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.foregroundColor)
            
            Picker("Current Category", selection: $currentCategory) {
                ForEach(categories, id: \.self) { cat in
                    Text(cat.capitalized).tag(cat)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color.backgroundColor)
            .cornerRadius(20)
            .neuomorphicStyle()
            
            Text(formatTime(elapsedFocusTime))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.primaryColor)
                .accessibilityLabel("Focus time elapsed")
            
            Text(formatTime(elapsedBreakTime))
                .font(.headline)
                .foregroundColor(.secondaryColor)
                .accessibilityLabel("Break time elapsed")
            
            // Todo list with togglable completion
            List {
                Section(header: Text("Tasks for \(currentCategory.capitalized)")) {
                    if filteredTodos.isEmpty {
                        Text("No tasks for this category")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(filteredTodos) { todo in
                            Button(action: {
                                toggleCompletion(for: todo)
                            }) {
                                HStack {
                                    Image(systemName: completedTaskIDs.contains(todo.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(completedTaskIDs.contains(todo.id) ? .green : .gray)
                                    Text(todo.title)
                                        .foregroundColor(.primary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .frame(maxHeight: 250)
            
            HStack(spacing: 40) {
                Button(action: toggleBreakAction) {
                    Text(isOnBreak ? "Resume Focus" : "Take Break")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(Color.accentForeground)
                        .cornerRadius(20)
                        .neuomorphicStyle(cornerRadius: 20)
                }
                
                Button(action: endSessionAction) {
                    Text("End Session")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.secondaryColor)
                        .foregroundColor(Color.secondaryForeground)
                        .cornerRadius(20)
                        .neuomorphicStyle(cornerRadius: 20)
                }
            }
        }
        .onAppear {
            completedTaskIDs = loadCompletedTaskIDs()
        }
    }
    
    private func toggleCompletion(for todo: Todo) {
        if completedTaskIDs.contains(todo.id) {
            completedTaskIDs.remove(todo.id)
        } else {
            completedTaskIDs.insert(todo.id)
        }
        saveCompletedTaskIDs()
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let intSec = Int(interval)
        let m = intSec / 60
        let s = intSec % 60
        return String(format: "%02d:%02d", m, s)
    }
}
