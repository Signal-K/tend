//
//  SessionTimer.swift
//  Tend
//
//  Created by Liam Arbuckle on 15/7/2025.
//

import SwiftUI

struct SessionTimerView: View {
    @Binding var currentCategory: String
    let categories: [String]
    let elapsedFocusTime: TimeInterval
    let elapsedBreakTime: TimeInterval
    let isOnBreak: Bool
    
    let toggleBreakAction: () -> Void
    let endSessionAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Focus Session")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.foregroundColor)
            
            Picker("Current Category", selection: $currentCategory) {
                ForEach(categories, id: \.self) { cat in
                    Text(cat.capitalized).tag(cat)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color.backgroundColor)
            .cornerRadius(20)
            .neuomorphicStyle()
            
            Text(formatTime(elapsedFocusTime))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.primaryColor)
                .accessibilityLabel("Focus time elapsed")
            
            Text(formatTime(elapsedBreakTime))
                .font(.headline)
                .foregroundColor(.secondaryColor)
                .accessibilityLabel("Break time elapsed")
            
            HStack(spacing: 40) {
                Button(action: toggleBreakAction) {
                    Text(isOnBreak ? "Resume Focus" : "Take Break")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(Color.accentForeground)
                        .cornerRadius(20)
                        .neuomorphicStyle(cornerRadius: 20)
                }
                
                Button(action: endSessionAction) {
                    Text("End Session")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.secondaryColor)
                        .foregroundColor(Color.secondaryForeground)
                        .cornerRadius(20)
                        .neuomorphicStyle(cornerRadius: 20)
                }
            }
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let intSec = Int(interval)
        let m = intSec / 60
        let s = intSec % 60
        return String(format: "%02d:%02d", m, s)
    }
}
