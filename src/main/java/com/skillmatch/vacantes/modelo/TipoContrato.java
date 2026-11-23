package com.skillmatch.vacantes.modelo;

/** Tipo de contrato de una vacante (columna {@code vacante.tipo_contrato}). */
public enum TipoContrato implements ValorBD {

    PRACTICA("practica", "Práctica"),
    MEDIO_TIEMPO("medio_tiempo", "Medio tiempo"),
    TIEMPO_COMPLETO("tiempo_completo", "Tiempo completo"),
    TEMPORAL("temporal", "Temporal");

    private final String valor;
    private final String etiqueta;

    TipoContrato(String valor, String etiqueta) {
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
