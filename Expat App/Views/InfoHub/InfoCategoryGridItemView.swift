//
//  InfoCategoryGridItemView.swift
//  Expat App
//
//  Created by Dominik Baki on 28.05.25.
//

import Foundation
import SwiftUI

struct InfoCategoryGridItemView: View {
    let category: InfoCategory // Nimmt eine InfoCategory als Input

    var body: some View {
        VStack {
            if let iconName = category.iconName {
                Image(systemName: iconName)
                    .font(.largeTitle) // Vergrößerte Icon-Größe
                    .foregroundColor(AppStyles.accentColor) // Akzentfarbe für Icons
                    .padding(.bottom, 5)
            }
            
            Text(category.title)
                .font(.headline)
                .foregroundColor(AppStyles.primaryTextColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if let subtitle = category.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppStyles.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            } else {
                Spacer(minLength: 20)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(AppStyles.cellBackgroundColor.opacity(0.5)) // Hintergrundfarbe für das Grid-Element
        .cornerRadius(15) // Abgerundete Ecken
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5) // Leichter Schatten
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppStyles.borderColor.opacity(0.8), lineWidth: 1) // Optional: Rand um das Element
        )
        .accessibilityElement(children: .combine)
    }
}
