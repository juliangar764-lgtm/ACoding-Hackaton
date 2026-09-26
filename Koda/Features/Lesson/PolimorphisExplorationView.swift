//
//  PolimorphisExplorationView.swift
//  Koda
//
//  Created by ADMIN UNACH on 25/09/26.
//

import SwiftUI

@MainActor
struct PolymorphismExplorationView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var results: [SoundResult] = []

    private let onExampleStateChange: (String) -> Void

    init(
        onExampleStateChange: @escaping (String) -> Void = { _ in }
    ) {
        self.onExampleStateChange = onExampleStateChange
    }

    // MARK: - Ejemplos y resultados

    private struct AnimalExample: Identifiable {
        let id: String
        let title: String
        let emoji: String
        let animal: LearningAnimal

        var creationCode: String {
            "\(title)(nombre: \"\(animal.name)\")"
        }
    }

    private struct SoundResult: Identifiable {
        let id: String
        let title: String
        let message: String
        let creationCode: String
    }

    private let examples: [AnimalExample] = [
        AnimalExample(
            id: "dog",
            title: "Perro",
            emoji: "🐶",
            animal: LearningDog(name: "Toby")
        ),
        AnimalExample(
            id: "cat",
            title: "Gato",
            emoji: "🐱",
            animal: LearningCat(name: "Luna")
        ),
        AnimalExample(
            id: "cow",
            title: "Vaca",
            emoji: "🐮",
            animal: LearningCow(name: "Lola")
        )
    ]

    private var columns: [GridItem] {
        dynamicTypeSize.isAccessibilitySize
            ? [GridItem(.flexible())]
            : [
                GridItem(
                    .adaptive(minimum: 100),
                    spacing: 12
                )
            ]
    }

    // MARK: - Código visible

    private var exampleCode: String? {
        guard let first = results.first else {
            return nil
        }

        if results.count == 1 {
            return """
            let animal: Animal = \(first.creationCode)
            animal.hacerSonido()
            """
        }

        let creations = results
            .map(\.creationCode)
            .joined(separator: ",\n    ")

        return """
        let animales: [Animal] = [
            \(creations)
        ]

        for animal in animales {
            print(animal.hacerSonido())
        }
        """
    }

    // MARK: - Estado para el profesor

    private var currentExampleState: String {
        let visibleResults = results.isEmpty
            ? "Todavía no se ha probado ningún animal en este ejemplo."
            : results.map { result in
                "\(result.creationCode) → \(result.message)"
            }
            .joined(separator: "\n")

        return """
        Ejemplo visible: polimorfismo con Perro, Gato y Vaca.
        Método común: hacerSonido().
        Las referencias tienen tipo Animal y cada clase hija
        proporciona su propia implementación del método.

        Resultados visibles de la última prueba:
        \(visibleResults)

        Cada nueva prueba reemplaza los resultados anteriores.
        Probar un animal muestra solo su respuesta; Probar los tres
        muestra las respuestas de Perro, Gato y Vaca.
        Las respuestas se muestran como texto; no se reproducen sonidos de animales.
        No se proporciona un historial completo de pruebas.
        """
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 10) {
                Text("La misma llamada")
                    .font(.headline)

                Text("hacerSonido()")
                    .font(
                        .system(
                            .title2,
                            design: .monospaced,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(KodaPalette.blue)

                Text(
                    "Cada animal responde con su propia implementación."
                )
                .font(.subheadline)
                .foregroundStyle(KodaPalette.secondary)
                .multilineTextAlignment(.center)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .kodaPanel(fill: KodaPalette.paleBlue)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(examples) { example in
                    animalButton(example)
                }
            }

            KodaPrimaryAction(
                title: "Probar los tres",
                symbol: "play.fill"
            ) {
                results = examples.map {
                    makeResult(for: $0)
                }
            }

            if !results.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Respuestas")
                        .font(.title3.bold())
                        .accessibilityAddTraits(.isHeader)

                    ForEach(results) { result in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(result.title)
                                .font(.headline)

                            Text(result.message)
                                .font(.body)
                        }
                        .padding(16)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .kodaPanel()
                        .accessibilityElement(children: .combine)
                    }
                }
            }

            if let exampleCode {
                KodaCodeCard(code: exampleCode)
            }

            KodaTeacherMessage(
                message: results.isEmpty
                    ? """
                    Prueba un animal o los tres juntos. Siempre \
                    llamaremos a hacerSonido(), pero cada clase \
                    decidirá cómo responder.
                    """
                    : """
                    Usamos referencias de tipo Animal. Al llamar \
                    a hacerSonido(), se ejecuta la versión del objeto \
                    concreto: Perro, Gato o Vaca. Eso es polimorfismo.
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

    // MARK: - Probar un animal

    private func animalButton(
        _ example: AnimalExample
    ) -> some View {
        let included = results.contains {
            $0.id == example.id
        }

        return Button {
            results = [makeResult(for: example)]
        } label: {
            VStack(spacing: 8) {
                Text(example.emoji)
                    .font(.system(size: 48))
                    .accessibilityHidden(true)

                Text(example.title)
                    .font(.headline)

                Text(example.animal.name)
                    .font(.subheadline)

                Label(
                    "Probar",
                    systemImage: "play.circle"
                )
                .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(KodaPalette.ink)
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 44)
            .kodaPanel(
                fill: included
                    ? KodaPalette.paleBlue
                    : .white,
                border: included
                    ? KodaPalette.blue
                    : KodaPalette.line
            )
            .contentShape(
                RoundedRectangle(cornerRadius: 20)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "Probar \(example.title): \(example.animal.name)"
        )
        .accessibilityHint(
            "Ejecutar hacerSonido y mostrar su respuesta escrita"
        )
    }

    // MARK: - Ejecución polimórfica

    private func makeResult(
        for example: AnimalExample
    ) -> SoundResult {
        // La referencia utiliza el tipo de la clase base.
        // Swift ejecuta la implementación de la clase concreta.
        let animal: LearningAnimal = example.animal

        return SoundResult(
            id: example.id,
            title: example.title,
            message: animal.makeSound(),
            creationCode: example.creationCode
        )
    }
}

#Preview("Explorar el polimorfismo") {
    ScrollView {
        PolymorphismExplorationView()
            .padding(20)
    }
    .kodaScreen()
    .preferredColorScheme(.light)
}
