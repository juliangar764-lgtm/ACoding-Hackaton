//
//  POOLessonView.swift
//  Koda
//
//  Created by ADMIN UNACH on 24/09/26.
//

import SwiftUI
import SwiftData

@MainActor
struct POOLessonView: View {

    private struct TutorPresentation: Identifiable {
        let id = UUID()
        let context: KodaTutorContext
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var viewModel: POOLessonViewModel
    @State private var retryPreviousStep = false
    @State private var tutorPresentation: TutorPresentation?
    @State private var currentExampleState: String?

    init(lesson: POOLesson) {
        _viewModel = State(
            initialValue: POOLessonViewModel(lesson: lesson)
        )
    }

    private var isAttributesLesson: Bool {
        viewModel.lesson.topic.id == "properties-and-methods"
    }

    private var isInheritanceLesson: Bool {
        viewModel.lesson.topic.id == "inheritance"
    }

    private var isEncapsulationLesson: Bool {
        viewModel.lesson.topic.id == "encapsulation"
    }

    private var isPolymorphismLesson: Bool {
        viewModel.lesson.topic.id == "polymorphism"
    }

    var body: some View {
        Group {
            if viewModel.hasLoaded {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        stepHeader
                        stepContent
                    }
                    .padding(20)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
                .id(viewModel.step)
            } else if let error = viewModel.errorMessage {
                ContentUnavailableView {
                    Label(
                        "No pudimos abrir la lección",
                        systemImage: "exclamationmark.triangle"
                    )
                } description: {
                    Text(error)
                } actions: {
                    Button("Reintentar") {
                        viewModel.load(using: modelContext)
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                ProgressView("Preparando lección…")
            }
        }
        .kodaScreen()
        .navigationTitle(viewModel.lesson.topic.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if viewModel.canGoBack {
                    Button {
                        retryPreviousStep = !viewModel.goBack(
                            using: modelContext
                        )
                    } label: {
                        Image(systemName: "chevron.left")
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityLabel("Paso anterior")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("Cerrar lección")
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if viewModel.hasLoaded {
                footer
            }
        }
        .sheet(item: $tutorPresentation) { presentation in
            KodaChatView(context: presentation.context)
                .id(presentation.id)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: viewModel.step) { _, newStep in
            // Al salir del ejemplo descartamos sus valores.
            // Si volvemos, la vista comunicará su nuevo estado inicial.
            if newStep != .exploration {
                currentExampleState = nil
            }
        }
        .task {
            viewModel.load(using: modelContext)
        }
    }

    // MARK: - Encabezado

    private var stepHeader: some View {
        VStack(spacing: 10) {
            Text(
                "Paso \(viewModel.step.rawValue + 1) de \(POOLesson.Step.allCases.count)"
            )
            .font(.subheadline)
            .foregroundStyle(KodaPalette.secondary)

            KodaStepDots(current: viewModel.step.rawValue)

            Text(stepTitle)
                .font(
                    .system(
                        .title,
                        design: .rounded,
                        weight: .bold
                    )
                )
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(maxWidth: .infinity)
    }

    private var stepTitle: String {
        switch viewModel.step {
        case .explanation:
            return viewModel.lesson.topic.title

        case .exploration:
            if isPolymorphismLesson {
                return "Una llamada, distintas respuestas"
            }

            if isEncapsulationLesson {
                return "Protege el saldo"
            }

            return isInheritanceLesson
                ? "Explora la herencia"
                : "Explora un objeto"

        case .practice:
            return "Ponlo en práctica"

        case .result:
            return "¡Tema completado!"
        }
    }

    // MARK: - Contenido de cada paso

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.step {
        case .explanation:
            explanation

        case .exploration:
            Text(viewModel.lesson.explorationPrompt)
                .foregroundStyle(KodaPalette.secondary)

            lessonSpeech(
                for: viewModel.lesson.explorationPrompt
            )

            if isPolymorphismLesson {
                PolymorphismExplorationView { newState in
                    guard viewModel.step == .exploration else {
                        return
                    }

                    currentExampleState = newState
                }
            } else if isEncapsulationLesson {
                EncapsulationExplorationView { newState in
                    guard viewModel.step == .exploration else {
                        return
                    }

                    currentExampleState = newState
                }
            } else if isInheritanceLesson {
                InheritanceExplorationView { newState in
                    guard viewModel.step == .exploration else {
                        return
                    }

                    currentExampleState = newState
                }
            } else if isAttributesLesson {
                AttributesMethodsExplorationView()
            } else {
                CarExplorationView { newState in
                    // Ignora notificaciones de un ejemplo
                    // que ya se cerró.
                    guard viewModel.step == .exploration else {
                        return
                    }

                    currentExampleState = newState
                }
            }

        case .practice:
            practice

        case .result:
            result
        }
    }

    // MARK: - Explicación

    private var explanation: some View {
        VStack(spacing: 20) {
            Text(viewModel.lesson.topic.explanation)
                .multilineTextAlignment(.center)
                .foregroundStyle(KodaPalette.secondary)

            explanationIllustration

            KodaTeacherMessage(
                message: viewModel.lesson.teacherMessage
            )

            lessonSpeech(
                for: viewModel.lesson.teacherMessage
            )

            KodaCodeCard(code: viewModel.lesson.code)
        }
    }

    @ViewBuilder
    private var explanationIllustration: some View {
        if isPolymorphismLesson {
            polymorphismIllustration
        } else if isEncapsulationLesson {
            encapsulationIllustration
        } else if isInheritanceLesson {
            inheritanceIllustration
        } else if isAttributesLesson {
            VStack(alignment: .leading, spacing: 16) {
                Text("miCoche")
                    .font(.headline)
                    .frame(maxWidth: .infinity)

                CarIllustrationView(
                    color: .blue,
                    doors: .four
                )
                .frame(maxWidth: 360)
                .frame(maxWidth: .infinity)

                Label(
                    "Atributos: color, puertas, enMarcha",
                    systemImage: "list.bullet"
                )

                Label(
                    "Métodos: arrancar(), frenar()",
                    systemImage: "play.circle"
                )
            }
            .font(.subheadline)
            .padding(16)
            .kodaPanel(fill: KodaPalette.paleBlue)
        } else {
            VStack(spacing: 12) {
                Label(
                    "Clase Coche",
                    systemImage: "square.stack.3d.up"
                )
                .font(.headline)
                .foregroundStyle(KodaPalette.blue)

                Image(systemName: "arrow.down")
                    .accessibilityHidden(true)

                let layout = dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(spacing: 16))
                    : AnyLayout(HStackLayout(spacing: 16))

                layout {
                    VStack {
                        CarIllustrationView(
                            color: .red,
                            doors: .four
                        )

                        Text("miCoche")
                            .font(.subheadline.bold())
                    }

                    VStack {
                        CarIllustrationView(
                            color: .blue,
                            doors: .four
                        )

                        Text("cocheDeAna")
                            .font(.subheadline.bold())
                    }
                }
            }
            .padding(16)
            .kodaPanel(fill: KodaPalette.paleBlue)
        }
    }

    // MARK: - Ilustración de polimorfismo

    private var polymorphismIllustration: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("hacerSonido()")
                .font(
                    .system(
                        .title2,
                        design: .monospaced,
                        weight: .bold
                    )
                )
                .foregroundStyle(KodaPalette.blue)
                .frame(maxWidth: .infinity)

            soundIllustrationRow(
                name: "Perro",
                emoji: "🐶",
                sound: "¡Guau!"
            )

            soundIllustrationRow(
                name: "Gato",
                emoji: "🐱",
                sound: "¡Miau!"
            )

            soundIllustrationRow(
                name: "Vaca",
                emoji: "🐮",
                sound: "¡Muu!"
            )

            Text(
                "La misma llamada ejecuta la implementación del animal concreto."
            )
            .font(.subheadline)
            .foregroundStyle(KodaPalette.secondary)
        }
        .padding(16)
        .kodaPanel(fill: KodaPalette.paleBlue)
    }

    private func soundIllustrationRow(
        name: String,
        emoji: String,
        sound: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.system(size: 40))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)

                Text(sound)
                    .font(.body)
                    .foregroundStyle(KodaPalette.purple)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Ilustración de encapsulación

    private var encapsulationIllustration: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mi alcancía")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)

            Text("🐷")
                .font(.system(size: 80))
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            Label(
                "saldo: dato privado",
                systemImage: "lock.fill"
            )

            Label(
                "saldoActual: permite consultar el saldo",
                systemImage: "eye"
            )

            Label(
                "depositar() y retirar(): validan los cambios",
                systemImage: "checkmark.shield"
            )
        }
        .font(.subheadline)
        .padding(16)
        .kodaPanel(fill: KodaPalette.paleBlue)
    }

    // MARK: - Ilustración de herencia

    private var inheritanceIllustration: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))

        return VStack(spacing: 14) {
            VStack(spacing: 8) {
                Label(
                    "Animal",
                    systemImage: "pawprint.fill"
                )
                .font(.title2.bold())

                Text("Clase base: comer() y dormir()")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .kodaPanel(fill: KodaPalette.paleBlue)

            Image(systemName: "arrow.down")
                .foregroundStyle(KodaPalette.blue)
                .accessibilityHidden(true)

            layout {
                animalClassCard(
                    name: "Perro",
                    emoji: "🐶",
                    ownMethod: "ladrar()"
                )

                animalClassCard(
                    name: "Gato",
                    emoji: "🐱",
                    ownMethod: "maullar()"
                )
            }
        }
    }

    private func animalClassCard(
        name: String,
        emoji: String,
        ownMethod: String
    ) -> some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 44))
                .accessibilityHidden(true)

            Text(name)
                .font(.headline)

            Text("Hereda comer() y dormir()")
                .font(.subheadline)

            Text("Añade \(ownMethod)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KodaPalette.purple)
        }
        .multilineTextAlignment(.center)
        .padding(16)
        .frame(maxWidth: .infinity)
        .kodaPanel()
        .accessibilityElement(children: .combine)
    }

    // MARK: - Ejercicio

    private var practice: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.lesson.exercise.question)
                .font(.title3.weight(.semibold))

            ForEach(viewModel.lesson.exercise.answers) { answer in
                answerButton(answer)
            }

            if let feedback = viewModel.feedback {
                Label(
                    viewModel.isAnswerCorrect
                        ? "¡Correcto!"
                        : "Vamos a revisarlo",
                    systemImage: viewModel.isAnswerCorrect
                        ? "checkmark.circle.fill"
                        : "lightbulb.fill"
                )
                .font(.headline)
                .foregroundStyle(
                    viewModel.isAnswerCorrect
                        ? KodaPalette.green
                        : KodaPalette.purple
                )

                KodaTeacherMessage(message: feedback)

                lessonSpeech(for: feedback)
            }
        }
    }

    private func answerButton(
        _ answer: POOLesson.Answer
    ) -> some View {
        let selected = viewModel.selectedAnswerID == answer.id

        return Button {
            viewModel.selectAnswer(answer.id)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(
                    systemName: selected
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(.title2)
                .foregroundStyle(
                    selected
                        ? KodaPalette.blue
                        : KodaPalette.secondary
                )
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(answer.title)
                        .font(.headline)

                    Text(answer.detail)
                        .font(.subheadline)
                        .foregroundStyle(KodaPalette.secondary)
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(KodaPalette.ink)
            .padding(16)
            .frame(minHeight: 44)
            .kodaPanel(
                fill: selected ? KodaPalette.paleBlue : .white,
                border: selected ? KodaPalette.blue : KodaPalette.line
            )
            .contentShape(
                RoundedRectangle(cornerRadius: 20)
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.hasChecked || viewModel.isBusy)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    // MARK: - Resultado

    private var result: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.yellow)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            if viewModel.earnedExperiencePoints > 0 {
                Text("+\(viewModel.earnedExperiencePoints) XP")
                    .font(.title.bold())
                    .foregroundStyle(KodaPalette.blue)
                    .frame(maxWidth: .infinity)
            } else {
                Text(
                    "Este tema ya está completado. Puedes repasarlo cuando quieras."
                )
                .foregroundStyle(KodaPalette.secondary)
            }

            ForEach(
                viewModel.lesson.learningGoals,
                id: \.self
            ) { goal in
                Label(
                    goal,
                    systemImage: "checkmark.seal.fill"
                )
                .foregroundStyle(KodaPalette.ink)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .kodaPanel()
            }

            KodaTeacherMessage(message: completionMessage)

            lessonSpeech(for: completionMessage)
        }
    }

    private var completionMessage: String {
        """
        ¡Bien hecho! Has completado esta lección. Puedes repasar \
        el ejemplo y volver a practicar cuando quieras.
        """
    }

    // MARK: - Profesor

    @ViewBuilder
    private func lessonSpeech(
        for text: String
    ) -> some View {
        // Retirar el reproductor detiene su lectura.
        // El ejemplo interactivo conserva su identidad.
        if tutorPresentation == nil {
            KodaSpeechButton(text: text)
        }
    }

    private var askKodaButton: some View {
        Button(action: openTutor) {
            Label(
                "Preguntar a Koda",
                systemImage: "bubble.left.and.bubble.right"
            )
            .font(.headline)
            .foregroundStyle(KodaPalette.blue)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 44)
            .kodaPanel(fill: KodaPalette.paleBlue)
            .contentShape(
                RoundedRectangle(cornerRadius: 20)
            )
        }
        .buttonStyle(.plain)
        .disabled(
            viewModel.isBusy || tutorPresentation != nil
        )
        .accessibilityHint(
            "Abre el chat sobre el tema y el paso actual de la lección."
        )
    }

    private func openTutor() {
        guard viewModel.hasLoaded,
              !viewModel.isBusy,
              tutorPresentation == nil else {
            return
        }

        // Captura los valores al abrir el chat.
        // La lección permanece detrás de la hoja.
        let context = KodaTutorContext(
            lesson: viewModel.lesson,
            step: viewModel.step,
            currentExampleState: currentExampleState
        )

        tutorPresentation = TutorPresentation(
            context: context
        )
    }

    // MARK: - Controles inferiores

    private var footer: some View {
        VStack(spacing: 10) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }

            askKodaButton

            KodaPrimaryAction(
                title: actionTitle,
                isEnabled: actionEnabled,
                action: performAction
            )

            if viewModel.step == .result {
                Button("Repasar lección") {
                    viewModel.restartReview()
                }
                .font(.headline)
                .frame(minHeight: 44)
            }
        }
        .padding(16)
        .frame(maxWidth: 560)
        .frame(maxWidth: .infinity)
        .background(.white)
    }

    private var actionTitle: String {
        if viewModel.errorMessage != nil {
            return "Reintentar guardado"
        }

        switch viewModel.step {
        case .explanation:
            return "Explorar ejemplo"

        case .exploration:
            return "Ir al ejercicio"

        case .practice:
            if !viewModel.hasChecked {
                return "Comprobar"
            }

            return viewModel.isAnswerCorrect
                ? "Finalizar tema"
                : "Intentar de nuevo"

        case .result:
            return "Terminar"
        }
    }

    private var actionEnabled: Bool {
        guard !viewModel.isBusy else {
            return false
        }

        if viewModel.errorMessage != nil {
            return retryPreviousStep
                ? viewModel.canGoBack
                : viewModel.canAdvance
        }

        if viewModel.step == .practice {
            return viewModel.hasChecked || viewModel.canCheckAnswer
        }

        return viewModel.step == .result || viewModel.canAdvance
    }

    private func performAction() {
        if viewModel.errorMessage != nil, retryPreviousStep {
            retryPreviousStep = !viewModel.goBack(
                using: modelContext
            )
            return
        }

        retryPreviousStep = false

        switch viewModel.step {
        case .explanation, .exploration:
            viewModel.advance(using: modelContext)

        case .practice:
            if !viewModel.hasChecked {
                viewModel.checkAnswer()
            } else if viewModel.isAnswerCorrect {
                viewModel.advance(using: modelContext)
            } else {
                viewModel.retryAnswer()
            }

        case .result:
            dismiss()
        }
    }
}

#Preview("Lección de clases y objetos") {
    NavigationStack {
        if let topic = POOTopic.topics.first(
            where: { $0.id == "classes-and-objects" }
        ),
           let lesson = POOLesson.lesson(for: topic) {
            POOLessonView(lesson: lesson)
        }
    }
    .modelContainer(
        for: [
            StudentProfile.self,
            TopicProgress.self
        ],
        inMemory: true
    )
    .preferredColorScheme(.light)
}
