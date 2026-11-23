package com.skillmatch.vacantes.modelo;

/** Experiencia que pide una vacante (columna {@code vacante.nivel_experiencia}). */
public enum NivelExperiencia implements ValorBD {

    SIN_EXPERIENCIA("sin_experiencia", "Sin experiencia"),
    JUNIOR("junior", "Junior"),
    SEMI_SENIOR("semi_senior", "Semi senior"),
    SENIOR("senior", "Senior");

    private final String valor;
    private final String etiqueta;

    NivelExperiencia(String valor, String etiqueta) {
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
