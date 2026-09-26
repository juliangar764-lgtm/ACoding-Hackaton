//
//  EncapsulationExplorationView.swift
//  Koda
//
//  Created by ADMIN UNACH on 25/09/26.
//

import SwiftUI

@MainActor
struct EncapsulationExplorationView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var bank = LearningPiggyBank()
    @State private var result: OperationResult?

    private let onExampleStateChange: (String) -> Void

    init(
        onExampleStateChange: @escaping (String) -> Void = { _ in }
    ) {
        self.onExampleStateChange = onExampleStateChange
    }

    // MARK: - Operaciones

    private enum Operation: Equatable {
        case deposit
        case withdraw

        var title: String {
            self == .deposit ? "Depositar 10" : "Retirar 10"
        }

        var symbol: String {
            self == .deposit
                ? "plus.circle.fill"
                : "minus.circle.fill"
        }

        var code: String {
            self == .deposit
                ? "try miAlcancia.depositar(10)"
                : "try miAlcancia.retirar(10)"
        }
    }

    private struct OperationResult {
        let accepted: Bool
        let code: String
        let explanation: String
        let previousBalance: Int
        let resultingBalance: Int
    }

    // MARK: - Estado para el profesor

    private var currentExampleState: String {
        let lastOperation: String

        if let result {
            lastOperation = """
            Llamada: \(result.code)
            Resultado: \(result.accepted ? "aceptada" : "rechazada")
            Saldo anterior: \(result.previousBalance) monedas
            Saldo después del intento: \(result.resultingBalance) monedas
            Explicación mostrada: \(result.explanation)
            """
        } else {
            lastOperation = """
            Todavía no se ha intentado ninguna operación.
            """
        }

        return """
        Ejemplo visible: encapsulación en el objeto miAlcancia.
        Saldo actual: \(bank.balance) monedas.
        El saldo es privado y saldoActual permite consultarlo.
        Los botones llaman a depositar(10) y retirar(10).
        Los métodos validan la operación antes de modificar el saldo.

        Última operación intentada:
        \(lastOperation)

        No se proporciona un historial completo de operaciones.
        Las monedas pertenecen al ejemplo educativo, no al progreso ni a los XP.
        """
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 12) {
                Text("Mi alcancía")
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)

                Text("🐷")
                    .font(.system(size: 96))
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundStyle(KodaPalette.blue)
                    }
                    .accessibilityHidden(true)

                Text("Saldo: \(bank.balance) monedas")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Label(
                    "El saldo no se modifica directamente",
                    systemImage: "lock.shield"
                )
                .font(.subheadline)
                .foregroundStyle(KodaPalette.secondary)
                .multilineTextAlignment(.center)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .kodaPanel(fill: KodaPalette.paleBlue)

            controls

            Text(
                """
                Prueba a retirar cuando el saldo llegue a 0. \
                La alcancía rechazará la operación.
                """
            )
            .font(.subheadline)
            .foregroundStyle(KodaPalette.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Consultar el saldo")
                    .font(.headline)

                KodaCodeCard(
                    code: "miAlcancia.saldoActual // \(bank.balance)"
                )

                Text(
                    """
                    saldoActual permite leer el valor. Para cambiarlo, \
                    usamos los métodos de la alcancía.
                    """
                )
                .font(.subheadline)
                .foregroundStyle(KodaPalette.secondary)
            }

            if let result {
                resultCard(result)
            }

            KodaTeacherMessage(
                message: result?.explanation
                    ?? """
                    La encapsulación permite controlar cómo se modifica \
                    un dato. Esta alcancía mantiene su saldo privado \
                    y valida cada depósito y retiro.
                    """
            )
        }
        .foregroundStyle(KodaPalette.ink)
        .onChange(
            of: currentExampleState,
            initial: true
        ) { _, newState in
            onExampleStateChange(newState)
        }
    }

    // MARK: - Controles

    private var controls: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))

        return layout {
            operationButton(.deposit)
            operationButton(.withdraw)
        }
    }

    private func operationButton(
        _ operation: Operation
    ) -> some View {
        Button {
            perform(operation)
        } label: {
            Label(
                operation.title,
                systemImage: operation.symbol
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
        .tint(
            operation == .deposit
                ? KodaPalette.green
                : KodaPalette.purple
        )
        .accessibilityLabel(
            "\(operation.title) monedas"
        )
    }

    // MARK: - Resultado de la operación

    private func resultCard(
        _ result: OperationResult
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                result.accepted
                    ? "Operación aceptada"
                    : "Operación rechazada",
                systemImage: result.accepted
                    ? "checkmark.circle.fill"
                    : "exclamationmark.shield.fill"
            )
            .font(.headline)
            .foregroundStyle(
                result.accepted
                    ? KodaPalette.green
                    : KodaPalette.purple
            )
            .accessibilityAddTraits(.isHeader)

            Text(
                "Saldo anterior: \(result.previousBalance) monedas"
            )

            Text(
                "Saldo después del intento: \(result.resultingBalance) monedas"
            )

            KodaCodeCard(code: result.code)
        }
        .font(.subheadline)
        .padding(16)
        .kodaPanel()
    }

    // MARK: - Ejecutar la operación

    private func perform(_ operation: Operation) {
        let previousBalance = bank.balance
        let accepted: Bool
        let explanation: String

        do {
            switch operation {
            case .deposit:
                try bank.deposit(10)

            case .withdraw:
                try bank.withdraw(10)
            }

            accepted = true

            explanation = """
            El método validó la operación antes de modificar el saldo. \
            Pasó de \(previousBalance) a \(bank.balance) monedas. \
            Podemos consultar el saldo desde fuera, pero solo \
            la alcancía modifica su dato privado.
            """
        } catch let error as LearningPiggyBank.OperationError {
            accepted = false

            explanation = """
            \(error.explanation) El saldo se mantiene en \
            \(bank.balance) monedas. El método rechazó el cambio \
            para conservar un estado válido.
            """
        } catch {
            accepted = false
            explanation = """
            No se pudo completar la operación. Vuelve a intentarlo.
            """
        }

        result = OperationResult(
            accepted: accepted,
            code: operation.code,
            explanation: explanation,
            previousBalance: previousBalance,
            resultingBalance: bank.balance
        )
    }
}

#Preview("Explorar la encapsulación") {
    ScrollView {
        EncapsulationExplorationView()
            .padding(20)
    }
    .kodaScreen()
    .preferredColorScheme(.light)
}
