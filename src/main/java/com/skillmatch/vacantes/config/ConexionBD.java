package com.skillmatch.vacantes.config;

import com.skillmatch.vacantes.excepcion.DatosException;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Abre conexiones JDBC con la base de datos de SkillMatch.
 *
 * <p>Los datos de conexión se leen de {@code db.properties}. Si existen las variables de entorno
 * {@code SKILLMATCH_DB_URL}, {@code SKILLMATCH_DB_USUARIO} o {@code SKILLMATCH_DB_CLAVE}, tienen
 * prioridad: así ninguna contraseña real queda escrita en el código.</p>
 */
public final class ConexionBD {

    private static final String ARCHIVO_PROPIEDADES = "db.properties";

    private final String url;
    private final String usuario;
    private final String clave;

    public ConexionBD() {
        Properties propiedades = cargarPropiedades();
        this.url = valor("SKILLMATCH_DB_URL", propiedades.getProperty("db.url"));
        this.usuario = valor("SKILLMATCH_DB_USUARIO", propiedades.getProperty("db.usuario"));
        this.clave = valor("SKILLMATCH_DB_CLAVE", propiedades.getProperty("db.clave", ""));
    }

    /**
     * Abre una conexión nueva. Quien la pide debe cerrarla, idealmente con try-with-resources.
     */
    public Connection obtenerConexion() {
        try {
            return DriverManager.getConnection(url, usuario, clave);
        } catch (SQLException e) {
            throw new DatosException("No se pudo conectar a la base de datos. ¿Está encendido MySQL en XAMPP?", e);
        }
    }

    public String getUrl() {
        return url;
    }

    private static Properties cargarPropiedades() {
        Properties propiedades = new Properties();
        try (InputStream entrada = ConexionBD.class.getClassLoader().getResourceAsStream(ARCHIVO_PROPIEDADES)) {
            if (entrada == null) {
                throw new IllegalStateException("No se encontró " + ARCHIVO_PROPIEDADES + " en el classpath");
            }
            propiedades.load(entrada);
            return propiedades;
        } catch (IOException e) {
            throw new IllegalStateException("No se pudo leer " + ARCHIVO_PROPIEDADES, e);
        }
    }

    // La variable de entorno, si existe, reemplaza el valor del archivo
    private static String valor(String variableEntorno, String valorPorDefecto) {
        String desdeEntorno = System.getenv(variableEntorno);
        return (desdeEntorno != null && !desdeEntorno.isBlank()) ? desdeEntorno : valorPorDefecto;
    }
}
