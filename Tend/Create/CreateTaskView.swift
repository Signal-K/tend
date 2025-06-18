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
    var groupId: String
    var onSuccess: () -> Void
    var onError: (String) -> Void

    @State private var isLoading = false

    var body: some View {
        Form {
            Section(header: Text("Task Info")) {
                TextField("Title", text: $input.title)
                TextField("Description", text: $input.description)
                DatePicker("Due Date", selection: $input.dueDate, displayedComponents: .date)
                TextField("Repeat Rule", text: $input.repeatRule)
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

                _ = try await supabase
                    .from("tasks")
                    .insert(
                        [
                            "group_id": groupId,
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
