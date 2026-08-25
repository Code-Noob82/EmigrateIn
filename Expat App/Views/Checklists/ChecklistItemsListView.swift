//
//  ChecklistItemsListView.swift
//  Expat App
//
//  Created by Dominik Baki on 21.05.25.
//

import SwiftUI
import MarkdownUI

struct ChecklistItemsListView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel // Für Authentifizierungsstatus
    @StateObject var viewModel: ChecklistViewModel // Wird für diese View initialisiert
    
    let categoryId: String // Die ID der Kategorie, die von der vorherigen View übergeben wird
    let backgroundGradient = AppStyles.backgroundGradient
    
    // Initializer für @StateObject, um categoryId zu übergeben
    init(categoryId: String) {
        self.categoryId = categoryId
        _viewModel = StateObject(wrappedValue: ChecklistViewModel(categoryId: categoryId))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient // Hintergrundgradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if let description = viewModel.categoryDescription {
                            Markdown(description)
                                .markdownTheme(.basic)
                                .font(.body)
                                .foregroundColor(AppStyles.primaryTextColor)
                                .padding(.horizontal)
                                .padding(.top, 10)
                        }
                        // Ladezustand des ViewModels
                        if viewModel.isLoading && viewModel.items.isEmpty {
                            LoadingIndicatorView(message: "Lade Checklisten...")
                                .padding(.top, 20)
                                .frame(maxWidth: .infinity)
                                .background(Color.clear)
                            
                        } else if let errorMessage = viewModel.errorMessage {
                            ErrorDisplayView(title: "Fehler", message: errorMessage) {
                                Task { await viewModel.fetchChecklistItemsAndCategoryDetails() } // Items neu laden
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.clear)
                            
                        } else if viewModel.items.isEmpty && !viewModel.isLoading {
                            EmptyCategoriesMessageView(message: "Keine Items in der Checkliste gefunden", iconName: "tray.fill")
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.clear)
                            
                        } else {
                            contentView
                        }
                    }
                }
            }
            .navigationTitle(viewModel.categoryTitle ?? "Checkliste")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.fetchChecklistItemsAndCategoryDetails()}
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppStyles.primaryTextColor)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .toolbarBackground(backgroundGradient, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
            .onAppear {
                Task {
                    await viewModel.fetchChecklistItemsAndCategoryDetails()
                }
            }
            
        }
    }
    
    // MARK: - content View (bleibt als Computed Property)
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Gesamtfortschrittsbalken
            overallProgressBar
            
            // Checklisten-Items direkt im Grid (ohne Unterkategorien)
            let columns = [
                GridItem(.adaptive(minimum: 150, maximum: 260), spacing: 16)
            ]
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.items) { item in
                    Button {
                        Task {
                            await viewModel.toggleItemCompletion(item: item)
                        }
                    } label: {
                        ChecklistItemGridItemView(item: item, viewModel: viewModel)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Overall Progress Bar View (bleibt als Computed Property)
    private var overallProgressBar: some View {
        VStack(alignment: .leading) {
            Text("Gesamtfortschritt")
                .font(.subheadline)
                .foregroundColor(AppStyles.secondaryTextColor)
            HStack {
                ProgressView(value: viewModel.totalProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppStyles.primaryTextColor))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .animation(.easeOut, value: viewModel.totalProgress)
            }
            .padding(.top, 5)
            .padding(.bottom, 5)
            .frame(maxWidth: .infinity)
            .background(AppStyles.cellBackgroundColor.opacity(0.5))
            Text("\(viewModel.totalCompletedItems) von \(viewModel.totalItems) erledigt")
                .font(.caption)
                .foregroundColor(AppStyles.secondaryTextColor)
                .padding(.top, 5)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

//#Preview("ChecklistItemsListView") {
//    ChecklistItemsListView(categoryId: "some_test_category_id")
//        .environmentObject(AuthenticationViewModel())
//}
