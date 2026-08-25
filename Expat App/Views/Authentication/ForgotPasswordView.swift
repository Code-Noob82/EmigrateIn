//
//  ForgotPasswordView.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//

import SwiftUI

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        ZStack {
            AppStyles.backgroundGradient
                .ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Gib deine E-Mail-Adresse ein, \num einen Link zum Zurücksetzen deines Passworts zu erhalten.")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppStyles.secondaryTextColor)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        TextField("E-Mail Adresse", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(20)
                        
                        Button {
                            Task { await viewModel.forgotPassword() }
                        } label: {
                            Image(systemName: "envelope.circle.fill")
                            Text("Link senden")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppStyles.buttonBackgroundColor)
                        .foregroundColor(AppStyles.buttonTextColor)
                        .clipShape(Capsule())
                        .disabled(viewModel.isLoading)
                    }
                    .padding()
                    .safeAreaInset(edge: .bottom) { // Optional: Wenn der Spacer am Ende der ScrollView nicht reicht, um den Footer frei zu halten
                        Color.clear.frame(height: 70) // Höhe des Footers + etwas Puffer
                    }
                }
                // Fixierter Footer
                HStack {
                    Text("Passwort nicht vergessen?")
                        .font(.subheadline)
                        .foregroundColor(AppStyles.secondaryTextColor)
                    Button("Zurück zum Login") {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewModel.currentAuthView = .login
                        }
                    }
                    .buttonStyle(TextLinkButtonStyle(textColor: AppStyles.primaryTextColor))
                }
                .padding() // Padding für den Footer selbst
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .overlay { // Zeigt Ladeindikator
            if viewModel.isLoading {
                ProgressView()
                    .tint(AppStyles.primaryTextColor)
            }
        }
    }
}

#Preview("Forgot Password View") {
    ForgotPasswordView()
        .environmentObject(AuthenticationViewModel())
}
