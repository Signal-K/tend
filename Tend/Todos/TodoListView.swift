//
//  TodoListView.swift
//  Tend
//
//  Created by Liam Arbuckle on 15/7/2025.
//

import SwiftUI

struct TodoListView: View {
    @Binding var todos: [String]
    @Binding var newTodo: String
    var addTodoAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add Todos (optional)")
                .fontWeight(.semibold)
                .foregroundColor(.foregroundColor)
            
            VStack(spacing: 6) {
                ForEach(todos, id: \.self) { todo in
                    HStack {
                        Text("• \(todo)")
                            .foregroundColor(.foregroundColor)
                        Spacer()
                        Button {
                            todos.removeAll(where: { $0 == todo })
                        } label: {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.secondaryColor)
                        }
                    }
                }
            }
            
            HStack {
                TextField("New todo", text: $newTodo)
                    .padding(10)
                    .background(Color.backgroundColor)
                    .cornerRadius(12)
                    .foregroundColor(.foregroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondaryColor.opacity(0.5), lineWidth: 1)
                    )
                Button(action: addTodoAction) {
                    Text("Add")
                        .fontWeight(.semibold)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.secondaryColor)
                        .foregroundColor(Color.secondaryForeground)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .neuomorphicStyle()
    }
}
