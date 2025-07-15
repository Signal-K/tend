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
                    Section("Tasks") {
                        ForEach(todos, id: \.self) { todo in
                            Text(todo)
                        }
                    }
                    
                    Section("Mark Completed Tasks") {
                        VStack {
                            ForEach(completedTasks, id: \.self) { task in
                                Text("• \(task)")
                                    .foregroundColor(.foregroundColor)
                            }
                            
                            HStack {
                                TextField("Add completed task", text: $newCompletedTask)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button("Add") {
                                    let trimmed = newCompletedTask.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !trimmed.isEmpty else { return }
                                    completedTasks.append(trimmed)
                                    newCompletedTask = ""
                                }
                            }
                        }
                    }
                }
                
                Button(action: endSessionAction) {
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
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let intSec = Int(interval)
        let m = intSec / 60
        let s = intSec % 60
        return String(format: "%02d:%02d", m, s)
    }
}
