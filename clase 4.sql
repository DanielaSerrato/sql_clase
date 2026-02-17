-- =========================
-- DDL: Creación de esquema
-- =========================
CREATE DATABASE IF NOT EXISTS planta_nuclear;
USE planta_nuclear;

CREATE TABLE empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    turno ENUM('mañana','tarde','noche') NOT NULL,
    rol VARCHAR(50) NULL
);

CREATE TABLE turnos (
    id_turno INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL
);

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

CREATE TABLE reactores (
    id_reactor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    estado ENUM('activo','apagado','mantenimiento') NOT NULL
);

CREATE TABLE incidentes (
    id_incidente INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    tipo ENUM('eléctrico','mecánico','sistema') NOT NULL,
    severidad INT NOT NULL,
    id_turno INT NOT NULL,
    id_reactor INT NOT NULL,
    CONSTRAINT fk_incidente_turno
        FOREIGN KEY (id_turno) REFERENCES turnos(id_turno)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_incidente_reactor
        FOREIGN KEY (id_reactor) REFERENCES reactores(id_reactor)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

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

CREATE TABLE casilleros (
    id_casillero INT AUTO_INCREMENT PRIMARY KEY,
    numero INT NOT NULL,
    id_empleado INT NOT NULL,
    CONSTRAINT fk_casillero_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleados(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =========================
-- DML: Inserción de datos
-- =========================
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

INSERT INTO empleado_turno (id_turno, id_empleado) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO reactores (nombre, estado) VALUES
('Reactor A', 'activo'),
('Reactor B', 'mantenimiento'),
('Reactor C', 'apagado'),
('Reactor D', 'activo'),
('Reactor E', 'mantenimiento');

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

-- =========================
-- Consultas de prueba
-- =========================
-- SELECT *
SELECT * FROM empleados;

-- SELECT con WHERE
SELECT id, nombre, rol
FROM empleados
WHERE turno = 'tarde';

-- JOIN 1: incidentes + reactores + turnos
SELECT i.id_incidente, i.fecha, i.tipo, i.severidad, r.nombre AS reactor, t.fecha AS fecha_turno
FROM incidentes i
JOIN reactores r ON i.id_reactor = r.id_reactor
JOIN turnos t ON i.id_turno = t.id_turno;

-- JOIN 2: empleado_turno + empleados + turnos
SELECT et.id_turno, t.fecha, e.id AS id_empleado, e.nombre, e.turno, e.rol
FROM empleado_turno et
JOIN empleados e ON et.id_empleado = e.id
JOIN turnos t ON et.id_turno = t.id_turno;

-- UPDATE: ascender a Lisa
UPDATE empleados
SET rol = 'Jefa de Seguridad'
WHERE nombre = 'Lisa Simpson';

SELECT id, nombre, rol
FROM empleados
WHERE nombre = 'Lisa Simpson';

-- DELETE: ejemplo de borrado de duplicado por ID (sin romper FKs)
-- (Se inserta un turno duplicado temporal y luego se elimina)
INSERT INTO turnos (fecha, hora_inicio, hora_fin)
VALUES ('2025-05-05', '14:00:00', '22:00:00');

DELETE FROM turnos
WHERE id_turno = 6;

-- =========================
-- Autoverificación
-- =========================
-- Verificar que hay 5 filas por tabla
SELECT 'empleados' AS tabla, COUNT(*) AS total FROM empleados
UNION ALL
SELECT 'turnos', COUNT(*) FROM turnos
UNION ALL
SELECT 'empleado_turno', COUNT(*) FROM empleado_turno
UNION ALL
SELECT 'reactores', COUNT(*) FROM reactores
UNION ALL
SELECT 'incidentes', COUNT(*) FROM incidentes
UNION ALL
SELECT 'mantenimientos', COUNT(*) FROM mantenimientos
UNION ALL
SELECT 'casilleros', COUNT(*) FROM casilleros;

-- Verificar que no haya relaciones huérfanas
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
