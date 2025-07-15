//
//  CategoryPicker.swift
//  Tend
//
//  Created by Liam Arbuckle on 15/7/2025.
//

import SwiftUI

struct CategoryPickerView: View {
    @Binding var categories: [String]
    @Binding var selectedCategory: String
    @Binding var newCategoryName: String
    
    @Binding var todos: [Todo]      
    @Binding var newTodo: String
    
    var addCategoryAction: () -> Void
    var addTodoAction: () -> Void
    
    @State private var showAddCategory: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Category")
                .fontWeight(.semibold)
                .foregroundColor(.foregroundColor)
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { cat in
                    Text(cat.capitalized).tag(cat)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if showAddCategory {
                HStack {
                    TextField("Add new category", text: $newCategoryName)
                        .padding(10)
                        .background(Color.backgroundColor)
                        .cornerRadius(12)
                        .foregroundColor(.foregroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondaryColor.opacity(0.5), lineWidth: 1)
                        )
                    
                    Button(action: {
                        addCategoryAction()
                        newCategoryName = ""
                        showAddCategory = false
                    }) {
                        Text("Add")
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.secondaryColor)
                            .foregroundColor(Color.secondaryForeground)
                            .cornerRadius(12)
                    }
                }
            } else {
                Button(action: {
                    withAnimation {
                        showAddCategory = true
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Add Category")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color.primaryColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // MARK: Add Todo Section inside Category Picker
            
            Text("Todos")
                .fontWeight(.semibold)
                .foregroundColor(.foregroundColor)
                .padding(.top, 8)
            
            VStack(spacing: 8) {
                // Show only todos in the selected category
                ForEach(todos.filter { $0.category == selectedCategory }) { todo in
                    Text("• \(todo.title)")
                        .foregroundColor(.foregroundColor)
                }
                
                HStack {
                    TextField("Add new todo", text: $newTodo)
                        .padding(10)
                        .background(Color.backgroundColor)
                        .cornerRadius(12)
                        .foregroundColor(.foregroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondaryColor.opacity(0.5), lineWidth: 1)
                        )
                    
                    Button(action: {
                        addTodoAction()
                    }) {
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
        }
        .padding()
        .neuomorphicStyle()
    }
}
