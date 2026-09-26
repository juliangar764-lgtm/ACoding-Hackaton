//
//  AppTap.swift
//  Koda
//
//  Created by ADMIN UNACH on 23/09/26.
//

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case topics
    case progress
    case profile

    var id: Self {
        self
    }

    // MARK: - Nombre visible

    var title: String {
        switch self {
        case .home:
            return "Inicio"

        case .topics:
            return "Temas"

        case .progress:
            return "Progreso"

        case .profile:
            return "Perfil"
        }
    }

    // MARK: - Icono del sistema

    var systemImage: String {
        switch self {
        case .home:
            return "house"

        case .topics:
            return "book.closed"

        case .progress:
            return "chart.bar"

        case .profile:
            return "person.crop.circle"
        }
    }
}
