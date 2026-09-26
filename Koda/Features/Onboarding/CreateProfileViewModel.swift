//
//  CreateProfileViewModel.swift
//  Koda
//
//  Created by ADMIN UNACH on 21/09/26.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class CreateProfileViewModel {

    // MARK: - Formulario

    var name = ""
    var selectedAvatar: ProfileAvatar?
    var errorMessage: String?

    private(set) var isSaving = false

    private var hasLoadedProfile = false

    // MARK: - Validación

    var cleanName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !cleanName.isEmpty &&
        cleanName.count <= 30 &&
        selectedAvatar != nil &&
        !isSaving
    }

    var nameValidationMessage: String? {
        cleanName.count > 30
            ? "Usa un nombre de hasta 30 caracteres."
            : nil
    }

    // MARK: - Recuperar perfil

    func loadProfile(using context: ModelContext) {
        guard !hasLoadedProfile else { return }

        do {
            if let profile = try findProfile(in: context) {
                name = profile.name

                selectedAvatar = ProfileAvatar(
                    rawValue: profile.avatarName
                )
            }

            hasLoadedProfile = true
            errorMessage = nil
        } catch {
            errorMessage = "No pudimos recuperar tu perfil."
        }
    }

    // MARK: - Guardar perfil

    func saveProfile(using context: ModelContext) -> Bool {
        guard canSave, let avatar = selectedAvatar else {
            return false
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        do {
            if let profile = try findProfile(in: context) {
                try update(
                    profile,
                    avatar: avatar,
                    using: context
                )
            } else {
                try insert(
                    avatar: avatar,
                    using: context
                )
            }

            name = cleanName
            return true
        } catch {
            errorMessage = """
            No pudimos guardar tu perfil. \
            Conservamos tus cambios en el formulario \
            para que puedas intentarlo de nuevo.
            """

            return false
        }
    }

    // MARK: - Actualizar perfil existente

    private func update(
        _ profile: StudentProfile,
        avatar: ProfileAvatar,
        using context: ModelContext
    ) throws {
        let previousName = profile.name
        let previousAvatar = profile.avatarName

        profile.name = cleanName
        profile.avatarName = avatar.rawValue

        do {
            try context.save()
        } catch {
            profile.name = previousName
            profile.avatarName = previousAvatar
            throw error
        }
    }

    // MARK: - Crear perfil nuevo

    private func insert(
        avatar: ProfileAvatar,
        using context: ModelContext
    ) throws {
        let profile = StudentProfile(
            name: cleanName,
            avatarName: avatar.rawValue
        )

        context.insert(profile)

        do {
            try context.save()
        } catch {
            context.delete(profile)
            throw error
        }
    }

    // MARK: - Buscar perfil local

    private func findProfile(
        in context: ModelContext
    ) throws -> StudentProfile? {
        var descriptor = FetchDescriptor<StudentProfile>(
            predicate: #Predicate {
                $0.id == "local-student"
            }
        )

        descriptor.fetchLimit = 1

        return try context.fetch(descriptor).first
    }
}
