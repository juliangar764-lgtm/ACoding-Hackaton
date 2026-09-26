//
//  KnowledgeCheckView.swift
//  Koda
//
//  Created by ADMIN UNACH on 22/09/26.
//

import SwiftUI
import SwiftData

struct KnowledgeCheckView: View {
    let profile: StudentProfile

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = KnowledgeCheckViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                KodaStepDots(current: 1)
                    .padding(.top, 12)

                introduction
                experienceOptions

                KodaTeacherMessage(message: teacherMessage)

                if let message = viewModel.errorMessage {
                    Label(
                        message,
                        systemImage: "exclamationmark.circle"
                    )
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            continueButton
        }
        .kodaScreen()
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Encabezado

    private var introduction: some View {
        VStack(spacing: 10) {
            Text("Antes de empezar")
                .font(
                    .system(
                        .title,
                        design: .rounded,
                        weight: .bold
                    )
                )
                .accessibilityAddTraits(.isHeader)

            Text(
                "Esto nos ayudará a personalizar tu experiencia de aprendizaje."
            )
            .font(.subheadline)
            .foregroundStyle(KodaPalette.secondary)
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Opciones

    private var experienceOptions: some View {
        VStack(spacing: 16) {
            Text("¿Conoces las bases de programación?")
                .font(
                    .system(
                        .title3,
                        design: .rounded,
                        weight: .bold
                    )
                )
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 12)

            ForEach(ProgrammingExperience.allCases) { option in
                choice(option)
            }
        }
    }

    private func choice(
        _ option: ProgrammingExperience
    ) -> some View {
        let selected = viewModel.selection == option

        return Button {
            viewModel.selection = option
        } label: {
            HStack(spacing: 14) {
                Image(
                    systemName: selected
                        ? "largecircle.fill.circle"
                        : "circle"
                )
                .font(.title2)
                .foregroundStyle(
                    selected
                        ? KodaPalette.blue
                        : KodaPalette.secondary.opacity(0.5)
                )
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(option.title)
                        .font(.subheadline.weight(.semibold))

                    Text(option.subtitle)
                        .font(.caption)
                        .foregroundStyle(KodaPalette.secondary)
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                Image(
                    systemName: option == .familiar
                        ? "chevron.left.forwardslash.chevron.right"
                        : "book"
                )
                .font(.title2)
                .foregroundStyle(
                    option == .familiar
                        ? KodaPalette.purple
                        : KodaPalette.blue
                )
                .accessibilityHidden(true)
            }
            .foregroundStyle(KodaPalette.ink)
            .padding(18)
            .kodaPanel(
                fill: selected ? KodaPalette.paleBlue : .white,
                border: selected
                    ? KodaPalette.blue
                    : KodaPalette.line
            )
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(
            selected ? [.isSelected] : []
        )
    }

    // MARK: - Mensaje del profesor

    private var teacherMessage: String {
        switch viewModel.selection {
        case .familiar:
            return """
            ¡Perfecto, \(profile.name)! Empezaremos directamente \
            con los conceptos de POO.
            """

        case .needsReview:
            return """
            ¡Perfecto! Empezaremos con una breve revisión \
            de lo esencial.
            """

        case nil:
            return """
            Hola, \(profile.name). Elige tu punto de partida; \
            aprenderemos paso a paso.
            """
        }
    }

    // MARK: - Continuar

    private var continueButton: some View {
        KodaPrimaryAction(
            title: "Continuar",
            isEnabled: viewModel.selection != nil
        ) {
            viewModel.save(
                profile: profile,
                context: modelContext
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: 520)
        .frame(maxWidth: .infinity)
        .background(.white)
    }
}

#Preview {
    let profile = StudentProfile(
        name: "Alex",
        avatarName: ProfileAvatar.alex.rawValue
    )

    NavigationStack {
        KnowledgeCheckView(profile: profile)
    }
    .preferredColorScheme(.light)
    .modelContainer(
        for: StudentProfile.self,
        inMemory: true
    )
}
