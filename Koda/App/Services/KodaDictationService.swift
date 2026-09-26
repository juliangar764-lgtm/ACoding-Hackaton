//
//  KodaDictationService.swift
//  Koda
//
//  Created by ADMIN UNACH on 25/09/26.
//

import Foundation
import Observation
import OSLog
import UIKit
@preconcurrency import AVFAudio
@preconcurrency import Speech

@MainActor
@Observable
final class KodaDictationService {
    enum State: Equatable {
        case idle
        case requestingPermission
        case listening
        case finishing
    }

    private(set) var state: State = .idle
    private(set) var transcript = ""
    private(set) var errorMessage: String?

    var isActive: Bool {
        state != .idle
    }

    @ObservationIgnored
    private var engine: AVAudioEngine?

    @ObservationIgnored
    private var request: SFSpeechAudioBufferRecognitionRequest?

    @ObservationIgnored
    private var recognitionTask: SFSpeechRecognitionTask?

    @ObservationIgnored
    private var recognizer: SFSpeechRecognizer?

    @ObservationIgnored
    private var timeoutTask: Task<Void, Never>?

    @ObservationIgnored
    private var observers: [NSObjectProtocol] = []

    @ObservationIgnored
    private var sessionID: UUID?

    @ObservationIgnored
    private var hasTap = false

    @ObservationIgnored
    private var ownsAudioSession = false

    @ObservationIgnored
    private let logger = Logger(
        subsystem: "Koda",
        category: "Dictation"
    )

    // El llamador debe detener la lectura en voz alta antes de iniciar.
    func start() async {
        guard !isActive else { return }

        let id = UUID()
        sessionID = id
        transcript = ""
        errorMessage = nil
        state = .requestingPermission

        do {
            guard let recognizer = SFSpeechRecognizer(
                locale: Locale(identifier: "es-MX")
            ), recognizer.supportsOnDeviceRecognition else {
                fail(
                    """
                    El dictado local en español no está disponible \
                    en este dispositivo.
                    """
                )
                return
            }

            try await KodaSpeechPermissions.request()
            try Task.checkCancellation()

            guard sessionID == id else { return }

            guard UIApplication.shared.applicationState == .active else {
                cancel()
                return
            }

            guard recognizer.isAvailable,
                  recognizer.supportsOnDeviceRecognition else {
                fail(
                    """
                    El reconocimiento local no está disponible ahora. \
                    Puedes escribir tu pregunta.
                    """
                )
                return
            }

            self.recognizer = recognizer

            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .record,
                mode: .measurement
            )
            try audioSession.setActive(true)
            ownsAudioSession = true

            let engine = AVAudioEngine()
            self.engine = engine

            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)

            guard format.sampleRate > 0,
                  format.channelCount > 0 else {
                fail("No hay una entrada de micrófono disponible.")
                return
            }

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.requiresOnDeviceRecognition = true
            request.shouldReportPartialResults = true
            request.taskHint = .dictation
            self.request = request

            // Este callback procesa audio fuera del actor principal.
            input.installTap(
                onBus: 0,
                bufferSize: 1024,
                format: format
            ) { @Sendable buffer, _ in
                request.append(buffer)
            }

            hasTap = true

            recognitionTask = recognizer.recognitionTask(
                with: request
            ) { @Sendable [weak self] result, error in
                // Solo transferimos valores simples a la interfaz.
                let text = result?.bestTranscription.formattedString
                let isFinal = result?.isFinal ?? false
                let failed = error != nil

                Task { @MainActor [weak self] in
                    guard let self,
                          self.sessionID == id else {
                        return
                    }

                    if let text {
                        self.transcript = text
                    }

                    if isFinal {
                        self.complete()
                    } else if failed {
                        self.fail(
                            """
                            El dictado se interrumpió. Revisa el texto \
                            o vuelve a intentarlo.
                            """
                        )
                    }
                }
            }

            engine.prepare()
            try engine.start()

            state = .listening
            observeInterruptions(id: id)
            scheduleTimeout(seconds: 45, id: id)
        } catch {
            guard sessionID == id else { return }

            if error is CancellationError {
                cancel()
            } else if let permissionError =
                        error as? KodaSpeechPermissionError {
                fail(permissionError.localizedDescription)
            } else {
                logger.error(
                    "No se pudo iniciar el dictado: \(String(describing: error), privacy: .private)"
                )

                fail(
                    """
                    No se pudo iniciar el micrófono. \
                    Vuelve a intentarlo o escribe tu pregunta.
                    """
                )
            }
        }
    }

    // Deja de capturar audio y espera brevemente el resultado final.
    func finish() {
        guard state == .listening,
              let id = sessionID else {
            return
        }

        state = .finishing
        stopMicrophone()
        request?.endAudio()

        scheduleTimeout(seconds: 4, id: id)
    }

    // Conserva el texto parcial. No lo envía al profesor.
    func cancel() {
        releaseResources()
        errorMessage = nil
    }

    private func complete() {
        releaseResources()

        if transcript.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty {
            errorMessage = """
            No se detectaron palabras. Intenta hablar de nuevo.
            """
        }
    }

    private func fail(_ message: String) {
        releaseResources()
        errorMessage = message
    }

    private func stopMicrophone() {
        engine?.stop()

        if hasTap {
            engine?.inputNode.removeTap(onBus: 0)
            hasTap = false
        }
    }

    private func releaseResources() {
        // Invalida callbacks pendientes antes de cancelar la tarea.
        sessionID = nil

        timeoutTask?.cancel()
        timeoutTask = nil

        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()

        stopMicrophone()
        request?.endAudio()
        recognitionTask?.cancel()

        recognitionTask = nil
        request = nil
        recognizer = nil
        engine = nil

        if ownsAudioSession {
            do {
                try AVAudioSession.sharedInstance().setActive(
                    false,
                    options: .notifyOthersOnDeactivation
                )
            } catch {
                logger.error(
                    "No se pudo desactivar el audio: \(String(describing: error), privacy: .private)"
                )
            }

            ownsAudioSession = false
        }

        state = .idle
    }

    private func scheduleTimeout(
        seconds: Int,
        id: UUID
    ) {
        timeoutTask?.cancel()

        timeoutTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(for: .seconds(seconds))
            } catch {
                return
            }

            guard let self,
                  self.sessionID == id else {
                return
            }

            if self.state == .listening {
                self.finish()
            } else if self.state == .finishing {
                self.fail(
                    """
                    No llegó el resultado final. Puedes revisar \
                    y usar el texto parcial.
                    """
                )
            }
        }
    }

    private func observeInterruptions(id: UUID) {
        let center = NotificationCenter.default

        for name in [
            AVAudioSession.interruptionNotification,
            AVAudioSession.routeChangeNotification,
            UIApplication.didEnterBackgroundNotification
        ] {
            let observer = center.addObserver(
                forName: name,
                object: nil,
                queue: .main
            ) { @Sendable [weak self] notification in
                if notification.name ==
                    AVAudioSession.routeChangeNotification {
                    let reason = notification.userInfo?[
                        AVAudioSessionRouteChangeReasonKey
                    ] as? UInt

                    guard reason ==
                        AVAudioSession.RouteChangeReason
                            .oldDeviceUnavailable.rawValue else {
                        return
                    }
                }

                Task { @MainActor [weak self] in
                    guard let self,
                          self.sessionID == id else {
                        return
                    }

                    self.fail(
                        """
                        El dictado se detuvo por un cambio de audio \
                        o al salir de la app. Revisa el texto \
                        antes de continuar.
                        """
                    )
                }
            }

            observers.append(observer)
        }
    }
}
