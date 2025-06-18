//
// ArchiveView.swift
// Tend
//
// Created by Liam Arbuckle on 18/6/2025.
//

import SwiftUI
import Supabase

struct ArchiveProject: Identifiable, Decodable {
    let id: UUID?
    let name: String?
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case id, name, icon
    }
}

struct ArchiveView: View {
    @State private var projects: [ArchiveProject] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading projects...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Text("Failed to load projects")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task { await loadProjects() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if projects.isEmpty {
                    Text("No projects found")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(projects) { project in
                        Label(project.name ?? "Unnamed Project", systemImage: project.icon ?? "folder")
                    }
                    .listStyle(.plain)
                    .navigationTitle("Projects")
                    .refreshable {
                        await loadProjects()
                    }
                }
            }
            .task {
                await loadProjects()
            }
        }
    }

    @MainActor
    func loadProjects() async {
        isLoading = true
        errorMessage = nil
        projects = []

        do {
            let response: [ArchiveProject] = try await supabase
                .from("projects")
                .select("id,name,icon")
                .execute()
                .value

            projects = response
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading projects:", error)
        }

        isLoading = false
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView()
    }
}
