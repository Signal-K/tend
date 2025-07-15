//
//  FocusMode.swift
//  Tend
//
//  Created by Liam Arbuckle on 15/7/2025.
//

import SwiftUI

struct FocusSessionView: View {
    @State private var categories: [String] = ["Work", "Study", "Exercise"]
    @State private var selectedCategory: String = "Work"
    @State private var newCategoryName: String = ""
    
    @State private var todos: [Todo] = []
    @State private var newTodo: String = ""
    
    @State private var elapsedFocusTime: TimeInterval = 0
    @State private var elapsedBreakTime: TimeInterval = 0
    @State private var isOnBreak: Bool = false
    
    @State private var showEndSessionSheet = false
    @State private var showPreviousSessionsSheet = false
    
    @State private var previousSessions: [FocusSession] = []
    
    @State private var isSessionActive: Bool = false
    
    // Persisted todos, sessions, and categories in UserDefaults
    @AppStorage("persistedTodos") private var persistedTodosData: Data = Data()
    @AppStorage("previousSessions") private var previousSessionsData: Data = Data()
    @AppStorage("persistedCategories") private var persistedCategoriesData: Data = Data()
    
    // Timer
    @State private var timer: Timer? = nil
    
    // Store completed tasks selected at session end
    @State private var sessionCompletedTasks: [Todo] = []
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if isOnBreak {
                elapsedBreakTime += 1
            } else {
                elapsedFocusTime += 1
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func addCategory() {
        let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty, !categories.contains(trimmed) else { return }
        categories.append(trimmed)
        selectedCategory = trimmed
        newCategoryName = ""
        saveCategoriesToStorage()
    }
    
    func addTodo() {
        let trimmed = newTodo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newTodoItem = Todo(title: trimmed, category: selectedCategory)
        todos.append(newTodoItem)
        saveTodosToStorage()
        newTodo = ""
    }
    
    func saveTodosToStorage() {
        if let encoded = try? JSONEncoder().encode(todos) {
            persistedTodosData = encoded
        }
    }
    
    func loadTodosFromStorage() {
        if let decoded = try? JSONDecoder().decode([Todo].self, from: persistedTodosData) {
            todos = decoded
        }
    }
    
    func saveSessionsToStorage() {
        if let encoded = try? JSONEncoder().encode(previousSessions) {
            previousSessionsData = encoded
        }
    }
    
    func loadSessionsFromStorage() {
        if let decoded = try? JSONDecoder().decode([FocusSession].self, from: previousSessionsData) {
            previousSessions = decoded
        }
    }
    
    func saveCategoriesToStorage() {
        if let encoded = try? JSONEncoder().encode(categories) {
            persistedCategoriesData = encoded
        }
    }
    
    func loadCategoriesFromStorage() {
        if let decoded = try? JSONDecoder().decode([String].self, from: persistedCategoriesData) {
            categories = decoded
            if !categories.contains(selectedCategory), let first = categories.first {
                selectedCategory = first
            }
        }
    }
    
    func toggleBreak() {
        isOnBreak.toggle()
    }
    
    func endSession() {
        stopTimer()
        isSessionActive = false
        showEndSessionSheet = true
    }
    
    func saveSession(completedTasks: [Todo]) {
        var categoryTimes = [String: TimeInterval]()
        categoryTimes[selectedCategory] = elapsedFocusTime
        
        let newSession = FocusSession(
            id: UUID(),
            date: Date(),
            categoryTimes: categoryTimes,
            breakTime: elapsedBreakTime,
            todos: todos.map { $0.title },                 // convert todos to [String]
            completedTodos: completedTasks.map { $0.title } // convert completedTasks to [String]
        )
        previousSessions.append(newSession)
        saveSessionsToStorage()
        
        // Reset session state
        elapsedFocusTime = 0
        elapsedBreakTime = 0
        todos.removeAll()
        saveTodosToStorage()
        isOnBreak = false
        showEndSessionSheet = false
    }
    
    var body: some View {
        ZStack {
            Color.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                if isSessionActive {
                    SessionTimerView(
                        currentCategory: $selectedCategory,
                        categories: categories,
                        elapsedFocusTime: elapsedFocusTime,
                        elapsedBreakTime: elapsedBreakTime,
                        isOnBreak: isOnBreak,
                        toggleBreakAction: toggleBreak,
                        endSessionAction: endSession
                    )
                } else {
                    CategoryPickerView(
                        categories: $categories,
                        selectedCategory: $selectedCategory,
                        newCategoryName: $newCategoryName,
                        todos: $todos,
                        newTodo: $newTodo,
                        addCategoryAction: addCategory,
                        addTodoAction: addTodo
                    )
                    
                    Button("Start Focus Session") {
                        isSessionActive = true
                        startTimer()
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.primaryColor)
                    .foregroundColor(Color.primaryForeground)
                    .cornerRadius(12)
                    .neuomorphicStyle()
                }
                
                Button("Show Previous Sessions") {
                    showPreviousSessionsSheet = true
                }
                .padding()
                .foregroundColor(.primaryColor)
            }
            .padding()
        }
        .onAppear {
            loadTodosFromStorage()
            loadSessionsFromStorage()
            loadCategoriesFromStorage()
        }
        .sheet(isPresented: $showEndSessionSheet) {
            // Pass completedTasks binding so EndSessionSheetView can update it
            EndSessionSheetView(
                elapsedFocusTime: $elapsedFocusTime,
                elapsedBreakTime: $elapsedBreakTime,
                todos: $todos,
                completedTasks: $sessionCompletedTasks,
                newCompletedTask: .constant(""),
                endSessionAction: {
                    saveSession(completedTasks: sessionCompletedTasks)
                }
            )
        }
        .sheet(isPresented: $showPreviousSessionsSheet) {
            PreviousSessionsSheetView(isPresented: $showPreviousSessionsSheet)
        }
    }
}

struct FocusSessionView_Previews: PreviewProvider {
    static var previews: some View {
        FocusSessionView()
    }
}
