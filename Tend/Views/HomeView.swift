//
//  HomeView.swift
//  Tend
//
//  Created by Liam Arbuckle on 18/6/2025.
//

import SwiftUI
import Supabase

import SwiftUI
import Supabase

struct HomeView: View {
    @State private var tasks: [TaskWithGroupAndProject] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showCreateProject = false
    @State private var newProject = ProjectInput()

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if !todayTasks.isEmpty {
                        Section(header: Text("Today")) {
                            ForEach(todayTasks) { task in
                                TaskRow(task: task)
                            }
                        }
                    }
                    if !weekTasks.isEmpty {
                        Section(header: Text("This Week")) {
                            ForEach(weekTasks) { task in
                                TaskRow(task: task)
                            }
                        }
                    }
                    Section {
                        NavigationLink("View All Tasks", destination: AllTasksView(tasks: tasks))
                    }
                }
                .listStyle(.insetGrouped)
                .task {
                    await loadTasks()
                }

                Button("Create Project") {
                    showCreateProject = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gardenGreen)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding([.leading, .trailing, .bottom])
            }
            .navigationTitle("Home")
            .overlay {
                if isLoading {
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
            .sheet(isPresented: $showCreateProject) {
                NavigationStack {
                    CreateProjectView(
                        input: $newProject,
                        onSuccess: {
                            showCreateProject = false
                        },
                        onError: { _ in
                            showCreateProject = false
                        }
                    )
                }
            }
        }
    }

    private var todayTasks: [TaskWithGroupAndProject] {
        tasks.filter { Calendar.current.isDateInToday($0.due_date ?? Date()) }
    }

    private var weekTasks: [TaskWithGroupAndProject] {
        tasks.filter {
            let due = $0.due_date ?? Date()
            return Calendar.current.isDate(due, equalTo: Date(), toGranularity: .weekOfYear) && !Calendar.current.isDateInToday(due)
        }
    }

    @MainActor
    func loadTasks() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await supabase
                .from("tasks")
                .select("""
                    id,
                    title,
                    due_date,
                    group:task_groups (
                      id,
                      name,
                      icon,
                      project:projects (
                        id,
                        name,
                        icon
                      )
                    )
                """)
                .order("due_date", ascending: true)
                .execute()

            let decodedTasks = try JSONDecoder().decode([TaskWithGroupAndProject].self, from: response.data)
            tasks = decodedTasks
        } catch {
            self.error = error
        }
    }
}

struct TaskRow: View {
    let task: TaskWithGroupAndProject

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button(action: {}) {
                Image(systemName: "circle")
                    .foregroundColor(.green)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                HStack {
                    if let g = task.group {
                        Text(g.icon)
                        Text(g.project?.name ?? "")
                            .font(.caption)
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
                if let due = task.due_date {
                    Text(due, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AllTasksView: View {
    let tasks: [TaskWithGroupAndProject]

    var body: some View {
        List(tasks) { task in
            TaskRow(task: task)
        }
        .navigationTitle("All Tasks")
        .listStyle(.plain)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
