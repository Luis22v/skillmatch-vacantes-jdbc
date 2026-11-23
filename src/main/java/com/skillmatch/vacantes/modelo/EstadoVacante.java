package com.skillmatch.vacantes.modelo;

/** Estado de publicación de una vacante (columna {@code vacante.estado}). */
public enum EstadoVacante implements ValorBD {

    ABIERTA("abierta", "Abierta"),
    PAUSADA("pausada", "Pausada"),
    CERRADA("cerrada", "Cerrada");

    private final String valor;
    private final String etiqueta;

    EstadoVacante(String valor, String etiqueta) {
        this.valor = valor;
        this.etiqueta = etiqueta;
    }

    @Override
    public String getValor() {
        return valor;
    }

    @Override
    public String getEtiqueta() {
        return etiqueta;
    }
}
