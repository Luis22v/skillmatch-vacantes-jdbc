package com.skillmatch.vacantes.excepcion;

/**
 * Error al leer o escribir en la base de datos.
 *
 * <p>Envuelve la {@link java.sql.SQLException} original para que las capas de arriba
 * no dependan de JDBC y reciban un mensaje claro en español.</p>
 */
public class DatosException extends RuntimeException {

    public DatosException(String mensaje, Throwable causa) {
        super(mensaje, causa);
    }
}
