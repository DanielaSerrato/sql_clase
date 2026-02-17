-- ==========================================================
-- GUÍA DOCENTE (MySQL Workbench): de SIN FK -> CON FK
-- Caso: Planta Nuclear de Springfield
-- ==========================================================

-- PASO 0) Reinicio
DROP DATABASE IF EXISTS planta_nuclear;
CREATE DATABASE planta_nuclear
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_spanish_ci;
USE planta_nuclear;

-- ==========================================================
-- PASO 1) Crear tablas SIN claves foráneas (solo PK y dominio)
-- ==========================================================
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

-- Tabla puente SIN FK por ahora (solo PK compuesta)
CREATE TABLE empleado_turno (
    id_turno INT NOT NULL,
    id_empleado INT NOT NULL,
    PRIMARY KEY (id_turno, id_empleado)
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
    -- CHECK = regla de dominio.
    -- Aquí definimos: severidad solo puede ser 1, 2 o 3
    -- (puedes explicarlo como Bajo=1, Medio=2, Alto=3).
    CONSTRAINT chk_incidente_severidad CHECK (severidad BETWEEN 1 AND 3)
);

CREATE TABLE mantenimientos (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    tipo ENUM('eléctrico','mecánico','sistema') NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    id_reactor INT NOT NULL
);

CREATE TABLE casilleros (
    id_casillero INT AUTO_INCREMENT PRIMARY KEY,
    numero INT NOT NULL,
    id_empleado INT NOT NULL,
    -- UNIQUE convierte la relación con empleados en 1:1 (un casillero activo por empleado).
    CONSTRAINT uq_casillero_empleado UNIQUE (id_empleado)
);

-- ==========================================================
-- PASO 2) Cargar datos base (aún sin FK)
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

INSERT INTO empleado_turno (id_turno, id_empleado) VALUES
(1,1),(2,2),(3,3),(4,4),(5,5);

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
(101,1),(102,2),(103,3),(104,4),(105,5);

-- ==========================================================
-- PASO 3) Validaciones iniciales (SIN JOIN)
-- ==========================================================
SELECT * FROM empleados;
SELECT * FROM turnos;
SELECT * FROM empleado_turno;
SELECT * FROM reactores;
SELECT * FROM incidentes;
SELECT * FROM mantenimientos;
SELECT * FROM casilleros;

SELECT id, nombre, rol
FROM empleados
WHERE turno = 'tarde';

SELECT 'empleados' AS tabla, COUNT(*) AS total FROM empleados
UNION ALL SELECT 'turnos', COUNT(*) FROM turnos
UNION ALL SELECT 'empleado_turno', COUNT(*) FROM empleado_turno
UNION ALL SELECT 'reactores', COUNT(*) FROM reactores
UNION ALL SELECT 'incidentes', COUNT(*) FROM incidentes
UNION ALL SELECT 'mantenimientos', COUNT(*) FROM mantenimientos
UNION ALL SELECT 'casilleros', COUNT(*) FROM casilleros;

-- UPDATE de práctica
UPDATE empleados
SET rol = 'Jefa de Seguridad'
WHERE nombre = 'Lisa Simpson';

SELECT id, nombre, rol
FROM empleados
WHERE nombre = 'Lisa Simpson';

-- DELETE de práctica (duplicado temporal en turnos)
INSERT INTO turnos (fecha, hora_inicio, hora_fin)
VALUES ('2025-05-05', '14:00:00', '22:00:00');
DELETE FROM turnos WHERE id_turno = 6;

-- ==========================================================
-- PASO 4) Ahora sí: agregar restricciones y claves foráneas (ALTER TABLE)
-- ==========================================================
-- CONSTRAINT = regla formal que MySQL hace cumplir.
-- Aquí agregamos integridad referencial sobre datos ya cargados.

ALTER TABLE empleado_turno
ADD CONSTRAINT fk_empleado_turno_turno
    FOREIGN KEY (id_turno) REFERENCES turnos(id_turno)
    ON UPDATE CASCADE ON DELETE RESTRICT,
ADD CONSTRAINT fk_empleado_turno_empleado
    FOREIGN KEY (id_empleado) REFERENCES empleados(id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE incidentes
ADD CONSTRAINT fk_incidente_turno
    FOREIGN KEY (id_turno) REFERENCES turnos(id_turno)
    ON UPDATE CASCADE ON DELETE RESTRICT,
ADD CONSTRAINT fk_incidente_reactor
    FOREIGN KEY (id_reactor) REFERENCES reactores(id_reactor)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE mantenimientos
ADD CONSTRAINT fk_mantenimiento_reactor
    FOREIGN KEY (id_reactor) REFERENCES reactores(id_reactor)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- Ya existe UNIQUE(id_empleado), por eso casilleros-empleados queda en 1:1.
ALTER TABLE casilleros
ADD CONSTRAINT fk_casillero_empleado
    FOREIGN KEY (id_empleado) REFERENCES empleados(id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- ==========================================================
-- PASO 5) Probar relaciones (SIN JOIN)
-- ==========================================================
-- 5.1 PK compuesta: duplicado exacto -> error (descomentar)
-- INSERT INTO empleado_turno (id_turno, id_empleado) VALUES (1,1);

-- 5.2 FK: turno inexistente -> error (descomentar)
-- INSERT INTO empleado_turno (id_turno, id_empleado) VALUES (99,1);

-- 5.3 FK: empleado inexistente -> error (descomentar)
-- INSERT INTO empleado_turno (id_turno, id_empleado) VALUES (1,99);

-- 5.4 ON DELETE RESTRICT: no deja borrar padre con hijos (descomentar)
-- DELETE FROM empleados WHERE id = 1;
-- DELETE FROM turnos WHERE id_turno = 1;

-- 5.5 ON UPDATE CASCADE: cambia ID del padre y se propaga a la hija
UPDATE empleados SET id = 50 WHERE id = 5;
SELECT * FROM empleado_turno WHERE id_empleado IN (5,50);
UPDATE empleados SET id = 5 WHERE id = 50;

-- 5.6 Ver rápidamente las reglas creadas
SHOW CREATE TABLE empleado_turno;
SHOW CREATE TABLE incidentes;
SHOW CREATE TABLE mantenimientos;
SHOW CREATE TABLE casilleros;


-- 5.7 Caso 1:1 en casilleros-empleados (por UNIQUE + FK)
-- La relación quedó 1:1 porque id_empleado es UNIQUE en casilleros.
-- Eso significa: un empleado NO puede tener dos casilleros activos.

-- 5.7.a Inserción válida (nuevo casillero para empleado 1 ya existe en datos iniciales, así que usamos empleado 5 solo si no existe)
-- INSERT INTO casilleros (numero, id_empleado) VALUES (106, 5);

-- 5.7.b Error esperado por 1:1 (UNIQUE): empleado repetido en casilleros
-- Como empleado 1 ya tiene casillero 101, este INSERT debe fallar.
-- INSERT INTO casilleros (numero, id_empleado) VALUES (999, 1);

-- 5.7.c Error esperado por FK: empleado inexistente
-- INSERT INTO casilleros (numero, id_empleado) VALUES (200, 99);

-- 5.7.d ON DELETE RESTRICT: no permite borrar un empleado con casillero asignado
-- DELETE FROM empleados WHERE id = 1;

-- 5.7.e ON UPDATE CASCADE: si cambia PK del empleado, se actualiza en casilleros
UPDATE empleados SET id = 60 WHERE id = 4;
SELECT * FROM casilleros WHERE id_empleado IN (4,60);
UPDATE empleados SET id = 4 WHERE id = 60;
SELECT * FROM casilleros WHERE numero = 104;

-- ==========================================================
-- PASO 6) Verificación final sin huérfanos (SIN JOIN)
-- ==========================================================
SELECT COUNT(*) AS huerfanos_empleado_turno_turno
FROM empleado_turno
WHERE id_turno NOT IN (SELECT id_turno FROM turnos);

SELECT COUNT(*) AS huerfanos_empleado_turno_empleado
FROM empleado_turno
WHERE id_empleado NOT IN (SELECT id FROM empleados);

SELECT COUNT(*) AS huerfanos_incidentes_turno
FROM incidentes
WHERE id_turno NOT IN (SELECT id_turno FROM turnos);

SELECT COUNT(*) AS huerfanos_incidentes_reactor
FROM incidentes
WHERE id_reactor NOT IN (SELECT id_reactor FROM reactores);

SELECT COUNT(*) AS huerfanos_mantenimientos
FROM mantenimientos
WHERE id_reactor NOT IN (SELECT id_reactor FROM reactores);

SELECT COUNT(*) AS huerfanos_casilleros
FROM casilleros
WHERE id_empleado NOT IN (SELECT id FROM empleados);

-- ==========================================================
-- PASO 7) QUIZ EN CÓDIGO (retos de integridad para clase)
-- Nota rápida: ENUM limita lista de textos válidos; CHECK limita rangos/reglas lógicas.
-- ==========================================================
-- Dinámica sugerida:
-- 1) Lean el intento de Homero/Sr. Burns.
-- 2) Predigan: ¿pasa o falla? ¿qué regla actúa? (Entidad / Referencial / Dominio)
-- 3) Descomenten y ejecuten 1 por 1 para comprobar.

-- QUIZ 1) Homero intenta registrar el MISMO incidente dos veces.
-- Pregunta: ¿qué lo impide?
-- Respuesta esperada: Integridad de ENTIDAD (PK duplicada en id_incidente).
-- INSERT INTO incidentes (id_incidente, fecha, tipo, severidad, id_turno, id_reactor)
-- VALUES (1, '2025-05-10', 'eléctrico', 2, 1, 1);

-- QUIZ 2) Homero intenta guardar un incidente con "turno inexistente".
-- Pregunta: ¿pasa sin FK? ¿pasa con FK ya agregada?
-- Respuesta esperada: con FK activa, falla por integridad REFERENCIAL.
-- INSERT INTO incidentes (fecha, tipo, severidad, id_turno, id_reactor)
-- VALUES ('2025-05-10', 'mecánico', 2, 99, 1);

-- QUIZ 3) Homero intenta guardar "rosado" como tipo de incidente.
-- Pregunta: ¿qué regla lo frena?
-- Respuesta esperada: Integridad de DOMINIO (ENUM en columna tipo).
-- INSERT INTO incidentes (fecha, tipo, severidad, id_turno, id_reactor)
-- VALUES ('2025-05-10', 'rosado', 2, 1, 1);

-- QUIZ 4) Homero intenta poner severidad = 10.
-- Pregunta: ¿qué regla lo frena?
-- Respuesta esperada: Integridad de DOMINIO (CHECK severidad BETWEEN 1 AND 3).
-- Equivalencia docente: 1=Bajo, 2=Medio, 3=Alto; cualquier otro valor falla.
-- INSERT INTO incidentes (fecha, tipo, severidad, id_turno, id_reactor)
-- VALUES ('2025-05-10', 'sistema', 10, 1, 1);

-- QUIZ 5) El Sr. Burns despide a Homero y quiere borrarlo.
-- Pregunta: con ON DELETE RESTRICT, ¿se puede borrar si tiene relaciones hijas?
-- Respuesta esperada: NO; falla para evitar huérfanos.
-- DELETE FROM empleados WHERE id = 1;

-- QUIZ 6) Cambio de ID de empleado con ON UPDATE CASCADE.
-- Pregunta: ¿se actualiza automáticamente en tablas hijas?
-- Respuesta esperada: SÍ, se propaga en empleado_turno y casilleros.
UPDATE empleados SET id = 70 WHERE id = 2;
SELECT * FROM empleado_turno WHERE id_empleado IN (2,70);
SELECT * FROM casilleros WHERE id_empleado IN (2,70);
-- Restauración para no romper continuidad del guion.
UPDATE empleados SET id = 2 WHERE id = 70;

-- QUIZ 7) Pregunta conceptual rápida (sin ejecutar):
-- Si quitáramos UNIQUE(id_empleado) en casilleros, ¿seguiría siendo 1:1?
-- Respuesta esperada: NO, pasaría a 1:N (un empleado podría tener varios casilleros).
-- QUIZ EXTRA CHECK) Pruebas rápidas solo de CHECK (descomentar una por una):
-- Caso válido (pasa):
-- INSERT INTO incidentes (fecha, tipo, severidad, id_turno, id_reactor)
-- VALUES ('2025-05-11', 'sistema', 3, 1, 1);
-- Caso inválido (falla por CHECK):
-- INSERT INTO incidentes (fecha, tipo, severidad, id_turno, id_reactor)
-- VALUES ('2025-05-11', 'sistema', -1, 1, 1);

