# SkillMatch · Módulo de vacantes con JDBC

Módulo del proyecto formativo **SkillMatch** (bolsa de empleo de Cartagena) que administra las
vacantes en una base de datos MySQL usando **JDBC**: crear, consultar, actualizar y eliminar.

Evidencias **GA7-220501096-AA2-EV01** (módulo con JDBC) y **GA7-220501096-AA2-EV02** (módulo web con
servlets y JSP) · Tecnología en Análisis y Desarrollo de Software · Ficha 3336093
· Aprendiz: Luis Eduardo Amaya Vidal.

## Tecnologías

| Pieza | Versión |
| --- | --- |
| Java | 17 o superior |
| Maven (incluido como `mvnw`) | 3.9 |
| Controlador JDBC | mysql-connector-j 9.5.0 |
| Base de datos | MySQL 8 o MariaDB 10.4 (XAMPP) |
| Servidor web | Apache Tomcat 8.5 (XAMPP) · Servlet 3.1 · JSP 2.3 |

## Estructura

```
src/main/java/com/skillmatch/vacantes/
├── config/      ConexionBD          abre conexiones JDBC con los datos de db.properties
├── modelo/      Vacante y enums     la tabla vacante como objeto Java
├── dao/         VacanteDAO          contrato de acceso a datos (interfaz)
│                VacanteDAOJdbc      implementación con PreparedStatement
│                CatalogoDAO         empresas y ciudades para elegir
├── servicio/    VacanteServicio     reglas del negocio y validaciones
├── excepcion/   DatosException, ValidacionException
├── app/         AplicacionConsola   menú de consola y modo demostración
└── web/         VacanteServlet      controlador web: GET consulta, POST modifica
                 CodificacionFilter  filtro que fija UTF-8 en todas las peticiones
                 Html                escapa el texto para evitar XSS
src/main/webapp/
├── index.jsp                        redirige al listado
├── css/estilos.css
└── WEB-INF/
    ├── web.xml                      configuración de la aplicación web
    └── vistas/                      lista.jsp, formulario.jsp, detalle.jsp, error.jsp
                                     encabezado.jspf y pie.jspf (incluidos con <%@ include %>)
database/
├── 01_estructura.sql                crea la base skillmatch_relacional (19 tablas)
└── 02_datos_ejemplo.sql             datos de prueba
```

Cada capa solo llama a la de abajo: `app` → `servicio` → `dao` → base de datos.

## Cómo ejecutarlo

1. Encender MySQL desde el panel de XAMPP.
2. Crear la base, una sola vez:
   ```
   C:\xampp\mysql\bin\mysql -u root < database\01_estructura.sql
   C:\xampp\mysql\bin\mysql -u root < database\02_datos_ejemplo.sql
   ```
3. Ejecutar:
   ```
   ejecutar.cmd           (menú interactivo)
   ejecutar.cmd --demo    (crea, consulta, actualiza y elimina una vacante de prueba)
   ```

### Versión web (servlets y JSP)

1. Con MySQL encendido, ejecutar `desplegar.cmd`: compila y copia la aplicación al Tomcat de XAMPP
   (también genera `target\skillmatch-vacantes.war`).
2. Encender Tomcat desde el panel de XAMPP.
3. Abrir http://localhost:8080/skillmatch-vacantes/

| Petición | Qué hace |
| --- | --- |
| `GET /vacantes` | Lista las vacantes; con `?estado=abierta` filtra por estado |
| `GET /vacantes?accion=ver&id=1` | Muestra el detalle de una vacante |
| `GET /vacantes?accion=nueva` / `accion=editar&id=1` | Muestra el formulario |
| `POST /vacantes` con `accion=guardar` | Crea (sin id) o actualiza (con id) y redirige al listado |
| `POST /vacantes` con `accion=eliminar` | Elimina y redirige al listado |

Las páginas JSP usan directivas (`<%@ page %>`, `<%@ include %>`), scriptlets (`<% %>`),
expresiones (`<%= %>`), declaraciones (`<%! %>`), lenguaje de expresiones (`${}`) y objetos
implícitos (`request`, `response`, `exception`).

La conexión usa `root` sin contraseña, como trae XAMPP. Para otro servidor no se edita el código:
se definen las variables de entorno `SKILLMATCH_DB_URL`, `SKILLMATCH_DB_USUARIO` y `SKILLMATCH_DB_CLAVE`.

## Estándares de codificación aplicados

- Paquetes en minúscula; clases en PascalCase; métodos y variables en camelCase; constantes en MAYÚSCULAS.
- Todo el SQL usa `PreparedStatement` con parámetros `?` (evita la inyección SQL).
- Conexiones, sentencias y resultados se cierran con try-with-resources.
- Los errores de JDBC se envuelven en `DatosException` con un mensaje claro en español.
- Ninguna contraseña queda escrita en el código.
