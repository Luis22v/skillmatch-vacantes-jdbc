package com.skillmatch.vacantes.app;

import com.skillmatch.vacantes.config.ConexionBD;
import com.skillmatch.vacantes.dao.CatalogoDAO;
import com.skillmatch.vacantes.dao.VacanteDAOJdbc;
import com.skillmatch.vacantes.excepcion.DatosException;
import com.skillmatch.vacantes.excepcion.ValidacionException;
import com.skillmatch.vacantes.modelo.EstadoVacante;
import com.skillmatch.vacantes.modelo.Modalidad;
import com.skillmatch.vacantes.modelo.NivelExperiencia;
import com.skillmatch.vacantes.modelo.OpcionCatalogo;
import com.skillmatch.vacantes.modelo.TipoContrato;
import com.skillmatch.vacantes.modelo.Vacante;
import com.skillmatch.vacantes.modelo.ValorBD;
import com.skillmatch.vacantes.servicio.VacanteServicio;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Locale;
import java.util.Scanner;

/**
 * Menú de consola para administrar las vacantes de SkillMatch.
 *
 * <p>Con el argumento {@code --demo} ejecuta solo, de principio a fin, las cuatro operaciones
 * (crear, consultar, actualizar y eliminar) para comprobar que el módulo funciona.</p>
 */
public class AplicacionConsola {

    private static final NumberFormat FORMATO_PESOS = NumberFormat.getCurrencyInstance(Locale.forLanguageTag("es-CO"));

    private final VacanteServicio servicio;
    private final CatalogoDAO catalogoDAO;
    private final Scanner entrada;

    public AplicacionConsola(VacanteServicio servicio, CatalogoDAO catalogoDAO, Scanner entrada) {
        this.servicio = servicio;
        this.catalogoDAO = catalogoDAO;
        this.entrada = entrada;
    }

    public static void main(String[] args) {
        ConexionBD conexionBD = new ConexionBD();
        CatalogoDAO catalogoDAO = new CatalogoDAO(conexionBD);
        VacanteServicio servicio = new VacanteServicio(new VacanteDAOJdbc(conexionBD), catalogoDAO);
        AplicacionConsola aplicacion = new AplicacionConsola(servicio, catalogoDAO, new Scanner(System.in));

        System.out.println("=== SkillMatch · Módulo de vacantes (JDBC) ===");
        System.out.println("Base de datos: " + conexionBD.getUrl().split("\\?")[0]);
        try {
            if (args.length > 0 && args[0].equals("--demo")) {
                aplicacion.ejecutarDemostracion();
            } else {
                aplicacion.ejecutarMenu();
            }
        } catch (DatosException e) {
            System.out.println("ERROR: " + e.getMessage());
            System.exit(1);
        }
    }

    // ------------------------------------------------------------------ menú

    private void ejecutarMenu() {
        int opcion;
        do {
            System.out.println();
            System.out.println("1. Listar vacantes");
            System.out.println("2. Listar vacantes por estado");
            System.out.println("3. Buscar una vacante por id");
            System.out.println("4. Crear vacante");
            System.out.println("5. Actualizar vacante");
            System.out.println("6. Eliminar vacante");
            System.out.println("0. Salir");
            opcion = leerEntero("Elige una opción: ");
            try {
                switch (opcion) {
                    case 1 -> mostrarLista(servicio.listar());
                    case 2 -> mostrarLista(servicio.listarPorEstado(elegir("Estado", EstadoVacante.class)));
                    case 3 -> buscarVacante();
                    case 4 -> crearVacante();
                    case 5 -> actualizarVacante();
                    case 6 -> eliminarVacante();
                    case 0 -> System.out.println("Hasta luego.");
                    default -> System.out.println("Opción no válida.");
                }
            } catch (ValidacionException e) {
                System.out.println("No se pudo: " + e.getMessage());
            }
        } while (opcion != 0);
    }

    private void buscarVacante() {
        int id = leerEntero("Id de la vacante: ");
        servicio.buscar(id).ifPresentOrElse(this::mostrarDetalle,
                () -> System.out.println("No existe una vacante con id " + id + "."));
    }

    private void crearVacante() {
        Vacante vacante = new Vacante();
        vacante.setIdEmpresa(elegirDeCatalogo("Empresa", catalogoDAO.listarEmpresas(), false));
        pedirDatos(vacante);
        int id = servicio.crear(vacante);
        System.out.println("Vacante creada con id " + id + ".");
    }

    private void actualizarVacante() {
        int id = leerEntero("Id de la vacante a actualizar: ");
        Vacante vacante = servicio.buscar(id)
                .orElseThrow(() -> new ValidacionException("No existe una vacante con id " + id + "."));
        mostrarDetalle(vacante);
        System.out.println("Escribe los datos nuevos:");
        pedirDatos(vacante);
        vacante.setEstado(elegir("Estado", EstadoVacante.class));
        servicio.actualizar(vacante);
        System.out.println("Vacante " + id + " actualizada.");
    }

    private void eliminarVacante() {
        int id = leerEntero("Id de la vacante a eliminar: ");
        String confirmacion = leerTexto("¿Seguro? Se borrarán también sus postulaciones (s/n): ");
        if (confirmacion.equalsIgnoreCase("s")) {
            servicio.eliminar(id);
            System.out.println("Vacante " + id + " eliminada.");
        } else {
            System.out.println("No se eliminó nada.");
        }
    }

    private void pedirDatos(Vacante vacante) {
        vacante.setTitulo(leerTexto("Título: "));
        vacante.setDescripcion(leerTexto("Descripción: "));
        vacante.setTipoContrato(elegir("Tipo de contrato", TipoContrato.class));
        vacante.setModalidad(elegir("Modalidad", Modalidad.class));
        vacante.setNivelExperiencia(elegir("Nivel de experiencia", NivelExperiencia.class));
        vacante.setSalarioMin(leerDinero("Salario mínimo (vacío si no aplica): "));
        vacante.setSalarioMax(leerDinero("Salario máximo (vacío si no aplica): "));
        int ciudad = elegirDeCatalogo("Ciudad", catalogoDAO.listarCiudades(), true);
        vacante.setIdCiudad(ciudad == 0 ? null : ciudad);
        vacante.setFechaCierre(leerFecha("Fecha de cierre AAAA-MM-DD (vacío si no tiene): "));
    }

    // ------------------------------------------------------- demostración

    private void ejecutarDemostracion() {
        System.out.println();
        System.out.println(">> 1. CONSULTAR: vacantes actuales");
        mostrarLista(servicio.listar());

        System.out.println();
        System.out.println(">> 2. CREAR: nueva vacante de prueba");
        Vacante nueva = new Vacante();
        nueva.setIdEmpresa(catalogoDAO.listarEmpresas().get(0).id());
        nueva.setTitulo("Auxiliar de soporte técnico");
        nueva.setDescripcion("Atención de incidencias de hardware y software para los usuarios internos.");
        nueva.setTipoContrato(TipoContrato.MEDIO_TIEMPO);
        nueva.setModalidad(Modalidad.PRESENCIAL);
        nueva.setNivelExperiencia(NivelExperiencia.SIN_EXPERIENCIA);
        nueva.setSalarioMin(new BigDecimal("1423500"));
        nueva.setSalarioMax(new BigDecimal("1600000"));
        nueva.setIdCiudad(catalogoDAO.listarCiudades().get(0).id());
        int id = servicio.crear(nueva);
        System.out.println("Creada con id " + id + ":");
        mostrarDetalle(servicio.buscar(id).orElseThrow());

        System.out.println();
        System.out.println(">> 3. ACTUALIZAR: sube el salario y se pausa la vacante");
        Vacante guardada = servicio.buscar(id).orElseThrow();
        guardada.setSalarioMax(new BigDecimal("1800000"));
        guardada.setEstado(EstadoVacante.PAUSADA);
        servicio.actualizar(guardada);
        mostrarDetalle(servicio.buscar(id).orElseThrow());

        System.out.println();
        System.out.println(">> 4. VALIDACIÓN: salario máximo menor que el mínimo");
        guardada.setSalarioMax(new BigDecimal("1000000"));
        try {
            servicio.actualizar(guardada);
            System.out.println("ERROR: se aceptó un dato inválido");
        } catch (ValidacionException e) {
            System.out.println("Rechazado como se esperaba: " + e.getMessage());
        }

        System.out.println();
        System.out.println(">> 5. ELIMINAR: se borra la vacante de prueba");
        servicio.eliminar(id);
        System.out.println("¿Sigue existiendo la vacante " + id + "? " + (servicio.buscar(id).isPresent() ? "sí" : "no"));

        System.out.println();
        System.out.println(">> 6. CONSULTAR: vacantes al final (igual que al principio)");
        mostrarLista(servicio.listar());
    }

    // ----------------------------------------------------------- mostrar

    private void mostrarLista(List<Vacante> vacantes) {
        if (vacantes.isEmpty()) {
            System.out.println("(no hay vacantes)");
            return;
        }
        System.out.printf("%-4s %-34s %-20s %-10s %s%n", "ID", "TÍTULO", "EMPRESA", "ESTADO", "SALARIO");
        for (Vacante v : vacantes) {
            System.out.printf("%-4d %-34s %-20s %-10s %s%n", v.getIdVacante(), recortar(v.getTitulo(), 34),
                    recortar(v.getNombreEmpresa(), 20), v.getEstado().getEtiqueta(), rangoSalario(v));
        }
    }

    private void mostrarDetalle(Vacante v) {
        System.out.println("  Id:          " + v.getIdVacante());
        System.out.println("  Título:      " + v.getTitulo());
        System.out.println("  Empresa:     " + v.getNombreEmpresa());
        System.out.println("  Ciudad:      " + (v.getNombreCiudad() == null ? "-" : v.getNombreCiudad()));
        System.out.println("  Contrato:    " + v.getTipoContrato().getEtiqueta() + " · " + v.getModalidad().getEtiqueta()
                + " · " + v.getNivelExperiencia().getEtiqueta());
        System.out.println("  Salario:     " + rangoSalario(v));
        System.out.println("  Estado:      " + v.getEstado().getEtiqueta());
        System.out.println("  Publicada:   " + v.getFechaPublicacion()
                + (v.getFechaCierre() == null ? "" : " · cierra " + v.getFechaCierre()));
    }

    private static String rangoSalario(Vacante v) {
        if (v.getSalarioMin() == null && v.getSalarioMax() == null) {
            return "A convenir";
        }
        String minimo = v.getSalarioMin() == null ? "?" : FORMATO_PESOS.format(v.getSalarioMin());
        String maximo = v.getSalarioMax() == null ? "?" : FORMATO_PESOS.format(v.getSalarioMax());
        return minimo + " - " + maximo;
    }

    private static String recortar(String texto, int maximo) {
        return texto.length() <= maximo ? texto : texto.substring(0, maximo - 1) + "…";
    }

    // ------------------------------------------------------------- leer

    private <E extends Enum<E> & ValorBD> E elegir(String nombre, Class<E> tipo) {
        E[] opciones = tipo.getEnumConstants();
        for (int i = 0; i < opciones.length; i++) {
            System.out.println("   " + (i + 1) + ". " + opciones[i].getEtiqueta());
        }
        while (true) {
            int elegida = leerEntero(nombre + ": ");
            if (elegida >= 1 && elegida <= opciones.length) {
                return opciones[elegida - 1];
            }
            System.out.println("Elige un número entre 1 y " + opciones.length + ".");
        }
    }

    private int elegirDeCatalogo(String nombre, List<OpcionCatalogo> opciones, boolean opcional) {
        opciones.forEach(o -> System.out.println("   " + o.id() + ". " + o.nombre()));
        if (opcional) {
            System.out.println("   0. Ninguna");
        }
        while (true) {
            int elegida = leerEntero(nombre + " (id): ");
            if ((opcional && elegida == 0) || opciones.stream().anyMatch(o -> o.id() == elegida)) {
                return elegida;
            }
            System.out.println("Ese id no está en la lista.");
        }
    }

    private String leerTexto(String mensaje) {
        System.out.print(mensaje);
        return entrada.nextLine().trim();
    }

    private int leerEntero(String mensaje) {
        while (true) {
            String texto = leerTexto(mensaje);
            try {
                return Integer.parseInt(texto);
            } catch (NumberFormatException e) {
                System.out.println("Escribe un número entero.");
            }
        }
    }

    private BigDecimal leerDinero(String mensaje) {
        while (true) {
            String texto = leerTexto(mensaje).replace(".", "").replace(",", "");
            if (texto.isEmpty()) {
                return null;
            }
            try {
                return new BigDecimal(texto);
            } catch (NumberFormatException e) {
                System.out.println("Escribe solo números, por ejemplo 1500000.");
            }
        }
    }

    private LocalDate leerFecha(String mensaje) {
        while (true) {
            String texto = leerTexto(mensaje);
            if (texto.isEmpty()) {
                return null;
            }
            try {
                return LocalDate.parse(texto);
            } catch (DateTimeParseException e) {
                System.out.println("Usa el formato AAAA-MM-DD, por ejemplo 2026-12-31.");
            }
        }
    }
}
