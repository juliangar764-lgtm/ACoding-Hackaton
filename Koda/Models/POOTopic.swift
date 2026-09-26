//
//  POOTopic.swift
//  Koda
//
//  Created by ADMIN UNACH on 22/09/26.
//

struct POOTopic: Identifiable {
    let id: String
    let title: String
    let explanation: String

    // MARK: - Descripción corta para las tarjetas

    var subtitle: String {
        switch id {
        case "classes-and-objects":
            return "Del molde al objeto"

        case "properties-and-methods":
            return "Características y acciones"

        case "inheritance":
            return "Comparte y extiende"

        case "encapsulation":
            return "Controla el acceso"

        case "polymorphism":
            return "Una acción, distintas respuestas"

        default:
            return title
        }
    }

    // MARK: - Temas del curso

    static let topics: [Self] = [
        .init(
            id: "classes-and-objects",
            title: "Clases y objetos",
            explanation: """
            Una clase define un tipo de objeto.
            A partir de Coche podemos crear varios coches,
            cada uno con sus propios valores.
            """
        ),

        .init(
            id: "properties-and-methods",
            title: "Atributos y métodos",
            explanation: """
            Las propiedades guardan datos del objeto;
            los métodos describen acciones.
            Un coche puede tener un color
            y un método arrancar().
            """
        ),

        .init(
            id: "inheritance",
            title: "Herencia",
            explanation: """
            Una clase puede heredar propiedades y métodos
            de otra y añadir o modificar comportamientos.
            Perro puede heredar de Animal.
            """
        ),

        .init(
            id: "encapsulation",
            title: "Encapsulación",
            explanation: """
            Un objeto controla el acceso a sus datos.
            Una cuenta puede mantener privado su saldo
            y modificarlo mediante métodos que validan
            cada operación.
            """
        ),

        .init(
            id: "polymorphism",
            title: "Polimorfismo",
            explanation: """
            Podemos trabajar con objetos mediante una interfaz
            común y obtener comportamientos distintos.
            hacerSonido() puede producir respuestas diferentes
            en Perro y Gato.
            """
        )
    ]
}
