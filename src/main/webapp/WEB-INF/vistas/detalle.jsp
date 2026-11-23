<%-- Detalle de una vacante. Usa sobre todo lenguaje de expresiones (EL) --%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.skillmatch.vacantes.modelo.Vacante" %>
<%@ page import="com.skillmatch.vacantes.web.Html" %>
<%@ include file="encabezado.jspf" %>
<% Vacante v = (Vacante) request.getAttribute("vacante"); %>

<p><a href="${pageContext.request.contextPath}/vacantes">&larr; Volver al listado</a></p>

<article class="tarjeta">
    <h1><%= Html.escapar(v.getTitulo()) %></h1>
    <p class="subtitulo"><%= Html.escapar(v.getNombreEmpresa()) %> · ${vacante.modalidad.etiqueta} · ${vacante.estado.etiqueta}</p>

    <dl class="datos">
        <dt>Id</dt>                  <dd>${vacante.idVacante}</dd>
        <dt>Tipo de contrato</dt>    <dd>${vacante.tipoContrato.etiqueta}</dd>
        <dt>Experiencia</dt>         <dd>${vacante.nivelExperiencia.etiqueta}</dd>
        <dt>Ciudad</dt>              <dd><%= v.getNombreCiudad() == null ? "Sin ciudad" : Html.escapar(v.getNombreCiudad()) %></dd>
        <dt>Salario</dt>             <dd><%= Html.pesos(v.getSalarioMin()) %> – <%= Html.pesos(v.getSalarioMax()) %></dd>
        <dt>Publicada</dt>           <dd>${vacante.fechaPublicacion}</dd>
        <dt>Cierre</dt>              <dd><%= v.getFechaCierre() == null ? "Sin fecha de cierre" : v.getFechaCierre() %></dd>
    </dl>

    <h2>Descripción</h2>
    <p><%= Html.escapar(v.getDescripcion()) %></p>

    <a class="boton boton-acento" href="${pageContext.request.contextPath}/vacantes?accion=editar&amp;id=${vacante.idVacante}">Editar</a>
</article>

<%@ include file="pie.jspf" %>
