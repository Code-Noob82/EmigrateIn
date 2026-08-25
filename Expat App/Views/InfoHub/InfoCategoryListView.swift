//
//  InfoCategoryListView.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import SwiftUI

struct InfoCategoryListView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var viewModel = InfoCategoryViewModel()
    @State private var showRegistrationPrompt = false
    @State private var tappedCategory: InfoCategory?
    let backgroundGradient = AppStyles.backgroundGradient
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(AppStyles.primaryTextColor)
                        
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(AppStyles.destructiveTextColor)
                                .padding(.bottom, 5)
                            
                            Text("Fehler")
                                .font(.headline)
                                .foregroundColor(AppStyles.primaryTextColor)
                            
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(AppStyles.secondaryTextColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button("Erneut versuchen") {
                                Task { await viewModel.fetchCategories() }
                            }
                            .padding(.top)
                            .buttonStyle(.borderedProminent)
                            .tint(AppStyles.buttonBackgroundColor)
                        }
                        .padding()
                    } else if viewModel.categories.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray.fill")
                                .font(.largeTitle)
                                .foregroundColor(AppStyles.secondaryTextColor)
                                .padding(.bottom, 5)
                            
                            Text("Keine Kategorien gefunden.")
                                .foregroundColor(AppStyles.secondaryTextColor)
                        }
                        .padding()
                    } else {
                        ScrollView {
                            let columns = [
                                GridItem(.adaptive(minimum: 150, maximum: 240), spacing: 16)
                            ]
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.categories) { category in
                                    NavigationLink(value: category) {
                                        InfoCategoryGridItemView(category: category)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(category.title)
                                    .accessibilityHint("Öffnet die Inhalte dieser Kategorie")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Info Kategorien")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(backgroundGradient, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
            .task(id: authViewModel.session?.id) {
                if authViewModel.isAuthenticated,
                   viewModel.categories.isEmpty,
                   viewModel.errorMessage == nil {
                    await viewModel.fetchCategories()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.fetchCategories() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppStyles.primaryTextColor)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationDestination(for: InfoCategory.self) { selectedCategory in
                InfoContentListView(category: selectedCategory)
            }
            .navigationDestination(for: InfoContent.self) { selectedContent in
                InfoContentDetailView(contentItem: selectedContent)
            }
        }
    }
}

#Preview("Info Category List") {
    InfoCategoryListView()
        .environmentObject(AuthenticationViewModel())
}
