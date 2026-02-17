
USE planta_nuclear;
CREATE TABLE empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    turno ENUM('mañana', 'tarde', 'noche') NOT NULL,
    rol VARCHAR(50),
    fecha date,
    hora time
);
INSERT INTO empleados (nombre, turno, rol)
VALUES ('Homero Simpson', 'mañana', 'Supervisor'),
               ('Lisa Simpson', 'tarde', 'Técnica'),
               ('Carl Carlson', 'noche', 'Seguridad');
               
SELECT *
FROM empleados

;
SET SQL_SAFE_UPDATES = 0;
;
UPDATE empleados
SET rol = 'Jefa de seguridad'
WHERE id in (2,6,3);

DELETE FROM  empleados
WHERE id in (2,6,3);

SELECT *
FROM empleados