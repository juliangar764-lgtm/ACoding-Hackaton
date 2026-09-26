//
//  KodaTutorContext.swift
//  Koda
//
//  Created by ADMIN UNACH on 25/09/26.
//

import Foundation

struct KodaTutorContext: Encodable, Equatable, Sendable {
    let topicID: String
    let topicTitle: String
    let stepTitle: String
    let lessonExplanation: String
    let referenceCode: String
    let learningGoals: [String]
    let activityDescription: String
    let currentExampleState: String?

    init(
        lesson: POOLesson,
        step: POOLesson.Step,
        currentExampleState: String? = nil
    ) {
        topicID = lesson.topic.id
        topicTitle = lesson.topic.title
        lessonExplanation = lesson.teacherMessage
        referenceCode = lesson.code
        learningGoals = lesson.learningGoals

        switch step {
        case .explanation:
            stepTitle = "Explicación"
            activityDescription = lesson.topic.explanation

        case .exploration:
            stepTitle = "Exploración interactiva"
            activityDescription = lesson.explorationPrompt

        case .practice:
            stepTitle = "Ejercicio"
            activityDescription = lesson.exercise.question

        case .result:
            stepTitle = "Resultado"
            activityDescription = """
            El estudiante ha completado el tema y puede repasarlo.
            """
        }

        // El estado real solo corresponde al paso de exploración.
        // No lo deducimos del código de referencia de la lección.
        if step == .exploration,
           let cleanState = currentExampleState?.trimmingCharacters(
               in: .whitespacesAndNewlines
           ),
           !cleanState.isEmpty {
            self.currentExampleState = cleanState
        } else {
            self.currentExampleState = nil
        }
    }
}
