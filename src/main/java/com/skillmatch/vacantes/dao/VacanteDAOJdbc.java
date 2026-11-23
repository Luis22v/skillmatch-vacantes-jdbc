package com.skillmatch.vacantes.dao;

import com.skillmatch.vacantes.config.ConexionBD;
import com.skillmatch.vacantes.excepcion.DatosException;
import com.skillmatch.vacantes.modelo.EstadoVacante;
import com.skillmatch.vacantes.modelo.Modalidad;
import com.skillmatch.vacantes.modelo.NivelExperiencia;
import com.skillmatch.vacantes.modelo.TipoContrato;
import com.skillmatch.vacantes.modelo.ValorBD;
import com.skillmatch.vacantes.modelo.Vacante;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Implementación de {@link VacanteDAO} con JDBC.
 *
 * <p>Reglas que sigue toda la clase:</p>
 * <ul>
 *   <li>Siempre {@link PreparedStatement} con parámetros {@code ?}: nunca se concatena texto del
 *       usuario en el SQL, lo que evita la inyección SQL.</li>
 *   <li>Conexión, sentencia y resultado se cierran solos con try-with-resources.</li>
 *   <li>Cada {@link SQLException} se convierte en {@link DatosException} con un mensaje claro.</li>
 * </ul>
 */
public class VacanteDAOJdbc implements VacanteDAO {

    // La consulta une vacante con empresa y ciudad para traer sus nombres
    private static final String SELECT_BASE = """
            SELECT v.id_vacante, v.id_empresa, v.titulo, v.descripcion, v.tipo_contrato, v.modalidad,
                   v.nivel_experiencia, v.salario_min, v.salario_max, v.id_ciudad, v.estado,
                   v.fecha_publicacion, v.fecha_cierre,
                   e.nombre AS nombre_empresa, c.nombre AS nombre_ciudad
            FROM vacante v
            JOIN empresa e ON e.id_empresa = v.id_empresa
            LEFT JOIN ciudad c ON c.id_ciudad = v.id_ciudad
            """;

    private static final String SQL_INSERTAR = """
            INSERT INTO vacante (id_empresa, titulo, descripcion, tipo_contrato, modalidad, nivel_experiencia,
                                 salario_min, salario_max, id_ciudad, estado, fecha_publicacion, fecha_cierre)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

    private static final String SQL_ACTUALIZAR = """
            UPDATE vacante
            SET id_empresa = ?, titulo = ?, descripcion = ?, tipo_contrato = ?, modalidad = ?,
                nivel_experiencia = ?, salario_min = ?, salario_max = ?, id_ciudad = ?, estado = ?,
                fecha_publicacion = ?, fecha_cierre = ?
            WHERE id_vacante = ?
            """;

    private static final String SQL_ELIMINAR = "DELETE FROM vacante WHERE id_vacante = ?";

    private final ConexionBD conexionBD;

    public VacanteDAOJdbc(ConexionBD conexionBD) {
        this.conexionBD = conexionBD;
    }

    @Override
    public int insertar(Vacante vacante) {
        try (Connection conexion = conexionBD.obtenerConexion();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_INSERTAR, Statement.RETURN_GENERATED_KEYS)) {
            asignarParametros(sentencia, vacante);
            sentencia.executeUpdate();
            try (ResultSet llaves = sentencia.getGeneratedKeys()) {
                if (!llaves.next()) {
                    throw new DatosException("La base de datos no devolvió el id de la vacante creada", null);
                }
                int idNuevo = llaves.getInt(1);
                vacante.setIdVacante(idNuevo);
                return idNuevo;
            }
        } catch (SQLException e) {
            throw new DatosException("No se pudo crear la vacante: " + e.getMessage(), e);
        }
    }

    @Override
    public Optional<Vacante> buscarPorId(int idVacante) {
        String sql = SELECT_BASE + " WHERE v.id_vacante = ?";
        try (Connection conexion = conexionBD.obtenerConexion();
             PreparedStatement sentencia = conexion.prepareStatement(sql)) {
            sentencia.setInt(1, idVacante);
            try (ResultSet resultado = sentencia.executeQuery()) {
                return resultado.next() ? Optional.of(mapearFila(resultado)) : Optional.empty();
            }
        } catch (SQLException e) {
            throw new DatosException("No se pudo consultar la vacante " + idVacante, e);
        }
    }

    @Override
    public List<Vacante> listarTodas() {
        String sql = SELECT_BASE + " ORDER BY v.fecha_publicacion DESC, v.id_vacante DESC";
        try (Connection conexion = conexionBD.obtenerConexion();
             PreparedStatement sentencia = conexion.prepareStatement(sql);
             ResultSet resultado = sentencia.executeQuery()) {
            return mapearLista(resultado);
        } catch (SQLException e) {
            throw new DatosException("No se pudo listar las vacantes", e);
        }
    }

    @Override
    public List<Vacante> listarPorEstado(EstadoVacante estado) {
        String sql = SELECT_BASE + " WHERE v.estado = ? ORDER BY v.fecha_publicacion DESC, v.id_vacante DESC";
        try (Connection conexion = conexionBD.obtenerConexion();
             PreparedStatement sentencia = conexion.prepareStatement(sql)) {
            sentencia.setString(1, estado.getValor());
            try (ResultSet resultado = sentencia.executeQuery()) {
                return mapearLista(resultado);
            }
        } catch (SQLException e) {
            throw new DatosException("No se pudo listar las vacantes en estado " + estado.getEtiqueta(), e);
        }
    }

    @Override
    public boolean actualizar(Vacante vacante) {
        try (Connection conexion = conexionBD.obtenerConexion();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_ACTUALIZAR)) {
            asignarParametros(sentencia, vacante);
            sentencia.setInt(13, vacante.getIdVacante());
            return sentencia.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new DatosException("No se pudo actualizar la vacante: " + e.getMessage(), e);
        }
    }

    @Override
    public boolean eliminar(int idVacante) {
        try (Connection conexion = conexionBD.obtenerConexion();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_ELIMINAR)) {
            sentencia.setInt(1, idVacante);
            return sentencia.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new DatosException("No se pudo eliminar la vacante " + idVacante, e);
        }
    }

    // Los 12 primeros parámetros son iguales en INSERT y UPDATE, en el mismo orden
    private void asignarParametros(PreparedStatement sentencia, Vacante vacante) throws SQLException {
        sentencia.setInt(1, vacante.getIdEmpresa());
        sentencia.setString(2, vacante.getTitulo());
        sentencia.setString(3, vacante.getDescripcion());
        sentencia.setString(4, vacante.getTipoContrato().getValor());
        sentencia.setString(5, vacante.getModalidad().getValor());
        sentencia.setString(6, vacante.getNivelExperiencia().getValor());
        sentencia.setBigDecimal(7, vacante.getSalarioMin());
        sentencia.setBigDecimal(8, vacante.getSalarioMax());
        if (vacante.getIdCiudad() == null) {
            sentencia.setNull(9, Types.SMALLINT);
        } else {
            sentencia.setInt(9, vacante.getIdCiudad());
        }
        sentencia.setString(10, vacante.getEstado().getValor());
        sentencia.setDate(11, Date.valueOf(vacante.getFechaPublicacion()));
        sentencia.setDate(12, vacante.getFechaCierre() == null ? null : Date.valueOf(vacante.getFechaCierre()));
    }

    private List<Vacante> mapearLista(ResultSet resultado) throws SQLException {
        List<Vacante> vacantes = new ArrayList<>();
        while (resultado.next()) {
            vacantes.add(mapearFila(resultado));
        }
        return vacantes;
    }

    // Convierte la fila actual del ResultSet en un objeto Vacante
    private Vacante mapearFila(ResultSet resultado) throws SQLException {
        Vacante vacante = new Vacante();
        vacante.setIdVacante(resultado.getInt("id_vacante"));
        vacante.setIdEmpresa(resultado.getInt("id_empresa"));
        vacante.setTitulo(resultado.getString("titulo"));
        vacante.setDescripcion(resultado.getString("descripcion"));
        vacante.setTipoContrato(ValorBD.desdeValor(TipoContrato.class, resultado.getString("tipo_contrato")));
        vacante.setModalidad(ValorBD.desdeValor(Modalidad.class, resultado.getString("modalidad")));
        vacante.setNivelExperiencia(ValorBD.desdeValor(NivelExperiencia.class, resultado.getString("nivel_experiencia")));
        vacante.setSalarioMin(resultado.getBigDecimal("salario_min"));
        vacante.setSalarioMax(resultado.getBigDecimal("salario_max"));
        int idCiudad = resultado.getInt("id_ciudad");
        vacante.setIdCiudad(resultado.wasNull() ? null : idCiudad);
        vacante.setEstado(ValorBD.desdeValor(EstadoVacante.class, resultado.getString("estado")));
        vacante.setFechaPublicacion(resultado.getDate("fecha_publicacion").toLocalDate());
        Date fechaCierre = resultado.getDate("fecha_cierre");
        vacante.setFechaCierre(fechaCierre == null ? null : fechaCierre.toLocalDate());
        vacante.setNombreEmpresa(resultado.getString("nombre_empresa"));
        vacante.setNombreCiudad(resultado.getString("nombre_ciudad"));
        return vacante;
    }
}
