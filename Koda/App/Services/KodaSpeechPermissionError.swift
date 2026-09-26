//
//  KodaSpeechPermissionError.swift
//  Koda
//
//  Created by ADMIN UNACH on 25/09/26.
//

import Foundation
import AVFAudio
import Speech

enum KodaSpeechPermissionError: LocalizedError {
    case missingDescription(String)
    case microphoneDenied
    case speechDenied
    case speechRestricted
    case unavailable

    var errorDescription: String? {
        switch self {
        case .missingDescription(let key):
            return "Falta configurar \(key) en la información de la app."

        case .microphoneDenied:
            return """
            Permite el acceso al micrófono en Ajustes para hablar con Koda. \
            Puedes seguir escribiendo.
            """

        case .speechDenied:
            return """
            Permite el reconocimiento de voz en Ajustes para convertir \
            tu voz en texto. Puedes seguir escribiendo.
            """

        case .speechRestricted:
            return """
            El reconocimiento de voz está restringido en este dispositivo. \
            Puedes escribir tu pregunta.
            """

        case .unavailable:
            return """
            No se pudieron obtener los permisos de voz. \
            Puedes escribir tu pregunta.
            """
        }
    }
}

@MainActor
enum KodaSpeechPermissions {
    // Llamar únicamente cuando el estudiante pulse el micrófono.
    static func request() async throws {
        try Task.checkCancellation()
        try validatePurposeStrings()

        // Evita otro aviso si ya hay un permiso denegado o restringido.
        try validateSpeechStatus(
            SFSpeechRecognizer.authorizationStatus()
        )

        if AVAudioApplication.shared.recordPermission == .denied {
            throw KodaSpeechPermissionError.microphoneDenied
        }

        var speechStatus = SFSpeechRecognizer.authorizationStatus()

        if speechStatus == .notDetermined {
            speechStatus = await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status)
                }
            }
        }

        try Task.checkCancellation()
        try validateSpeechStatus(speechStatus)

        guard speechStatus == .authorized else {
            throw KodaSpeechPermissionError.unavailable
        }

        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            break

        case .denied:
            throw KodaSpeechPermissionError.microphoneDenied

        case .undetermined:
            let granted = await AVAudioApplication.requestRecordPermission()

            try Task.checkCancellation()

            guard granted else {
                throw KodaSpeechPermissionError.microphoneDenied
            }

        @unknown default:
            throw KodaSpeechPermissionError.unavailable
        }

        try Task.checkCancellation()
    }

    private static func validateSpeechStatus(
        _ status: SFSpeechRecognizerAuthorizationStatus
    ) throws {
        switch status {
        case .authorized, .notDetermined:
            break

        case .denied:
            throw KodaSpeechPermissionError.speechDenied

        case .restricted:
            throw KodaSpeechPermissionError.speechRestricted

        @unknown default:
            throw KodaSpeechPermissionError.unavailable
        }
    }

    private static func validatePurposeStrings() throws {
        for key in [
            "NSMicrophoneUsageDescription",
            "NSSpeechRecognitionUsageDescription"
        ] {
            guard let value = Bundle.main.object(
                forInfoDictionaryKey: key
            ) as? String,
            !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw KodaSpeechPermissionError.missingDescription(key)
            }
        }
    }
}
