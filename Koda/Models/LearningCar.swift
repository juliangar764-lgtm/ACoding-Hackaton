//
//  LearningCar.swift
//  Koda
//
//  Created by ADMIN UNACH on 24/09/26.
//

import Observation

@MainActor
@Observable
final class LearningCar {
    enum PaintColor: String, CaseIterable, Identifiable {
        case red = "rojo"
        case blue = "azul"
        case green = "verde"

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .red:
                return "Rojo"
            case .blue:
                return "Azul"
            case .green:
                return "Verde"
            }
        }
    }

    enum DoorCount: Int, CaseIterable, Identifiable {
        case two = 2
        case four = 4

        var id: Int {
            rawValue
        }
    }

    var color: PaintColor
    var doors: DoorCount

    private(set) var isRunning = false

    init(
        color: PaintColor = .blue,
        doors: DoorCount = .four
    ) {
        self.color = color
        self.doors = doors
    }

    func start() {
        isRunning = true
    }

    func stop() {
        isRunning = false
    }
}
