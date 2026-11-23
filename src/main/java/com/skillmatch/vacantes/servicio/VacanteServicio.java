package com.skillmatch.vacantes.servicio;

import com.skillmatch.vacantes.dao.CatalogoDAO;
import com.skillmatch.vacantes.dao.VacanteDAO;
import com.skillmatch.vacantes.excepcion.ValidacionException;
import com.skillmatch.vacantes.modelo.EstadoVacante;
import com.skillmatch.vacantes.modelo.Vacante;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Reglas del negocio de las vacantes. Valida los datos antes de enviarlos al DAO.
 *
 * <p>La base de datos también tiene restricciones (CHECK, llaves foráneas), pero validar aquí
 * permite dar un mensaje claro al usuario en vez de un error técnico de MySQL.</p>
 */
public class VacanteServicio {

    private static final int MAX_TITULO = 120;

    private final VacanteDAO vacanteDAO;
    private final CatalogoDAO catalogoDAO;

    public VacanteServicio(VacanteDAO vacanteDAO, CatalogoDAO catalogoDAO) {
        this.vacanteDAO = vacanteDAO;
        this.catalogoDAO = catalogoDAO;
    }

    public int crear(Vacante vacante) {
        if (vacante.getFechaPublicacion() == null) {
            vacante.setFechaPublicacion(LocalDate.now());
        }
        validar(vacante);
        return vacanteDAO.insertar(vacante);
    }

    public Optional<Vacante> buscar(int idVacante) {
        return vacanteDAO.buscarPorId(idVacante);
    }

    public List<Vacante> listar() {
        return vacanteDAO.listarTodas();
    }

    public List<Vacante> listarPorEstado(EstadoVacante estado) {
        return vacanteDAO.listarPorEstado(estado);
    }

    public void actualizar(Vacante vacante) {
        if (vacante.getIdVacante() == null) {
            throw new ValidacionException("Para actualizar se necesita el id de la vacante.");
        }
        validar(vacante);
        if (!vacanteDAO.actualizar(vacante)) {
            throw new ValidacionException("No existe una vacante con id " + vacante.getIdVacante() + ".");
        }
    }

    public void eliminar(int idVacante) {
        if (!vacanteDAO.eliminar(idVacante)) {
            throw new ValidacionException("No existe una vacante con id " + idVacante + ".");
        }
    }

    private void validar(Vacante vacante) {
        if (vacante.getTitulo() == null || vacante.getTitulo().isBlank()) {
            throw new ValidacionException("El título es obligatorio.");
        }
        if (vacante.getTitulo().length() > MAX_TITULO) {
            throw new ValidacionException("El título no puede pasar de " + MAX_TITULO + " caracteres.");
        }
        if (vacante.getDescripcion() == null || vacante.getDescripcion().isBlank()) {
            throw new ValidacionException("La descripción es obligatoria.");
        }
        if (vacante.getTipoContrato() == null || vacante.getModalidad() == null
                || vacante.getNivelExperiencia() == null || vacante.getEstado() == null) {
            throw new ValidacionException("Faltan el tipo de contrato, la modalidad, el nivel o el estado.");
        }
        validarSalario(vacante.getSalarioMin(), vacante.getSalarioMax());
        if (vacante.getFechaCierre() != null && vacante.getFechaCierre().isBefore(vacante.getFechaPublicacion())) {
            throw new ValidacionException("La fecha de cierre no puede ser anterior a la de publicación.");
        }
        if (!catalogoDAO.existeEmpresa(vacante.getIdEmpresa())) {
            throw new ValidacionException("No existe una empresa con id " + vacante.getIdEmpresa() + ".");
        }
        if (vacante.getIdCiudad() != null && !catalogoDAO.existeCiudad(vacante.getIdCiudad())) {
            throw new ValidacionException("No existe una ciudad con id " + vacante.getIdCiudad() + ".");
        }
    }

    private void validarSalario(BigDecimal minimo, BigDecimal maximo) {
        if (minimo != null && minimo.signum() < 0 || maximo != null && maximo.signum() < 0) {
            throw new ValidacionException("El salario no puede ser negativo.");
        }
        if (minimo != null && maximo != null && maximo.compareTo(minimo) < 0) {
            throw new ValidacionException("El salario máximo no puede ser menor que el mínimo.");
        }
    }
}
