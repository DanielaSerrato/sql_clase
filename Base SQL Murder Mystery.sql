-- ============================================================
--  MISTERIO DE ASESINATO EN SQL — Versión didáctica (MySQL)
--  Inspirado en SQL Murder Mystery
--  Adaptado y simplificado para fines pedagógicos
-- ============================================================

DROP DATABASE IF EXISTS misterio_sql;
CREATE DATABASE misterio_sql CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE misterio_sql;

-- ─────────────────────────────────────────────
-- TABLAS
-- ─────────────────────────────────────────────

CREATE TABLE licencia_conducir (
    id              INT PRIMARY KEY,
    edad            INT,
    altura          INT,
    color_ojos      VARCHAR(20),
    color_cabello   VARCHAR(20),
    genero          VARCHAR(10),
    placa           VARCHAR(20),
    marca_auto      VARCHAR(50),
    modelo_auto     VARCHAR(50)
);

CREATE TABLE persona (
    id                      INT PRIMARY KEY,
    nombre                  VARCHAR(100),
    id_licencia             INT,
    numero_direccion        INT,
    nombre_calle            VARCHAR(100),
    cedula                  VARCHAR(20),
    FOREIGN KEY (id_licencia) REFERENCES licencia_conducir(id)
);

CREATE TABLE reporte_crimen (
    fecha           INT,
    tipo            VARCHAR(50),
    descripcion     TEXT,
    ciudad          VARCHAR(50)
);

CREATE TABLE entrevista (
    id_persona      INT,
    transcripcion   TEXT,
    FOREIGN KEY (id_persona) REFERENCES persona(id)
);

CREATE TABLE miembro_gimnasio (
    id                      VARCHAR(20) PRIMARY KEY,
    id_persona              INT,
    nombre                  VARCHAR(100),
    fecha_inicio_membresia  INT,
    estado_membresia        VARCHAR(20),
    FOREIGN KEY (id_persona) REFERENCES persona(id)
);

CREATE TABLE checkin_gimnasio (
    id_membresia        VARCHAR(20),
    fecha_checkin       INT,
    hora_entrada        INT,
    hora_salida         INT,
    FOREIGN KEY (id_membresia) REFERENCES miembro_gimnasio(id)
);

CREATE TABLE checkin_evento (
    id_persona      INT,
    id_evento       INT,
    nombre_evento   VARCHAR(100),
    fecha           INT,
    FOREIGN KEY (id_persona) REFERENCES persona(id)
);

CREATE TABLE ingreso (
    cedula          VARCHAR(20) PRIMARY KEY,
    ingreso_anual   INT
);

CREATE TABLE solucion (
    id_usuario INT,
    valor VARCHAR(100)
);

INSERT INTO solucion VALUES (1, '');

-- ─────────────────────────────────────────────
-- DATOS
-- ─────────────────────────────────────────────

INSERT INTO licencia_conducir VALUES
(100280, 35, 70, 'cafe',   'cafe',   'masculino',  'QX143J',  'Toyota',     'Prius'),
(173289, 55, 68, 'verde',  'rubio',  'femenino',   'TW394F',  'BMW',        'M5'),
(202298, 28, 72, 'azul',   'negro',  'masculino',  'H42W0X',  'Chevrolet',  'Spark LS'),
(291182, 65, 66, 'azul',   'rubio',  'femenino',   '0H42W2',  'Chevrolet',  'Equinox'),
(423327, 30, 70, 'cafe',   'cafe',   'masculino',  '0H42W2',  'Chevrolet',  'Spark LS'),
(664760, 21, 71, 'negro',  'negro',  'masculino',  '4H42WR',  'Nissan',     'Altima'),
(918773, 48, 65, 'negro',  'rojo',   'femenino',   '917UU3',  'Tesla',      'Model S'),
(172386, 54, 67, 'cafe',   'rojo',   'femenino',   'WD5M3N',  'Tesla',      'Model S'),
(465671, 34, 65, 'azul',   'rojo',   'femenino',   '4IQXK9',  'Tesla',      'Model S'),
(789518, 42, 69, 'avellana','cafe',  'masculino',  'ZX123A',  'Ford',       'F-150'),
(111564, 38, 73, 'azul',   'rubio',  'masculino',  'W34CQ4',  'BMW',        '328i'),
(490173, 29, 66, 'cafe',   'negro',  'femenino',   'AB123C',  'Kia',        'Rio'); -- FIX

INSERT INTO persona VALUES
(14887, 'Mauricio Chaparro',   111564, 4919, 'Av. Noroccidental', '111564949'),
(16371, 'Anabel Millan',       490173, 103,  'Calle Franklin',    '318771143'),
(37191, 'Jorge Benavides',     423327, 530,  'Calle Washington',  '871539279'),
(67318, 'Miranda Prieto',      202298, 1883, 'Av. Dorada',        '987756388'),
(28819, 'Jose Guerrero',       100280, 111,  'Calle Fisk',        '137882671');

INSERT INTO reporte_crimen VALUES
(20180115, 'asesinato', 'Dos testigos: uno en Av. Noroccidental y Anabel en Calle Franklin.', 'SQL City');

INSERT INTO miembro_gimnasio VALUES
('48Z7A', 28819, 'Jose Guerrero',    20160305, 'oro'),
('48Z55', 37191, 'Jorge Benavides',  20160101, 'oro'),
('90081', 16371, 'Anabel Millan',    20160208, 'oro');

INSERT INTO checkin_gimnasio VALUES
('48Z7A', 20180109, 1600, 1730),
('48Z55', 20180109, 1530, 1700);

INSERT INTO checkin_evento VALUES
(67318, 1143, 'Concierto Sinfonia SQL', 20171206),
(67318, 1143, 'Concierto Sinfonia SQL', 20171212),
(67318, 1143, 'Concierto Sinfonia SQL', 20171229);

INSERT INTO entrevista VALUES
(14887, 'El sospechoso tenia bolsa del gimnasio, membresia 48Z y placa H42W.'),
(16371, 'Lo vi en el gimnasio el 9 de enero.'),
(37191, 'Me contrato una mujer rica, cabello rojo, Tesla, fue 3 veces a concierto.');

INSERT INTO ingreso VALUES
('987756388', 310000);

-- ─────────────────────────────────────────────
-- PROCEDIMIENTOS
-- ─────────────────────────────────────────────


CREATE PROCEDURE verificar_asesino(IN nombre VARCHAR(100))
BEGIN
    IF nombre = 'Jorge Benavides' THEN
        SELECT 'CORRECTO: Encontraste al asesino material.' AS resultado;
    ELSE
        SELECT 'Incorrecto. Sigue investigando.' AS resultado;
    END IF;
END //

CREATE PROCEDURE verificar_autora(IN nombre VARCHAR(100))
BEGIN
    IF nombre = 'Miranda Prieto' THEN
        SELECT 'CORRECTO: Encontraste a la autora intelectual.' AS resultado;
    ELSE
        SELECT 'Incorrecto. Sigue investigando.' AS resultado;
    END IF;
END //

DELIMITER ;