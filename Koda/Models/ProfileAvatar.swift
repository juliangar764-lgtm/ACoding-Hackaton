//
//  ProfileAvatar.swift
//  Koda
//
//  Created by ADMIN UNACH on 21/09/26.
//

import Foundation

enum ProfileAvatar: String, CaseIterable, Identifiable {
    case alex = "avatarAlex"
    case sofia = "avatarSofia"
    case leo = "avatarLeo"
    case valeria = "avatarValeria"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .alex:
            return "Alex"
        case .sofia:
            return "Sofía"
        case .leo:
            return "Leo"
        case .valeria:
            return "Valeria"
        }
    }
}
