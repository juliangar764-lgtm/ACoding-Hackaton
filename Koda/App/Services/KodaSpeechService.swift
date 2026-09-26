//
//  KodaSpeechService.swift
//  Koda
//
//  Created by ADMIN UNACH on 25/09/26.
//

import Foundation
import Observation
import AVFoundation

@MainActor
@Observable
final class KodaSpeechService: NSObject, AVSpeechSynthesizerDelegate {

    enum PlaybackState: Equatable {
        case idle
        case preparing
        case speaking
    }

    private(set) var state: PlaybackState = .idle
    private(set) var errorMessage: String?

    @ObservationIgnored
    private let synthesizer = AVSpeechSynthesizer()

    @ObservationIgnored
    private var currentUtterance: AVSpeechUtterance?

    var isActive: Bool {
        state != .idle
    }

    override init() {
        super.init()

        synthesizer.delegate = self

        // iOS gestiona la sesión de audio de esta lectura.
        synthesizer.usesApplicationAudioSession = false
    }

    // MARK: - Lectura

    @discardableResult
    func speak(_ text: String) -> Bool {
        let cleanText = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanText.isEmpty else {
            stop()
            errorMessage = "No hay texto para leer."
            return false
        }

        guard let voice = spanishVoice() else {
            stop()
            errorMessage = """
            No encontramos una voz en español disponible \
            en este dispositivo.
            """
            return false
        }

        let utterance = AVSpeechUtterance(string: cleanText)
        utterance.voice = voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate

        // Reemplaza la lectura anterior sin acumular explicaciones.
        stop()

        currentUtterance = utterance
        state = .preparing

        synthesizer.speak(utterance)

        return true
    }

    func stop() {
        // La cancelación anterior puede notificarse después.
        // Dejamos de considerarla activa antes de detenerla.
        currentUtterance = nil
        state = .idle
        errorMessage = nil

        synthesizer.stopSpeaking(at: .immediate)
    }

    // MARK: - Selección de voz

    private func spanishVoice() -> AVSpeechSynthesisVoice? {
        AVSpeechSynthesisVoice(language: "es-MX")
            ?? AVSpeechSynthesisVoice(language: "es-ES")
            ?? AVSpeechSynthesisVoice.speechVoices().first {
                $0.language == "es"
                    || $0.language.hasPrefix("es-")
            }
    }

    // MARK: - Estado de la lectura actual

    private func didStart(utteranceID: ObjectIdentifier) {
        guard let currentUtterance,
              ObjectIdentifier(currentUtterance) == utteranceID else {
            return
        }

        state = .speaking
    }

    private func didEnd(utteranceID: ObjectIdentifier) {
        guard let currentUtterance,
              ObjectIdentifier(currentUtterance) == utteranceID else {
            return
        }

        self.currentUtterance = nil
        state = .idle
    }

    // MARK: - Eventos de AVSpeechSynthesizer

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didStart utterance: AVSpeechUtterance
    ) {
        let utteranceID = ObjectIdentifier(utterance)

        Task { @MainActor [weak self] in
            self?.didStart(utteranceID: utteranceID)
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        let utteranceID = ObjectIdentifier(utterance)

        Task { @MainActor [weak self] in
            self?.didEnd(utteranceID: utteranceID)
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        let utteranceID = ObjectIdentifier(utterance)

        Task { @MainActor [weak self] in
            self?.didEnd(utteranceID: utteranceID)
        }
    }
}
