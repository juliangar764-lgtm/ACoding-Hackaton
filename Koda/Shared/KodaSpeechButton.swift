//
//  KodaSpeechButton.swift
//  Koda
//
//  Created by ADMIN UNACH on 25/09/26.
//

import SwiftUI

@MainActor
struct KodaSpeechButton: View {
    let text: String

    @Environment(\.scenePhase) private var scenePhase
    @State private var speechService = KodaSpeechService()

    private var hasText: Bool {
        !text.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }

    private var title: String {
        speechService.isActive
            ? "Detener lectura"
            : "Escuchar"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: toggleSpeech) {
                HStack(spacing: 10) {
                    Image(
                        systemName: speechService.isActive
                            ? "stop.fill"
                            : "speaker.wave.2.fill"
                    )
                    .accessibilityHidden(true)

                    Text(title)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
                .font(.headline)
                .foregroundStyle(KodaPalette.blue)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(
                    maxWidth: .infinity,
                    minHeight: 44
                )
                .background(
                    KodaPalette.paleBlue,
                    in: RoundedRectangle(cornerRadius: 18)
                )
                .contentShape(
                    RoundedRectangle(cornerRadius: 18)
                )
            }
            .buttonStyle(.plain)
            .disabled(!hasText)
            .opacity(hasText ? 1 : 0.5)
            .accessibilityHint(
                speechService.isActive
                    ? "Detiene la explicación que está leyendo Koda."
                    : "Lee esta explicación en voz alta."
            )

            if let errorMessage = speechService.errorMessage {
                Label(
                    errorMessage,
                    systemImage: "exclamationmark.circle"
                )
                .font(.subheadline)
                .foregroundStyle(KodaPalette.ink)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .accessibilityElement(children: .combine)
            }
        }
        .onChange(of: text) { _, _ in
            speechService.stop()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                speechService.stop()
            }
        }
        .onDisappear {
            speechService.stop()
        }
    }

    // MARK: - Acción del botón

    private func toggleSpeech() {
        if speechService.isActive {
            speechService.stop()
        } else {
            speechService.speak(text)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        KodaTeacherMessage(
            message: """
            Una clase es un molde. Los objetos se crean \
            a partir de ella.
            """
        )

        KodaSpeechButton(
            text: """
            Una clase es un molde. Los objetos se crean \
            a partir de ella.
            """
        )
    }
    .padding(24)
    .kodaScreen()
    .preferredColorScheme(.light)
}
