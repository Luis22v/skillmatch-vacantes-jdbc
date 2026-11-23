package com.skillmatch.vacantes.modelo;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Una oferta de empleo o práctica publicada por una empresa. Corresponde a la tabla {@code vacante}.
 *
 * <p>{@code nombreEmpresa} y {@code nombreCiudad} no son columnas de la tabla: se llenan al
 * consultar, uniendo con {@code empresa} y {@code ciudad}, para mostrar nombres en vez de números.</p>
 */
public class Vacante {

    private Integer idVacante;
    private int idEmpresa;
    private String titulo;
    private String descripcion;
    private TipoContrato tipoContrato;
    private Modalidad modalidad;
    private NivelExperiencia nivelExperiencia;
    private BigDecimal salarioMin;
    private BigDecimal salarioMax;
    private Integer idCiudad;
    private EstadoVacante estado = EstadoVacante.ABIERTA;
    private LocalDate fechaPublicacion;
    private LocalDate fechaCierre;

    private String nombreEmpresa;
    private String nombreCiudad;

    public Integer getIdVacante() {
        return idVacante;
    }

    public void setIdVacante(Integer idVacante) {
        this.idVacante = idVacante;
    }

    public int getIdEmpresa() {
        return idEmpresa;
    }

    public void setIdEmpresa(int idEmpresa) {
        this.idEmpresa = idEmpresa;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public TipoContrato getTipoContrato() {
        return tipoContrato;
    }

    public void setTipoContrato(TipoContrato tipoContrato) {
        this.tipoContrato = tipoContrato;
    }

    public Modalidad getModalidad() {
        return modalidad;
    }

    public void setModalidad(Modalidad modalidad) {
        this.modalidad = modalidad;
    }

    public NivelExperiencia getNivelExperiencia() {
        return nivelExperiencia;
    }

    public void setNivelExperiencia(NivelExperiencia nivelExperiencia) {
        this.nivelExperiencia = nivelExperiencia;
    }

    public BigDecimal getSalarioMin() {
        return salarioMin;
    }

    public void setSalarioMin(BigDecimal salarioMin) {
        this.salarioMin = salarioMin;
    }

    public BigDecimal getSalarioMax() {
        return salarioMax;
    }

    public void setSalarioMax(BigDecimal salarioMax) {
        this.salarioMax = salarioMax;
    }

    public Integer getIdCiudad() {
        return idCiudad;
    }

    public void setIdCiudad(Integer idCiudad) {
        this.idCiudad = idCiudad;
    }

    public EstadoVacante getEstado() {
        return estado;
    }

    public void setEstado(EstadoVacante estado) {
        this.estado = estado;
    }

    public LocalDate getFechaPublicacion() {
        return fechaPublicacion;
    }

    public void setFechaPublicacion(LocalDate fechaPublicacion) {
        this.fechaPublicacion = fechaPublicacion;
    }

    public LocalDate getFechaCierre() {
        return fechaCierre;
    }

    public void setFechaCierre(LocalDate fechaCierre) {
        this.fechaCierre = fechaCierre;
    }

    public String getNombreEmpresa() {
        return nombreEmpresa;
    }

    public void setNombreEmpresa(String nombreEmpresa) {
        this.nombreEmpresa = nombreEmpresa;
    }

    public String getNombreCiudad() {
        return nombreCiudad;
    }

    public void setNombreCiudad(String nombreCiudad) {
        this.nombreCiudad = nombreCiudad;
    }

    @Override
    public String toString() {
        return "Vacante{id=" + idVacante + ", titulo='" + titulo + "', empresa=" + idEmpresa
                + ", estado=" + estado + "}";
    }
}
