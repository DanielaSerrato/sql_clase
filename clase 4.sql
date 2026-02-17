-- DDL: eliminamos la base si ya existe para poder ejecutar este script muchas veces sin errores.
DROP DATABASE IF EXISTS planta_nuclear;
-- DDL: creamos la base de datos principal del ejercicio.
CREATE DATABASE planta_nuclear
-- DDL: definimos juego de caracteres UTF-8 completo para soportar acentos y símbolos.
  CHARACTER SET utf8mb4
-- DDL: configuramos collation en español para comparaciones/ordenamiento de texto.
  COLLATE utf8mb4_spanish_ci;
-- DDL: seleccionamos la base recién creada para que todo se cree dentro de ella.
USE planta_nuclear;

-- DDL: creamos la tabla de empleados.
CREATE TABLE empleados (
    -- DDL: identificador único autoincremental (clave primaria).
    id INT AUTO_INCREMENT PRIMARY KEY,
    -- DDL: nombre obligatorio del empleado.
    nombre VARCHAR(100) NOT NULL,
    -- DDL: turno obligatorio, restringido a valores válidos mediante ENUM.
    turno ENUM('mañana','tarde','noche') NOT NULL,
    -- DDL: rol opcional del empleado.
    rol VARCHAR(50) NULL
);

-- DDL: creamos la tabla de turnos.
CREATE TABLE turnos (
    -- DDL: identificador único del turno.
    id_turno INT AUTO_INCREMENT PRIMARY KEY,
    -- DDL: fecha del turno.
    fecha DATE NOT NULL,
    -- DDL: hora de inicio del turno.
    hora_inicio TIME NOT NULL,
    -- DDL: hora de fin del turno.
    hora_fin TIME NOT NULL
);

-- DDL: creamos tabla puente para relación muchos-a-muchos entre empleados y turnos.
CREATE TABLE empleado_turno (
    -- DDL: referencia al turno asignado.
    id_turno INT NOT NULL,
    -- DDL: referencia al empleado asignado.
    id_empleado INT NOT NULL,
    -- DDL: clave primaria compuesta para evitar duplicar el mismo empleado en el mismo turno.
    PRIMARY KEY (id_turno, id_empleado),
    -- DDL RELACIÓN (N:1): muchos registros de empleado_turno pueden apuntar al mismo turno en turnos(id_turno).
    CONSTRAINT fk_empleado_turno_turno
        FOREIGN KEY (id_turno) REFERENCES turnos(id_turno)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    -- DDL RELACIÓN (N:1): muchos registros de empleado_turno pueden apuntar al mismo empleado en empleados(id).
    CONSTRAINT fk_empleado_turno_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleados(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- DDL: creamos la tabla de reactores.
CREATE TABLE reactores (
    -- DDL: identificador único del reactor.
    id_reactor INT AUTO_INCREMENT PRIMARY KEY,
    -- DDL: nombre del reactor.
    nombre VARCHAR(100) NOT NULL,
    -- DDL: estado controlado por ENUM según enunciado.
    estado ENUM('activo','apagado','mantenimiento') NOT NULL
);

-- DDL: creamos la tabla de incidentes.
CREATE TABLE incidentes (
    -- DDL: identificador único del incidente.
    id_incidente INT AUTO_INCREMENT PRIMARY KEY,
    -- DDL: fecha en que ocurrió el incidente.
    fecha DATE NOT NULL,
    -- DDL: tipo de incidente según catálogo permitido.
    tipo ENUM('eléctrico','mecánico','sistema') NOT NULL,
    -- DDL: severidad entera (ejemplo: 1, 2, 3).
    severidad INT NOT NULL,
    -- DDL: turno asociado al incidente.
    id_turno INT NOT NULL,
    -- DDL: reactor asociado al incidente.
    id_reactor INT NOT NULL,
    -- DDL RELACIÓN (N:1): muchos incidentes pueden ocurrir dentro de un mismo turno (turnos.id_turno).
    CONSTRAINT fk_incidente_turno
        FOREIGN KEY (id_turno) REFERENCES turnos(id_turno)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    -- DDL RELACIÓN (N:1): muchos incidentes pueden asociarse al mismo reactor (reactores.id_reactor).
    CONSTRAINT fk_incidente_reactor
        FOREIGN KEY (id_reactor) REFERENCES reactores(id_reactor)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- DDL: creamos la tabla de mantenimientos.
CREATE TABLE mantenimientos (
    -- DDL: identificador único del mantenimiento.
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    -- DDL: fecha del mantenimiento.
    fecha DATE NOT NULL,
    -- DDL: tipo de mantenimiento.
    tipo ENUM('eléctrico','mecánico','sistema') NOT NULL,
    -- DDL: costo del mantenimiento con dos decimales.
    costo DECIMAL(10,2) NOT NULL,
    -- DDL: reactor al que se aplicó el mantenimiento.
    id_reactor INT NOT NULL,
    -- DDL RELACIÓN (N:1): muchos mantenimientos pueden corresponder a un mismo reactor (reactores.id_reactor).
    CONSTRAINT fk_mantenimiento_reactor
        FOREIGN KEY (id_reactor) REFERENCES reactores(id_reactor)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- DDL: creamos la tabla de casilleros.
CREATE TABLE casilleros (
    -- DDL: identificador único del casillero.
    id_casillero INT AUTO_INCREMENT PRIMARY KEY,
    -- DDL: número físico del casillero.
    numero INT NOT NULL,
    -- DDL: empleado dueño/asignado del casillero.
    id_empleado INT NOT NULL,
    -- DDL RELACIÓN (N:1): muchos casilleros (históricamente) podrían asociarse al mismo empleado; aquí registramos uno activo por fila.
    CONSTRAINT fk_casillero_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleados(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- RESUMEN DOCENTE DE RELACIONES (CLAVES FORÁNEAS):
-- 1) empleado_turno.id_turno   -> turnos.id_turno
-- 2) empleado_turno.id_empleado-> empleados.id
-- 3) incidentes.id_turno       -> turnos.id_turno
-- 4) incidentes.id_reactor     -> reactores.id_reactor
-- 5) mantenimientos.id_reactor -> reactores.id_reactor
-- 6) casilleros.id_empleado    -> empleados.id
-- Idea clave para clase: primero se insertan las tablas padre (empleados/turnos/reactores),
-- luego las tablas hijas que contienen las FK (empleado_turno/incidentes/mantenimientos/casilleros).

-- DML: insertamos 5 empleados (incluye Homero, Lisa, Carl y "Yo").
INSERT INTO empleados (nombre, turno, rol) VALUES
('Homero Simpson', 'mañana', 'Supervisor de Seguridad'),
('Lisa Simpson', 'tarde', 'Analista Junior'),
('Carl Carlson', 'noche', 'Operador'),
('Lenny Leonard', 'mañana', 'Técnico'),
('Yo (Estudiante)', 'tarde', 'Practicante');

-- DML: insertamos 5 turnos.
INSERT INTO turnos (fecha, hora_inicio, hora_fin) VALUES
('2025-05-01', '06:00:00', '14:00:00'),
('2025-05-02', '14:00:00', '22:00:00'),
('2025-05-03', '22:00:00', '06:00:00'),
('2025-05-04', '06:00:00', '14:00:00'),
('2025-05-05', '14:00:00', '22:00:00');

-- DML: vinculamos cada turno con un empleado existente.
INSERT INTO empleado_turno (id_turno, id_empleado) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- DML: insertamos 5 reactores con distintos estados.
INSERT INTO reactores (nombre, estado) VALUES
('Reactor A', 'activo'),
('Reactor B', 'mantenimiento'),
('Reactor C', 'apagado'),
('Reactor D', 'activo'),
('Reactor E', 'mantenimiento');

-- DML: insertamos 5 incidentes, cada uno asociado a turno y reactor existentes.
INSERT INTO incidentes (fecha, tipo, severidad, id_turno, id_reactor) VALUES
('2025-05-01', 'eléctrico', 2, 1, 1),
('2025-05-02', 'mecánico', 3, 2, 2),
('2025-05-03', 'sistema', 1, 3, 3),
('2025-05-04', 'eléctrico', 2, 4, 4),
('2025-05-05', 'mecánico', 3, 5, 5);

-- DML: insertamos 5 mantenimientos asociados a reactores existentes.
INSERT INTO mantenimientos (fecha, tipo, costo, id_reactor) VALUES
('2025-05-01', 'mecánico', 1500.00, 1),
('2025-05-02', 'eléctrico', 2200.50, 2),
('2025-05-03', 'sistema', 1800.00, 3),
('2025-05-04', 'mecánico', 2050.75, 4),
('2025-05-05', 'eléctrico', 1999.99, 5);

-- DML: insertamos 5 casilleros asignados a empleados existentes.
INSERT INTO casilleros (numero, id_empleado) VALUES
(101, 1),
(102, 2),
(103, 3),
(104, 4),
(105, 5);

-- CONSULTA: mostrar todos los empleados.
SELECT * FROM empleados;

-- CONSULTA: filtrar empleados del turno tarde.
SELECT id, nombre, rol
FROM empleados
WHERE turno = 'tarde';

-- CONSULTA JOIN 1: unir incidentes con reactores y turnos para ver contexto completo.
SELECT i.id_incidente, i.fecha, i.tipo, i.severidad, r.nombre AS reactor, t.fecha AS fecha_turno
FROM incidentes i
JOIN reactores r ON i.id_reactor = r.id_reactor
JOIN turnos t ON i.id_turno = t.id_turno;

-- CONSULTA JOIN 2: ver asignaciones empleado-turno con datos descriptivos.
SELECT et.id_turno, t.fecha, e.id AS id_empleado, e.nombre, e.turno, e.rol
FROM empleado_turno et
JOIN empleados e ON et.id_empleado = e.id
JOIN turnos t ON et.id_turno = t.id_turno;

-- CONSULTA UPDATE: ascender a Lisa al rol solicitado.
UPDATE empleados
SET rol = 'Jefa de Seguridad'
WHERE nombre = 'Lisa Simpson';

-- CONSULTA: validar visualmente el ascenso de Lisa.
SELECT id, nombre, rol
FROM empleados
WHERE nombre = 'Lisa Simpson';

-- CONSULTA DELETE: crear un turno duplicado temporal para demostrar borrado por ID.
INSERT INTO turnos (fecha, hora_inicio, hora_fin)
VALUES ('2025-05-05', '14:00:00', '22:00:00');

-- CONSULTA DELETE: eliminar el duplicado recién creado (id_turno=6) sin afectar FKs.
DELETE FROM turnos
WHERE id_turno = 6;

-- AUTOVERIFICACIÓN: confirmar que cada tabla tiene exactamente 5 filas.
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

-- AUTOVERIFICACIÓN: buscar huérfanos en empleado_turno (debe dar 0).
SELECT COUNT(*) AS huerfanos_empleado_turno
FROM empleado_turno et
LEFT JOIN empleados e ON et.id_empleado = e.id
LEFT JOIN turnos t ON et.id_turno = t.id_turno
WHERE e.id IS NULL OR t.id_turno IS NULL;

-- AUTOVERIFICACIÓN: buscar huérfanos en incidentes (debe dar 0).
SELECT COUNT(*) AS huerfanos_incidentes
FROM incidentes i
LEFT JOIN turnos t ON i.id_turno = t.id_turno
LEFT JOIN reactores r ON i.id_reactor = r.id_reactor
WHERE t.id_turno IS NULL OR r.id_reactor IS NULL;

-- AUTOVERIFICACIÓN: buscar huérfanos en mantenimientos (debe dar 0).
SELECT COUNT(*) AS huerfanos_mantenimientos
FROM mantenimientos m
LEFT JOIN reactores r ON m.id_reactor = r.id_reactor
WHERE r.id_reactor IS NULL;

-- AUTOVERIFICACIÓN: buscar huérfanos en casilleros (debe dar 0).
SELECT COUNT(*) AS huerfanos_casilleros
FROM casilleros c
LEFT JOIN empleados e ON c.id_empleado = e.id
WHERE e.id IS NULL;
