//
//  CreateProfileViewModel.swift
//  Koda
//
//  Created by ADMIN UNACH on 21/09/26.
//

import SwiftUI
import SwiftData
import UIKit

struct CreateProfileView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = CreateProfileViewModel()
    @FocusState private var isNameFocused: Bool

    @ScaledMetric(relativeTo: .body)
    private var avatarSize = 56

    private let blue = Color(
        red: 0.10,
        green: 0.42,
        blue: 1
    )

    private let ink = Color(
        red: 0.04,
        green: 0.09,
        blue: 0.24
    )

    private let secondaryInk = Color(
        red: 0.28,
        green: 0.35,
        blue: 0.48
    )

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                introduction
                selectedAvatar
                avatarPicker
                nameField

                if let message = viewModel.errorMessage {
                    Label(
                        message,
                        systemImage: "exclamationmark.circle"
                    )
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .frame(maxWidth: 460)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            footer
        }
        .background {
            LinearGradient(
                colors: [
                    .white,
                    Color(red: 0.95, green: 0.97, blue: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .foregroundStyle(ink)
        .tint(blue)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .onAppear {
            viewModel.loadProfile(using: modelContext)
        }
    }

    // MARK: - Encabezado

    private var introduction: some View {
        VStack(spacing: 10) {
            Text("Crea tu perfil")
                .font(.title)
                .bold()
                .foregroundStyle(ink)
                .accessibilityAddTraits(.isHeader)

            Text("Personaliza tu experiencia en Koda")
                .font(.subheadline)
                .foregroundStyle(secondaryInk)
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - Avatar principal

    private var selectedAvatar: some View {
        VStack(spacing: 12) {
            Group {
                if let avatar = viewModel.selectedAvatar {
                    avatarImage(avatar)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(blue.opacity(0.45))
                }
            }
            .padding(12)
            .frame(width: 144, height: 144)
            .background {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.89, green: 0.91, blue: 1),
                                Color(red: 0.76, green: 0.82, blue: 1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(Circle())
            .accessibilityHidden(true)

            Text("Elige tu avatar")
                .font(.subheadline)
                .foregroundStyle(secondaryInk)
        }
    }

    // MARK: - Selector de avatares

    private var avatarPicker: some View {
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: avatarSize + 12),
                    spacing: 10
                )
            ],
            spacing: 16
        ) {
            ForEach(ProfileAvatar.allCases) { avatar in
                avatarButton(avatar)
            }
        }
    }

    private func avatarButton(
        _ avatar: ProfileAvatar
    ) -> some View {
        let isSelected = viewModel.selectedAvatar == avatar

        return Button {
            viewModel.selectedAvatar = avatar
        } label: {
            VStack(spacing: 8) {
                avatarImage(avatar)
                    .padding(5)
                    .frame(
                        width: avatarSize,
                        height: avatarSize
                    )
                    .background {
                        Circle()
                            .fill(blue.opacity(0.08))
                    }
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .strokeBorder(
                                isSelected ? blue : .clear,
                                lineWidth: 2
                            )
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.white, blue)
                                .background(.white, in: Circle())
                        }
                    }

                Text(avatar.displayName)
                    .font(.caption)
                    .foregroundStyle(
                        isSelected ? blue : secondaryInk
                    )
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Avatar \(avatar.displayName)")
        .accessibilityAddTraits(
            isSelected ? [.isSelected] : []
        )
    }

    @ViewBuilder
    private func avatarImage(
        _ avatar: ProfileAvatar
    ) -> some View {
        if let image = UIImage(named: avatar.rawValue) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(blue.opacity(0.5))
        }
    }

    // MARK: - Campo de nombre

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tu nombre")
                .font(.subheadline)
                .foregroundStyle(secondaryInk)

            TextField(
                "",
                text: $viewModel.name,
                prompt: Text("Escribe tu nombre")
                    .foregroundStyle(secondaryInk)
            )
            .font(.body)
            .foregroundStyle(ink)
            .tint(blue)
            .textContentType(.givenName)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .focused($isNameFocused)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                .white,
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        isNameFocused ? blue : blue.opacity(0.2),
                        lineWidth: 1
                    )
            }
            .accessibilityLabel("Tu nombre")
            .onSubmit {
                saveProfile()
            }

            if let message = viewModel.nameValidationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    // MARK: - Botón y privacidad

    private var footer: some View {
        VStack(spacing: 18) {
            Button(action: saveProfile) {
                Text("Continuar")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(
                                viewModel.canSave
                                    ? blue
                                    : Color(
                                        red: 0.35,
                                        green: 0.42,
                                        blue: 0.54
                                    )
                            )
                    }
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canSave)

            Label(
                "Tus datos se guardan en este dispositivo.",
                systemImage: "lock.fill"
            )
            .font(.caption)
            .foregroundStyle(secondaryInk)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .frame(maxWidth: 460)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Guardado

    private func saveProfile() {
        guard viewModel.canSave else {
            return
        }

        isNameFocused = false

        // ContentView cambia de etapa al observar el perfil guardado.
        _ = viewModel.saveProfile(using: modelContext)
    }
}

#Preview {
    NavigationStack {
        CreateProfileView()
    }
    .preferredColorScheme(.light)
    .modelContainer(
        for: StudentProfile.self,
        inMemory: true
    )
}
