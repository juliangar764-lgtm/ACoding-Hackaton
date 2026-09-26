//
//  InheritanceExplorationView.swift
//  Koda
//
//  Created by ADMIN UNACH on 25/09/26.
//

import SwiftUI

@MainActor
struct InheritanceExplorationView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var selection: AnimalChoice = .dog
    @State private var result: ActionResult?

    private let dog = LearningDog(name: "Toby")
    private let cat = LearningCat(name: "Luna")

    private let onExampleStateChange: (String) -> Void

    init(
        onExampleStateChange: @escaping (String) -> Void = { _ in }
    ) {
        self.onExampleStateChange = onExampleStateChange
    }

    // MARK: - Animales disponibles

    private enum AnimalChoice: String, CaseIterable, Identifiable {
        case dog
        case cat

        var id: String {
            rawValue
        }

        var title: String {
            self == .dog ? "Perro" : "Gato"
        }

        var emoji: String {
            self == .dog ? "🐶" : "🐱"
        }

        var variableName: String {
            self == .dog ? "miPerro" : "miGato"
        }

        var ownMethod: String {
            self == .dog ? "ladrar()" : "maullar()"
        }
    }

    private enum InheritedAction: String, CaseIterable, Identifiable {
        case eat = "comer()"
        case sleep = "dormir()"

        var id: String {
            rawValue
        }
    }

    private struct ActionResult {
        let code: String
        let message: String
        let explanation: String
    }

    private var selectedAnimal: LearningAnimal {
        switch selection {
        case .dog:
            return dog

        case .cat:
            return cat
        }
    }

    private var adaptiveLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))
    }

    // MARK: - Estado para el profesor

    private var currentExampleState: String {
        let visibleAction: String

        if let result {
            visibleAction = """
            Llamada: \(result.code)
            Respuesta mostrada: \(result.message)
            Explicación: \(result.explanation)
            """
        } else {
            visibleAction = """
            No hay un resultado visible para la selección actual.
            """
        }

        return """
        Ejemplo visible: herencia entre Animal, Perro y Gato.
        Clase base: Animal.
        Clases hijas: Perro y Gato.

        Objeto seleccionado: \(selection.variableName).
        Clase del objeto: \(selection.title).
        Nombre del animal: \(selectedAnimal.name).
        Métodos heredados disponibles en esta pantalla: comer() y dormir().
        Método propio disponible: \(selection.ownMethod).

        Última acción mostrada:
        \(visibleAction)

        Al cambiar de animal se limpia el resultado anterior.
        No se proporciona un historial completo de acciones.
        Los métodos de este ejemplo devuelven mensajes de texto.
        """
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            hierarchy

            Text("Prueba con \(selectedAnimal.name)")
                .font(.title3.bold())
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 12) {
                Text("Métodos heredados de Animal")
                    .font(.headline)

                adaptiveLayout {
                    ForEach(InheritedAction.allCases) { action in
                        Button {
                            perform(action)
                        } label: {
                            Text(action.rawValue)
                                .font(
                                    .system(
                                        .body,
                                        design: .monospaced
                                    )
                                )
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: 44
                                )
                        }
                        .accessibilityLabel(
                            "\(selectedAnimal.name): ejecutar \(action.rawValue), heredado de Animal"
                        )
                    }
                }
                .buttonStyle(.bordered)
                .tint(KodaPalette.blue)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Método propio de \(selection.title)")
                    .font(.headline)

                Button {
                    performOwnMethod()
                } label: {
                    Text(selection.ownMethod)
                        .font(
                            .system(
                                .body,
                                design: .monospaced
                            )
                        )
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 44
                        )
                }
                .buttonStyle(.bordered)
                .tint(KodaPalette.purple)
                .accessibilityLabel(
                    "\(selectedAnimal.name): ejecutar \(selection.ownMethod), propio de \(selection.title)"
                )
            }

            if let result {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Resultado")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    Text(result.message)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(16)
                        .kodaPanel(fill: KodaPalette.paleBlue)

                    KodaCodeCard(code: result.code)
                }
            }

            KodaTeacherMessage(
                message: result?.explanation
                    ?? """
                    Selecciona Perro o Gato. Ambos heredan comer() \
                    y dormir() de Animal; cada uno añade un método propio.
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

    // MARK: - Jerarquía de clases

    private var hierarchy: some View {
        VStack(spacing: 14) {
            VStack(spacing: 8) {
                Label(
                    "Animal",
                    systemImage: "pawprint.fill"
                )
                .font(.title2.bold())

                Text("Clase base")
                    .font(.subheadline)

                Text("comer() · dormir()")
                    .font(
                        .system(
                            .subheadline,
                            design: .monospaced
                        )
                    )
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .kodaPanel(fill: KodaPalette.paleBlue)

            Image(systemName: "arrow.down")
                .foregroundStyle(KodaPalette.blue)
                .accessibilityHidden(true)

            adaptiveLayout {
                ForEach(AnimalChoice.allCases) { choice in
                    animalButton(choice)
                }
            }
        }
    }

    private func animalButton(
        _ choice: AnimalChoice
    ) -> some View {
        let selected = selection == choice

        return Button {
            guard selection != choice else {
                return
            }

            selection = choice

            // Evita mostrar el resultado del animal anterior
            // como si perteneciera al recién seleccionado.
            result = nil
        } label: {
            VStack(spacing: 8) {
                Text(choice.emoji)
                    .font(.system(size: 48))
                    .accessibilityHidden(true)

                Text(choice.title)
                    .font(.headline)

                Text("Hereda de Animal")
                    .font(.caption)

                Image(
                    systemName: selected
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .accessibilityHidden(true)
            }
            .foregroundStyle(
                selected
                    ? KodaPalette.blue
                    : KodaPalette.ink
            )
            .padding(16)
            .frame(
                maxWidth: .infinity,
                minHeight: 44
            )
            .kodaPanel(
                fill: selected
                    ? KodaPalette.paleBlue
                    : .white,
                border: selected
                    ? KodaPalette.blue
                    : KodaPalette.line
            )
            .contentShape(
                RoundedRectangle(cornerRadius: 20)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(
            selected ? .isSelected : []
        )
        .accessibilityHint(
            "Seleccionar para probar sus métodos"
        )
    }

    // MARK: - Ejecutar métodos heredados

    private func perform(_ action: InheritedAction) {
        let message: String

        switch action {
        case .eat:
            message = selectedAnimal.eat()

        case .sleep:
            message = selectedAnimal.sleep()
        }

        result = ActionResult(
            code: "\(selection.variableName).\(action.rawValue)",
            message: message,
            explanation: """
            \(selection.title) puede ejecutar \(action.rawValue) \
            porque lo hereda de Animal. No tuvimos que volver \
            a definir ese método en la clase hija.
            """
        )
    }

    // MARK: - Ejecutar el método propio

    private func performOwnMethod() {
        let message: String

        switch selection {
        case .dog:
            message = dog.bark()

        case .cat:
            message = cat.meow()
        }

        result = ActionResult(
            code: "\(selection.variableName).\(selection.ownMethod)",
            message: message,
            explanation: """
            \(selection.ownMethod) está definido en \(selection.title). \
            La clase hija añade esta acción y conserva los métodos \
            que hereda de Animal.
            """
        )
    }
}

#Preview("Explorar la herencia") {
    ScrollView {
        InheritanceExplorationView()
            .padding(20)
    }
    .kodaScreen()
    .preferredColorScheme(.light)
}
