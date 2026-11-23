package com.skillmatch.vacantes.modelo;

/** Modalidad de trabajo de una vacante (columna {@code vacante.modalidad}). */
public enum Modalidad implements ValorBD {

    PRESENCIAL("presencial", "Presencial"),
    REMOTO("remoto", "Remoto"),
    HIBRIDO("hibrido", "Híbrido");

    private final String valor;
    private final String etiqueta;

    Modalidad(String valor, String etiqueta) {
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
