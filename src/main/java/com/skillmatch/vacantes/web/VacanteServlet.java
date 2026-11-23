package com.skillmatch.vacantes.web;

import com.skillmatch.vacantes.config.ConexionBD;
import com.skillmatch.vacantes.dao.CatalogoDAO;
import com.skillmatch.vacantes.dao.VacanteDAOJdbc;
import com.skillmatch.vacantes.excepcion.ValidacionException;
import com.skillmatch.vacantes.modelo.EstadoVacante;
import com.skillmatch.vacantes.modelo.Modalidad;
import com.skillmatch.vacantes.modelo.NivelExperiencia;
import com.skillmatch.vacantes.modelo.TipoContrato;
import com.skillmatch.vacantes.modelo.Vacante;
import com.skillmatch.vacantes.modelo.ValorBD;
import com.skillmatch.vacantes.servicio.VacanteServicio;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Optional;

/**
 * Controlador web de las vacantes. Atiende todas las peticiones a {@code /vacantes}.
 *
 * <ul>
 *   <li><b>GET</b> solo consulta, nunca modifica datos: listar, filtrar por estado, ver el detalle
 *       y mostrar el formulario de crear o editar.</li>
 *   <li><b>POST</b> modifica datos: guardar (crear o actualizar) y eliminar. Después de un POST
 *       exitoso se redirige al listado (patrón Post/Redirect/Get), para que al recargar la página
 *       el navegador no vuelva a enviar el formulario.</li>
 * </ul>
 *
 * <p>El servlet no escribe HTML: prepara los datos en la petición y se los pasa a una página JSP.</p>
 */
@WebServlet(name = "VacanteServlet", urlPatterns = "/vacantes")
public class VacanteServlet extends HttpServlet {

    private static final String VISTAS = "/WEB-INF/vistas/";
    private static final String ATRIBUTO_MENSAJE = "mensaje";

    private VacanteServicio servicio;
    private CatalogoDAO catalogoDAO;

    @Override
    public void init() {
        ConexionBD conexionBD = new ConexionBD();
        catalogoDAO = new CatalogoDAO(conexionBD);
        servicio = new VacanteServicio(new VacanteDAOJdbc(conexionBD), catalogoDAO);
    }

    // ------------------------------------------------------------------ GET

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        String accion = parametro(peticion, "accion").orElse("listar");
        switch (accion) {
            case "ver" -> verDetalle(peticion, respuesta);
            case "nueva" -> mostrarFormulario(peticion, respuesta, new Vacante(), null);
            case "editar" -> editar(peticion, respuesta);
            default -> listar(peticion, respuesta);
        }
    }

    private void listar(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        // Un estado desconocido en la URL se ignora y se muestran todas
        Optional<EstadoVacante> filtro = parametro(peticion, "estado")
                .flatMap(valor -> java.util.Arrays.stream(EstadoVacante.values())
                        .filter(estado -> estado.getValor().equals(valor)).findFirst());
        List<Vacante> vacantes = filtro.map(servicio::listarPorEstado).orElseGet(servicio::listar);

        // El mensaje de la acción anterior viaja en la sesión y se muestra una sola vez
        Object mensaje = peticion.getSession().getAttribute(ATRIBUTO_MENSAJE);
        peticion.getSession().removeAttribute(ATRIBUTO_MENSAJE);

        peticion.setAttribute("vacantes", vacantes);
        peticion.setAttribute("estadoFiltro", filtro.orElse(null));
        peticion.setAttribute("estados", EstadoVacante.values());
        peticion.setAttribute(ATRIBUTO_MENSAJE, mensaje);
        peticion.getRequestDispatcher(VISTAS + "lista.jsp").forward(peticion, respuesta);
    }

    private void verDetalle(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        Optional<Vacante> vacante = idDe(peticion).flatMap(servicio::buscar);
        if (vacante.isEmpty()) {
            respuesta.sendError(HttpServletResponse.SC_NOT_FOUND, "La vacante no existe");
            return;
        }
        peticion.setAttribute("vacante", vacante.get());
        peticion.getRequestDispatcher(VISTAS + "detalle.jsp").forward(peticion, respuesta);
    }

    private void editar(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        Optional<Vacante> vacante = idDe(peticion).flatMap(servicio::buscar);
        if (vacante.isEmpty()) {
            respuesta.sendError(HttpServletResponse.SC_NOT_FOUND, "La vacante no existe");
            return;
        }
        mostrarFormulario(peticion, respuesta, vacante.get(), null);
    }

    private void mostrarFormulario(HttpServletRequest peticion, HttpServletResponse respuesta,
                                   Vacante vacante, String error) throws ServletException, IOException {
        peticion.setAttribute("vacante", vacante);
        peticion.setAttribute("error", error);
        peticion.setAttribute("empresas", catalogoDAO.listarEmpresas());
        peticion.setAttribute("ciudades", catalogoDAO.listarCiudades());
        peticion.setAttribute("tiposContrato", TipoContrato.values());
        peticion.setAttribute("modalidades", Modalidad.values());
        peticion.setAttribute("niveles", NivelExperiencia.values());
        peticion.setAttribute("estados", EstadoVacante.values());
        peticion.getRequestDispatcher(VISTAS + "formulario.jsp").forward(peticion, respuesta);
    }

    // ----------------------------------------------------------------- POST

    @Override
    protected void doPost(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        String accion = parametro(peticion, "accion").orElse("");
        switch (accion) {
            case "guardar" -> guardar(peticion, respuesta);
            case "eliminar" -> eliminar(peticion, respuesta);
            default -> respuesta.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
        }
    }

    private void guardar(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        Vacante vacante = new Vacante();
        try {
            leerFormulario(peticion, vacante);
            if (vacante.getIdVacante() == null) {
                int id = servicio.crear(vacante);
                redirigirConMensaje(peticion, respuesta, "Se creó la vacante «" + vacante.getTitulo() + "» con id " + id + ".");
            } else {
                servicio.actualizar(vacante);
                redirigirConMensaje(peticion, respuesta, "Se actualizó la vacante " + vacante.getIdVacante() + ".");
            }
        } catch (ValidacionException e) {
            // Se vuelve a mostrar el formulario con lo que el usuario escribió y el motivo del error
            respuesta.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            mostrarFormulario(peticion, respuesta, vacante, e.getMessage());
        }
    }

    private void eliminar(HttpServletRequest peticion, HttpServletResponse respuesta) throws IOException {
        int id = idDe(peticion).orElseThrow(() -> new ValidacionException("Falta el id de la vacante."));
        try {
            servicio.eliminar(id);
            redirigirConMensaje(peticion, respuesta, "Se eliminó la vacante " + id + ".");
        } catch (ValidacionException e) {
            redirigirConMensaje(peticion, respuesta, e.getMessage());
        }
    }

    private void redirigirConMensaje(HttpServletRequest peticion, HttpServletResponse respuesta, String mensaje)
            throws IOException {
        peticion.getSession().setAttribute(ATRIBUTO_MENSAJE, mensaje);
        respuesta.sendRedirect(peticion.getContextPath() + "/vacantes");
    }

    // ------------------------------------------------- leer el formulario

    private void leerFormulario(HttpServletRequest peticion, Vacante vacante) {
        vacante.setIdVacante(idDe(peticion).orElse(null));
        vacante.setIdEmpresa(entero(peticion, "idEmpresa").orElse(0));
        vacante.setTitulo(parametro(peticion, "titulo").orElse(""));
        vacante.setDescripcion(parametro(peticion, "descripcion").orElse(""));
        vacante.setTipoContrato(enumeracion(peticion, "tipoContrato", TipoContrato.class));
        vacante.setModalidad(enumeracion(peticion, "modalidad", Modalidad.class));
        vacante.setNivelExperiencia(enumeracion(peticion, "nivelExperiencia", NivelExperiencia.class));
        vacante.setSalarioMin(dinero(peticion, "salarioMin"));
        vacante.setSalarioMax(dinero(peticion, "salarioMax"));
        vacante.setIdCiudad(entero(peticion, "idCiudad").filter(id -> id > 0).orElse(null));
        EstadoVacante estado = enumeracion(peticion, "estado", EstadoVacante.class);
        vacante.setEstado(estado == null ? EstadoVacante.ABIERTA : estado);
        vacante.setFechaPublicacion(fecha(peticion, "fechaPublicacion"));
        vacante.setFechaCierre(fecha(peticion, "fechaCierre"));
    }

    private static Optional<String> parametro(HttpServletRequest peticion, String nombre) {
        String valor = peticion.getParameter(nombre);
        return (valor == null || valor.isBlank()) ? Optional.empty() : Optional.of(valor.trim());
    }

    private static Optional<Integer> idDe(HttpServletRequest peticion) {
        return entero(peticion, "id");
    }

    private static Optional<Integer> entero(HttpServletRequest peticion, String nombre) {
        try {
            return parametro(peticion, nombre).map(Integer::valueOf);
        } catch (NumberFormatException e) {
            throw new ValidacionException("El campo " + nombre + " debe ser un número entero.");
        }
    }

    private static BigDecimal dinero(HttpServletRequest peticion, String nombre) {
        try {
            return parametro(peticion, nombre).map(BigDecimal::new).orElse(null);
        } catch (NumberFormatException e) {
            throw new ValidacionException("El salario debe escribirse solo con números, por ejemplo 1500000.");
        }
    }

    private static LocalDate fecha(HttpServletRequest peticion, String nombre) {
        try {
            return parametro(peticion, nombre).map(LocalDate::parse).orElse(null);
        } catch (DateTimeParseException e) {
            throw new ValidacionException("La fecha debe tener el formato AAAA-MM-DD.");
        }
    }

    private static <E extends Enum<E> & ValorBD> E enumeracion(HttpServletRequest peticion, String nombre, Class<E> tipo) {
        try {
            return parametro(peticion, nombre).map(valor -> ValorBD.desdeValor(tipo, valor)).orElse(null);
        } catch (IllegalArgumentException e) {
            throw new ValidacionException("El valor elegido en " + nombre + " no es válido.");
        }
    }
}
