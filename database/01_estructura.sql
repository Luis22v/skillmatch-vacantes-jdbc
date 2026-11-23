-- =====================================================================
-- SkillMatch: modelo físico de la base de datos relacional
-- Proyecto formativo: Tecnología en Análisis y Desarrollo de Software
-- Ficha 3336093 · Aprendiz: Luis Eduardo Amaya Vidal
--
-- Motor: MySQL 8 / MariaDB 10.4 (XAMPP). Codificación: utf8mb4.
-- Normalizado a tercera forma normal (3FN):
--   1FN: ningún campo guarda listas (roles, habilidades, requisitos
--        de una vacante van en tablas propias).
--   2FN: en las tablas con llave compuesta, cada dato depende de la
--        llave completa (nivel depende de usuario + habilidad).
--   3FN: ningún dato depende de otro que no sea llave (la ciudad y el
--        sector van en catálogos y se referencian por su id).
-- =====================================================================

CREATE DATABASE IF NOT EXISTS skillmatch_relacional
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE skillmatch_relacional;

-- ---------------------------------------------------------------------
-- Catálogos
-- ---------------------------------------------------------------------

CREATE TABLE rol (
    id_rol      TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(30)      NOT NULL,
    CONSTRAINT pk_rol PRIMARY KEY (id_rol),
    CONSTRAINT uq_rol_nombre UNIQUE (nombre)
) ENGINE = InnoDB;

CREATE TABLE ciudad (
    id_ciudad     SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(60)       NOT NULL,
    departamento  VARCHAR(60)       NOT NULL,
    CONSTRAINT pk_ciudad PRIMARY KEY (id_ciudad),
    CONSTRAINT uq_ciudad_nombre_depto UNIQUE (nombre, departamento)
) ENGINE = InnoDB;

CREATE TABLE sector (
    id_sector   SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(60)       NOT NULL,
    CONSTRAINT pk_sector PRIMARY KEY (id_sector),
    CONSTRAINT uq_sector_nombre UNIQUE (nombre)
) ENGINE = InnoDB;

CREATE TABLE habilidad (
    id_habilidad  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(60)  NOT NULL,
    CONSTRAINT pk_habilidad PRIMARY KEY (id_habilidad),
    CONSTRAINT uq_habilidad_nombre UNIQUE (nombre)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Usuarios y su perfil
-- ---------------------------------------------------------------------

CREATE TABLE usuario (
    id_usuario       INT UNSIGNED      NOT NULL AUTO_INCREMENT,
    correo           VARCHAR(120)      NOT NULL,
    contrasena_hash  VARCHAR(100)      NOT NULL,
    nombres          VARCHAR(60)       NOT NULL,
    apellidos        VARCHAR(60)       NOT NULL,
    telefono         VARCHAR(15)       NULL,
    titular          VARCHAR(120)      NULL,
    biografia        TEXT              NULL,
    id_ciudad        SMALLINT UNSIGNED NULL,
    foto_url         VARCHAR(255)      NULL,
    activo           BOOLEAN           NOT NULL DEFAULT TRUE,
    correo_verificado BOOLEAN          NOT NULL DEFAULT FALSE,
    creado_en        DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en   DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                       ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_correo UNIQUE (correo),
    CONSTRAINT fk_usuario_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES ciudad (id_ciudad)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE = InnoDB;

-- Un usuario puede tener varios roles (estudiante, empresa, admin): N:M
CREATE TABLE usuario_rol (
    id_usuario  INT UNSIGNED     NOT NULL,
    id_rol      TINYINT UNSIGNED NOT NULL,
    CONSTRAINT pk_usuario_rol PRIMARY KEY (id_usuario, id_rol),
    CONSTRAINT fk_usuario_rol_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (id_rol)
        REFERENCES rol (id_rol)
) ENGINE = InnoDB;

-- Habilidades de cada usuario con su nivel: N:M con atributos
CREATE TABLE usuario_habilidad (
    id_usuario         INT UNSIGNED     NOT NULL,
    id_habilidad       INT UNSIGNED     NOT NULL,
    nivel              ENUM('basico', 'intermedio', 'avanzado', 'experto') NOT NULL,
    anios_experiencia  TINYINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT pk_usuario_habilidad PRIMARY KEY (id_usuario, id_habilidad),
    CONSTRAINT fk_usuario_habilidad_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_usuario_habilidad_habilidad FOREIGN KEY (id_habilidad)
        REFERENCES habilidad (id_habilidad),
    CONSTRAINT ck_usuario_habilidad_anios CHECK (anios_experiencia <= 60)
) ENGINE = InnoDB;

CREATE TABLE educacion (
    id_educacion    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_usuario      INT UNSIGNED NOT NULL,
    institucion     VARCHAR(120) NOT NULL,
    titulo          VARCHAR(120) NOT NULL,
    area_estudio    VARCHAR(120) NULL,
    fecha_inicio    DATE         NOT NULL,
    fecha_fin       DATE         NULL,
    CONSTRAINT pk_educacion PRIMARY KEY (id_educacion),
    CONSTRAINT fk_educacion_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT ck_educacion_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
) ENGINE = InnoDB;

CREATE TABLE experiencia (
    id_experiencia  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_usuario      INT UNSIGNED NOT NULL,
    empresa_nombre  VARCHAR(120) NOT NULL,
    cargo           VARCHAR(120) NOT NULL,
    descripcion     TEXT         NULL,
    fecha_inicio    DATE         NOT NULL,
    fecha_fin       DATE         NULL,
    CONSTRAINT pk_experiencia PRIMARY KEY (id_experiencia),
    CONSTRAINT fk_experiencia_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT ck_experiencia_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
) ENGINE = InnoDB;

CREATE TABLE certificacion (
    id_certificacion   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_usuario         INT UNSIGNED NOT NULL,
    nombre             VARCHAR(120) NOT NULL,
    entidad_emisora    VARCHAR(120) NOT NULL,
    fecha_emision      DATE         NOT NULL,
    fecha_vencimiento  DATE         NULL,
    url_credencial     VARCHAR(255) NULL,
    CONSTRAINT pk_certificacion PRIMARY KEY (id_certificacion),
    CONSTRAINT fk_certificacion_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT ck_certificacion_fechas
        CHECK (fecha_vencimiento IS NULL OR fecha_vencimiento >= fecha_emision)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Empresas y vacantes
-- ---------------------------------------------------------------------

-- Cada empresa la administra un usuario: relación 1:1
CREATE TABLE empresa (
    id_empresa     INT UNSIGNED      NOT NULL AUTO_INCREMENT,
    id_usuario     INT UNSIGNED      NOT NULL,
    nit            VARCHAR(15)       NOT NULL,
    nombre         VARCHAR(120)      NOT NULL,
    descripcion    TEXT              NULL,
    id_sector      SMALLINT UNSIGNED NULL,
    id_ciudad      SMALLINT UNSIGNED NULL,
    sitio_web      VARCHAR(255)      NULL,
    telefono       VARCHAR(15)       NULL,
    verificada     BOOLEAN           NOT NULL DEFAULT FALSE,
    creado_en      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_empresa PRIMARY KEY (id_empresa),
    CONSTRAINT uq_empresa_usuario UNIQUE (id_usuario),
    CONSTRAINT uq_empresa_nit UNIQUE (nit),
    CONSTRAINT fk_empresa_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario),
    CONSTRAINT fk_empresa_sector FOREIGN KEY (id_sector)
        REFERENCES sector (id_sector) ON DELETE SET NULL,
    CONSTRAINT fk_empresa_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES ciudad (id_ciudad) ON DELETE SET NULL
) ENGINE = InnoDB;

CREATE TABLE vacante (
    id_vacante        INT UNSIGNED      NOT NULL AUTO_INCREMENT,
    id_empresa        INT UNSIGNED      NOT NULL,
    titulo            VARCHAR(120)      NOT NULL,
    descripcion       TEXT              NOT NULL,
    tipo_contrato     ENUM('practica', 'medio_tiempo', 'tiempo_completo', 'temporal') NOT NULL,
    modalidad         ENUM('presencial', 'remoto', 'hibrido') NOT NULL,
    nivel_experiencia ENUM('sin_experiencia', 'junior', 'semi_senior', 'senior') NOT NULL,
    salario_min       DECIMAL(12, 2)    NULL,
    salario_max       DECIMAL(12, 2)    NULL,
    id_ciudad         SMALLINT UNSIGNED NULL,
    estado            ENUM('abierta', 'pausada', 'cerrada') NOT NULL DEFAULT 'abierta',
    fecha_publicacion DATE              NOT NULL,
    fecha_cierre      DATE              NULL,
    CONSTRAINT pk_vacante PRIMARY KEY (id_vacante),
    CONSTRAINT fk_vacante_empresa FOREIGN KEY (id_empresa)
        REFERENCES empresa (id_empresa) ON DELETE CASCADE,
    CONSTRAINT fk_vacante_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES ciudad (id_ciudad) ON DELETE SET NULL,
    CONSTRAINT ck_vacante_salario
        CHECK (salario_min IS NULL OR salario_max IS NULL OR salario_max >= salario_min),
    CONSTRAINT ck_vacante_fechas
        CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_publicacion)
) ENGINE = InnoDB;

-- Requisitos, responsabilidades y beneficios de una vacante: 1:N
CREATE TABLE vacante_detalle (
    id_detalle  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_vacante  INT UNSIGNED NOT NULL,
    tipo        ENUM('requisito', 'responsabilidad', 'beneficio') NOT NULL,
    texto       VARCHAR(255) NOT NULL,
    CONSTRAINT pk_vacante_detalle PRIMARY KEY (id_detalle),
    CONSTRAINT fk_vacante_detalle_vacante FOREIGN KEY (id_vacante)
        REFERENCES vacante (id_vacante) ON DELETE CASCADE
) ENGINE = InnoDB;

-- Habilidades que pide cada vacante: N:M
CREATE TABLE vacante_habilidad (
    id_vacante    INT UNSIGNED NOT NULL,
    id_habilidad  INT UNSIGNED NOT NULL,
    obligatoria   BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_vacante_habilidad PRIMARY KEY (id_vacante, id_habilidad),
    CONSTRAINT fk_vacante_habilidad_vacante FOREIGN KEY (id_vacante)
        REFERENCES vacante (id_vacante) ON DELETE CASCADE,
    CONSTRAINT fk_vacante_habilidad_habilidad FOREIGN KEY (id_habilidad)
        REFERENCES habilidad (id_habilidad)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Interacción entre usuarios y vacantes
-- ---------------------------------------------------------------------

CREATE TABLE postulacion (
    id_postulacion    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_usuario        INT UNSIGNED NOT NULL,
    id_vacante        INT UNSIGNED NOT NULL,
    estado            ENUM('pendiente', 'revisada', 'aceptada', 'rechazada') NOT NULL DEFAULT 'pendiente',
    carta_presentacion TEXT        NULL,
    porcentaje_match  TINYINT UNSIGNED NULL,
    postulado_en      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revisado_en       DATETIME     NULL,
    CONSTRAINT pk_postulacion PRIMARY KEY (id_postulacion),
    CONSTRAINT uq_postulacion_usuario_vacante UNIQUE (id_usuario, id_vacante),
    CONSTRAINT fk_postulacion_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_postulacion_vacante FOREIGN KEY (id_vacante)
        REFERENCES vacante (id_vacante) ON DELETE CASCADE,
    CONSTRAINT ck_postulacion_match CHECK (porcentaje_match IS NULL OR porcentaje_match <= 100)
) ENGINE = InnoDB;

CREATE TABLE vacante_guardada (
    id_usuario   INT UNSIGNED NOT NULL,
    id_vacante   INT UNSIGNED NOT NULL,
    guardada_en  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_vacante_guardada PRIMARY KEY (id_usuario, id_vacante),
    CONSTRAINT fk_vacante_guardada_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_vacante_guardada_vacante FOREIGN KEY (id_vacante)
        REFERENCES vacante (id_vacante) ON DELETE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Red de contactos, mensajes y notificaciones
-- ---------------------------------------------------------------------

CREATE TABLE conexion (
    id_conexion     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_solicitante  INT UNSIGNED NOT NULL,
    id_receptor     INT UNSIGNED NOT NULL,
    estado          ENUM('pendiente', 'aceptada', 'rechazada') NOT NULL DEFAULT 'pendiente',
    solicitada_en   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    respondida_en   DATETIME     NULL,
    CONSTRAINT pk_conexion PRIMARY KEY (id_conexion),
    CONSTRAINT uq_conexion_par UNIQUE (id_solicitante, id_receptor),
    CONSTRAINT fk_conexion_solicitante FOREIGN KEY (id_solicitante)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_conexion_receptor FOREIGN KEY (id_receptor)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT ck_conexion_distintos CHECK (id_solicitante <> id_receptor)
) ENGINE = InnoDB;

CREATE TABLE mensaje (
    id_mensaje   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_emisor    INT UNSIGNED NOT NULL,
    id_receptor  INT UNSIGNED NOT NULL,
    contenido    TEXT         NOT NULL,
    leido        BOOLEAN      NOT NULL DEFAULT FALSE,
    enviado_en   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_mensaje PRIMARY KEY (id_mensaje),
    CONSTRAINT fk_mensaje_emisor FOREIGN KEY (id_emisor)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_mensaje_receptor FOREIGN KEY (id_receptor)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE notificacion (
    id_notificacion  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_usuario       INT UNSIGNED NOT NULL,
    tipo             VARCHAR(40)  NOT NULL,
    contenido        VARCHAR(255) NOT NULL,
    leida            BOOLEAN      NOT NULL DEFAULT FALSE,
    creada_en        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_notificacion PRIMARY KEY (id_notificacion),
    CONSTRAINT fk_notificacion_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE
) ENGINE = InnoDB;

-- Índices para las búsquedas más frecuentes
CREATE INDEX ix_vacante_estado_ciudad ON vacante (estado, id_ciudad);
CREATE INDEX ix_mensaje_receptor_leido ON mensaje (id_receptor, leido);
CREATE INDEX ix_notificacion_usuario_leida ON notificacion (id_usuario, leida);
