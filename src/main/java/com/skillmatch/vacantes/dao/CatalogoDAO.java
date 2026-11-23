package com.skillmatch.vacantes.dao;

import com.skillmatch.vacantes.config.ConexionBD;
import com.skillmatch.vacantes.excepcion.DatosException;
import com.skillmatch.vacantes.modelo.OpcionCatalogo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Consultas de solo lectura a los catálogos que necesita una vacante: empresas y ciudades.
 */
public class CatalogoDAO {

    private static final String SQL_EMPRESAS = "SELECT id_empresa, nombre FROM empresa ORDER BY nombre";
    private static final String SQL_CIUDADES =
            "SELECT id_ciudad, CONCAT(nombre, ', ', departamento) FROM ciudad ORDER BY nombre";

    private final ConexionBD conexionBD;

    public CatalogoDAO(ConexionBD conexionBD) {
        this.conexionBD = conexionBD;
    }

    public List<OpcionCatalogo> listarEmpresas() {
        return listar(SQL_EMPRESAS, "empresas");
    }

    public List<OpcionCatalogo> listarCiudades() {
        return listar(SQL_CIUDADES, "ciudades");
    }

    public boolean existeEmpresa(int idEmpresa) {
        return listarEmpresas().stream().anyMatch(opcion -> opcion.id() == idEmpresa);
    }

    public boolean existeCiudad(int idCiudad) {
        return listarCiudades().stream().anyMatch(opcion -> opcion.id() == idCiudad);
    }

    private List<OpcionCatalogo> listar(String sql, String nombreCatalogo) {
        try (Connection conexion = conexionBD.obtenerConexion();
             PreparedStatement sentencia = conexion.prepareStatement(sql);
             ResultSet resultado = sentencia.executeQuery()) {
            List<OpcionCatalogo> opciones = new ArrayList<>();
            while (resultado.next()) {
                opciones.add(new OpcionCatalogo(resultado.getInt(1), resultado.getString(2)));
            }
            return opciones;
        } catch (SQLException e) {
            throw new DatosException("No se pudo leer el catálogo de " + nombreCatalogo, e);
        }
    }
}
