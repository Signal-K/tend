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
    
    var addCategoryAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Category")
                .fontWeight(.semibold)
                .foregroundColor(.foregroundColor)
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { cat in
                    Text(cat.capitalized).tag(cat)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 6)
            
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
                
                Button(action: addCategoryAction) {
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
