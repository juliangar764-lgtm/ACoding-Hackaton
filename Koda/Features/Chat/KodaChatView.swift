//
//  KodaChatView.swift
//  Koda
//
//  Created by ADMIN UNACH on 25/09/26.
//

import SwiftUI

@MainActor
struct KodaChatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @FocusState private var isQuestionFocused: Bool

    @State private var viewModel: KodaChatViewModel
    @State private var showsDictation = false

    private let bottomAnchor = "conversation-bottom"

    init(
        context: KodaTutorContext,
        tutor: (any KodaTutoring)? = nil
    ) {
        _viewModel = State(
            initialValue: KodaChatViewModel(
                context: context,
                tutor: tutor
            )
        )
    }

    private var latestKodaMessageID: UUID? {
        viewModel.messages.last(where: {
            $0.role == .koda
        })?.id
    }

    var body: some View {
        // Se presenta como una hoja desde la lección.
        NavigationStack {
            conversation
                .kodaScreen()
                .navigationTitle("Pregunta a Koda")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.cancelResponse()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .frame(
                                    minWidth: 44,
                                    minHeight: 44
                                )
                        }
                        .accessibilityLabel("Cerrar chat")
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    composer
                }
        }
        .preferredColorScheme(.light)
        .tint(KodaPalette.blue)
        .sheet(isPresented: $showsDictation) {
            KodaDictationView(
                initialText: viewModel.draft,
                maximumLength: viewModel.maximumQuestionLength
            ) { text in
                // Solo actualiza el borrador: no envía la pregunta.
                viewModel.draft = text
            }
        }
        .task {
            viewModel.refreshAvailability()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.refreshAvailability()
            } else if newPhase == .background {
                viewModel.cancelResponse()
            }
        }
        .onDisappear {
            viewModel.cancelResponse()
        }
    }

    // MARK: - Conversación

    private var conversation: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    contextHeader

                    if let reason = viewModel.unavailableMessage {
                        availabilityNotice(reason)
                    }

                    if viewModel.messages.isEmpty {
                        introduction
                    }

                    ForEach(viewModel.messages) { message in
                        if message.role == .student {
                            studentMessage(message)
                        } else {
                            kodaMessage(message)
                        }
                    }

                    if viewModel.isSending {
                        responseStatus
                    }

                    if let error = viewModel.errorMessage,
                       viewModel.unavailableMessage == nil {
                        Label(
                            error,
                            systemImage: "exclamationmark.circle"
                        )
                        .font(.subheadline)
                        .foregroundStyle(KodaPalette.ink)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                    }

                    if viewModel.retryMessageID != nil &&
                        !viewModel.isSending {
                        Button("Reintentar última pregunta") {
                            isQuestionFocused = false
                            viewModel.retryLastQuestion()
                        }
                        .buttonStyle(.bordered)
                        .frame(minHeight: 44)
                        .disabled(!viewModel.canRetry)
                    }

                    Color.clear
                        .frame(height: 1)
                        .id(bottomAnchor)
                        .accessibilityHidden(true)
                }
                .padding(20)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) { _, _ in
                proxy.scrollTo(
                    bottomAnchor,
                    anchor: .bottom
                )
            }
            .onChange(of: viewModel.requestState) { _, _ in
                proxy.scrollTo(
                    bottomAnchor,
                    anchor: .bottom
                )
            }
            .onChange(of: viewModel.errorMessage) { _, _ in
                proxy.scrollTo(
                    bottomAnchor,
                    anchor: .bottom
                )
            }
        }
    }

    private var contextHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(
                viewModel.context.topicTitle,
                systemImage: "book.closed"
            )
            .font(.headline)
            .accessibilityAddTraits(.isHeader)

            Text(viewModel.context.stepTitle)
                .font(.subheadline)
                .foregroundStyle(KodaPalette.secondary)
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .kodaPanel(fill: KodaPalette.paleBlue)
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 16) {
            teacherBubble(
                """
                Puedes preguntarme sobre este tema o pedirme \
                que te recuerde un concepto anterior.
                """
            )

            Button {
                viewModel.draft = """
                Explícame este tema de forma sencilla.
                """
                isQuestionFocused = true
            } label: {
                Label(
                    "Ayúdame a entender este tema",
                    systemImage: "lightbulb"
                )
                .frame(minHeight: 44)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            }
            .buttonStyle(.bordered)
            .accessibilityHint(
                """
                Escribe una sugerencia en el campo de pregunta \
                para que puedas editarla.
                """
            )
        }
    }

    private func availabilityNotice(
        _ reason: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                "IA no disponible",
                systemImage: "info.circle"
            )
            .font(.headline)

            Text(reason)
                .font(.subheadline)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text("Puedes cerrar el chat y continuar con la lección.")
                .font(.subheadline)
                .foregroundStyle(KodaPalette.secondary)

            Button("Volver a comprobar") {
                viewModel.refreshAvailability()
            }
            .buttonStyle(.bordered)
            .frame(minHeight: 44)
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .kodaPanel()
    }

    // MARK: - Mensajes del estudiante

    private func studentMessage(
        _ message: KodaChatViewModel.Message
    ) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text("Tú")
                .font(.caption.weight(.semibold))
                .foregroundStyle(KodaPalette.secondary)

            Text(message.text)
                .textSelection(.enabled)
                .foregroundStyle(.white)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .padding(16)
                .background(
                    KodaPalette.blue,
                    in: RoundedRectangle(cornerRadius: 20)
                )

            if message.deliveryState == .failed {
                Label(
                    "Sin respuesta",
                    systemImage: "exclamationmark.circle"
                )
                .font(.caption)
                .foregroundStyle(KodaPalette.secondary)
            } else if message.deliveryState == .cancelled {
                Label(
                    "Solicitud cancelada",
                    systemImage: "stop.circle"
                )
                .font(.caption)
                .foregroundStyle(KodaPalette.secondary)
            }
        }
        .padding(
            .leading,
            dynamicTypeSize.isAccessibilitySize ? 0 : 28
        )
        .frame(
            maxWidth: .infinity,
            alignment: .trailing
        )
        .accessibilityElement(children: .contain)
    }

    // MARK: - Mensajes de Koda

    private func kodaMessage(
        _ message: KodaChatViewModel.Message
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Koda · IA")
                .font(.caption.weight(.semibold))
                .foregroundStyle(KodaPalette.secondary)

            teacherBubble(message.text)

            // Solo se puede escuchar la última respuesta.
            // Al abrir el dictado se retira el reproductor.
            // Su onDisappear detiene la lectura.
            if message.id == latestKodaMessageID &&
                !viewModel.isSending &&
                !showsDictation {
                KodaSpeechButton(text: message.text)
            }
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func teacherBubble(
        _ text: String
    ) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            Text(text)
                .textSelection(.enabled)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .padding(16)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .kodaPanel(fill: KodaPalette.paleBlue)
                .accessibilityLabel("Koda: \(text)")
        } else {
            KodaTeacherMessage(message: text)
                .textSelection(.enabled)
        }
    }

    // MARK: - Solicitud en curso

    private var responseStatus: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ProgressView()
                    .accessibilityHidden(true)

                Text(
                    viewModel.requestState == .cancelling
                        ? "Cancelando…"
                        : "Koda está preparando tu respuesta…"
                )
                .font(.subheadline)
            }

            if viewModel.requestState == .responding {
                Button("Cancelar respuesta") {
                    viewModel.cancelResponse()
                }
                .buttonStyle(.bordered)
                .frame(minHeight: 44)
            }
        }
    }

    // MARK: - Escritura y dictado

    private var composer: some View {
        @Bindable var editableViewModel = viewModel

        return VStack(alignment: .leading, spacing: 10) {
            Button(
                "Preguntar por voz",
                systemImage: "mic.fill"
            ) {
                isQuestionFocused = false
                showsDictation = true
            }
            .buttonStyle(.bordered)
            .frame(minHeight: 44)
            .disabled(
                viewModel.isSending ||
                viewModel.unavailableMessage != nil
            )

            TextField(
                "Escribe tu pregunta…",
                text: $editableViewModel.draft,
                axis: .vertical
            )
            .lineLimit(1...4)
            .textInputAutocapitalization(.sentences)
            .focused($isQuestionFocused)
            .submitLabel(.send)
            .onSubmit(sendQuestion)
            .padding(14)
            .kodaPanel()
            .accessibilityLabel("Tu pregunta para Koda")

            HStack(spacing: 16) {
                Text(
                    "\(viewModel.questionLength)/\(viewModel.maximumQuestionLength)"
                )
                .font(.caption)
                .foregroundStyle(
                    viewModel.questionLength >
                        viewModel.maximumQuestionLength
                        ? Color.red
                        : KodaPalette.secondary
                )
                .accessibilityLabel(
                    "\(viewModel.questionLength) de \(viewModel.maximumQuestionLength) caracteres"
                )

                Spacer(minLength: 0)

                Button(action: sendQuestion) {
                    Label(
                        "Enviar",
                        systemImage: "paperplane.fill"
                    )
                    .font(.headline)
                    .frame(minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSend)
                .accessibilityLabel("Enviar pregunta")
            }

            if viewModel.questionLength >
                viewModel.maximumQuestionLength {
                Text("Acorta tu pregunta para poder enviarla.")
                    .font(.caption)
                    .foregroundStyle(KodaPalette.ink)
            }
        }
        .padding(16)
        .frame(maxWidth: 560)
        .frame(maxWidth: .infinity)
        .background(.white)
    }

    private func sendQuestion() {
        guard viewModel.canSend else { return }

        isQuestionFocused = false
        viewModel.send()
    }
}

// MARK: - Tutor simulado para la previsualización

@MainActor
private final class PreviewKodaTutor: KodaTutoring {
    var availability: KodaTutorAvailability {
        .available
    }

    func respond(
        to question: String,
        context: KodaTutorContext
    ) async throws -> String {
        try await Task.sleep(for: .milliseconds(500))

        return """
        Esta es una respuesta de demostración para revisar el chat. \
        Una clase es un molde; los objetos se crean a partir de ella \
        y pueden tener valores diferentes.
        """
    }
}

#Preview("Chat con tutor simulado") {
    if let topic = POOTopic.topics.first(where: {
        $0.id == "classes-and-objects"
    }),
       let lesson = POOLesson.lesson(for: topic) {
        KodaChatView(
            context: KodaTutorContext(
                lesson: lesson,
                step: .explanation
            ),
            tutor: PreviewKodaTutor()
        )
    }
}
