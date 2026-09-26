//
//  POOLesson.swift
//  Koda
//
//  Created by ADMIN UNACH on 24/09/26.
//

struct POOLesson: Identifiable {
    // Estos números se guardan en TopicProgress.
    // Mantén sus valores para conservar el progreso existente.
    enum Step: Int, CaseIterable {
        case explanation = 0
        case exploration = 1
        case practice = 2
        case result = 3
    }

    struct Answer: Identifiable {
        let id: String
        let title: String
        let detail: String
        let feedback: String
    }

    struct Exercise {
        let question: String
        let answers: [Answer]
        let correctAnswerID: String

        func answer(withID id: String) -> Answer? {
            answers.first { $0.id == id }
        }

        func isCorrect(answerID: String) -> Bool {
            guard answer(withID: answerID) != nil else {
                return false
            }

            return answerID == correctAnswerID
        }
    }

    let topic: POOTopic
    let code: String
    let teacherMessage: String
    let explorationPrompt: String
    let exercise: Exercise
    let learningGoals: [String]

    var id: String {
        topic.id
    }

    static func lesson(for topic: POOTopic) -> POOLesson? {
        switch topic.id {
        case "classes-and-objects":
            return classesAndObjects(topic: topic)

        case "properties-and-methods":
            return propertiesAndMethods(topic: topic)

        case "inheritance":
            return inheritance(topic: topic)

        case "encapsulation":
            return encapsulation(topic: topic)

        case "polymorphism":
            return polymorphism(topic: topic)

        default:
            return nil
        }
    }

    // MARK: - Clases y objetos

    private static func classesAndObjects(
        topic: POOTopic
    ) -> POOLesson {
        POOLesson(
            topic: topic,
            code: """
            final class Coche {
                var color = "azul"
                var puertas = 4
            }

            let miCoche = Coche()
            let cocheDeAna = Coche()

            miCoche.color = "rojo"
            """,
            teacherMessage: """
            La clase Coche es el molde. miCoche y cocheDeAna son dos \
            objetos distintos creados con él. En este ejemplo, cambiar \
            el color de miCoche no cambia el color de cocheDeAna.
            """,
            explorationPrompt: """
            Cambia el color y el número de puertas de miCoche. \
            Observa cómo cambian sus valores mientras cocheDeAna \
            conserva los suyos.
            """,
            exercise: Exercise(
                question: "¿Cuál de estos elementos representa una clase?",
                answers: [
                    Answer(
                        id: "car-blueprint",
                        title: "El molde Coche",
                        detail: "Define cómo serán sus objetos.",
                        feedback: """
                        ¡Exacto! Coche es la clase: define las propiedades \
                        que tendrán los coches que creemos a partir de ella.
                        """
                    ),
                    Answer(
                        id: "my-car",
                        title: "miCoche",
                        detail: "Un coche concreto con sus propios valores.",
                        feedback: """
                        miCoche es un objeto creado a partir de Coche. \
                        La clase es el molde que usamos para crearlo. \
                        Busca la opción que representa ese molde.
                        """
                    ),
                    Answer(
                        id: "anas-car",
                        title: "cocheDeAna",
                        detail: "Otro coche creado con el mismo molde.",
                        feedback: """
                        cocheDeAna también es un objeto. Comparte la clase \
                        Coche con miCoche, pero es una instancia distinta. \
                        Busca el molde, no uno de los coches creados.
                        """
                    )
                ],
                correctAnswerID: "car-blueprint"
            ),
            learningGoals: [
                "Distinguir una clase de los objetos creados con ella.",
                "Reconocer que cada objeto puede tener sus propios valores."
            ]
        )
    }

    // MARK: - Atributos y métodos

    private static func propertiesAndMethods(
        topic: POOTopic
    ) -> POOLesson {
        POOLesson(
            topic: topic,
            code: """
            final class Coche {
                var color = "azul"
                var puertas = 4
                private(set) var enMarcha = false

                func arrancar() {
                    enMarcha = true
                }

                func frenar() {
                    enMarcha = false
                }
            }

            let miCoche = Coche()
            miCoche.arrancar()
            // miCoche.enMarcha ahora es true
            """,
            teacherMessage: """
            Los atributos guardan datos del objeto; en Swift los llamamos \
            propiedades. color, puertas y enMarcha son propiedades del coche. \
            Los métodos definen acciones: arrancar() y frenar() cambian su estado. \
            En este ejemplo, private(set) permite consultar enMarcha desde fuera, \
            pero su valor se modifica dentro de la clase.
            """,
            explorationPrompt: """
            Cambia el color o las puertas y observa sus valores. Después, \
            ejecuta arrancar() y frenar(): verás cambiar enMarcha mientras \
            los demás atributos conservan sus valores.
            """,
            exercise: Exercise(
                question: "¿Cuál de estas opciones ejecuta un método?",
                answers: [
                    Answer(
                        id: "read-color",
                        title: "miCoche.color",
                        detail: "Consultar el color del coche.",
                        feedback: """
                        color es una propiedad: guarda un dato del coche. \
                        Esta expresión consulta su valor. Busca la opción \
                        que llama a una acción del objeto.
                        """
                    ),
                    Answer(
                        id: "call-start",
                        title: "miCoche.arrancar()",
                        detail: "Ejecutar la acción de arrancar.",
                        feedback: """
                        ¡Exacto! arrancar() es un método del coche. \
                        Al llamarlo, se ejecuta su código y en este ejemplo \
                        la propiedad enMarcha pasa a true.
                        """
                    ),
                    Answer(
                        id: "set-doors",
                        title: "miCoche.puertas = 2",
                        detail: "Asignar un valor al número de puertas.",
                        feedback: """
                        Aquí modificas directamente una propiedad. Aunque \
                        el objeto cambia, esta expresión no llama a uno \
                        de los métodos definidos en nuestra clase Coche. \
                        Busca la llamada a arrancar().
                        """
                    )
                ],
                correctAnswerID: "call-start"
            ),
            learningGoals: [
                "Distinguir los datos de un objeto de las acciones que realiza.",
                "Observar cómo un método puede modificar el estado del objeto."
            ]
        )
    }

    // MARK: - Herencia

    private static func inheritance(
        topic: POOTopic
    ) -> POOLesson {
        POOLesson(
            topic: topic,
            code: """
            class Animal {
                func comer() -> String {
                    "El animal está comiendo."
                }

                func dormir() -> String {
                    "El animal está durmiendo."
                }
            }

            final class Perro: Animal {
                func ladrar() -> String {
                    "¡Guau!"
                }
            }

            final class Gato: Animal {
                func maullar() -> String {
                    "¡Miau!"
                }
            }

            let miPerro = Perro()
            let miGato = Gato()

            miPerro.comer()   // Heredado de Animal
            miGato.dormir()   // Heredado de Animal
            miPerro.ladrar()  // Propio de Perro
            miGato.maullar()  // Propio de Gato
            """,
            teacherMessage: """
            Perro y Gato son clases hijas de Animal. Ambas pueden usar \
            comer() y dormir() porque los heredan de la clase base. \
            Perro añade ladrar() y Gato añade maullar(). Así reutilizamos \
            los métodos comunes sin volver a escribirlos en cada clase hija.
            """,
            explorationPrompt: """
            Selecciona Perro y prueba comer(), dormir() y ladrar(). \
            Después selecciona Gato y compara sus acciones. Observa \
            qué métodos comparten y cuál añade cada clase.
            """,
            exercise: Exercise(
                question: "En este ejemplo, ¿qué métodos puede usar miPerro?",
                answers: [
                    Answer(
                        id: "only-own-method",
                        title: "Solo ladrar()",
                        detail: "Únicamente el método escrito en Perro.",
                        feedback: """
                        Perro añade ladrar(), pero también hereda comer() \
                        y dormir() de Animal. No necesita volver a definir \
                        esos métodos para que miPerro pueda utilizarlos.
                        """
                    ),
                    Answer(
                        id: "inherited-and-own",
                        title: "comer(), dormir() y ladrar()",
                        detail: "Los métodos heredados y el propio de Perro.",
                        feedback: """
                        ¡Exacto! miPerro puede comer y dormir gracias \
                        a Animal, y ladrar gracias al método añadido \
                        en Perro. La clase hija conserva los métodos \
                        heredados y puede añadir otros propios.
                        """
                    ),
                    Answer(
                        id: "sibling-method",
                        title: "comer(), dormir() y maullar()",
                        detail: "Los métodos comunes y el propio de Gato.",
                        feedback: """
                        maullar() está definido en Gato. Perro y Gato \
                        comparten la clase base Animal, pero Perro no \
                        hereda los métodos que Gato añade. Su método \
                        propio es ladrar().
                        """
                    )
                ],
                correctAnswerID: "inherited-and-own"
            ),
            learningGoals: [
                "Identificar la clase base y sus clases hijas.",
                "Distinguir los métodos heredados de los que añade cada clase hija."
            ]
        )
    }

    // MARK: - Encapsulación

    private static func encapsulation(
        topic: POOTopic
    ) -> POOLesson {
        POOLesson(
            topic: topic,
            code: """
            final class Alcancia {
                enum ErrorOperacion: Error {
                    case cantidadInvalida
                    case saldoInsuficiente
                    case limiteDeSaldo
                }

                private var saldo = 50

                var saldoActual: Int {
                    saldo
                }

                func depositar(_ cantidad: Int) throws {
                    guard cantidad > 0 else {
                        throw ErrorOperacion.cantidadInvalida
                    }

                    let (nuevoSaldo, desbordamiento) =
                        saldo.addingReportingOverflow(cantidad)

                    guard !desbordamiento else {
                        throw ErrorOperacion.limiteDeSaldo
                    }

                    saldo = nuevoSaldo
                }

                func retirar(_ cantidad: Int) throws {
                    guard cantidad > 0 else {
                        throw ErrorOperacion.cantidadInvalida
                    }

                    guard cantidad <= saldo else {
                        throw ErrorOperacion.saldoInsuficiente
                    }

                    saldo -= cantidad
                }
            }

            let miAlcancia = Alcancia()

            do {
                try miAlcancia.retirar(60)
            } catch {
                print("Operación rechazada")
            }

            // miAlcancia.saldoActual sigue siendo 50
            """,
            teacherMessage: """
            saldo es privado: desde fuera de Alcancia no podemos asignarle \
            un valor directamente. saldoActual permite consultarlo sin \
            modificarlo. Los métodos depositar() y retirar() validan cada \
            operación antes de cambiar el dato. private controla el acceso; \
            las comprobaciones de los métodos hacen cumplir las reglas.
            """,
            explorationPrompt: """
            Deposita y retira monedas. Después intenta retirar cuando \
            el saldo llegue a cero. Observa cómo el método rechaza \
            la operación y conserva el saldo anterior.
            """,
            exercise: Exercise(
                question: "Hay 50 monedas. ¿Por qué retirar(60) rechaza la operación?",
                answers: [
                    Answer(
                        id: "private-means-unchangeable",
                        title: "Porque un dato privado nunca puede cambiar",
                        detail: "Confundir acceso privado con un valor constante.",
                        feedback: """
                        private no convierte saldo en una constante. \
                        Los métodos de Alcancia sí pueden modificarlo. \
                        El rechazo ocurre por la comprobación que compara \
                        la cantidad solicitada con las monedas disponibles.
                        """
                    ),
                    Answer(
                        id: "withdrawals-forbidden",
                        title: "Porque la encapsulación prohíbe retirar monedas",
                        detail: "Suponer que todos los retiros están bloqueados.",
                        feedback: """
                        La alcancía permite retiros válidos. Por ejemplo, \
                        retirar 10 cuando hay 50 sí funciona. La encapsulación \
                        permite controlar los cambios mediante métodos; \
                        no obliga a prohibir todas las operaciones.
                        """
                    ),
                    Answer(
                        id: "validated-withdrawal",
                        title: "Porque el método comprueba que haya saldo suficiente",
                        detail: "Valida antes de modificar el saldo privado.",
                        feedback: """
                        ¡Exacto! retirar() comprueba la cantidad antes \
                        de restarla. Como 60 es mayor que 50, lanza un error \
                        y conserva el saldo. El acceso privado evita cambiar \
                        ese dato directamente desde fuera de la clase.
                        """
                    )
                ],
                correctAnswerID: "validated-withdrawal"
            ),
            learningGoals: [
                "Distinguir la lectura de un dato de su modificación controlada.",
                "Comprender cómo los métodos validan cambios sobre datos privados."
            ]
        )
    }

    // MARK: - Polimorfismo

    private static func polymorphism(
        topic: POOTopic
    ) -> POOLesson {
        POOLesson(
            topic: topic,
            code: #"""
            class Animal {
                let nombre: String

                init(nombre: String) {
                    self.nombre = nombre
                }

                func hacerSonido() -> String {
                    "\(nombre) hace un sonido."
                }
            }

            final class Perro: Animal {
                override func hacerSonido() -> String {
                    "\(nombre) dice: ¡Guau!"
                }
            }

            final class Gato: Animal {
                override func hacerSonido() -> String {
                    "\(nombre) dice: ¡Miau!"
                }
            }

            final class Vaca: Animal {
                override func hacerSonido() -> String {
                    "\(nombre) dice: ¡Muu!"
                }
            }

            let animales: [Animal] = [
                Perro(nombre: "Toby"),
                Gato(nombre: "Luna"),
                Vaca(nombre: "Lola")
            ]

            for animal in animales {
                print(animal.hacerSonido())
            }
            """#,
            teacherMessage: """
            Los tres animales comparten el método hacerSonido(), pero \
            cada clase hija proporciona su propia implementación con \
            override. Aunque usamos referencias de tipo Animal, Swift \
            ejecuta la versión del objeto concreto. La misma llamada \
            puede producir respuestas diferentes: eso es polimorfismo.
            """,
            explorationPrompt: """
            Prueba Perro, Gato y Vaca. Después pulsa Probar los tres. \
            Observa que llamamos al mismo método en todos los casos, \
            pero cada objeto responde según su clase.
            """,
            exercise: Exercise(
                question: "Al recorrer estos animales como Animal y llamar a hacerSonido(), ¿qué ocurre?",
                answers: [
                    Answer(
                        id: "concrete-implementation",
                        title: "Cada animal ejecuta su propia versión",
                        detail: "Perro responde Guau, Gato Miau y Vaca Muu.",
                        feedback: """
                        ¡Exacto! La referencia tiene tipo Animal, pero \
                        cada objeto conserva su tipo concreto. Swift \
                        ejecuta el método sobrescrito de Perro, Gato \
                        o Vaca sin que el bucle tenga que distinguirlos.
                        """
                    ),
                    Answer(
                        id: "base-implementation-only",
                        title: "Siempre se ejecuta la versión de Animal",
                        detail: "Suponer que el tipo de la referencia decide la respuesta.",
                        feedback: """
                        Usar una referencia de tipo Animal no convierte \
                        un Gato en un objeto de la clase base. Como \
                        hacerSonido() está sobrescrito con override, \
                        se ejecuta la implementación del objeto concreto.
                        """
                    ),
                    Answer(
                        id: "same-name-same-result",
                        title: "Todos deben responder lo mismo",
                        detail: "Confundir el nombre del método con su implementación.",
                        feedback: """
                        Compartir el nombre hacerSonido() no obliga \
                        a ejecutar el mismo código. Cada clase hija \
                        puede sobrescribir ese método y ofrecer \
                        un comportamiento diferente.
                        """
                    )
                ],
                correctAnswerID: "concrete-implementation"
            ),
            learningGoals: [
                "Reconocer que una misma llamada puede producir comportamientos distintos.",
                "Comprender cómo override permite usar la implementación del objeto concreto."
            ]
        )
    }
}
