//
//  KodaDictationView.swift
//  Koda
//
//  Created by ADMIN UNACH on 25/09/26.
//

import SwiftUI

@MainActor
struct KodaDictationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var isEditing: Bool

    @State private var dictation = KodaDictationService()
    @State private var reviewText: String
    @State private var textBeforeRecording = ""
    @State private var recordingID: UUID?

    private let maximumLength: Int
    private let onUseText: (String) -> Void

    init(
        initialText: String,
        maximumLength: Int,
        onUseText: @escaping (String) -> Void
    ) {
        _reviewText = State(initialValue: initialText)
        self.maximumLength = maximumLength
        self.onUseText = onUseText
    }

    private var isBusy: Bool {
        recordingID != nil || dictation.isActive
    }

    private var cleanText: String {
        reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var statusText: String {
        switch dictation.state {
        case .idle:
            return recordingID == nil
                ? "Pulsa el micrófono para comenzar."
                : "Preparando el dictado…"

        case .requestingPermission:
            return "Comprobando los permisos de voz…"

        case .listening:
            return "Escuchando… Puedes hablar durante 45 segundos."

        case .finishing:
            return "Terminando de reconocer tu pregunta…"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Dicta tu pregunta")
                        .font(.title2.bold())
                        .accessibilityAddTraits(.isHeader)

                    Text(
                        """
                        Revisa el texto antes de llevarlo al chat. \
                        Tu pregunta no se enviará automáticamente.
                        """
                    )
                    .foregroundStyle(KodaPalette.secondary)

                    Label(
                        statusText,
                        systemImage: dictation.state == .listening
                            ? "mic.fill"
                            : "info.circle"
                    )
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)

                    recordingControls

                    if let error = dictation.errorMessage {
                        Label(
                            error,
                            systemImage: "exclamationmark.circle"
                        )
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                    }

                    Text("Texto para revisar")
                        .font(.headline)

                    TextEditor(text: $reviewText)
                        .frame(minHeight: 180)
                        .scrollContentBackground(.hidden)
                        .padding(10)
                        .kodaPanel()
                        .focused($isEditing)
                        .disabled(isBusy)
                        .accessibilityLabel(
                            "Pregunta dictada. Puedes editarla al terminar."
                        )

                    Text(
                        "\(cleanText.count)/\(maximumLength) caracteres"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        cleanText.count > maximumLength
                            ? Color.red
                            : KodaPalette.secondary
                    )

                    if cleanText.count > maximumLength {
                        Text(
                            "Acorta el texto para poder usarlo en el chat."
                        )
                        .font(.subheadline)
                    }

                    Button {
                        guard !isBusy,
                              !cleanText.isEmpty,
                              cleanText.count <= maximumLength else {
                            return
                        }

                        onUseText(cleanText)
                        dismiss()
                    } label: {
                        Label(
                            "Usar este texto",
                            systemImage: "checkmark"
                        )
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 44
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        isBusy ||
                        cleanText.isEmpty ||
                        cleanText.count > maximumLength
                    )
                }
                .padding(20)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .kodaScreen()
            .navigationTitle("Pregunta por voz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        stopDictation()
                        dismiss()
                    }
                    .frame(minHeight: 44)
                }
            }
        }
        .preferredColorScheme(.light)
        .tint(KodaPalette.blue)
        .task(id: recordingID) {
            guard let id = recordingID else { return }

            await dictation.start()

            if recordingID == id {
                recordingID = nil
            }
        }
        .onChange(of: dictation.transcript) { _, newText in
            reviewText = [textBeforeRecording, newText]
                .filter { !$0.isEmpty }
                .joined(separator: " ")
        }
        .onChange(of: scenePhase) { _, phase in
            // Los avisos de permisos pueden pasar temporalmente a inactive.
            if phase == .background {
                stopDictation()
            }
        }
        .onDisappear {
            stopDictation()
        }
    }

    @ViewBuilder
    private var recordingControls: some View {
        if isBusy {
            VStack(alignment: .leading, spacing: 12) {
                if dictation.state == .listening {
                    Button(
                        "Terminar dictado",
                        systemImage: "stop.fill"
                    ) {
                        dictation.finish()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(minHeight: 44)
                } else {
                    ProgressView()
                        .accessibilityLabel(statusText)
                }

                Button("Detener sin esperar") {
                    stopDictation()
                }
                .buttonStyle(.bordered)
                .frame(minHeight: 44)
            }
        } else {
            Button("Dictar", systemImage: "mic.fill") {
                isEditing = false
                textBeforeRecording = cleanText
                recordingID = UUID()
            }
            .buttonStyle(.borderedProminent)
            .frame(minHeight: 44)
            .accessibilityHint(
                "El texto reconocido se añadirá al que ya tienes."
            )
        }
    }

    private func stopDictation() {
        recordingID = nil
        dictation.cancel()
    }
}

#Preview {
    KodaDictationView(
        initialText: "",
        maximumLength: 600
    ) { _ in }
}
