//
//  FundamentalsReviewView.swift
//  Koda
//
//  Created by ADMIN UNACH on 22/09/26.
//


import SwiftUI
import SwiftData

struct FundamentalsReviewView: View {
    let profile: StudentProfile

    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = FundamentalsReviewViewModel()
    @State private var showingOverview: Bool
    @State private var showingPractice = false

    init(profile: StudentProfile) {
        self.profile = profile

        _showingOverview = State(
            initialValue: profile.fundamentalsStep == nil
        )
    }

    private var index: Int {
        max(0, profile.fundamentalsStep ?? 0)
    }

    var body: some View {
        Group {
            if showingOverview {
                overview
            } else if FundamentalsLesson.lessons.indices.contains(index) {
                lessonPage(FundamentalsLesson.lessons[index])
            } else {
                ContentUnavailableView(
                    "Repaso completado",
                    systemImage: "checkmark.circle",
                    description: Text("Ya puedes continuar con POO.")
                )
            }
        }
        .kodaScreen()
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Presentación del repaso

    private var overview: some View {
        ScrollView {
            VStack(spacing: 22) {
                KodaStepDots(current: 2)
                    .padding(.top, 16)

                VStack(spacing: 8) {
                    Text("Preparación para POO")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KodaPalette.purple)

                    Text("Repaso de programación")
                        .font(
                            .system(
                                .title2,
                                design: .rounded,
                                weight: .bold
                            )
                        )
                        .accessibilityAddTraits(.isHeader)

                    Text(
                        "Vamos a revisar los conceptos clave antes de entrar en POO."
                    )
                    .font(.subheadline)
                    .foregroundStyle(KodaPalette.secondary)
                }
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

                KodaTeacherMessage(
                    message: "Vamos a explorar lo esencial, paso a paso."
                )

                VStack(spacing: 12) {
                    ForEach(FundamentalsLesson.lessons) { lesson in
                        overviewRow(lesson)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            KodaPrimaryAction(
                title: index == 0
                    ? "Iniciar repaso"
                    : "Continuar repaso"
            ) {
                showingOverview = false
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
            .background(.white)
        }
    }

    private func overviewRow(
        _ lesson: FundamentalsLesson
    ) -> some View {
        HStack(spacing: 14) {
            KodaSymbolBadge(
                symbol: symbol(for: lesson.id),
                color: accent(for: lesson.id)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.subheadline.weight(.semibold))

                Text(summary(for: lesson.id))
                    .font(.caption)
                    .foregroundStyle(KodaPalette.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(14)
        .kodaPanel()
        .accessibilityElement(children: .combine)
    }

    // MARK: - Lección y práctica

    private func lessonPage(
        _ lesson: FundamentalsLesson
    ) -> some View {
        ScrollView {
            VStack(spacing: 22) {
                lessonHeader

                VStack(spacing: 10) {
                    Text(
                        showingPractice
                            ? "Ponlo en práctica"
                            : lesson.title
                    )
                    .font(
                        .system(
                            .title,
                            design: .rounded,
                            weight: .bold
                        )
                    )
                    .accessibilityAddTraits(.isHeader)

                    Text(
                        showingPractice
                            ? lesson.question
                            : lesson.explanation
                    )
                    .font(.subheadline)
                    .foregroundStyle(KodaPalette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .multilineTextAlignment(.center)

                if showingPractice {
                    Text("Responde según este ejemplo:")
                        .font(.caption)
                        .foregroundStyle(KodaPalette.secondary)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )

                    KodaCodeCard(code: lesson.code)

                    practiceAnswers(lesson)

                    KodaTeacherMessage(
                        message: feedbackMessage(for: lesson)
                    )
                } else {
                    FundamentalsPlayground(lessonID: lesson.id)
                        .id(lesson.id)

                    KodaTeacherMessage(
                        message: hint(for: lesson.id)
                    )
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
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .id("\(lesson.id)-\(showingPractice)")
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            lessonAction(lesson)
        }
    }

    // MARK: - Navegación y progreso

    private var lessonHeader: some View {
        HStack(spacing: 16) {
            Button {
                if showingPractice {
                    showingPractice = false
                    viewModel.retry()
                } else {
                    showingOverview = true
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                showingPractice
                    ? "Volver al ejemplo"
                    : "Ver índice del repaso"
            )

            VStack(spacing: 8) {
                Text(
                    "Paso \(index + 1) de \(FundamentalsLesson.lessons.count)"
                )
                .font(.caption)
                .foregroundStyle(KodaPalette.secondary)

                ProgressView(
                    value: Double(index),
                    total: Double(FundamentalsLesson.lessons.count)
                )
                .accessibilityLabel("Pasos completados")
                .accessibilityValue(
                    "\(index) de \(FundamentalsLesson.lessons.count)"
                )
            }

            Color.clear
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)
        }
    }

    // MARK: - Respuestas

    private func practiceAnswers(
        _ lesson: FundamentalsLesson
    ) -> some View {
        VStack(spacing: 12) {
            ForEach(lesson.answers.indices, id: \.self) { answer in
                answerButton(answer, for: lesson)
            }
        }
    }

    private func answerButton(
        _ answer: Int,
        for lesson: FundamentalsLesson
    ) -> some View {
        let selected = viewModel.selectedAnswer == answer
        let correct = selected && viewModel.isCorrect(for: lesson)

        let icon = correct
            ? "checkmark.circle.fill"
            : (selected ? "largecircle.fill.circle" : "circle")

        let fill: Color = correct
            ? KodaPalette.green.opacity(0.08)
            : (selected ? KodaPalette.paleBlue : .white)

        let border: Color = correct
            ? KodaPalette.green
            : (selected ? KodaPalette.blue : KodaPalette.line)

        return Button {
            viewModel.selectedAnswer = answer
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(
                        correct ? KodaPalette.green : KodaPalette.blue
                    )
                    .accessibilityHidden(true)

                Text(lesson.answers[answer])
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .foregroundStyle(KodaPalette.ink)
            .padding(18)
            .frame(
                maxWidth: .infinity,
                minHeight: 60,
                alignment: .leading
            )
            .kodaPanel(fill: fill, border: border)
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.hasChecked)
        .accessibilityAddTraits(
            selected ? [.isSelected] : []
        )
    }

    private func feedbackMessage(
        for lesson: FundamentalsLesson
    ) -> String {
        guard viewModel.hasChecked else {
            return "Observa el código y elige tu respuesta."
        }

        let introduction = viewModel.isCorrect(for: lesson)
            ? "¡Correcto!"
            : "Vamos a intentarlo otra vez."

        return "\(introduction) \(lesson.feedback)"
    }

    // MARK: - Acción principal

    private func lessonAction(
        _ lesson: FundamentalsLesson
    ) -> some View {
        let needsRetry = viewModel.hasChecked
            && !viewModel.isCorrect(for: lesson)

        return KodaPrimaryAction(
            title: actionTitle(for: lesson),
            symbol: needsRetry
                ? "arrow.counterclockwise"
                : "arrow.right",
            isEnabled: !showingPractice
                || viewModel.selectedAnswer != nil
        ) {
            performAction(for: lesson)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: 520)
        .frame(maxWidth: .infinity)
        .background(.white)
    }

    private func actionTitle(
        for lesson: FundamentalsLesson
    ) -> String {
        if !showingPractice {
            return "Continuar"
        }

        if !viewModel.hasChecked {
            return "Comprobar"
        }

        if !viewModel.isCorrect(for: lesson) {
            return "Intentar de nuevo"
        }

        return index == FundamentalsLesson.lessons.count - 1
            ? "Comenzar POO"
            : "Continuar"
    }

    private func performAction(
        for lesson: FundamentalsLesson
    ) {
        if !showingPractice {
            showingPractice = true
        } else if !viewModel.hasChecked {
            viewModel.checkAnswer(for: lesson)
        } else if !viewModel.isCorrect(for: lesson) {
            viewModel.retry()
        } else if viewModel.advance(
            profile: profile,
            context: modelContext
        ) {
            showingPractice = false
        }
    }

    // MARK: - Presentación de cada tema

    private func symbol(for id: String) -> String {
        switch id {
        case "variables":
            return "xmark"
        case "conditions":
            return "arrow.triangle.branch"
        case "loops":
            return "arrow.triangle.2.circlepath"
        default:
            return "function"
        }
    }

    private func accent(for id: String) -> Color {
        switch id {
        case "variables":
            return KodaPalette.purple
        case "conditions":
            return .orange
        case "loops":
            return KodaPalette.green
        default:
            return KodaPalette.blue
        }
    }

    private func summary(for id: String) -> String {
        switch id {
        case "variables":
            return "Guardar y cambiar valores"
        case "conditions":
            return "Tomar decisiones"
        case "loops":
            return "Repetir instrucciones"
        default:
            return "Organizar código"
        }
    }

    private func hint(for id: String) -> String {
        switch id {
        case "variables":
            return """
            Mueve el control y observa cómo cambia \
            el valor de la variable.
            """

        case "conditions":
            return """
            Cambia el semáforo y observa qué rama \
            de la condición se ejecuta.
            """

        case "loops":
            return """
            Cambia el número de repeticiones \
            y cuenta los mensajes.
            """

        default:
            return """
            Pulsa Ejecutar para llamar a la función \
            y ver su resultado.
            """
        }
    }
}

#Preview {
    let profile = StudentProfile(
        name: "Alex",
        avatarName: ProfileAvatar.alex.rawValue
    )

    NavigationStack {
        FundamentalsReviewView(profile: profile)
    }
    .preferredColorScheme(.light)
    .modelContainer(
        for: StudentProfile.self,
        inMemory: true
    )
}
