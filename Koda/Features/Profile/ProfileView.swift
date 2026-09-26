//
//  ProfileView.swift
//  Koda
//
//  Created by ADMIN UNACH on 24/09/26.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    let profile: StudentProfile
    let onShowProgress: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Mi perfil")
                    .font(
                        .system(
                            .title,
                            design: .rounded,
                            weight: .bold
                        )
                    )
                    .accessibilityAddTraits(.isHeader)

                profileSummary

                menuButton(
                    title: "Editar nombre y avatar",
                    symbol: "person.crop.circle"
                ) {
                    isEditing = true
                }

                menuButton(
                    title: "Ver mi progreso",
                    symbol: "chart.bar",
                    action: onShowProgress
                )

                KodaTeacherMessage(
                    message: """
                    Este es tu espacio. Sigue aprendiendo \
                    a tu ritmo.
                    """
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Acerca de Koda")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    Label(
                        "Tu perfil y tu progreso se guardan en este dispositivo.",
                        systemImage: "lock"
                    )
                    .font(.subheadline)
                    .foregroundStyle(KodaPalette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .kodaPanel()
            }
            .padding(24)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .kodaScreen()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                ProfileEditorSheet(profile: profile)
            }
        }
    }

    // MARK: - Perfil guardado

    private var profileSummary: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(
                VStackLayout(alignment: .leading, spacing: 16)
            )
            : AnyLayout(
                HStackLayout(spacing: 16)
            )

        return layout {
            ProfilePortrait(
                avatar: ProfileAvatar(
                    rawValue: profile.avatarName
                ) ?? .alex
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(profile.name)
                    .font(.title2.bold())

                Text("Aprende, practica y descubre.")
                    .font(.subheadline)
                    .foregroundStyle(KodaPalette.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
    }

    private func menuButton(
        title: String,
        symbol: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.title2)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(KodaPalette.blue)
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 52)
            .kodaPanel()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Edición del perfil

private struct ProfileEditorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @FocusState private var isNameFocused: Bool
    @State private var viewModel: CreateProfileViewModel

    init(profile: StudentProfile) {
        let draft = CreateProfileViewModel()
        draft.name = profile.name
        draft.selectedAvatar = ProfileAvatar(
            rawValue: profile.avatarName
        )

        _viewModel = State(initialValue: draft)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                nameField

                Text("Elige tu avatar")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                LazyVGrid(
                    columns: [
                        GridItem(
                            .adaptive(minimum: 110),
                            spacing: 16
                        )
                    ],
                    spacing: 20
                ) {
                    ForEach(ProfileAvatar.allCases) { avatar in
                        avatarButton(avatar)
                    }
                }

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
            .padding(24)
            .frame(maxWidth: 460)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            KodaPrimaryAction(
                title: "Guardar cambios",
                symbol: "checkmark",
                isEnabled: viewModel.canSave,
                action: save
            )
            .padding(24)
            .frame(maxWidth: 460)
            .frame(maxWidth: .infinity)
            .background(.white)
        }
        .kodaScreen()
        .navigationTitle("Editar perfil")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar", role: .cancel) {
                    dismiss()
                }
                .disabled(viewModel.isSaving)
            }
        }
        .interactiveDismissDisabled(viewModel.isSaving)
    }

    // MARK: - Nombre

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tu nombre")
                .font(.headline)

            TextField(
                "Escribe tu nombre",
                text: $viewModel.name
            )
            .textContentType(.givenName)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .focused($isNameFocused)
            .padding(18)
            .kodaPanel()
            .accessibilityLabel("Tu nombre")
            .onSubmit {
                save()
            }

            if let message = viewModel.nameValidationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    // MARK: - Selección del avatar

    private func avatarButton(
        _ avatar: ProfileAvatar
    ) -> some View {
        let selected = viewModel.selectedAvatar == avatar

        return Button {
            viewModel.selectedAvatar = avatar
        } label: {
            VStack(spacing: 10) {
                ProfilePortrait(avatar: avatar)
                    .overlay {
                        Circle()
                            .strokeBorder(
                                selected
                                    ? KodaPalette.blue
                                    : .clear,
                                lineWidth: 3
                            )
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if selected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(
                                    .white,
                                    KodaPalette.blue
                                )
                                .background(.white, in: Circle())
                        }
                    }

                Text(avatar.displayName)
                    .font(.subheadline)
                    .foregroundStyle(
                        selected
                            ? KodaPalette.blue
                            : KodaPalette.secondary
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
            selected ? [.isSelected] : []
        )
    }

    // MARK: - Guardado

    private func save() {
        guard viewModel.canSave else {
            return
        }

        isNameFocused = false

        if viewModel.saveProfile(using: modelContext) {
            dismiss()
        }
    }
}

// MARK: - Retrato usado en esta pantalla

private struct ProfilePortrait: View {
    let avatar: ProfileAvatar

    var body: some View {
        Image(avatar.rawValue)
            .resizable()
            .scaledToFill()
            .frame(width: 88, height: 88)
            .scaleEffect(1.1)
            .background(
                KodaPalette.paleBlue,
                in: Circle()
            )
            .clipShape(Circle())
            .accessibilityHidden(true)
    }
}

// MARK: - Vista previa con datos temporales

private struct ProfilePreviewHost: View {
    @Environment(\.modelContext) private var modelContext
    @State private var profile: StudentProfile?

    var body: some View {
        Group {
            if let profile {
                NavigationStack {
                    ProfileView(
                        profile: profile,
                        onShowProgress: {}
                    )
                }
            } else {
                ProgressView("Preparando perfil…")
            }
        }
        .task {
            guard profile == nil else {
                return
            }

            let student = StudentProfile(
                name: "Alex",
                avatarName: ProfileAvatar.alex.rawValue
            )

            modelContext.insert(student)
            profile = student
        }
    }
}

#Preview {
    ProfilePreviewHost()
        .preferredColorScheme(.light)
        .modelContainer(
            for: [
                StudentProfile.self,
                TopicProgress.self
            ],
            inMemory: true
        )
}
