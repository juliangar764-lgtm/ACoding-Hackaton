//
//  AttributesMethodsExplorationView.swift
//  Koda
//
//  Created by ADMIN UNACH on 24/09/26.
//

import SwiftUI

@MainActor
struct AttributesMethodsExplorationView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var car = LearningCar(
        color: .blue,
        doors: .four
    )

    @State private var lastMethod: Method?

    private let onExampleStateChange: (String) -> Void

    init(
        onExampleStateChange: @escaping (String) -> Void = { _ in }
    ) {
        self.onExampleStateChange = onExampleStateChange
    }

    // MARK: - Métodos del ejemplo

    private enum Method {
        case start
        case stop

        var code: String {
            switch self {
            case .start:
                return "miCoche.arrancar()"

            case .stop:
                return "miCoche.frenar()"
            }
        }

        var explanation: String {
            switch self {
            case .start:
                return """
                arrancar() es un método. En este ejemplo, cambia \
                el atributo enMarcha a true. Un método puede \
                modificar el estado del objeto.
                """

            case .stop:
                return """
                frenar() es un método. En este ejemplo, cambia \
                enMarcha a false. El coche conserva su color \
                y su número de puertas.
                """
            }
        }
    }

    // MARK: - Código visible

    private var attributesCode: String {
        """
        miCoche.color     // "\(car.color.rawValue)"
        miCoche.puertas   // \(car.doors.rawValue)
        miCoche.enMarcha  // \(car.isRunning ? "true" : "false")
        """
    }

    // MARK: - Estado para el profesor

    private var currentExampleState: String {
        """
        Ejemplo visible: atributos y métodos del objeto miCoche.

        Valores actuales:
        - color: \(car.color.rawValue)
        - puertas: \(car.doors.rawValue)
        - enMarcha: \(car.isRunning ? "true" : "false")

        Último método ejecutado en este ejemplo:
        \(lastMethod?.code ?? "Todavía no se ha ejecutado ningún método.")

        Los selectores modifican color y puertas directamente.
        arrancar() cambia enMarcha a true; frenar() la cambia a false.
        Esos métodos no modifican el color ni las puertas.
        El último método no es necesariamente la última interacción:
        después pueden haberse cambiado propiedades con los selectores.
        No se proporciona un historial completo de acciones.
        """
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 8) {
                Text("miCoche")
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)

                CarIllustrationView(
                    color: car.color,
                    doors: car.doors,
                    isRunning: car.isRunning
                )
                .frame(maxWidth: 360)

                Label(
                    car.isRunning ? "En marcha" : "Detenido",
                    systemImage: car.isRunning
                        ? "play.fill"
                        : "stop.fill"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(
                    car.isRunning
                        ? KodaPalette.green
                        : KodaPalette.secondary
                )
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .kodaPanel(fill: KodaPalette.paleBlue)

            attributes

            KodaCodeCard(code: attributesCode)

            methods

            if let lastMethod {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Último método ejecutado")
                        .font(.subheadline.weight(.semibold))

                    KodaCodeCard(code: lastMethod.code)
                }
            }

            KodaTeacherMessage(
                message: lastMethod?.explanation
                    ?? """
                    Los atributos describen el objeto y su estado. \
                    Los métodos son acciones que puede realizar. \
                    Cambia un atributo y después pulsa arrancar().
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

    // MARK: - Atributos editables

    private var attributes: some View {
        @Bindable var editableCar = car

        return VStack(alignment: .leading, spacing: 12) {
            Text("Atributos")
                .font(.title3.bold())
                .accessibilityAddTraits(.isHeader)

            Text(
                "Datos del objeto. Puedes cambiar el color y las puertas."
            )
            .font(.subheadline)
            .foregroundStyle(KodaPalette.secondary)

            Picker(
                "Color",
                selection: $editableCar.color
            ) {
                ForEach(LearningCar.PaintColor.allCases) { color in
                    Text(color.title)
                        .tag(color)
                }
            }
            .frame(minHeight: 44)

            Divider()

            Picker(
                "Puertas",
                selection: $editableCar.doors
            ) {
                ForEach(LearningCar.DoorCount.allCases) { doors in
                    Text("\(doors.rawValue) puertas")
                        .tag(doors)
                }
            }
            .frame(minHeight: 44)

            Divider()

            LabeledContent(
                "En marcha",
                value: car.isRunning
                    ? "Sí (true)"
                    : "No (false)"
            )
            .font(.subheadline)
        }
        .pickerStyle(.menu)
        .tint(KodaPalette.blue)
        .padding(16)
        .kodaPanel()
    }

    // MARK: - Controles de métodos

    private var methods: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))

        return VStack(alignment: .leading, spacing: 12) {
            Text("Métodos")
                .font(.title3.bold())
                .accessibilityAddTraits(.isHeader)

            Text(
                "Ejecuta una acción y observa el atributo enMarcha."
            )
            .font(.subheadline)
            .foregroundStyle(KodaPalette.secondary)

            layout {
                Button {
                    car.start()
                    lastMethod = .start
                } label: {
                    Label(
                        "arrancar()",
                        systemImage: "play.fill"
                    )
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 44
                    )
                }
                .tint(KodaPalette.green)
                .disabled(car.isRunning)
                .accessibilityLabel(
                    "Ejecutar el método arrancar"
                )

                Button {
                    car.stop()
                    lastMethod = .stop
                } label: {
                    Label(
                        "frenar()",
                        systemImage: "stop.fill"
                    )
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 44
                    )
                }
                .tint(.red)
                .disabled(!car.isRunning)
                .accessibilityLabel(
                    "Ejecutar el método frenar"
                )
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview("Atributos y métodos") {
    ScrollView {
        AttributesMethodsExplorationView()
            .padding(20)
    }
    .kodaScreen()
    .preferredColorScheme(.light)
}
