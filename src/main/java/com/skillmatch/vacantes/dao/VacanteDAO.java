package com.skillmatch.vacantes.dao;

import com.skillmatch.vacantes.modelo.EstadoVacante;
import com.skillmatch.vacantes.modelo.Vacante;

import java.util.List;
import java.util.Optional;

/**
 * Operaciones de acceso a datos de las vacantes: crear, consultar, actualizar y eliminar.
 *
 * <p>Es una interfaz para separar el "qué" del "cómo": hoy la implementa JDBC
 * ({@link VacanteDAOJdbc}), y el resto del programa no depende de ese detalle.</p>
 */
public interface VacanteDAO {

    /** Inserta la vacante y devuelve el id que le asignó la base de datos. */
    int insertar(Vacante vacante);

    /** Busca una vacante por su id. Vacío si no existe. */
    Optional<Vacante> buscarPorId(int idVacante);

    /** Todas las vacantes, de la más reciente a la más antigua. */
    List<Vacante> listarTodas();

    /** Las vacantes que están en el estado indicado. */
    List<Vacante> listarPorEstado(EstadoVacante estado);

    /** Actualiza todos los datos editables. {@code true} si la vacante existía. */
    boolean actualizar(Vacante vacante);

    /** Elimina la vacante. {@code true} si existía y se borró. */
    boolean eliminar(int idVacante);
}
