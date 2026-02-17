-- ==========================================================
-- SCRIPT DOCENTE PASO A PASO - MySQL 8+ (Workbench)
-- Caso: Planta Nuclear de Springfield (Los Simpson)
-- Objetivo de clase: entender relaciones + reglas de integridad
-- ==========================================================

-- PASO 0) Reinicio limpio del entorno
DROP DATABASE IF EXISTS planta_nuclear;
CREATE DATABASE planta_nuclear
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_spanish_ci;
USE planta_nuclear;

-- ==========================================================
-- PASO 1) MODELO FÍSICO (DDL)
-- ==========================================================

-- 1.1 Tabla PADRE: empleados
CREATE TABLE empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    turno ENUM('mañana','tarde','noche') NOT NULL,
    rol VARCHAR(50) NULL
);

-- 1.2 Tabla PADRE: turnos
CREATE TABLE turnos (
    id_turno INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL
);

-- 1.3 Tabla HIJA puente: empleado_turno
-- Relación N:N entre empleados y turnos resuelta con tabla intermedia.
CREATE TABLE empleado_turno (
    id_turno INT NOT NULL,
    id_empleado INT NOT NULL,
    PRIMARY KEY (id_turno, id_empleado),
    CONSTRAINT fk_empleado_turno_turno
        FOREIGN KEY (id_turno) REFERENCES turnos(id_turno)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_empleado_turno_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleados(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 1.4 Tabla PADRE: reactores
CREATE TABLE reactores (
    id_reactor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    estado ENUM('activo','apagado','mantenimiento') NOT NULL
);

-- 1.5 Tabla HIJA: incidentes
CREATE TABLE incidentes (
    id_incidente INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    tipo ENUM('eléctrico','mecánico','sistema') NOT NULL,
    severidad INT NOT NULL,
    id_turno INT NOT NULL,
    id_reactor INT NOT NULL,
    CONSTRAINT chk_incidente_severidad CHECK (severidad BETWEEN 1 AND 3),
    CONSTRAINT fk_incidente_turno
        FOREIGN KEY (id_turno) REFERENCES turnos(id_turno)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_incidente_reactor
        FOREIGN KEY (id_reactor) REFERENCES reactores(id_reactor)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 1.6 Tabla HIJA: mantenimientos
CREATE TABLE mantenimientos (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    tipo ENUM('eléctrico','mecánico','sistema') NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    id_reactor INT NOT NULL,
    CONSTRAINT fk_mantenimiento_reactor
        FOREIGN KEY (id_reactor) REFERENCES reactores(id_reactor)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 1.7 Tabla HIJA: casilleros
CREATE TABLE casilleros (
    id_casillero INT AUTO_INCREMENT PRIMARY KEY,
    numero INT NOT NULL,
    id_empleado INT NOT NULL,
    CONSTRAINT fk_casillero_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleados(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ==========================================================
-- PASO 2) CARGA DE DATOS PADRE (DML)
-- ==========================================================
INSERT INTO empleados (nombre, turno, rol) VALUES
('Homero Simpson', 'mañana', 'Supervisor de Seguridad'),
('Lisa Simpson', 'tarde', 'Analista Junior'),
('Carl Carlson', 'noche', 'Operador'),
('Lenny Leonard', 'mañana', 'Técnico'),
('Yo (Estudiante)', 'tarde', 'Practicante');

INSERT INTO turnos (fecha, hora_inicio, hora_fin) VALUES
('2025-05-01', '06:00:00', '14:00:00'),
('2025-05-02', '14:00:00', '22:00:00'),
('2025-05-03', '22:00:00', '06:00:00'),
('2025-05-04', '06:00:00', '14:00:00'),
('2025-05-05', '14:00:00', '22:00:00');

INSERT INTO reactores (nombre, estado) VALUES
('Reactor A', 'activo'),
('Reactor B', 'mantenimiento'),
('Reactor C', 'apagado'),
('Reactor D', 'activo'),
('Reactor E', 'mantenimiento');

-- ==========================================================
-- PASO 3) CARGA DE DATOS HIJA (DML)
-- ==========================================================
INSERT INTO empleado_turno (id_turno, id_empleado) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO incidentes (fecha, tipo, severidad, id_turno, id_reactor) VALUES
('2025-05-01', 'eléctrico', 2, 1, 1),
('2025-05-02', 'mecánico', 3, 2, 2),
('2025-05-03', 'sistema', 1, 3, 3),
('2025-05-04', 'eléctrico', 2, 4, 4),
('2025-05-05', 'mecánico', 3, 5, 5);

INSERT INTO mantenimientos (fecha, tipo, costo, id_reactor) VALUES
('2025-05-01', 'mecánico', 1500.00, 1),
('2025-05-02', 'eléctrico', 2200.50, 2),
('2025-05-03', 'sistema', 1800.00, 3),
('2025-05-04', 'mecánico', 2050.75, 4),
('2025-05-05', 'eléctrico', 1999.99, 5);

INSERT INTO casilleros (numero, id_empleado) VALUES
(101, 1),
(102, 2),
(103, 3),
(104, 4),
(105, 5);

-- ==========================================================
-- PASO 4) CONSULTAS BASE (válidas)
-- ==========================================================
SELECT * FROM empleados;

SELECT id, nombre, rol
FROM empleados
WHERE turno = 'tarde';

SELECT i.id_incidente, i.fecha, i.tipo, i.severidad, r.nombre AS reactor, t.fecha AS fecha_turno
FROM incidentes i
JOIN reactores r ON i.id_reactor = r.id_reactor
JOIN turnos t ON i.id_turno = t.id_turno;

SELECT et.id_turno, t.fecha, e.id AS id_empleado, e.nombre, e.turno, e.rol
FROM empleado_turno et
JOIN empleados e ON et.id_empleado = e.id
JOIN turnos t ON et.id_turno = t.id_turno;

UPDATE empleados
SET rol = 'Jefa de Seguridad'
WHERE nombre = 'Lisa Simpson';

SELECT id, nombre, rol
FROM empleados
WHERE nombre = 'Lisa Simpson';

-- Duplicado temporal + borrado por ID sin romper FKs.
INSERT INTO turnos (fecha, hora_inicio, hora_fin)
VALUES ('2025-05-05', '14:00:00', '22:00:00');

DELETE FROM turnos
WHERE id_turno = 6;

-- ==========================================================
-- PASO 5) CASOS DE INTEGRIDAD (para demostrar en clase)
-- ==========================================================
-- IMPORTANTE: estos casos están comentados para no romper la ejecución total.
-- Descomenta de a uno para mostrar el error en vivo.

-- CASO A) Integridad de ENTIDAD: PK duplicada (mismo id_incidente)
-- Esperado: ERROR por clave primaria duplicada.
-- INSERT INTO incidentes (id_incidente, fecha, tipo, severidad, id_turno, id_reactor)
-- VALUES (1, '2025-05-06', 'eléctrico', 2, 1, 1);

-- CASO B) Integridad REFERENCIAL: FK a padre inexistente
-- Esperado: ERROR, porque no existe id_turno = 99.
-- INSERT INTO incidentes (fecha, tipo, severidad, id_turno, id_reactor)
-- VALUES ('2025-05-06', 'mecánico', 2, 99, 1);

-- CASO C) Integridad de DOMINIO: valor fuera de ENUM
-- Esperado: ERROR, tipo='rosado' no es válido.
-- INSERT INTO incidentes (fecha, tipo, severidad, id_turno, id_reactor)
-- VALUES ('2025-05-06', 'rosado', 2, 1, 1);

-- CASO D) Integridad de DOMINIO: severidad fuera del CHECK
-- Esperado: ERROR, severidad debe ser 1..3.
-- INSERT INTO incidentes (fecha, tipo, severidad, id_turno, id_reactor)
-- VALUES ('2025-05-06', 'sistema', 10, 1, 1);

-- CASO E) ON DELETE RESTRICT: borrar padre con hijos
-- Esperado: ERROR al intentar borrar reactor 1, porque tiene incidentes/mantenimientos.
-- DELETE FROM reactores WHERE id_reactor = 1;

-- CASO F) ON UPDATE CASCADE: cambiar PK padre y ver propagación en hijas
-- (Demostración controlada: reactor 5 pasa a 50)
UPDATE reactores SET id_reactor = 50 WHERE id_reactor = 5;
SELECT id_incidente, id_reactor FROM incidentes WHERE id_incidente = 5;
SELECT id_mantenimiento, id_reactor FROM mantenimientos WHERE id_mantenimiento = 5;
-- Volvemos al valor original para no alterar el cierre de clase:
UPDATE reactores SET id_reactor = 5 WHERE id_reactor = 50;

-- ==========================================================
-- PASO 6) RESUMEN TEÓRICO ON DELETE / ON UPDATE
-- ==========================================================
-- RESTRICT / NO ACTION: bloquea borrar/actualizar padre con hijos.
-- CASCADE: propaga borrado/actualización a hijos.
-- SET NULL: deja FK en NULL (la columna hija debe permitir NULL).

-- En este modelo usamos:
--   ON DELETE RESTRICT (evitar huérfanos)
--   ON UPDATE CASCADE (propagar cambios de PK)

-- ==========================================================
-- PASO 7) AUTOVERIFICACIÓN FINAL
-- ==========================================================
SELECT 'empleados' AS tabla, COUNT(*) AS total FROM empleados
UNION ALL SELECT 'turnos', COUNT(*) FROM turnos
UNION ALL SELECT 'empleado_turno', COUNT(*) FROM empleado_turno
UNION ALL SELECT 'reactores', COUNT(*) FROM reactores
UNION ALL SELECT 'incidentes', COUNT(*) FROM incidentes
UNION ALL SELECT 'mantenimientos', COUNT(*) FROM mantenimientos
UNION ALL SELECT 'casilleros', COUNT(*) FROM casilleros;

SELECT COUNT(*) AS huerfanos_empleado_turno
FROM empleado_turno et
LEFT JOIN empleados e ON et.id_empleado = e.id
LEFT JOIN turnos t ON et.id_turno = t.id_turno
WHERE e.id IS NULL OR t.id_turno IS NULL;

SELECT COUNT(*) AS huerfanos_incidentes
FROM incidentes i
LEFT JOIN turnos t ON i.id_turno = t.id_turno
LEFT JOIN reactores r ON i.id_reactor = r.id_reactor
WHERE t.id_turno IS NULL OR r.id_reactor IS NULL;

SELECT COUNT(*) AS huerfanos_mantenimientos
FROM mantenimientos m
LEFT JOIN reactores r ON m.id_reactor = r.id_reactor
WHERE r.id_reactor IS NULL;

SELECT COUNT(*) AS huerfanos_casilleros
FROM casilleros c
LEFT JOIN empleados e ON c.id_empleado = e.id
WHERE e.id IS NULL;
