//
//  AuthView.swift
//  Tend
//
//  Created by Liam Arbuckle on 17/6/2025.
//

import SwiftUI
import Supabase

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var result: Result<Void, Error>?

    var body: some View {
        ZStack {
            Color.backgroundWhite.ignoresSafeArea()

            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("Tend")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.gardenGreen)

                    Text(isSignUp ? "Create your account" : "Grow your focus")
                        .font(.subheadline)
                        .foregroundColor(.textPrimary)
                }

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color.surfaceGray)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gardenGreen, lineWidth: 1.5)
                        )

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color.surfaceGray)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gardenGreen, lineWidth: 1.5)
                        )

                    Button(action: authButtonTapped) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.gardenGreen)
                            } else {
                                Text(isSignUp ? "Sign Up" : "Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.backgroundWhite)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gardenGreen, lineWidth: 2)
                        )
                    }
                    .disabled(email.isEmpty || password.isEmpty || isLoading)

                    Button(action: { isSignUp.toggle() }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.footnote)
                            .foregroundColor(.gardenGreen)
                            .underline()
                    }
                    .padding(.top, 8)
                }

                if let result = result {
                    VStack {
                        switch result {
                        case .success:
                            Text(isSignUp ? "🌱 Account created!" : "🌿 Signed in successfully!")
                                .foregroundColor(.gardenGreen)
                        case .failure(let error):
                            Text(error.localizedDescription)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.surfaceGray)
                    .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: 400)
        }
    }

    func authButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                if isSignUp {
                    try await supabase.auth.signUp(email: email, password: password)
                } else {
                    try await supabase.auth.signIn(email: email, password: password)
                }
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
    }
}

#Preview {
    AuthView()
}
