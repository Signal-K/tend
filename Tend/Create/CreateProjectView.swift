//
//  CreateProjectView.swift
//  Tend
//
//  Created by Liam Arbuckle on 17/6/2025.
//

import SwiftUI
import Supabase

struct ProjectResponse: Codable {
    let id: String
}

struct CreateProjectView: View {
    @Binding var input: ProjectInput
    var onSuccess: () -> Void
    var onError: (String) -> Void

    @State private var isLoading = false

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Project Info")) {
                    TextField("Project Name", text: $input.name)
                    TextField("Icon (Emoji)", text: $input.icon)
                    TextField("Description", text: $input.description)
                    TextField("Category", text: $input.category)
                    DatePicker("Timeline", selection: $input.timeline, displayedComponents: .date)
                }
            }

            Button(action: {
                Task {
                    await createProject()
                }
            }) {
                Text("Save Project")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
//                    .background(isLoading ? Color.gray : Color.gardenGreen)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isLoading)
            .padding()
        }
        .navigationTitle("Create Project")
    }

    private func createProject() async {
        isLoading = true
        defer { isLoading = false }

        guard let user = try? await supabase.auth.session.user else {
            onError("User not authenticated.")
            return
        }

        do {
            let isoTimeline = ISO8601DateFormatter().string(from: input.timeline)

            let response = try await supabase
                .from("projects")
                .insert(
                    [
                        "owner_id": user.id.uuidString,
                        "name": input.name,
                        "icon": input.icon,
                        "description": input.description,
                        "category": input.category,
                        "timeline_date": isoTimeline
                    ],
                    returning: .representation
                )
                .select()
                .single()
                .execute()

            let insertedProject = try JSONDecoder().decode(ProjectResponse.self, from: response.data)

            input.id = insertedProject.id
            onSuccess()

        } catch {
            onError(error.localizedDescription)
        }
    }
}
