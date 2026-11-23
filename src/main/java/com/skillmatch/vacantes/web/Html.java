package com.skillmatch.vacantes.web;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.Locale;

/**
 * Ayudas para mostrar datos en las páginas JSP de forma segura.
 */
public final class Html {

    private static final NumberFormat FORMATO_PESOS = NumberFormat.getCurrencyInstance(Locale.forLanguageTag("es-CO"));

    private Html() {
    }

    /**
     * Convierte los caracteres especiales de HTML en entidades. Así, si alguien escribe
     * {@code <script>} en un formulario, se muestra como texto y no se ejecuta (evita XSS).
     */
    public static String escapar(Object valor) {
        if (valor == null) {
            return "";
        }
        String texto = valor.toString();
        StringBuilder resultado = new StringBuilder(texto.length());
        for (char c : texto.toCharArray()) {
            switch (c) {
                case '<' -> resultado.append("&lt;");
                case '>' -> resultado.append("&gt;");
                case '&' -> resultado.append("&amp;");
                case '"' -> resultado.append("&quot;");
                case '\'' -> resultado.append("&#39;");
                default -> resultado.append(c);
            }
        }
        return resultado.toString();
    }

    /** Valor en pesos colombianos, o un guion si no hay valor. */
    public static String pesos(BigDecimal valor) {
        return valor == null ? "-" : FORMATO_PESOS.format(valor);
    }

    /** Valor para un campo de formulario: texto vacío si es null. */
    public static String campo(Object valor) {
        return valor == null ? "" : escapar(valor.toString());
    }
}
