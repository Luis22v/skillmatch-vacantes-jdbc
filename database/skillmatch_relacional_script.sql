-- ----------------------------------------------------------------------------
-- MySQL Workbench Migration
-- Migrated Schemata: skillmatch_relacional
-- Source Schemata: skillmatch_relacional
-- Created: Sun Nov 22 19:38:42 2026
-- Workbench Version: 8.0.47
-- ----------------------------------------------------------------------------

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------------------
-- Schema skillmatch_relacional
-- ----------------------------------------------------------------------------
DROP SCHEMA IF EXISTS `skillmatch_relacional` ;
CREATE SCHEMA IF NOT EXISTS `skillmatch_relacional` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.rol
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`rol` (
  `id_rol` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`id_rol`),
  UNIQUE INDEX `uq_rol_nombre` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.ciudad
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`ciudad` (
  `id_ciudad` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(60) NOT NULL,
  `departamento` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`id_ciudad`),
  UNIQUE INDEX `uq_ciudad_nombre_depto` (`nombre` ASC, `departamento` ASC) VISIBLE)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.sector
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`sector` (
  `id_sector` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`id_sector`),
  UNIQUE INDEX `uq_sector_nombre` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.habilidad
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`habilidad` (
  `id_habilidad` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`id_habilidad`),
  UNIQUE INDEX `uq_habilidad_nombre` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.usuario
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`usuario` (
  `id_usuario` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `correo` VARCHAR(120) NOT NULL,
  `contrasena_hash` VARCHAR(100) NOT NULL,
  `nombres` VARCHAR(60) NOT NULL,
  `apellidos` VARCHAR(60) NOT NULL,
  `telefono` VARCHAR(15) NULL DEFAULT NULL,
  `titular` VARCHAR(120) NULL DEFAULT NULL,
  `biografia` TEXT NULL DEFAULT NULL,
  `id_ciudad` SMALLINT UNSIGNED NULL DEFAULT NULL,
  `foto_url` VARCHAR(255) NULL DEFAULT NULL,
  `activo` BOOLEAN NOT NULL DEFAULT TRUE,
  `correo_verificado` BOOLEAN NOT NULL DEFAULT FALSE,
  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX `uq_usuario_correo` (`correo` ASC) VISIBLE,
  INDEX `fk_usuario_ciudad` (`id_ciudad` ASC) VISIBLE,
  CONSTRAINT `fk_usuario_ciudad`
    FOREIGN KEY (`id_ciudad`)
    REFERENCES `skillmatch_relacional`.`ciudad` (`id_ciudad`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.usuario_rol
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`usuario_rol` (
  `id_usuario` INT UNSIGNED NOT NULL,
  `id_rol` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_usuario`, `id_rol`),
  INDEX `fk_usuario_rol_rol` (`id_rol` ASC) VISIBLE,
  CONSTRAINT `fk_usuario_rol_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `skillmatch_relacional`.`usuario` (`id_usuario`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_usuario_rol_rol`
    FOREIGN KEY (`id_rol`)
    REFERENCES `skillmatch_relacional`.`rol` (`id_rol`))
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.usuario_habilidad
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`usuario_habilidad` (
  `id_usuario` INT UNSIGNED NOT NULL,
  `id_habilidad` INT UNSIGNED NOT NULL,
  `nivel` ENUM('basico', 'intermedio', 'avanzado', 'experto') NOT NULL,
  `anios_experiencia` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_usuario`, `id_habilidad`),
  INDEX `fk_usuario_habilidad_habilidad` (`id_habilidad` ASC) VISIBLE,
  CONSTRAINT `fk_usuario_habilidad_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `skillmatch_relacional`.`usuario` (`id_usuario`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_usuario_habilidad_habilidad`
    FOREIGN KEY (`id_habilidad`)
    REFERENCES `skillmatch_relacional`.`habilidad` (`id_habilidad`))
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.educacion
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`educacion` (
  `id_educacion` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL,
  `institucion` VARCHAR(120) NOT NULL,
  `titulo` VARCHAR(120) NOT NULL,
  `area_estudio` VARCHAR(120) NULL DEFAULT NULL,
  `fecha_inicio` DATE NOT NULL,
  `fecha_fin` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`id_educacion`),
  INDEX `fk_educacion_usuario` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_educacion_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `skillmatch_relacional`.`usuario` (`id_usuario`)
    ON DELETE CASCADE)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.experiencia
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`experiencia` (
  `id_experiencia` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL,
  `empresa_nombre` VARCHAR(120) NOT NULL,
  `cargo` VARCHAR(120) NOT NULL,
  `descripcion` TEXT NULL DEFAULT NULL,
  `fecha_inicio` DATE NOT NULL,
  `fecha_fin` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`id_experiencia`),
  INDEX `fk_experiencia_usuario` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_experiencia_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `skillmatch_relacional`.`usuario` (`id_usuario`)
    ON DELETE CASCADE)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.certificacion
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`certificacion` (
  `id_certificacion` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL,
  `nombre` VARCHAR(120) NOT NULL,
  `entidad_emisora` VARCHAR(120) NOT NULL,
  `fecha_emision` DATE NOT NULL,
  `fecha_vencimiento` DATE NULL DEFAULT NULL,
  `url_credencial` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id_certificacion`),
  INDEX `fk_certificacion_usuario` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_certificacion_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `skillmatch_relacional`.`usuario` (`id_usuario`)
    ON DELETE CASCADE)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.empresa
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`empresa` (
  `id_empresa` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL,
  `nit` VARCHAR(15) NOT NULL,
  `nombre` VARCHAR(120) NOT NULL,
  `descripcion` TEXT NULL DEFAULT NULL,
  `id_sector` SMALLINT UNSIGNED NULL DEFAULT NULL,
  `id_ciudad` SMALLINT UNSIGNED NULL DEFAULT NULL,
  `sitio_web` VARCHAR(255) NULL DEFAULT NULL,
  `telefono` VARCHAR(15) NULL DEFAULT NULL,
  `verificada` BOOLEAN NOT NULL DEFAULT FALSE,
  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_empresa`),
  UNIQUE INDEX `uq_empresa_usuario` (`id_usuario` ASC) VISIBLE,
  UNIQUE INDEX `uq_empresa_nit` (`nit` ASC) VISIBLE,
  INDEX `fk_empresa_sector` (`id_sector` ASC) VISIBLE,
  INDEX `fk_empresa_ciudad` (`id_ciudad` ASC) VISIBLE,
  CONSTRAINT `fk_empresa_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `skillmatch_relacional`.`usuario` (`id_usuario`),
  CONSTRAINT `fk_empresa_sector`
    FOREIGN KEY (`id_sector`)
    REFERENCES `skillmatch_relacional`.`sector` (`id_sector`)
    ON DELETE SET NULL,
  CONSTRAINT `fk_empresa_ciudad`
    FOREIGN KEY (`id_ciudad`)
    REFERENCES `skillmatch_relacional`.`ciudad` (`id_ciudad`)
    ON DELETE SET NULL)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.vacante
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`vacante` (
  `id_vacante` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_empresa` INT UNSIGNED NOT NULL,
  `titulo` VARCHAR(120) NOT NULL,
  `descripcion` TEXT NOT NULL,
  `tipo_contrato` ENUM('practica', 'medio_tiempo', 'tiempo_completo', 'temporal') NOT NULL,
  `modalidad` ENUM('presencial', 'remoto', 'hibrido') NOT NULL,
  `nivel_experiencia` ENUM('sin_experiencia', 'junior', 'semi_senior', 'senior') NOT NULL,
  `salario_min` DECIMAL(12,2) NULL DEFAULT NULL,
  `salario_max` DECIMAL(12,2) NULL DEFAULT NULL,
  `id_ciudad` SMALLINT UNSIGNED NULL DEFAULT NULL,
  `estado` ENUM('abierta', 'pausada', 'cerrada') NOT NULL DEFAULT 'abierta',
  `fecha_publicacion` DATE NOT NULL,
  `fecha_cierre` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`id_vacante`),
  INDEX `ix_vacante_estado_ciudad` (`estado` ASC, `id_ciudad` ASC) VISIBLE,
  INDEX `fk_vacante_empresa` (`id_empresa` ASC) VISIBLE,
  INDEX `fk_vacante_ciudad` (`id_ciudad` ASC) VISIBLE,
  CONSTRAINT `fk_vacante_empresa`
    FOREIGN KEY (`id_empresa`)
    REFERENCES `skillmatch_relacional`.`empresa` (`id_empresa`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_vacante_ciudad`
    FOREIGN KEY (`id_ciudad`)
    REFERENCES `skillmatch_relacional`.`ciudad` (`id_ciudad`)
    ON DELETE SET NULL)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.vacante_detalle
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`vacante_detalle` (
  `id_detalle` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_vacante` INT UNSIGNED NOT NULL,
  `tipo` ENUM('requisito', 'responsabilidad', 'beneficio') NOT NULL,
  `texto` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id_detalle`),
  INDEX `fk_vacante_detalle_vacante` (`id_vacante` ASC) VISIBLE,
  CONSTRAINT `fk_vacante_detalle_vacante`
    FOREIGN KEY (`id_vacante`)
    REFERENCES `skillmatch_relacional`.`vacante` (`id_vacante`)
    ON DELETE CASCADE)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.vacante_habilidad
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`vacante_habilidad` (
  `id_vacante` INT UNSIGNED NOT NULL,
  `id_habilidad` INT UNSIGNED NOT NULL,
  `obligatoria` BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (`id_vacante`, `id_habilidad`),
  INDEX `fk_vacante_habilidad_habilidad` (`id_habilidad` ASC) VISIBLE,
  CONSTRAINT `fk_vacante_habilidad_vacante`
    FOREIGN KEY (`id_vacante`)
    REFERENCES `skillmatch_relacional`.`vacante` (`id_vacante`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_vacante_habilidad_habilidad`
    FOREIGN KEY (`id_habilidad`)
    REFERENCES `skillmatch_relacional`.`habilidad` (`id_habilidad`))
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.postulacion
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`postulacion` (
  `id_postulacion` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL,
  `id_vacante` INT UNSIGNED NOT NULL,
  `estado` ENUM('pendiente', 'revisada', 'aceptada', 'rechazada') NOT NULL DEFAULT 'pendiente',
  `carta_presentacion` TEXT NULL DEFAULT NULL,
  `porcentaje_match` TINYINT UNSIGNED NULL DEFAULT NULL,
  `postulado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `revisado_en` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id_postulacion`),
  UNIQUE INDEX `uq_postulacion_usuario_vacante` (`id_usuario` ASC, `id_vacante` ASC) VISIBLE,
  INDEX `fk_postulacion_vacante` (`id_vacante` ASC) VISIBLE,
  CONSTRAINT `fk_postulacion_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `skillmatch_relacional`.`usuario` (`id_usuario`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_postulacion_vacante`
    FOREIGN KEY (`id_vacante`)
    REFERENCES `skillmatch_relacional`.`vacante` (`id_vacante`)
    ON DELETE CASCADE)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.vacante_guardada
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`vacante_guardada` (
  `id_usuario` INT UNSIGNED NOT NULL,
  `id_vacante` INT UNSIGNED NOT NULL,
  `guardada_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`, `id_vacante`),
  INDEX `fk_vacante_guardada_vacante` (`id_vacante` ASC) VISIBLE,
  CONSTRAINT `fk_vacante_guardada_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `skillmatch_relacional`.`usuario` (`id_usuario`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_vacante_guardada_vacante`
    FOREIGN KEY (`id_vacante`)
    REFERENCES `skillmatch_relacional`.`vacante` (`id_vacante`)
    ON DELETE CASCADE)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.conexion
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`conexion` (
  `id_conexion` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_solicitante` INT UNSIGNED NOT NULL,
  `id_receptor` INT UNSIGNED NOT NULL,
  `estado` ENUM('pendiente', 'aceptada', 'rechazada') NOT NULL DEFAULT 'pendiente',
  `solicitada_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `respondida_en` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id_conexion`),
  UNIQUE INDEX `uq_conexion_par` (`id_solicitante` ASC, `id_receptor` ASC) VISIBLE,
  INDEX `fk_conexion_receptor` (`id_receptor` ASC) VISIBLE,
  CONSTRAINT `fk_conexion_solicitante`
    FOREIGN KEY (`id_solicitante`)
    REFERENCES `skillmatch_relacional`.`usuario` (`id_usuario`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_conexion_receptor`
    FOREIGN KEY (`id_receptor`)
    REFERENCES `skillmatch_relacional`.`usuario` (`id_usuario`)
    ON DELETE CASCADE)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.mensaje
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`mensaje` (
  `id_mensaje` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_emisor` INT UNSIGNED NOT NULL,
  `id_receptor` INT UNSIGNED NOT NULL,
  `contenido` TEXT NOT NULL,
  `leido` BOOLEAN NOT NULL DEFAULT FALSE,
  `enviado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_mensaje`),
  INDEX `ix_mensaje_receptor_leido` (`id_receptor` ASC, `leido` ASC) VISIBLE,
  INDEX `fk_mensaje_emisor` (`id_emisor` ASC) VISIBLE,
  CONSTRAINT `fk_mensaje_emisor`
    FOREIGN KEY (`id_emisor`)
    REFERENCES `skillmatch_relacional`.`usuario` (`id_usuario`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_mensaje_receptor`
    FOREIGN KEY (`id_receptor`)
    REFERENCES `skillmatch_relacional`.`usuario` (`id_usuario`)
    ON DELETE CASCADE)
ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Table skillmatch_relacional.notificacion
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skillmatch_relacional`.`notificacion` (
  `id_notificacion` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL,
  `tipo` VARCHAR(40) NOT NULL,
  `contenido` VARCHAR(255) NOT NULL,
  `leida` BOOLEAN NOT NULL DEFAULT FALSE,
  `creada_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_notificacion`),
  INDEX `ix_notificacion_usuario_leida` (`id_usuario` ASC, `leida` ASC) VISIBLE,
  CONSTRAINT `fk_notificacion_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `skillmatch_relacional`.`usuario` (`id_usuario`)
    ON DELETE CASCADE)
ENGINE = InnoDB;
SET FOREIGN_KEY_CHECKS = 1;
