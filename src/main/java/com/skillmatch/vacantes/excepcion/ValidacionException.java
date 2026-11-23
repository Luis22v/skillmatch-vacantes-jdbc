package com.skillmatch.vacantes.excepcion;

/**
 * Un dato que no cumple una regla del negocio, por ejemplo un salario máximo menor que el mínimo.
 */
public class ValidacionException extends RuntimeException {

    public ValidacionException(String mensaje) {
        super(mensaje);
    }
}
