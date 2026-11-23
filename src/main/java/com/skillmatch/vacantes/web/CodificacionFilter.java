package com.skillmatch.vacantes.web;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import java.io.IOException;

/**
 * Filtro que pasa por todas las peticiones y fija la codificación UTF-8, para que tildes y eñes
 * de los formularios lleguen bien al servlet y se muestren bien en las páginas.
 */
@WebFilter("/*")
public class CodificacionFilter implements Filter {

    private static final String UTF_8 = "UTF-8";

    @Override
    public void init(FilterConfig configuracion) {
        // No necesita configuración
    }

    @Override
    public void doFilter(ServletRequest peticion, ServletResponse respuesta, FilterChain cadena)
            throws IOException, ServletException {
        peticion.setCharacterEncoding(UTF_8);
        respuesta.setCharacterEncoding(UTF_8);
        cadena.doFilter(peticion, respuesta);
    }

    @Override
    public void destroy() {
        // No guarda recursos
    }
}
