//
//  TodoArchive.swift
//  Tend
//
//  Created by Liam Arbuckle on 13/7/2025.
//

import SwiftUI

struct ArchiveTasksView: View {
    // Persisted tasks (added manually or through session)
    @AppStorage("persistedTodos", store: .standard) private var persistedTodosData: Data = Data()
    
    // Persisted completed tasks
    @AppStorage("completedTodos", store: .standard) private var completedTodosData: Data = Data()
    
    private var allTodos: [String] {
        (try? JSONDecoder().decode([String].self, from: persistedTodosData)) ?? []
    }
    
    private var completedTodos: [String] {
        (try? JSONDecoder().decode([String].self, from: completedTodosData)) ?? []
    }
    
    private var incompleteTodos: [String] {
        let completedSet = Set(completedTodos)
        return allTodos.filter { !completedSet.contains($0) }
    }

    var body: some View {
        NavigationView {
            List {
                if !incompleteTodos.isEmpty {
                    Section(header: Text("Incomplete Tasks")) {
                        ForEach(incompleteTodos, id: \.self) { todo in
                            Label(todo, systemImage: "circle")
                        }
                    }
                }
                
                if !completedTodos.isEmpty {
                    Section(header: Text("Completed Tasks")) {
                        ForEach(completedTodos, id: \.self) { todo in
                            Label(todo, systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("All Tasks")
            .listStyle(InsetGroupedListStyle())
            .background(Color.backgroundColor.edgesIgnoringSafeArea(.all))
        }
    }
}
