<%-- Página de error amable. isErrorPage permite usar el objeto implícito "exception" --%>
<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<%@ page import="com.skillmatch.vacantes.web.Html" %>
<%@ include file="encabezado.jspf" %>
<%
    Integer codigo = (Integer) request.getAttribute("javax.servlet.error.status_code");
    boolean noEncontrado = codigo != null && codigo == 404;
    Throwable causa = exception;
    while (causa != null && causa.getCause() != null && causa.getMessage() == null) {
        causa = causa.getCause();
    }
%>
<article class="tarjeta">
    <h1><%= noEncontrado ? "No encontramos esa página" : "Algo salió mal" %></h1>
    <p><%= noEncontrado
            ? "La vacante o la dirección que buscas no existe."
            : Html.escapar(causa == null ? "Ocurrió un error inesperado." : causa.getMessage()) %></p>
    <a class="boton boton-acento" href="${pageContext.request.contextPath}/vacantes">Ir al listado de vacantes</a>
</article>
<%@ include file="pie.jspf" %>
