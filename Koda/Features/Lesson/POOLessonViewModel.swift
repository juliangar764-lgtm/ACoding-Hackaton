//
//  POOLessonViewModel.swift
//  Koda
//
//  Created by ADMIN UNACH on 24/09/26.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class POOLessonViewModel {
    let lesson: POOLesson

    private(set) var step: POOLesson.Step = .explanation
    private(set) var selectedAnswerID: String?
    private(set) var hasChecked = false
    private(set) var hasLoaded = false
    private(set) var isBusy = false
    private(set) var isCompleted = false
    private(set) var earnedExperiencePoints = 0
    private(set) var errorMessage: String?

    private let saveChanges: (ModelContext) throws -> Void

    init(
        lesson: POOLesson,
        saveChanges: @escaping (ModelContext) throws -> Void = {
            try $0.save()
        }
    ) {
        self.lesson = lesson
        self.saveChanges = saveChanges
    }

    var isAnswerCorrect: Bool {
        guard hasChecked, let selectedAnswerID else {
            return false
        }

        return lesson.exercise.isCorrect(
            answerID: selectedAnswerID
        )
    }

    var feedback: String? {
        guard hasChecked, let selectedAnswerID else {
            return nil
        }

        return lesson.exercise
            .answer(withID: selectedAnswerID)?
            .feedback
    }

    var canCheckAnswer: Bool {
        guard hasLoaded,
              !isBusy,
              step == .practice,
              !hasChecked,
              let selectedAnswerID else {
            return false
        }

        return lesson.exercise.answer(
            withID: selectedAnswerID
        ) != nil
    }

    var canAdvance: Bool {
        guard hasLoaded, !isBusy else {
            return false
        }

        switch step {
        case .explanation, .exploration:
            return true

        case .practice:
            return isAnswerCorrect

        case .result:
            return false
        }
    }

    var canGoBack: Bool {
        hasLoaded
            && !isBusy
            && (step == .exploration || step == .practice)
    }

    // MARK: - Carga y reanudación

    @discardableResult
    func load(using context: ModelContext) -> Bool {
        guard !hasLoaded else {
            return true
        }

        guard !isBusy else {
            return false
        }

        isBusy = true
        errorMessage = nil

        defer {
            isBusy = false
        }

        do {
            let record: TopicProgress

            if let existing = try findProgress(in: context) {
                record = existing
            } else {
                let created = TopicProgress(topic: lesson.topic)
                context.insert(created)

                do {
                    try saveChanges(context)
                } catch {
                    context.delete(created)
                    throw error
                }

                record = created
            }

            isCompleted = record.isCompleted

            if isCompleted {
                step = .result
            } else {
                let savedStep = POOLesson.Step(
                    rawValue: record.currentStep
                ) ?? .explanation

                // Un paso final sin fecha de finalización
                // no acredita el tema.
                step = savedStep == .result
                    ? .practice
                    : savedStep
            }

            resetAnswer()
            earnedExperiencePoints = 0
            hasLoaded = true

            return true
        } catch {
            errorMessage = "No pudimos abrir la lección. Vuelve a intentarlo."
            return false
        }
    }

    // MARK: - Ejercicio

    func selectAnswer(_ answerID: String) {
        guard hasLoaded,
              !isBusy,
              step == .practice,
              !hasChecked,
              lesson.exercise.answer(withID: answerID) != nil else {
            return
        }

        selectedAnswerID = answerID
        errorMessage = nil
    }

    func checkAnswer() {
        guard canCheckAnswer else {
            return
        }

        hasChecked = true
    }

    func retryAnswer() {
        guard hasLoaded, !isBusy, step == .practice else {
            return
        }

        resetAnswer()
        errorMessage = nil
    }

    // MARK: - Navegación

    @discardableResult
    func advance(using context: ModelContext) -> Bool {
        guard canAdvance else {
            return false
        }

        switch step {
        case .explanation:
            return move(to: .exploration, using: context)

        case .exploration:
            return move(to: .practice, using: context)

        case .practice:
            return move(to: .result, using: context)

        case .result:
            return false
        }
    }

    @discardableResult
    func goBack(using context: ModelContext) -> Bool {
        guard canGoBack else {
            return false
        }

        switch step {
        case .exploration:
            return move(to: .explanation, using: context)

        case .practice:
            return move(to: .exploration, using: context)

        case .explanation, .result:
            return false
        }
    }

    func restartReview() {
        guard hasLoaded, !isBusy, isCompleted else {
            return
        }

        step = .explanation
        resetAnswer()
        earnedExperiencePoints = 0
        errorMessage = nil
    }

    private func move(
        to nextStep: POOLesson.Step,
        using context: ModelContext
    ) -> Bool {
        isBusy = true
        errorMessage = nil

        defer {
            isBusy = false
        }

        do {
            let completedNow = try persistProgress(
                at: nextStep,
                using: context
            )

            step = nextStep
            resetAnswer()

            if nextStep == .result {
                isCompleted = true

                earnedExperiencePoints = completedNow
                    ? LearningProgressSummary.pointsPerCompletedTopic
                    : 0
            }

            return true
        } catch {
            // Conserva el paso y la respuesta para
            // permitir reintentar el guardado.
            errorMessage = "No pudimos guardar tu avance. Vuelve a intentarlo."
            return false
        }
    }

    // MARK: - Persistencia

    private func findProgress(
        in context: ModelContext
    ) throws -> TopicProgress? {
        let topicID = lesson.id

        var descriptor = FetchDescriptor<TopicProgress>(
            predicate: #Predicate {
                $0.topicID == topicID
            }
        )

        descriptor.fetchLimit = 1

        return try context.fetch(descriptor).first
    }

    private func persistProgress(
        at nextStep: POOLesson.Step,
        using context: ModelContext
    ) throws -> Bool {
        let existing = try findProgress(in: context)

        // Un repaso conserva la finalización original
        // y no concede más XP.
        if existing?.isCompleted == true {
            return false
        }

        let record = existing ?? TopicProgress(
            topic: lesson.topic
        )

        let isNew = existing == nil
        let previousStep = record.currentStep
        let previousCompletion = record.completedAt

        if isNew {
            context.insert(record)
        }

        record.currentStep = nextStep.rawValue

        if nextStep == .result {
            record.completedAt = Date()
        }

        do {
            try saveChanges(context)
        } catch {
            if isNew {
                context.delete(record)
            } else {
                record.currentStep = previousStep
                record.completedAt = previousCompletion
            }

            throw error
        }

        return nextStep == .result
    }

    private func resetAnswer() {
        selectedAnswerID = nil
        hasChecked = false
    }
}
