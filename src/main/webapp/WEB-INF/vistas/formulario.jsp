<%-- Formulario para crear o editar una vacante. Se envía con POST al servlet --%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.skillmatch.vacantes.modelo.*" %>
<%@ page import="com.skillmatch.vacantes.web.Html" %>
<%@ include file="encabezado.jspf" %>
<%
    Vacante v = (Vacante) request.getAttribute("vacante");
    boolean editando = v.getIdVacante() != null;
    List<OpcionCatalogo> empresas = (List<OpcionCatalogo>) request.getAttribute("empresas");
    List<OpcionCatalogo> ciudades = (List<OpcionCatalogo>) request.getAttribute("ciudades");
%>

<h1><%= editando ? "Editar vacante " + v.getIdVacante() : "Nueva vacante" %></h1>

<%-- Si el servlet devolvió un error de validación, se muestra arriba del formulario --%>
<% if (request.getAttribute("error") != null) { %>
    <p class="aviso aviso-error"><%= Html.escapar(request.getAttribute("error")) %></p>
<% } %>

<form class="formulario" method="post" action="${pageContext.request.contextPath}/vacantes">
    <input type="hidden" name="accion" value="guardar">
    <% if (editando) { %>
        <input type="hidden" name="id" value="<%= v.getIdVacante() %>">
        <input type="hidden" name="fechaPublicacion" value="<%= Html.campo(v.getFechaPublicacion()) %>">
    <% } %>

    <label for="idEmpresa">Empresa</label>
    <select id="idEmpresa" name="idEmpresa" required>
        <option value="">Elige una empresa</option>
        <% for (OpcionCatalogo empresa : empresas) { %>
            <option value="<%= empresa.id() %>" <%= empresa.id() == v.getIdEmpresa() ? "selected" : "" %>><%= Html.escapar(empresa.nombre()) %></option>
        <% } %>
    </select>

    <label for="titulo">Título</label>
    <input id="titulo" name="titulo" type="text" maxlength="120" required value="<%= Html.campo(v.getTitulo()) %>">

    <label for="descripcion">Descripción</label>
    <textarea id="descripcion" name="descripcion" rows="4" required><%= Html.campo(v.getDescripcion()) %></textarea>

    <div class="fila">
        <div>
            <label for="tipoContrato">Tipo de contrato</label>
            <select id="tipoContrato" name="tipoContrato" required>
                <% for (TipoContrato tipo : TipoContrato.values()) { %>
                    <option value="<%= tipo.getValor() %>" <%= tipo == v.getTipoContrato() ? "selected" : "" %>><%= tipo.getEtiqueta() %></option>
                <% } %>
            </select>
        </div>
        <div>
            <label for="modalidad">Modalidad</label>
            <select id="modalidad" name="modalidad" required>
                <% for (Modalidad modalidad : Modalidad.values()) { %>
                    <option value="<%= modalidad.getValor() %>" <%= modalidad == v.getModalidad() ? "selected" : "" %>><%= modalidad.getEtiqueta() %></option>
                <% } %>
            </select>
        </div>
        <div>
            <label for="nivelExperiencia">Experiencia</label>
            <select id="nivelExperiencia" name="nivelExperiencia" required>
                <% for (NivelExperiencia nivel : NivelExperiencia.values()) { %>
                    <option value="<%= nivel.getValor() %>" <%= nivel == v.getNivelExperiencia() ? "selected" : "" %>><%= nivel.getEtiqueta() %></option>
                <% } %>
            </select>
        </div>
    </div>

    <div class="fila">
        <div>
            <label for="salarioMin">Salario mínimo (COP)</label>
            <input id="salarioMin" name="salarioMin" type="number" min="0" step="1000" value="<%= Html.campo(v.getSalarioMin() == null ? null : v.getSalarioMin().toBigInteger()) %>">
        </div>
        <div>
            <label for="salarioMax">Salario máximo (COP)</label>
            <input id="salarioMax" name="salarioMax" type="number" min="0" step="1000" value="<%= Html.campo(v.getSalarioMax() == null ? null : v.getSalarioMax().toBigInteger()) %>">
        </div>
    </div>

    <div class="fila">
        <div>
            <label for="idCiudad">Ciudad</label>
            <select id="idCiudad" name="idCiudad">
                <option value="0">Sin ciudad</option>
                <% for (OpcionCatalogo ciudad : ciudades) { %>
                    <option value="<%= ciudad.id() %>" <%= v.getIdCiudad() != null && ciudad.id() == v.getIdCiudad() ? "selected" : "" %>><%= Html.escapar(ciudad.nombre()) %></option>
                <% } %>
            </select>
        </div>
        <div>
            <label for="estado">Estado</label>
            <select id="estado" name="estado">
                <% for (EstadoVacante estado : EstadoVacante.values()) { %>
                    <option value="<%= estado.getValor() %>" <%= estado == v.getEstado() ? "selected" : "" %>><%= estado.getEtiqueta() %></option>
                <% } %>
            </select>
        </div>
        <div>
            <label for="fechaCierre">Fecha de cierre</label>
            <input id="fechaCierre" name="fechaCierre" type="date" value="<%= Html.campo(v.getFechaCierre()) %>">
        </div>
    </div>

    <div class="botones">
        <button class="boton boton-acento" type="submit"><%= editando ? "Guardar cambios" : "Crear vacante" %></button>
        <a class="boton boton-suave" href="${pageContext.request.contextPath}/vacantes">Cancelar</a>
    </div>
</form>

<%@ include file="pie.jspf" %>
