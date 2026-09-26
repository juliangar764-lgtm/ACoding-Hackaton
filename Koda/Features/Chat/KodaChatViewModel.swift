//
//  KodaChatViewModel.swift
//  Koda
//
//  Created by ADMIN UNACH on 25/09/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class KodaChatViewModel {

    // MARK: - Mensajes

    struct Message: Identifiable, Equatable, Sendable {
        enum Role: Equatable, Sendable {
            case student
            case koda
        }

        enum DeliveryState: Equatable, Sendable {
            case pending
            case delivered
            case failed
            case cancelled
        }

        let id = UUID()
        let role: Role
        let text: String
        var deliveryState: DeliveryState = .delivered
    }

    enum RequestState: Equatable {
        case idle
        case responding
        case cancelling
    }

    // MARK: - Estado de la pantalla

    // Una instancia representa el chat de este contexto de lección.
    let context: KodaTutorContext

    var draft = ""

    private(set) var messages: [Message] = []
    private(set) var requestState: RequestState = .idle
    private(set) var availability: KodaTutorAvailability
    private(set) var errorMessage: String?
    private(set) var retryMessageID: UUID?

    @ObservationIgnored
    private let tutor: any KodaTutoring

    @ObservationIgnored
    private var responseTask: Task<Void, Never>?

    init(
        context: KodaTutorContext,
        tutor: (any KodaTutoring)? = nil
    ) {
        let selectedTutor = tutor ?? KodaTutorService()

        self.context = context
        self.tutor = selectedTutor
        availability = selectedTutor.availability
    }

    deinit {
        responseTask?.cancel()
    }

    // MARK: - Validación y disponibilidad

    var maximumQuestionLength: Int {
        KodaTutorService.maximumQuestionLength
    }

    var questionLength: Int {
        cleanDraft.count
    }

    var isSending: Bool {
        requestState != .idle
    }

    var canSend: Bool {
        !isSending
            && availability == .available
            && !cleanDraft.isEmpty
            && questionLength <= maximumQuestionLength
    }

    var canRetry: Bool {
        !isSending
            && availability == .available
            && retryMessageID != nil
    }

    var unavailableMessage: String? {
        if case .unavailable(let reason) = availability {
            return reason
        }

        return nil
    }

    private var cleanDraft: String {
        draft.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    func refreshAvailability() {
        availability = tutor.availability
    }

    // MARK: - Enviar una pregunta

    @discardableResult
    func send() -> Task<Void, Never>? {
        guard !isSending else {
            return nil
        }

        let question = cleanDraft

        guard !question.isEmpty else {
            errorMessage = KodaTutorError
                .emptyQuestion
                .errorDescription

            return nil
        }

        guard question.count <= maximumQuestionLength else {
            errorMessage = KodaTutorError.questionTooLong(
                maximum: maximumQuestionLength
            ).errorDescription

            return nil
        }

        refreshAvailability()

        guard availability == .available else {
            errorMessage = unavailableMessage
            return nil
        }

        let message = Message(
            role: .student,
            text: question,
            deliveryState: .pending
        )

        messages.append(message)
        draft = ""

        return beginResponse(for: message)
    }

    // MARK: - Reintentar

    @discardableResult
    func retryLastQuestion() -> Task<Void, Never>? {
        guard !isSending,
              let retryMessageID,
              let message = messages.first(
                  where: { $0.id == retryMessageID }
              ),
              message.role == .student else {
            return nil
        }

        refreshAvailability()

        guard availability == .available else {
            errorMessage = unavailableMessage
            return nil
        }

        // Reutiliza la pregunta existente.
        // No añade otra burbuja con el mismo texto.
        return beginResponse(for: message)
    }

    // MARK: - Cancelar

    func cancelResponse() {
        guard requestState == .responding else {
            return
        }

        requestState = .cancelling
        responseTask?.cancel()
    }

    // MARK: - Ciclo de la solicitud

    private func beginResponse(
        for message: Message
    ) -> Task<Void, Never> {
        errorMessage = nil
        retryMessageID = nil
        requestState = .responding

        setDeliveryState(.pending, for: message.id)

        let task = Task {
            @MainActor [weak self, tutor, context] in

            defer {
                self?.requestState = .idle
                self?.responseTask = nil
            }

            do {
                try Task.checkCancellation()

                let answer = try await tutor.respond(
                    to: message.text,
                    context: context
                )

                try Task.checkCancellation()

                let cleanAnswer = answer.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

                guard !cleanAnswer.isEmpty else {
                    throw KodaTutorError.emptyResponse
                }

                self?.setDeliveryState(
                    .delivered,
                    for: message.id
                )

                self?.messages.append(
                    Message(
                        role: .koda,
                        text: cleanAnswer
                    )
                )
            } catch {
                if error is CancellationError || Task.isCancelled {
                    self?.setDeliveryState(
                        .cancelled,
                        for: message.id
                    )

                    self?.retryMessageID = message.id
                } else {
                    self?.setDeliveryState(
                        .failed,
                        for: message.id
                    )

                    self?.retryMessageID = message.id

                    self?.errorMessage =
                        (error as? LocalizedError)?.errorDescription
                        ?? "No pudimos obtener la respuesta. Inténtalo de nuevo."

                    self?.refreshAvailability()
                }
            }
        }

        responseTask = task
        return task
    }

    private func setDeliveryState(
        _ state: Message.DeliveryState,
        for messageID: UUID
    ) {
        guard let index = messages.firstIndex(
            where: { $0.id == messageID }
        ) else {
            return
        }

        messages[index].deliveryState = state
    }
}
