import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 1

    @State private var project = ProjectInput()
    @State private var group = GroupInput()
    @State private var task = TaskInput()

    @State private var error: String?

    var body: some View {
        VStack(spacing: 24) {
            ProgressView(value: Double(currentStep), total: 3)
                .padding()

            Group {
                switch currentStep {
                case 1:
                    CreateProjectView(input: $project) {
                        self.currentStep += 1
                    } onError: { err in
                        self.error = err
                    }

                case 2:
                    CreateTaskGroupView(input: $group, projectId: project.id ?? "") {
                        self.currentStep += 1
                    } onError: { err in
                        self.error = err
                    }

                case 3:
                    CreateTaskView(input: $task, groupId: group.id ?? "") {
                        self.currentStep += 1
                    } onError: { err in
                        self.error = err
                    }

                default:
                    VStack(spacing: 16) {
                        Text("🎉 You're all set!")
                            .font(.title)
                        Button("Restart Onboarding") {
                            resetOnboarding()
                        }
                        .padding()
                        .background(Color.gardenGreen)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }

            if let e = error {
                Text(e)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Onboarding")
        .padding()
    }

    private func resetOnboarding() {
        project = ProjectInput()
        group = GroupInput()
        task = TaskInput()
        currentStep = 1
        error = nil
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
    }
}
