//
//  KnowledgeCheckViewModel.swift
//  Koda
//
//  Created by ADMIN UNACH on 22/09/26.
//

import Observation
import SwiftData

enum ProgrammingExperience: CaseIterable, Identifiable, Hashable {
    case familiar
    case needsReview

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .familiar:
            return "Sí, conozco lo básico"

        case .needsReview:
            return "Necesito un repaso"
        }
    }

    var subtitle: String {
        switch self {
        case .familiar:
            return "Conozco variables, condiciones, bucles y funciones."

        case .needsReview:
            return "Quiero explorar estos conceptos antes de empezar POO."
        }
    }
}

@MainActor
@Observable
final class KnowledgeCheckViewModel {
    var selection: ProgrammingExperience?

    private(set) var errorMessage: String?

    @discardableResult
    func save(
        profile: StudentProfile,
        context: ModelContext
    ) -> Bool {
        guard let selection else {
            return false
        }

        let previousChoice = profile.needsBasicReview

        profile.needsBasicReview = selection == .needsReview
        errorMessage = nil

        do {
            try context.save()
            return true
        } catch {
            profile.needsBasicReview = previousChoice
            errorMessage = "No pudimos guardar tu elección. Vuelve a intentarlo."
            return false
        }
    }
}
