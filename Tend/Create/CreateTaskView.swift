//
//  CreateTaskView.swift
//  Tend
//
//  Created by Liam Arbuckle on 17/6/2025.
//

import SwiftUI
import Supabase

struct CreateTaskView: View {
    @Binding var input: TaskInput
    var groupId: String? = nil
    var projectId: String? = nil
    var onSuccess: () -> Void
    var onError: (String) -> Void

    @State private var isLoading = false
    @State private var selectedGroupId: String? = nil

    var body: some View {
        Form {
            Section(header: Text("Task Info")) {
                TextField("Title", text: $input.title)
                TextField("Description", text: $input.description)
                DatePicker("Due Date", selection: $input.dueDate, displayedComponents: .date)
                TextField("Repeat Rule", text: $input.repeatRule)
            }

            // Optional: Show group selection if groupId is nil but projectId exists
            if groupId == nil && projectId != nil {
                Section(header: Text("Select Group")) {
                    // You can pass groups here from ProjectDetailView if needed
                    // For demo, just a text placeholder
                    Text("Please select a group to assign this task.")
                        .foregroundColor(.secondary)
                }
            }

            Button(action: createTask) {
                HStack {
                    Spacer()
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Save Task")
                            .bold()
                    }
                    Spacer()
                }
            }
            .disabled(isLoading)
        }
    }

    private func createTask() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let isoDueDate = ISO8601DateFormatter().string(from: input.dueDate)

                // Use groupId if available, else fail (or you could allow tasks without group)
                guard let validGroupId = groupId else {
                    onError("Group ID is required to create a task.")
                    return
                }

                _ = try await supabase
                    .from("tasks")
                    .insert(
                        [
                            "group_id": validGroupId,
                            "title": input.title,
                            "description": input.description,
                            "due_date": isoDueDate,
                            "repeat_rule": input.repeatRule
                        ]
                    )
                    .execute()

                onSuccess()

            } catch {
                onError(error.localizedDescription)
            }
        }
    }
}
