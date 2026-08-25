//
//  ChecklistItemGridItemView.swift
//  Expat App
//
//  Created by Dominik Baki on 28.05.25.
//

import SwiftUI

struct ChecklistItemGridItemView: View {
    let item: ChecklistItem
    @ObservedObject var viewModel: ChecklistViewModel // Muss übergeben werden, um isItemCompleted zu prüfen
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Checkbox-Icon: Verwendet viewModel.isItemCompleted(item)
                Image(systemName: viewModel.isItemCompleted(item) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(viewModel.isItemCompleted(item) ? AppStyles.accentColor : AppStyles.secondaryTextColor.opacity(0.7))
                    .font(.title2)
                
                // Titel: Verwendet `item.text`
                Text(item.text)
                    .font(.subheadline)
                    .foregroundColor(AppStyles.primaryTextColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            // Details/Beschreibung: Verwendet `item.details`
            if let details = item.details, !details.isEmpty {
                Text(details)
                    .font(.caption2)
                    .foregroundColor(AppStyles.secondaryTextColor)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            } else {
                Spacer(minLength: 10) // Platzhalter, falls keine Details vorhanden sind
            }
            
            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(AppStyles.cellBackgroundColor.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                    // Randfarbe je nach Status: Verwendet viewModel.isItemCompleted(item)
                        .stroke(viewModel.isItemCompleted(item) ? AppStyles.accentColor : AppStyles.borderColor.opacity(0.8), lineWidth: viewModel.isItemCompleted(item) ? 2 : 1)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 3)
        // Animation beim Umschalten: Verwendet viewModel.isItemCompleted(item)
        .animation(.easeOut, value: viewModel.isItemCompleted(item))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.text)
        .accessibilityValue(viewModel.isItemCompleted(item) ? "Erledigt" : "Nicht erledigt")
        .accessibilityHint("Doppeltippen, um den Status zu ändern")
    }
}

//#Preview {
//    ChecklistItemGridItemView()
//}
