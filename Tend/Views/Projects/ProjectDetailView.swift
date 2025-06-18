//
//  ProjectDetailView.swift
//  Tend
//
//  Created by Liam Arbuckle on 18/6/2025.
//

import SwiftUI
import Supabase

struct ProjectDetailView: View {
    let project: ArchiveProject

    @State private var groups: [ArchiveGroup] = []
    @State private var tasks: [ArchiveTask] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var showAddOptions = false
    @State private var showingNewTaskGroupSheet = false

    // Now this is a tuple of group & flag so user can pick group before creating task
    @State private var showingNewTaskSheet = false
    @State private var selectedGroupForNewTask: ArchiveGroup?

    // Input binding for CreateTaskGroupView
    @State private var newGroupInput = GroupInput(id: nil, name: "", icon: "", description: "")

    @State private var newTaskInput = TaskInput(
        title: "",
        description: "",
        dueDate: Date(),
        repeatRule: ""
    )

    var filteredTasksByGroup: [[ArchiveTask]] {
        groups.map { group in
            tasks.filter { task in
                if let taskGroupId = task.group_id, let groupId = group.id {
                    return taskGroupId == groupId
                } else {
                    return false
                }
            }
        }
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                List {
                    ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                        Section(header: Label(group.name ?? "Unnamed Group", systemImage: group.icon ?? "folder")) {
                            ForEach(filteredTasksByGroup[index]) { task in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(task.title ?? "Untitled Task")
                                        .font(.body)
                                    if let notes = task.notes, !notes.isEmpty {
                                        Text(notes)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(6)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }

            // Bottom '+' button
            Button(action: {
                showAddOptions.toggle()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                    Text("Add")
                        .fontWeight(.semibold)
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.black)
                .clipShape(Capsule())
                .shadow(radius: 4)
            }
            .padding(.bottom)
            .confirmationDialog("Add", isPresented: $showAddOptions) {
                Button("New Task Group") {
                    newGroupInput = GroupInput(id: nil, name: "", icon: "", description: "")
                    showingNewTaskGroupSheet = true
                }
                Button("New Task") {
                    // Show UI to pick a group before creating task
                    if let firstGroup = groups.first {
                        selectedGroupForNewTask = firstGroup
                        newTaskInput = TaskInput(title: "", description: "", dueDate: Date(), repeatRule: "")
                        showingNewTaskSheet = true
                    } else {
                        // No groups, error or prompt user to create group first
                        errorMessage = "Please create a task group first."
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .navigationTitle(project.name ?? "Project")
        .task { await loadData() }
        .sheet(isPresented: $showingNewTaskGroupSheet) {
            createTaskGroupSheet
        }
        .sheet(isPresented: $showingNewTaskSheet) {
            if let group = selectedGroupForNewTask {
                CreateTaskView(
                    input: $newTaskInput,
                    groupId: group.id?.uuidString,
                    projectId: project.id?.uuidString,
                    onSuccess: {
                        showingNewTaskSheet = false
                        Task {
                            await loadData()
                        }
                    },
                    onError: { error in
                        showingNewTaskSheet = false
                        errorMessage = error
                    }
                )
                .presentationDetents([.medium])
            } else {
                Text("No group selected.")
                    .presentationDetents([.medium])
            }
        }
    }

    @MainActor
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load task groups
            let groupResponse: [ArchiveGroup] = try await supabase
                .from("task_groups")
                .select("id,project_id,name,icon")
                .eq("project_id", value: project.id)
                .execute()
                .value

            groups = groupResponse

            // Load tasks for these groups
            let groupIds = groupResponse.compactMap { $0.id }
            let taskResponse: [ArchiveTask] = try await supabase
                .from("tasks")
                .select("id,group_id,title,notes")
                .in("group_id", values: groupIds)
                .execute()
                .value

            tasks = taskResponse
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading project detail:", error)
        }

        isLoading = false
    }

    private var createTaskGroupSheet: some View {
        CreateTaskGroupView(
            input: $newGroupInput,
            projectId: project.id?.uuidString ?? "",
            onSuccess: {
                showingNewTaskGroupSheet = false
                Task {
                    await loadData()
                }
            },
            onError: { error in
                showingNewTaskGroupSheet = false
                errorMessage = error
            }
        )
        .presentationDetents([.medium])
    }
}
struct ProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProjectDetailView(project: ArchiveProject(
                id: UUID(),
                name: "Demo Project",
                icon: "folder"
            ))
        }
    }
}
