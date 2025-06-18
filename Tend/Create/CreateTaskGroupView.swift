//
//  CreateTaskGroupView.swift
//  Tend
//
//  Created by Liam Arbuckle on 17/6/2025.
//

import SwiftUI
import Supabase

struct TaskGroupResponse: Codable {
    let id: String
}

struct CreateTaskGroupView: View {
    @Binding var input: GroupInput
    var projectId: String
    var onSuccess: () -> Void
    var onError: (String) -> Void

    @State private var isLoading = false

    var body: some View {
        Form {
            Section(header: Text("Task Group Info")) {
                TextField("Title", text: $input.name)
                TextField("Icon (Emoji)", text: $input.icon)
                TextField("Description", text: $input.description)
            }

            Button(action: {
                Task {
                    await createGroup()
                }
            }) {
                HStack {
                    Spacer()
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Save Task Group")
                            .bold()
                    }
                    Spacer()
                }
            }
            .disabled(isLoading)
        }
    }

    private func createGroup() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await supabase
                .from("task_groups")
                .insert(
                    [
                        "project_id": projectId,
                        "name": input.name,
                        "icon": input.icon,
                        "description": input.description
                    ],
                    returning: .representation
                )
                .select()
                .single()
                .execute()

            guard let jsonData = try? JSONSerialization.data(withJSONObject: response.value ?? [:]),
                  let insertedGroup = try? JSONDecoder().decode(TaskGroupResponse.self, from: jsonData) else {
                onError("Failed to decode task group response.")
                return
            }

            input.id = insertedGroup.id
            onSuccess()

        } catch {
            onError(error.localizedDescription)
        }
    }
}
