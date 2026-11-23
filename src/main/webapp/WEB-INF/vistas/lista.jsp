<%-- Listado de vacantes. Recibe del servlet: vacantes, estados, estadoFiltro y mensaje --%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.skillmatch.vacantes.modelo.Vacante" %>
<%@ page import="com.skillmatch.vacantes.modelo.EstadoVacante" %>
<%@ page import="com.skillmatch.vacantes.web.Html" %>
<%!
    // Declaración JSP: un método que se puede usar en toda la página
    private String claseEstado(EstadoVacante estado) {
        switch (estado) {
            case ABIERTA: return "estado-abierta";
            case PAUSADA: return "estado-pausada";
            default: return "estado-cerrada";
        }
    }
%>
<%@ include file="encabezado.jspf" %>
<%
    // Scriptlet: se leen los atributos que dejó el servlet en la petición
    List<Vacante> vacantes = (List<Vacante>) request.getAttribute("vacantes");
    EstadoVacante[] estados = (EstadoVacante[]) request.getAttribute("estados");
    EstadoVacante estadoFiltro = (EstadoVacante) request.getAttribute("estadoFiltro");
%>

<h1>Vacantes</h1>

<%-- Mensaje de la acción anterior (crear, actualizar o eliminar). Solo aparece si existe --%>
<% if (request.getAttribute("mensaje") != null) { %>
    <p class="aviso aviso-ok"><%= Html.escapar(request.getAttribute("mensaje")) %></p>
<% } %>

<%-- Formulario con método GET: solo consulta, por eso los filtros quedan en la URL --%>
<form class="filtro" method="get" action="${pageContext.request.contextPath}/vacantes">
    <label for="estado">Estado</label>
    <select id="estado" name="estado">
        <option value="">Todas</option>
        <% for (EstadoVacante estado : estados) { %>
            <option value="<%= estado.getValor() %>" <%= estado == estadoFiltro ? "selected" : "" %>>
                <%= estado.getEtiqueta() %>
            </option>
        <% } %>
    </select>
    <button class="boton" type="submit">Filtrar</button>
</form>

<p class="contador"><%= vacantes.size() %> vacante(s)<%= estadoFiltro == null ? "" : " en estado " + estadoFiltro.getEtiqueta().toLowerCase() %>.</p>

<% if (vacantes.isEmpty()) { %>
    <p class="vacio">No hay vacantes para mostrar.</p>
<% } else { %>
<div class="tabla-contenedor">
<table class="tabla">
    <thead>
    <tr>
        <th>Id</th>
        <th>Título</th>
        <th>Empresa</th>
        <th>Ciudad</th>
        <th>Modalidad</th>
        <th>Salario</th>
        <th>Estado</th>
        <th>Acciones</th>
    </tr>
    </thead>
    <tbody>
    <% for (Vacante v : vacantes) { %>
    <tr>
        <td><%= v.getIdVacante() %></td>
        <td><a href="${pageContext.request.contextPath}/vacantes?accion=ver&amp;id=<%= v.getIdVacante() %>"><%= Html.escapar(v.getTitulo()) %></a></td>
        <td><%= Html.escapar(v.getNombreEmpresa()) %></td>
        <td><%= v.getNombreCiudad() == null ? "-" : Html.escapar(v.getNombreCiudad()) %></td>
        <td><%= v.getModalidad().getEtiqueta() %></td>
        <td class="numero"><%= Html.pesos(v.getSalarioMin()) %> – <%= Html.pesos(v.getSalarioMax()) %></td>
        <td><span class="etiqueta <%= claseEstado(v.getEstado()) %>"><%= v.getEstado().getEtiqueta() %></span></td>
        <td class="acciones">
            <a class="boton boton-suave" href="${pageContext.request.contextPath}/vacantes?accion=editar&amp;id=<%= v.getIdVacante() %>">Editar</a>
            <%-- Eliminar cambia datos, por eso va en un formulario POST y no en un enlace --%>
            <form method="post" action="${pageContext.request.contextPath}/vacantes"
                  onsubmit="return confirm('¿Eliminar la vacante <%= v.getIdVacante() %>? También se borran sus postulaciones.');">
                <input type="hidden" name="accion" value="eliminar">
                <input type="hidden" name="id" value="<%= v.getIdVacante() %>">
                <button class="boton boton-peligro" type="submit">Eliminar</button>
            </form>
        </td>
    </tr>
    <% } %>
    </tbody>
</table>
</div>
<% } %>

<%@ include file="pie.jspf" %>
