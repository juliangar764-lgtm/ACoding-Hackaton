//
//  FundamentalsReviewModel.swift
//  Koda
//
//  Created by ADMIN UNACH on 22/09/26.
//

import Observation
import SwiftData

@MainActor
@Observable
final class FundamentalsReviewViewModel {
    var selectedAnswer: Int?

    private(set) var hasChecked = false
    private(set) var errorMessage: String?

    func checkAnswer(for lesson: FundamentalsLesson) {
        guard let selectedAnswer,
              lesson.answers.indices.contains(selectedAnswer) else {
            return
        }

        hasChecked = true
    }

    func isCorrect(for lesson: FundamentalsLesson) -> Bool {
        hasChecked && selectedAnswer == lesson.correctAnswer
    }

    func retry() {
        selectedAnswer = nil
        hasChecked = false
        errorMessage = nil
    }

    @discardableResult
    func advance(
        profile: StudentProfile,
        context: ModelContext
    ) -> Bool {
        let index = max(0, profile.fundamentalsStep ?? 0)

        guard FundamentalsLesson.lessons.indices.contains(index),
              isCorrect(for: FundamentalsLesson.lessons[index]) else {
            return false
        }

        let previousStep = profile.fundamentalsStep

        profile.fundamentalsStep = index + 1
        errorMessage = nil

        do {
            try context.save()
            retry()
            return true
        } catch {
            profile.fundamentalsStep = previousStep
            errorMessage = "No pudimos guardar tu avance. Vuelve a intentarlo."
            return false
        }
    }
}
