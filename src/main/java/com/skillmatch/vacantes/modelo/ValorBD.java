package com.skillmatch.vacantes.modelo;

import java.util.Arrays;

/**
 * Enumeraciones que se guardan en una columna ENUM de MySQL con un texto en minúsculas.
 */
public interface ValorBD {

    /** Texto exacto con el que se guarda en la base de datos. */
    String getValor();

    /** Texto para mostrar al usuario. */
    String getEtiqueta();

    /** Convierte el texto de la base de datos en la constante de la enumeración. */
    static <E extends Enum<E> & ValorBD> E desdeValor(Class<E> tipo, String valor) {
        return Arrays.stream(tipo.getEnumConstants())
                .filter(constante -> constante.getValor().equals(valor))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException(
                        "Valor desconocido para " + tipo.getSimpleName() + ": " + valor));
    }
}
