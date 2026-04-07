-- ==========================================================
-- EJERCICIOS SQL AVANZADO
-- Temas: Subqueries, CTE, Vistas, CASE WHEN, Funciones y Procedimientos
-- Contexto: Planta Nuclear de Springfield (MySQL 8+)
-- ==========================================================

USE planta_nuclear;

-- ==========================================================
-- 0) PREPARACIÓN OPCIONAL (si te faltan columnas para practicar)
-- ==========================================================
-- Ejecuta solo si aún no existen estas columnas.
-- ALTER TABLE empleados ADD COLUMN salario DECIMAL(10,2) NULL;
-- ALTER TABLE empleados ADD COLUMN activo TINYINT(1) NOT NULL DEFAULT 1;
-- ALTER TABLE incidentes ADD COLUMN costo_estimado DECIMAL(12,2) NULL;
-- ALTER TABLE incidentes ADD COLUMN descripcion VARCHAR(255) NULL;

-- Datos de apoyo opcionales
-- UPDATE empleados
-- SET salario = CASE id
--     WHEN 1 THEN 42000
--     WHEN 2 THEN 38000
--     WHEN 3 THEN 31000
--     WHEN 4 THEN 34000
--     WHEN 5 THEN 28000
-- END;

-- UPDATE incidentes
-- SET costo_estimado = CASE id_incidente
--     WHEN 1 THEN 12000
--     WHEN 2 THEN 32000
--     WHEN 3 THEN 8000
--     WHEN 4 THEN 15000
--     WHEN 5 THEN 40000
-- END;


-- ==========================================================
-- 1) SUBQUERIES (12 ejercicios)
-- ==========================================================

-- 1.1 Empleados cuyo salario es mayor al salario promedio general.
-- Pista: subquery escalar en WHERE.

-- 1.2 Reactores con más incidentes que el promedio de incidentes por reactor.
-- Pista: subquery en HAVING.

-- 1.3 Empleados que trabajaron en turnos donde hubo incidentes severidad 3.
-- Pista: IN con subquery.

-- 1.4 Reactor(es) con el mayor costo total de mantenimiento.
-- Pista: subquery con MAX sobre un agregado.

-- 1.5 Empleados que NO tienen casillero asignado.
-- Pista: NOT IN o NOT EXISTS (mejor NOT EXISTS).

-- 1.6 Incidentes cuyo costo_estimado es mayor al promedio de su tipo.
-- Pista: subquery correlacionada por tipo.

-- 1.7 Top de empleados con salario por encima del promedio de su turno.
-- Pista: subquery correlacionada por turno.

-- 1.8 Listar turnos que tienen cantidad de incidentes igual al máximo encontrado.

-- 1.9 Empleados que participaron en más de un turno.
-- Pista: subquery con GROUP BY en tabla puente.

-- 1.10 Mantenimientos más caros que todos los mantenimientos del reactor 3.
-- Pista: > ALL (si tu motor lo permite) o reemplazar por MAX.

-- 1.11 Reactores que tienen al menos un incidente más severo que el promedio global de severidad.
-- Pista: EXISTS + subquery escalar.

-- 1.12 Empleados con salario en el top 3 de salarios distintos.
-- Pista: subquery con ORDER BY + LIMIT.


-- ==========================================================
-- 2) CTE (12 ejercicios)
-- ==========================================================

-- 2.1 Crear un CTE "incidentes_por_reactor" y mostrar reactor + total_incidentes.

-- 2.2 Con CTE "costos_mto", mostrar reactores cuyo costo total > promedio de costos totales.

-- 2.3 Encadenar 2 CTE: uno para incidentes por reactor y otro para mantenimientos por reactor.
-- Resultado final: reactor, incidentes, mantenimientos, ratio_incidentes_mto.

-- 2.4 CTE para empleados nocturnos con salario < 35000 y mostrar su % sobre total empleados.

-- 2.5 CTE para clasificar severidad promedio por reactor (Alta/Media/Baja con CASE WHEN).

-- 2.6 CTE recursivo: generar números del 1 al 31 (simular días del mes).

-- 2.7 CTE recursivo: calendario simple de 7 días desde una fecha dada.

-- 2.8 CTE "top_reactores" (top 2 por incidentes) y unirlo con tabla reactores.

-- 2.9 CTE para calcular costo acumulado de mantenimientos por reactor (ventana).

-- 2.10 CTE para detectar turnos "críticos" (>=2 incidentes severidad 3).

-- 2.11 CTE con ranking de empleados por salario dentro de cada turno.

-- 2.12 CTE para comparar costo mensual actual vs costo mensual anterior (si cargas más datos).


-- ==========================================================
-- 3) VISTAS (8 ejercicios)
-- ==========================================================

-- 3.1 Crear vista vw_incidentes_detalle con:
-- id_incidente, fecha, tipo, severidad, id_turno, id_reactor, nombre_reactor.

-- 3.2 Crear vista vw_costos_reactor con costo_total_mantenimientos por reactor.

-- 3.3 Crear vista vw_empleados_activos con empleados activos = 1.

-- 3.4 Crear vista vw_reactores_riesgo con severidad_promedio y total_incidentes.

-- 3.5 Consultar vw_reactores_riesgo y traer solo riesgo alto.

-- 3.6 Reemplazar (CREATE OR REPLACE) vw_empleados_activos para incluir salario.

-- 3.7 Verificar si una vista es actualizable e intentar UPDATE simple sobre vw_empleados_activos.

-- 3.8 Crear vista con WITH CHECK OPTION para evitar inserciones fuera de condición.


-- ==========================================================
-- 4) CASE WHEN (8 ejercicios)
-- ==========================================================

-- 4.1 Clasificar severidad numérica en etiqueta: Baja(1), Media(2), Alta(3).

-- 4.2 Clasificar salario:
-- <30000 = "Junior", 30000-39999 = "Semi", >=40000 = "Senior".

-- 4.3 En incidentes, columna calculada "accion_recomendada" según severidad.

-- 4.4 Conteo condicional por reactor:
-- incidentes_altos, incidentes_medios, incidentes_bajos.

-- 4.5 Ordenar empleados poniendo primero turno noche, luego tarde, luego mañana.

-- 4.6 CASE con múltiples condiciones: severidad alta y tipo eléctrico = "Crítico Eléctrico".

-- 4.7 CASE dentro de AVG para obtener porcentaje de incidentes severos.

-- 4.8 CASE para reemplazar NULL de costo_estimado por 0.


-- ==========================================================
-- 5) FUNCIONES (6 ejercicios)
-- ==========================================================

-- 5.1 Crear función fn_categoria_salario(p_salario DECIMAL)
-- que retorne VARCHAR(20): Junior / Semi / Senior.

-- 5.2 Crear función fn_riesgo_reactor(p_id_reactor INT)
-- que retorne DECIMAL con severidad promedio.

-- 5.3 Crear función fn_total_incidentes_turno(p_id_turno INT)
-- que retorne INT.

-- 5.4 Crear función fn_nombre_turno_legible('mañana'|'tarde'|'noche').

-- 5.5 Crear función fn_mto_anual_reactor(p_id_reactor INT, p_anio INT)
-- que retorne DECIMAL.

-- 5.6 Usar al menos 2 funciones anteriores en un SELECT final de reporte.


-- ==========================================================
-- 6) PROCEDIMIENTOS (6 ejercicios)
-- ==========================================================

-- 6.1 SP sp_incidentes_por_reactor(IN p_id_reactor INT)
-- devuelve incidentes de ese reactor.

-- 6.2 SP sp_registrar_incidente(...)
-- inserta incidente validando severidad entre 1 y 3.

-- 6.3 SP sp_actualizar_estado_reactor(IN p_id_reactor INT, IN p_estado VARCHAR(20)).

-- 6.4 SP sp_resumen_turno(IN p_id_turno INT, OUT p_total_incidentes INT, OUT p_severidad_prom DECIMAL(5,2)).

-- 6.5 SP sp_reporte_riesgo(IN p_umbral DECIMAL(5,2))
-- lista reactores con severidad_promedio >= umbral.

-- 6.6 SP sp_auditar_salario(IN p_id_empleado INT, IN p_nuevo_salario DECIMAL(10,2))
-- actualiza salario y registra cambio en tabla auditoria.


-- ==========================================================
-- 7) RETOS INTEGRADORES (10 ejercicios)
-- ==========================================================

-- R1) Subquery vs CTE: resolver el mismo problema con ambas técnicas.
-- R2) Crear vista de riesgo y consumirla en un procedimiento.
-- R3) Usar función de categoría salarial en una vista de empleados.
-- R4) Diseñar dashboard SQL: 5 métricas clave en un solo resultado (UNION o CTEs).
-- R5) Detectar anomalías: incidentes severos en turnos con poco personal.
-- R6) Ranking de reactores por costo total e incidentes (window functions).
-- R7) Procedimiento que reciba rango de fechas y entregue reporte completo.
-- R8) Vista materializable simulada: tabla resumen + evento de refresco manual.
-- R9) Corregir 3 consultas lentas reescribiéndolas con CTE/índices sugeridos.
-- R10) Examen final: combinar subquery + CTE + CASE + función + SP en una solución.


-- ==========================================================
-- SOLUCIONARIO BASE (selección de ejemplos resueltos)
-- ==========================================================

-- S1) Subquery: empleados sobre promedio salarial
SELECT id, nombre, turno, salario
FROM empleados
WHERE salario > (
    SELECT AVG(salario)
    FROM empleados
);

-- S2) Subquery correlacionada: incidentes con costo > promedio de su tipo
SELECT i1.id_incidente, i1.tipo, i1.costo_estimado
FROM incidentes i1
WHERE i1.costo_estimado > (
    SELECT AVG(i2.costo_estimado)
    FROM incidentes i2
    WHERE i2.tipo = i1.tipo
);

-- S3) CTE: incidentes por reactor
WITH incidentes_por_reactor AS (
    SELECT id_reactor, COUNT(*) AS total_incidentes
    FROM incidentes
    GROUP BY id_reactor
)
SELECT r.id_reactor, r.nombre, COALESCE(ir.total_incidentes, 0) AS total_incidentes
FROM reactores r
LEFT JOIN incidentes_por_reactor ir
  ON r.id_reactor = ir.id_reactor
ORDER BY total_incidentes DESC;

-- S4) CASE WHEN: etiqueta de severidad
SELECT id_incidente,
       severidad,
       CASE
         WHEN severidad = 1 THEN 'Baja'
         WHEN severidad = 2 THEN 'Media'
         WHEN severidad = 3 THEN 'Alta'
         ELSE 'Sin dato'
       END AS severidad_etiqueta
FROM incidentes;

-- S5) Vista de costos
CREATE OR REPLACE VIEW vw_costos_reactor AS
SELECT id_reactor, SUM(costo) AS costo_total
FROM mantenimientos
GROUP BY id_reactor;

-- S6) Función de categoría salarial
DELIMITER $$
CREATE FUNCTION fn_categoria_salario(p_salario DECIMAL(10,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    RETURN CASE
        WHEN p_salario < 30000 THEN 'Junior'
        WHEN p_salario < 40000 THEN 'Semi'
        ELSE 'Senior'
    END;
END $$
DELIMITER ;

-- S7) Procedimiento de resumen por reactor
DELIMITER $$
CREATE PROCEDURE sp_incidentes_por_reactor(IN p_id_reactor INT)
BEGIN
    SELECT id_incidente, fecha, tipo, severidad
    FROM incidentes
    WHERE id_reactor = p_id_reactor
    ORDER BY fecha DESC;
END $$
DELIMITER ;

-- Llamadas de ejemplo
-- SELECT fn_categoria_salario(38500) AS categoria;
-- CALL sp_incidentes_por_reactor(2);

