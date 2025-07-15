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
    @Binding var todos: [Todo]
    
    @Binding var completedTasks: [Todo] // For session summary, optional to keep
    
    @Binding var newCompletedTask: String
    
    @AppStorage("persistedTodos", store: .standard) private var persistedTodosData: Data = Data()
    
    let endSessionAction: () -> Void
    
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
                        ForEach(todos) { todo in
                            HStack {
                                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(todo.completed ? .green : .gray)
                                Text(todo.title)
                            }
                            .contentShape(Rectangle()) // To make entire row tappable
                            .onTapGesture {
                                toggleCompletion(todo)
                            }
                        }
                    }
                }
                
                Button(action: {
                    // Update completedTasks to todos where completed = true
                    completedTasks = todos.filter { $0.completed }
                    saveTodos()
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
            .navigationTitle("End Focus Session")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func toggleCompletion(_ todo: Todo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index].completed.toggle()
    }
    
    private func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            persistedTodosData = encoded
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let intSec = Int(interval)
        let m = intSec / 60
        let s = intSec % 60
        return String(format: "%02d:%02d", m, s)
    }
}
