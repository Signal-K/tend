//
//  NeuStyle.swift
//  Tend
//
//  Created by Liam Arbuckle on 15/7/2025.
//

import SwiftUI
import Foundation

struct NeuomorphicStyle: ViewModifier {
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                Color.backgroundColor
                    .cornerRadius(cornerRadius)
                    .shadow(color: Color.white.opacity(0.7), radius: 4, x: -4, y: -4)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 4, y: 4)
            )
    }
}

extension View {
    func neuomorphicStyle(cornerRadius: CGFloat = 16) -> some View {
        self.modifier(NeuomorphicStyle(cornerRadius: cornerRadius))
    }
}
