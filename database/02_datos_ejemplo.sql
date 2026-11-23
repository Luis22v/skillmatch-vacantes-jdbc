-- =====================================================================
-- SkillMatch: datos de ejemplo (ficticios) para probar la base
-- Ejecutar después de 01_estructura.sql
-- =====================================================================

USE skillmatch_relacional;

INSERT INTO rol (nombre) VALUES ('estudiante'), ('empresa'), ('administrador');

INSERT INTO ciudad (nombre, departamento) VALUES
    ('Cartagena', 'Bolívar'),
    ('Turbaco', 'Bolívar'),
    ('Barranquilla', 'Atlántico');

INSERT INTO sector (nombre) VALUES
    ('Tecnología'), ('Turismo y hotelería'), ('Logística portuaria');

INSERT INTO habilidad (nombre) VALUES
    ('Java'), ('SQL'), ('JavaScript'), ('Atención al cliente'), ('Inglés');

-- La contraseña es un hash de ejemplo; nunca se guarda la contraseña real
INSERT INTO usuario (correo, contrasena_hash, nombres, apellidos, telefono, titular, id_ciudad, correo_verificado) VALUES
    ('ana.perez@ejemplo.co',     '$2a$10$ejemploHashAnaPerez000000000000000000000000000000000', 'Ana',    'Pérez',   '3001234567', 'Estudiante de desarrollo de software', 1, TRUE),
    ('carlos.diaz@ejemplo.co',   '$2a$10$ejemploHashCarlosDiaz0000000000000000000000000000000', 'Carlos', 'Díaz',    '3009876543', 'Técnico en logística',                 2, TRUE),
    ('rrhh@tecnocaribe.co',      '$2a$10$ejemploHashTecnoCaribe00000000000000000000000000000', 'Laura',  'Gómez',   '6056543210', 'Talento humano en TecnoCaribe',        1, TRUE),
    ('talento@hotelbahia.co',    '$2a$10$ejemploHashHotelBahia000000000000000000000000000000', 'Mario',  'Herrera', '6051112233', 'Selección en Hotel Bahía',             1, TRUE);

INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (1, 1), (2, 1), (3, 2), (4, 2);

INSERT INTO usuario_habilidad (id_usuario, id_habilidad, nivel, anios_experiencia) VALUES
    (1, 1, 'intermedio', 1), (1, 2, 'intermedio', 1), (1, 3, 'basico', 0),
    (2, 4, 'avanzado', 3),   (2, 5, 'basico', 0);

INSERT INTO educacion (id_usuario, institucion, titulo, area_estudio, fecha_inicio) VALUES
    (1, 'SENA', 'Tecnología en Análisis y Desarrollo de Software', 'Software', '2025-07-01');

INSERT INTO experiencia (id_usuario, empresa_nombre, cargo, fecha_inicio, fecha_fin) VALUES
    (2, 'Puerto de Cartagena', 'Auxiliar de bodega', '2022-02-01', '2025-01-31');

INSERT INTO empresa (id_usuario, nit, nombre, descripcion, id_sector, id_ciudad, verificada) VALUES
    (3, '900123456-1', 'TecnoCaribe S.A.S.', 'Desarrollo de software a la medida', 1, 1, TRUE),
    (4, '800654321-2', 'Hotel Bahía',        'Hotel en el centro histórico',       2, 1, FALSE);

INSERT INTO vacante (id_empresa, titulo, descripcion, tipo_contrato, modalidad, nivel_experiencia, salario_min, salario_max, id_ciudad, fecha_publicacion) VALUES
    (1, 'Practicante de desarrollo Java', 'Apoyo en el desarrollo de servicios web con Java.', 'practica',        'hibrido',    'sin_experiencia', 1300000, 1500000, 1, '2026-11-15'),
    (1, 'Desarrollador web junior',       'Construcción de interfaces con HTML, CSS y JS.',    'tiempo_completo', 'remoto',     'junior',          2500000, 3200000, 1, '2026-11-18'),
    (2, 'Recepcionista bilingüe',         'Atención de huéspedes nacionales y extranjeros.',   'tiempo_completo', 'presencial', 'junior',          1800000, 2100000, 1, '2026-11-20');

INSERT INTO vacante_detalle (id_vacante, tipo, texto) VALUES
    (1, 'requisito', 'Estar cursando tecnología o ingeniería de sistemas'),
    (1, 'responsabilidad', 'Programar y probar módulos del backend'),
    (1, 'beneficio', 'Apoyo de sostenimiento y horario flexible'),
    (3, 'requisito', 'Inglés conversacional');

INSERT INTO vacante_habilidad (id_vacante, id_habilidad, obligatoria) VALUES
    (1, 1, TRUE), (1, 2, TRUE), (2, 3, TRUE), (3, 4, TRUE), (3, 5, TRUE);

INSERT INTO postulacion (id_usuario, id_vacante, estado, porcentaje_match) VALUES
    (1, 1, 'revisada', 85), (1, 2, 'pendiente', 60), (2, 3, 'pendiente', 70);

INSERT INTO vacante_guardada (id_usuario, id_vacante) VALUES (1, 2), (2, 3);

INSERT INTO conexion (id_solicitante, id_receptor, estado) VALUES (1, 3, 'aceptada'), (2, 4, 'pendiente');

INSERT INTO mensaje (id_emisor, id_receptor, contenido) VALUES
    (3, 1, 'Hola Ana, revisamos tu postulación a la práctica. ¿Puedes una entrevista el lunes?');

INSERT INTO notificacion (id_usuario, tipo, contenido) VALUES
    (1, 'postulacion', 'Tu postulación a Practicante de desarrollo Java fue revisada');
