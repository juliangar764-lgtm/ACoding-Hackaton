//
//  LearningPiggyBank.swift
//  Koda
//
//  Created by ADMIN UNACH on 25/09/26.
//

import Observation

@MainActor
@Observable
final class LearningPiggyBank {
    enum OperationError: Error, Equatable {
        case invalidAmount
        case insufficientBalance
        case balanceOverflow

        var explanation: String {
            switch self {
            case .invalidAmount:
                return "La cantidad debe ser mayor que cero."

            case .insufficientBalance:
                return "No puedes retirar más monedas de las que tienes."

            case .balanceOverflow:
                return "La cantidad es demasiado grande. Prueba con una menor."
            }
        }
    }

    // Solo esta clase puede acceder directamente al saldo almacenado.
    private var storedBalance = 50

    // Permite consultar el saldo, pero no asignarle otro valor.
    var balance: Int {
        storedBalance
    }

    func deposit(_ amount: Int) throws {
        guard amount > 0 else {
            throw OperationError.invalidAmount
        }

        let (newBalance, overflow) =
            storedBalance.addingReportingOverflow(amount)

        guard !overflow else {
            throw OperationError.balanceOverflow
        }

        storedBalance = newBalance
    }

    func withdraw(_ amount: Int) throws {
        guard amount > 0 else {
            throw OperationError.invalidAmount
        }

        guard amount <= storedBalance else {
            throw OperationError.insufficientBalance
        }

        storedBalance -= amount
    }
}
