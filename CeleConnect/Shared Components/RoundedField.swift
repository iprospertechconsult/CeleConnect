//
//  RoundedField.swift
//  CeleConnect
//
//  Created by Deborah on 1/7/26.
//

import SwiftUI

struct RoundedField: View {

    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {

            // Placeholder
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.7)) // 👈 WHITE PLACEHOLDER
                    .padding(.horizontal, 16)
            }

            // Text Field
            if isSecure {
                SecureField("", text: $text)
                    .foregroundColor(.white)               // 👈 WHITE TEXT
                    .padding()
            } else {
                TextField("", text: $text)
                    .foregroundColor(.white)               // 👈 WHITE TEXT
                    .padding()
            }
        }
        .background(Color.white.opacity(0.15))
        .cornerRadius(30)
    }
}
