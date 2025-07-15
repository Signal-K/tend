//
// ArchiveView.swift
// Tend
//
// Updated by ChatGPT on 18/6/2025.
//

import SwiftUI
import Supabase

struct ArchiveProject: Identifiable, Decodable {
    let id: UUID?
    let name: String?
    let icon: String?
}

struct ArchiveGroup: Identifiable, Decodable {
    let id: UUID?
    let project_id: UUID?
    let name: String?
    let icon: String?
}

struct ArchiveTask: Identifiable, Decodable {
    let id: UUID?
    let group_id: UUID?
    let title: String?
    let notes: String?
}

struct ArchiveView: View {
    @State private var projects: [ArchiveProject] = []
    @State private var groups: [ArchiveGroup] = []
    @State private var tasks: [ArchiveTask] = []
    @State private var focusSessions: [FocusSession] = []

    @State private var isLoading = false
    @State private var errorMessage: String?

    private var totalFocusTime: TimeInterval {
        focusSessions.reduce(0) { $0 + $1.categoryTimes.values.reduce(0, +) }
    }

    private var totalBreakTime: TimeInterval {
        focusSessions.reduce(0) { $0 + $1.breakTime }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let totalMinutes = Int(interval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    ProgressView("Loading archive...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Text("Failed to load archive")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task { await loadArchive() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if projects.isEmpty && focusSessions.isEmpty {
                    Text("No archive data found.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 24) {
                        // New Focus Sessions Section at the top
                        if !focusSessions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Focus Sessions")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)

                                ForEach(focusSessions.sorted(by: { $0.date > $1.date })) { session in
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(session.date, style: .date)
                                            .font(.headline)

                                        // Category times
                                        ForEach(session.categoryTimes.sorted(by: { $0.key < $1.key }), id: \.key) { category, time in
                                            HStack {
                                                Text(category.capitalized)
                                                Spacer()
                                                Text(formatTime(time))
                                            }
                                            .font(.subheadline)
                                        }

                                        HStack {
                                            Text("Break Time")
                                            Spacer()
                                            Text(formatTime(session.breakTime))
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                        if !session.todos.isEmpty {
                                            Text("Todos: " + session.todos.joined(separator: ", "))
                                                .font(.footnote)
                                                .foregroundColor(.primary)
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                        }

                                        if !session.completedTodos.isEmpty {
                                            Text("Completed: " + session.completedTodos.joined(separator: ", "))
                                                .font(.footnote)
                                                .foregroundColor(.green)
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                        }
                                    }
                                    .padding()
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                }

                                // Totals
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Total Focus Time: \(formatTime(totalFocusTime))")
                                        .font(.headline)
                                    Text("Total Break Time: \(formatTime(totalBreakTime))")
                                        .font(.headline)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            Divider()
                                .padding(.vertical)
                        }

                        // Existing Projects & Groups & Tasks display

                        ForEach(projects) { project in
                            NavigationLink(destination: ProjectDetailView(project: project)) {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: project.icon ?? "folder")
                                        Text(project.name ?? "Unnamed Project")
                                            .font(.title2)
                                            .bold()
                                    }

                                    let projectGroups = groups.filter { $0.project_id == project.id }
                                    ForEach(projectGroups) { group in
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Image(systemName: group.icon ?? "folder")
                                                Text(group.name ?? "Unnamed Group")
                                                    .font(.headline)
                                            }

                                            let groupTasks = tasks.filter { $0.group_id == group.id }
                                            ForEach(groupTasks) { task in
                                                VStack(alignment: .leading, spacing: 4) {
                                                    HStack {
                                                        Circle()
                                                            .strokeBorder(Color.primary, lineWidth: 2)
                                                            .frame(width: 16, height: 16)
                                                        Text(task.title ?? "Untitled Task")
                                                            .font(.body)
                                                            .padding(.leading, 4)
                                                    }
                                                    if let notes = task.notes, !notes.isEmpty {
                                                        Text(notes)
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                            .padding(.leading, 24)
                                                    }
                                                }
                                                .padding(8)
                                                .background(Color(UIColor.systemGray6))
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.primary, lineWidth: 1)
                                                )
                                            }
                                        }
                                        .padding(.leading, 16)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primary, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Archive")
            .task {
                await loadArchive()
            }
            .refreshable {
                await loadArchive()
            }
        }
    }

    @MainActor
    func loadArchive() async {
        isLoading = true
        errorMessage = nil
        projects = []
        groups = []
        tasks = []
        focusSessions = []

        do {
            projects = try await supabase
                .from("projects")
                .select("id,name,icon")
                .order("name", ascending: true)
                .execute()
                .value

            groups = try await supabase
                .from("task_groups")
                .select("id,project_id,name,icon")
                .order("name", ascending: true)
                .execute()
                .value

            tasks = try await supabase
                .from("tasks")
                .select("id,group_id,title,notes")
                .order("title", ascending: true)
                .execute()
                .value

            // Load focus sessions from supabase table "focus_sessions"
            focusSessions = try await supabase
                .from("focus_sessions")
                .select("id,date,categoryTimes,breakTime,todos,completedTodos")
                .order("date", ascending: false)
                .execute()
                .value
                ?? []

        } catch {
            errorMessage = error.localizedDescription
            print("Error loading archive:", error)
        }

        isLoading = false
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView()
    }
}
