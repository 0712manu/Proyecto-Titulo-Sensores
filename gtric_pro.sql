-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 29-05-2026 a las 00:04:31
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `gtric_pro`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_marca` (IN `p_sesion_id` INT UNSIGNED, IN `p_atleta_id` INT UNSIGNED, IN `p_nombre_atleta` VARCHAR(120), IN `p_tiempo` DECIMAL(8,4), IN `p_velocidad` DECIMAL(7,4), IN `p_numero_intento` TINYINT UNSIGNED, IN `p_fuente` VARCHAR(20), IN `p_topic_mqtt` VARCHAR(120), IN `p_raw_payload` JSON)   BEGIN
    -- Insertar la marca
    INSERT INTO marcas_tiempo
        (sesion_id, atleta_id, nombre_atleta, tiempo, velocidad,
         numero_intento, fuente, topic_mqtt, raw_payload)
    VALUES
        (p_sesion_id, p_atleta_id, p_nombre_atleta, p_tiempo, p_velocidad,
         p_numero_intento, p_fuente, p_topic_mqtt, p_raw_payload);

    -- Actualizar estadísticas del atleta si tiene ID registrado
    IF p_atleta_id IS NOT NULL THEN
        UPDATE atletas
        SET
            total_carreras = total_carreras + 1,
            mejor_tiempo   = CASE
                WHEN mejor_tiempo IS NULL OR p_tiempo < mejor_tiempo
                THEN p_tiempo ELSE mejor_tiempo END,
            velocidad_max  = CASE
                WHEN velocidad_max IS NULL OR p_velocidad > velocidad_max
                THEN p_velocidad ELSE velocidad_max END,
            updated_at = NOW()
        WHERE id = p_atleta_id;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `atletas`
--

CREATE TABLE `atletas` (
  `id` int(10) UNSIGNED NOT NULL,
  `usuario_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK a usuarios si el atleta tiene login propio',
  `entrenador_id` int(10) UNSIGNED NOT NULL COMMENT 'FK al entrenador/admin que gestiona este atleta',
  `nombre` varchar(80) NOT NULL,
  `apellido` varchar(80) NOT NULL,
  `rut` varchar(12) DEFAULT NULL COMMENT 'RUT del atleta (opcional)',
  `fecha_nacimiento` date DEFAULT NULL,
  `edad` tinyint(3) UNSIGNED DEFAULT NULL COMMENT 'Edad en años (calculada o ingresada)',
  `genero` enum('M','F','Otro') NOT NULL DEFAULT 'M',
  `peso` decimal(5,2) DEFAULT NULL COMMENT 'Peso en kg',
  `altura` decimal(5,2) DEFAULT NULL COMMENT 'Altura en cm',
  `token_enlace` varchar(36) DEFAULT NULL COMMENT 'UUID generado para URL /atleta/{token}',
  `token_generado_at` datetime DEFAULT NULL COMMENT 'Fecha en que se generó el token',
  `mejor_tiempo` decimal(8,4) DEFAULT NULL COMMENT 'Mejor tiempo en segundos registrado (100m)',
  `velocidad_max` decimal(6,3) DEFAULT NULL COMMENT 'Velocidad máxima registrada en m/s',
  `total_carreras` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Perfiles físicos y deportivos de los atletas';

--
-- Volcado de datos para la tabla `atletas`
--

INSERT INTO `atletas` (`id`, `usuario_id`, `entrenador_id`, `nombre`, `apellido`, `rut`, `fecha_nacimiento`, `edad`, `genero`, `peso`, `altura`, `token_enlace`, `token_generado_at`, `mejor_tiempo`, `velocidad_max`, `total_carreras`, `activo`, `created_at`, `updated_at`) VALUES
(1, 3, 1, 'Carlos', 'Ramírez', '11111111-1', '2002-03-15', 23, 'M', 72.50, 178.00, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', '2026-05-28 14:53:20', 10.8500, 9.210, 18, 1, '2026-05-28 14:53:20', '2026-05-28 17:50:19'),
(2, 4, 1, 'Diego', 'López', '22222222-2', '2003-07-22', 21, 'M', 68.00, 175.00, 'b2c3d4e5-f6a7-8901-bcde-f12345678901', '2026-05-28 14:53:20', 11.2300, 8.950, 8, 1, '2026-05-28 14:53:20', '2026-05-28 14:53:20'),
(3, 5, 1, 'Valentina', 'Morales', '33333333-3', '2001-11-05', 24, 'F', 58.00, 165.00, 'c3d4e5f6-a7b8-9012-cdef-123456789012', '2026-05-28 14:53:20', 12.1000, 8.260, 6, 1, '2026-05-28 14:53:20', '2026-05-28 14:53:20'),
(4, NULL, 1, 'Sebastián', 'Vega', '44444444-4', '2004-01-30', 20, 'M', 75.00, 181.00, 'd4e5f6a7-b8c9-0123-defa-234567890123', '2026-05-28 14:53:20', 10.9800, 9.100, 5, 1, '2026-05-28 14:53:20', '2026-05-28 14:53:20'),
(5, NULL, 2, 'Camila', 'Torres', '55555555-5', '2003-09-18', 22, 'F', 55.00, 162.00, 'e5f6a7b8-c9d0-1234-efab-345678901234', '2026-05-28 14:53:20', 12.4500, 8.030, 4, 1, '2026-05-28 14:53:20', '2026-05-28 14:53:20'),
(6, NULL, 1, 'Manuel', 'GVAy', NULL, NULL, 2, 'F', 1.00, 23.00, '4d4f55c9-f0da-42dc-b83d-66e99013c390', '2026-05-28 15:01:00', NULL, NULL, 0, 1, '2026-05-28 15:01:00', '2026-05-28 15:01:00'),
(7, NULL, 1, 'Javier', 'P', NULL, NULL, 20, 'M', 70.00, 175.00, 'ea2bc076-6a0d-4f23-8b17-b9d2640f4f0e', '2026-05-28 17:41:20', NULL, NULL, 0, 1, '2026-05-28 17:41:20', '2026-05-28 17:41:20');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_mqtt`
--

CREATE TABLE `log_mqtt` (
  `id` int(10) UNSIGNED NOT NULL,
  `topic` varchar(120) NOT NULL,
  `payload_raw` text NOT NULL,
  `procesado` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=guardado en marcas_tiempo, 0=error',
  `error_msg` varchar(500) DEFAULT NULL,
  `received_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Log de auditoría de todos los mensajes MQTT recibidos del ESP32';

--
-- Volcado de datos para la tabla `log_mqtt`
--

INSERT INTO `log_mqtt` (`id`, `topic`, `payload_raw`, `procesado`, `error_msg`, `received_at`) VALUES
(1, 'gtric/pista/marcas', '{\"sesion_id\":1,\"atleta_id\":1,\"nombre_atleta\":\"Carlos Ramírez\",\"tiempo\":10.850,\"velocidad\":9.21,\"numero_intento\":3}', 1, NULL, '2026-05-28 14:53:20.740'),
(2, 'gtric/pista/marcas', '{\"sesion_id\":1,\"atleta_id\":2,\"nombre_atleta\":\"Diego López\",\"tiempo\":11.230,\"velocidad\":8.95,\"numero_intento\":3}', 1, NULL, '2026-05-28 14:53:20.740'),
(3, 'gtric/pista/marcas', '{\"sesion_id\":4,\"atleta_id\":1,\"nombre_atleta\":\"Carlos Ramírez\",\"tiempo\":10.920,\"velocidad\":9.16,\"numero_intento\":1}', 1, NULL, '2026-05-28 14:53:20.740'),
(4, 'gtric/pista/marcas', '{\n  \"sesion_id\": 4,\n  \"atleta_id\": 1,\n  \"nombre_atleta\": \"Benja Sepulveda\",\n  \"tiempo\": 10.850,\n  \"velocidad\": 9.21,\n  \"numero_intento\": 1\n  \n}', 1, NULL, '2026-05-28 15:03:02.545'),
(5, 'gtric/pista/marcas', '{\n  \"sesion_id\": 4,\n  \"atleta_id\": 1,\n  \"nombre_atleta\": \"Manuel GVay\",\n  \"tiempo\": 10.850,\n  \"velocidad\": 9.21,\n  \"numero_intento\": 1\n\n}', 1, NULL, '2026-05-28 15:03:48.145'),
(6, 'gtric/pista/marcas', '{\n  \"sesion_id\": 4,\n  \"atleta_id\": 1,\n  \"nombre_atleta\": \"Javier P\",\n  \"tiempo\": 10.850,\n  \"velocidad\": 9.21,\n  \"numero_intento\": 1\n\n}', 1, NULL, '2026-05-28 17:42:27.665'),
(7, 'gtric/pista/marcas', '{\n  \"sesion_id\": 4,\n  \"atleta_id\": 1,\n  \"nombre_atleta\": \"Javier P\",\n  \"tiempo\": 10.850,\n  \"velocidad\": 9.21,\n  \"numero_intento\": 1\n\n}', 1, NULL, '2026-05-28 17:46:21.187'),
(8, 'gtric/pista/marcas', '{\n  \"sesion_id\": 4,\n  \"atleta_id\": 1,\n  \"nombre_atleta\": \"Javier P\",\n  \"tiempo\": 10.850,\n  \"velocidad\": 9.21,\n  \"numero_intento\": 1\n\n}', 1, NULL, '2026-05-28 17:49:09.896'),
(9, 'gtric/pista/marcas', '{\n  \"sesion_id\": 4,\n  \"atleta_id\": 11,\n  \"nombre_atleta\": \"Javier P\",\n  \"tiempo\": 10.850,\n  \"velocidad\": 9.21,\n  \"numero_intento\": 1\n\n}', 0, 'Cannot add or update a child row: a foreign key constraint fails (`gtric_pro`.`marcas_tiempo`, CONSTRAINT `fk_marca_atleta` FOREIGN KEY (`atleta_id`) REFERENCES `atletas` (`id`) ON DELETE SET NULL ON UPDATE CASCADE)', '2026-05-28 17:49:50.424'),
(10, 'gtric/pista/marcas', '{\n  \"sesion_id\": 5,\n  \"atleta_id\": 11,\n  \"nombre_atleta\": \"Javier P\",\n  \"tiempo\": 10.850,\n  \"velocidad\": 9.21,\n  \"numero_intento\": 1\n\n}', 0, 'Cannot add or update a child row: a foreign key constraint fails (`gtric_pro`.`marcas_tiempo`, CONSTRAINT `fk_marca_sesion` FOREIGN KEY (`sesion_id`) REFERENCES `sesiones_entrenamiento` (`id`) ON UPDATE CASCADE)', '2026-05-28 17:49:56.891'),
(11, 'gtric/pista/marcas', '{\n  \"sesion_id\": 5,\n  \"atleta_id\": 11,\n  \"nombre_atleta\": \"Javier P\",\n  \"tiempo\": 10.850,\n  \"velocidad\": 9.21,\n  \"numero_intento\": 1\n\n}', 0, 'Cannot add or update a child row: a foreign key constraint fails (`gtric_pro`.`marcas_tiempo`, CONSTRAINT `fk_marca_sesion` FOREIGN KEY (`sesion_id`) REFERENCES `sesiones_entrenamiento` (`id`) ON UPDATE CASCADE)', '2026-05-28 17:50:07.211'),
(12, 'gtric/pista/marcas', '{\n  \"sesion_id\": 4,\n  \"atleta_id\": 1,\n  \"nombre_atleta\": \"Javier P\",\n  \"tiempo\": 10.850,\n  \"velocidad\": 9.21,\n  \"numero_intento\": 1\n\n}', 1, NULL, '2026-05-28 17:50:19.417');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `marcas_tiempo`
--

CREATE TABLE `marcas_tiempo` (
  `id` int(10) UNSIGNED NOT NULL,
  `sesion_id` int(10) UNSIGNED NOT NULL,
  `atleta_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'NULL si el atleta no está registrado en el sistema',
  `nombre_atleta` varchar(120) NOT NULL DEFAULT 'Atleta Anónimo' COMMENT 'Nombre para mostrar en tiempo real',
  `tiempo` decimal(8,4) NOT NULL COMMENT 'Tiempo en segundos con 4 decimales, ej: 11.2340',
  `velocidad` decimal(7,4) DEFAULT NULL COMMENT 'Velocidad en m/s calculada por el ESP32 o el servidor',
  `numero_intento` tinyint(3) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Número del intento en la sesión para este atleta',
  `fuente` enum('esp32','manual','simulacion') NOT NULL DEFAULT 'esp32',
  `topic_mqtt` varchar(120) DEFAULT NULL COMMENT 'Tópico MQTT del que llegó el dato, ej: gtric/pista/marcas',
  `raw_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'JSON completo tal como lo mandó el ESP32' CHECK (json_valid(`raw_payload`)),
  `timestamp` datetime(3) NOT NULL DEFAULT current_timestamp(3) COMMENT 'Timestamp con milisegundos'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Telemetría recibida del ESP32 o ingresada manualmente por sesión';

--
-- Volcado de datos para la tabla `marcas_tiempo`
--

INSERT INTO `marcas_tiempo` (`id`, `sesion_id`, `atleta_id`, `nombre_atleta`, `tiempo`, `velocidad`, `numero_intento`, `fuente`, `topic_mqtt`, `raw_payload`, `timestamp`) VALUES
(1, 1, 1, 'Carlos Ramírez', 11.4200, 8.7600, 1, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(2, 1, 1, 'Carlos Ramírez', 11.0500, 9.0500, 2, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(3, 1, 1, 'Carlos Ramírez', 10.8500, 9.2100, 3, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(4, 1, 2, 'Diego López', 11.8000, 8.4700, 1, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(5, 1, 2, 'Diego López', 11.5000, 8.7000, 2, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(6, 1, 2, 'Diego López', 11.2300, 8.9500, 3, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(7, 1, 3, 'Valentina Morales', 12.9000, 7.7500, 1, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(8, 1, 3, 'Valentina Morales', 12.5000, 8.0000, 2, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(9, 1, 3, 'Valentina Morales', 12.1000, 8.2600, 3, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(10, 2, 1, 'Carlos Ramírez', 11.2000, 8.9300, 1, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(11, 2, 1, 'Carlos Ramírez', 10.9800, 9.1100, 2, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(12, 2, 2, 'Diego López', 11.6000, 8.6200, 1, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(13, 2, 4, 'Sebastián Vega', 11.4000, 8.7700, 1, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(14, 2, 4, 'Sebastián Vega', 10.9800, 9.1000, 2, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(15, 3, 1, 'Carlos Ramírez', 11.0500, 9.0500, 1, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(16, 3, 2, 'Diego López', 11.3800, 8.7900, 1, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(17, 3, 3, 'Valentina Morales', 12.3000, 8.1300, 1, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(18, 3, 4, 'Sebastián Vega', 11.2000, 8.9300, 1, 'esp32', NULL, NULL, '2026-05-28 14:53:20.683'),
(19, 4, 1, 'Benja Sepulveda', 10.8500, 9.2100, 1, 'esp32', 'gtric/pista/marcas', '{\"sesion_id\":4,\"atleta_id\":1,\"nombre_atleta\":\"Benja Sepulveda\",\"tiempo\":10.85,\"velocidad\":9.21,\"numero_intento\":1}', '2026-05-28 15:03:02.548'),
(20, 4, 1, 'Manuel GVay', 10.8500, 9.2100, 1, 'esp32', 'gtric/pista/marcas', '{\"sesion_id\":4,\"atleta_id\":1,\"nombre_atleta\":\"Manuel GVay\",\"tiempo\":10.85,\"velocidad\":9.21,\"numero_intento\":1}', '2026-05-28 15:03:48.149'),
(21, 4, 1, 'Javier P', 10.8500, 9.2100, 1, 'esp32', 'gtric/pista/marcas', '{\"sesion_id\":4,\"atleta_id\":1,\"nombre_atleta\":\"Javier P\",\"tiempo\":10.85,\"velocidad\":9.21,\"numero_intento\":1}', '2026-05-28 17:42:27.722'),
(22, 4, 1, 'Javier P', 10.8500, 9.2100, 1, 'esp32', 'gtric/pista/marcas', '{\"sesion_id\":4,\"atleta_id\":1,\"nombre_atleta\":\"Javier P\",\"tiempo\":10.85,\"velocidad\":9.21,\"numero_intento\":1}', '2026-05-28 17:46:21.198'),
(23, 4, 1, 'Javier P', 10.8500, 9.2100, 1, 'esp32', 'gtric/pista/marcas', '{\"sesion_id\":4,\"atleta_id\":1,\"nombre_atleta\":\"Javier P\",\"tiempo\":10.85,\"velocidad\":9.21,\"numero_intento\":1}', '2026-05-28 17:49:09.904'),
(27, 4, 1, 'Javier P', 10.8500, 9.2100, 1, 'esp32', 'gtric/pista/marcas', '{\"sesion_id\":4,\"atleta_id\":1,\"nombre_atleta\":\"Javier P\",\"tiempo\":10.85,\"velocidad\":9.21,\"numero_intento\":1}', '2026-05-28 17:50:19.425');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `planes_nutricion`
--

CREATE TABLE `planes_nutricion` (
  `id` int(10) UNSIGNED NOT NULL,
  `atleta_id` int(10) UNSIGNED NOT NULL,
  `entrenador_id` int(10) UNSIGNED NOT NULL COMMENT 'Quién generó el plan',
  `peso_kg` decimal(5,2) NOT NULL,
  `altura_cm` decimal(5,2) NOT NULL,
  `edad_anos` tinyint(3) UNSIGNED NOT NULL,
  `sexo` enum('m','f') NOT NULL,
  `tipo_entrenamiento` enum('velocidad','fuerza','resistencia','mixto') NOT NULL DEFAULT 'velocidad',
  `objetivo` enum('mantenimiento','masa','reduccion') NOT NULL DEFAULT 'mantenimiento',
  `sesiones_semanales` tinyint(3) UNSIGNED NOT NULL DEFAULT 3,
  `tmb` decimal(8,2) NOT NULL COMMENT 'Tasa Metabólica Basal',
  `calorias_totales` decimal(8,2) NOT NULL COMMENT 'GET (Gasto Energético Total)',
  `proteinas_pct` tinyint(3) UNSIGNED NOT NULL COMMENT 'Porcentaje de proteínas',
  `carbohidratos_pct` tinyint(3) UNSIGNED NOT NULL COMMENT 'Porcentaje de carbohidratos',
  `grasas_pct` tinyint(3) UNSIGNED NOT NULL COMMENT 'Porcentaje de grasas',
  `proteinas_g` smallint(5) UNSIGNED NOT NULL COMMENT 'Gramos de proteínas por día',
  `carbohidratos_g` smallint(5) UNSIGNED NOT NULL COMMENT 'Gramos de carbohidratos por día',
  `grasas_g` smallint(5) UNSIGNED NOT NULL COMMENT 'Gramos de grasas por día',
  `proteinas_por_kg` decimal(4,2) NOT NULL COMMENT 'g de proteína por kg de peso corporal',
  `agua_litros` decimal(4,2) NOT NULL COMMENT 'Litros de agua recomendados por día',
  `detalle_macros` text DEFAULT NULL COMMENT 'Resumen textual del plan generado',
  `recomendaciones` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Array JSON con sugerencias específicas por disciplina' CHECK (json_valid(`recomendaciones`)),
  `fecha_generacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Planes nutricionales calculados con Harris-Benedict para cada atleta';

--
-- Volcado de datos para la tabla `planes_nutricion`
--

INSERT INTO `planes_nutricion` (`id`, `atleta_id`, `entrenador_id`, `peso_kg`, `altura_cm`, `edad_anos`, `sexo`, `tipo_entrenamiento`, `objetivo`, `sesiones_semanales`, `tmb`, `calorias_totales`, `proteinas_pct`, `carbohidratos_pct`, `grasas_pct`, `proteinas_g`, `carbohidratos_g`, `grasas_g`, `proteinas_por_kg`, `agua_litros`, `detalle_macros`, `recomendaciones`, `fecha_generacion`) VALUES
(1, 1, 1, 72.50, 178.00, 23, 'm', 'velocidad', 'mantenimiento', 3, 1842.15, 3009.71, 30, 50, 20, 226, 376, 67, 1.80, 2.80, 'Plan velocidad: 30% proteínas, 50% carbohidratos, 20% grasas', '[\"Pre-entrenamiento: avena + plátano 1-2h antes\",\"Post-entrenamiento: proteína + carbohidratos en 30 min\",\"Incluir creatina monohidratada 3-5g/día\",\"Evitar grasas pesadas antes de sesiones de velocidad\"]', '2026-05-28 14:53:20'),
(2, 6, 1, 1.00, 23.00, 2, 'm', 'velocidad', '', 3, 200.76, 346.31, 30, 50, 20, 26, 43, 8, 1.80, 0.70, 'velocidad · rendimiento · 346 kcal', '[\"Pre-entrenamiento: avena + plátano 1–2h antes\",\"Post-entrenamiento: proteína + carbohidratos en 30 min\",\"Incluir creatina monohidratada (3–5g/día)\",\"Evitar grasas pesadas antes de sesiones de velocidad\"]', '2026-05-28 15:01:59');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sesiones_entrenamiento`
--

CREATE TABLE `sesiones_entrenamiento` (
  `id` int(10) UNSIGNED NOT NULL,
  `entrenador_id` int(10) UNSIGNED NOT NULL,
  `nombre_sesion` varchar(120) DEFAULT NULL COMMENT 'Nombre descriptivo, ej: "Martes velocidad 100m"',
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `distancia_metros` smallint(5) UNSIGNED NOT NULL DEFAULT 100 COMMENT 'Distancia de la prueba en metros',
  `ubicacion` varchar(200) DEFAULT NULL COMMENT 'Nombre de la pista o lugar',
  `estado_calibracion` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0=Sin calibrar, 1=Sensor calibrado OK',
  `estado_sesion` enum('pendiente','activa','finalizada','cancelada') NOT NULL DEFAULT 'pendiente',
  `notas` text DEFAULT NULL COMMENT 'Observaciones del entrenador',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sesiones de entrenamiento/medición gestionadas por el entrenador';

--
-- Volcado de datos para la tabla `sesiones_entrenamiento`
--

INSERT INTO `sesiones_entrenamiento` (`id`, `entrenador_id`, `nombre_sesion`, `fecha`, `distancia_metros`, `ubicacion`, `estado_calibracion`, `estado_sesion`, `notas`, `created_at`, `updated_at`) VALUES
(1, 1, 'Prueba velocidad 100m - Lunes', '2026-05-12 09:00:00', 100, 'Pista Estadio Regional Talca', 1, 'finalizada', 'Condiciones ideales, viento en calma', '2026-05-28 14:53:20', '2026-05-28 14:53:20'),
(2, 1, 'Sesión control martes', '2026-05-13 10:30:00', 100, 'Pista Estadio Regional Talca', 1, 'finalizada', 'Primer control del mes', '2026-05-28 14:53:20', '2026-05-28 14:53:20'),
(3, 1, 'Entrenamiento semana 3', '2026-05-19 08:00:00', 100, 'Pista Estadio Regional Talca', 1, 'finalizada', NULL, '2026-05-28 14:53:20', '2026-05-28 14:53:20'),
(4, 1, 'Sesión demo tiempo real', '2026-05-28 09:00:00', 100, 'Pista Estadio Regional Talca', 1, 'activa', 'Sesión de demostración del sistema', '2026-05-28 14:53:20', '2026-05-28 14:53:20');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tokens_sesion`
--

CREATE TABLE `tokens_sesion` (
  `id` int(10) UNSIGNED NOT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `token` varchar(512) NOT NULL COMMENT 'JWT o token de sesión',
  `ip_origen` varchar(45) DEFAULT NULL COMMENT 'IP desde donde se autenticó',
  `user_agent` varchar(300) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tokens de sesión web para control de autenticación';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(10) UNSIGNED NOT NULL,
  `rut` varchar(12) NOT NULL COMMENT 'RUT chileno con dígito verificador, ej: 12345678-9',
  `nombre` varchar(80) NOT NULL,
  `apellido` varchar(80) NOT NULL,
  `email` varchar(120) NOT NULL,
  `password_hash` varchar(255) NOT NULL COMMENT 'Contraseña hasheada (bcrypt recomendado)',
  `rol` enum('Admin','Atleta') NOT NULL DEFAULT 'Admin',
  `nombre_club` varchar(120) DEFAULT NULL COMMENT 'Nombre del club (aplica para rol Admin)',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Usuarios del sistema: entrenadores y atletas con acceso web';

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `rut`, `nombre`, `apellido`, `email`, `password_hash`, `rol`, `nombre_club`, `activo`, `created_at`, `updated_at`) VALUES
(1, '12345678-9', 'Manuel', 'Salcedo', 'manuel@gtricpro.cl', '$2b$10$demoHashAdminManuelGTRIC2026xxxx', 'Admin', 'Club Atletismo Regional', 1, '2026-05-28 14:53:20', '2026-05-28 14:53:20'),
(2, '98765432-1', 'Benjamin', 'Pinochet', 'benjamin@gtricpro.cl', '$2b$10$demoHashAdminBenjaminGTRIC2026x', 'Admin', 'Club Atletismo Regional', 1, '2026-05-28 14:53:20', '2026-05-28 14:53:20'),
(3, '11111111-1', 'Carlos', 'Ramírez', 'carlos.ramirez@demo.cl', '$2b$10$demoHashAtletaCarlosxxxxxx2026xx', 'Atleta', NULL, 1, '2026-05-28 14:53:20', '2026-05-28 14:53:20'),
(4, '22222222-2', 'Diego', 'López', 'diego.lopez@demo.cl', '$2b$10$demoHashAtletaDiegoxxxxxxx2026xx', 'Atleta', NULL, 1, '2026-05-28 14:53:20', '2026-05-28 14:53:20'),
(5, '33333333-3', 'Valentina', 'Morales', 'vale.morales@demo.cl', '$2b$10$demoHashAtletaValentinaxx2026xx', 'Atleta', NULL, 1, '2026-05-28 14:53:20', '2026-05-28 14:53:20');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_marcas_sesion`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_marcas_sesion` (
`id` int(10) unsigned
,`sesion_id` int(10) unsigned
,`nombre_sesion` varchar(120)
,`fecha_sesion` datetime
,`atleta_id` int(10) unsigned
,`atleta` varchar(161)
,`tiempo` decimal(8,4)
,`velocidad` decimal(7,4)
,`numero_intento` tinyint(3) unsigned
,`fuente` enum('esp32','manual','simulacion')
,`timestamp` datetime(3)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_ranking_atletas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_ranking_atletas` (
`atleta_id` int(10) unsigned
,`atleta` varchar(161)
,`mejor_tiempo` decimal(8,4)
,`velocidad_max` decimal(6,3)
,`total_carreras` int(10) unsigned
,`club` varchar(120)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_sesion_activa`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_sesion_activa` (
`sesion_id` int(10) unsigned
,`nombre_sesion` varchar(120)
,`fecha` datetime
,`distancia_metros` smallint(5) unsigned
,`estado_calibracion` tinyint(1)
,`entrenador` varchar(80)
,`club` varchar(120)
,`total_marcas` bigint(21)
,`mejor_tiempo_sesion` decimal(8,4)
,`velocidad_max_sesion` decimal(7,4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_ultima_marca_atleta`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_ultima_marca_atleta` (
`atleta_id` int(10) unsigned
,`atleta` varchar(161)
,`tiempo` decimal(8,4)
,`velocidad` decimal(7,4)
,`timestamp` datetime(3)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `v_marcas_sesion`
--
DROP TABLE IF EXISTS `v_marcas_sesion`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_marcas_sesion`  AS SELECT `mt`.`id` AS `id`, `mt`.`sesion_id` AS `sesion_id`, `se`.`nombre_sesion` AS `nombre_sesion`, `se`.`fecha` AS `fecha_sesion`, `mt`.`atleta_id` AS `atleta_id`, coalesce(concat(`a`.`nombre`,' ',`a`.`apellido`),`mt`.`nombre_atleta`) AS `atleta`, `mt`.`tiempo` AS `tiempo`, `mt`.`velocidad` AS `velocidad`, `mt`.`numero_intento` AS `numero_intento`, `mt`.`fuente` AS `fuente`, `mt`.`timestamp` AS `timestamp` FROM ((`marcas_tiempo` `mt` join `sesiones_entrenamiento` `se` on(`se`.`id` = `mt`.`sesion_id`)) left join `atletas` `a` on(`a`.`id` = `mt`.`atleta_id`)) ORDER BY `mt`.`timestamp` DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_ranking_atletas`
--
DROP TABLE IF EXISTS `v_ranking_atletas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_ranking_atletas`  AS SELECT `a`.`id` AS `atleta_id`, concat(`a`.`nombre`,' ',`a`.`apellido`) AS `atleta`, `a`.`mejor_tiempo` AS `mejor_tiempo`, `a`.`velocidad_max` AS `velocidad_max`, `a`.`total_carreras` AS `total_carreras`, `u`.`nombre_club` AS `club` FROM (`atletas` `a` join `usuarios` `u` on(`u`.`id` = `a`.`entrenador_id`)) WHERE `a`.`activo` = 1 ORDER BY `a`.`mejor_tiempo` ASC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_sesion_activa`
--
DROP TABLE IF EXISTS `v_sesion_activa`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_sesion_activa`  AS SELECT `se`.`id` AS `sesion_id`, `se`.`nombre_sesion` AS `nombre_sesion`, `se`.`fecha` AS `fecha`, `se`.`distancia_metros` AS `distancia_metros`, `se`.`estado_calibracion` AS `estado_calibracion`, `u`.`nombre` AS `entrenador`, `u`.`nombre_club` AS `club`, count(`mt`.`id`) AS `total_marcas`, min(`mt`.`tiempo`) AS `mejor_tiempo_sesion`, max(`mt`.`velocidad`) AS `velocidad_max_sesion` FROM ((`sesiones_entrenamiento` `se` join `usuarios` `u` on(`u`.`id` = `se`.`entrenador_id`)) left join `marcas_tiempo` `mt` on(`mt`.`sesion_id` = `se`.`id`)) WHERE `se`.`estado_sesion` = 'activa' GROUP BY `se`.`id`, `se`.`nombre_sesion`, `se`.`fecha`, `se`.`distancia_metros`, `se`.`estado_calibracion`, `u`.`nombre`, `u`.`nombre_club` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_ultima_marca_atleta`
--
DROP TABLE IF EXISTS `v_ultima_marca_atleta`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_ultima_marca_atleta`  AS SELECT `mt`.`atleta_id` AS `atleta_id`, coalesce(concat(`a`.`nombre`,' ',`a`.`apellido`),`mt`.`nombre_atleta`) AS `atleta`, `mt`.`tiempo` AS `tiempo`, `mt`.`velocidad` AS `velocidad`, `mt`.`timestamp` AS `timestamp` FROM (`marcas_tiempo` `mt` left join `atletas` `a` on(`a`.`id` = `mt`.`atleta_id`)) WHERE `mt`.`id` in (select max(`marcas_tiempo`.`id`) from `marcas_tiempo` group by `marcas_tiempo`.`atleta_id`) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `atletas`
--
ALTER TABLE `atletas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_token_enlace` (`token_enlace`),
  ADD KEY `idx_entrenador` (`entrenador_id`),
  ADD KEY `idx_usuario` (`usuario_id`);

--
-- Indices de la tabla `log_mqtt`
--
ALTER TABLE `log_mqtt`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_topic` (`topic`),
  ADD KEY `idx_procesado` (`procesado`),
  ADD KEY `idx_received` (`received_at`);

--
-- Indices de la tabla `marcas_tiempo`
--
ALTER TABLE `marcas_tiempo`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sesion` (`sesion_id`),
  ADD KEY `idx_atleta` (`atleta_id`),
  ADD KEY `idx_timestamp` (`timestamp`),
  ADD KEY `idx_fuente` (`fuente`),
  ADD KEY `idx_sesion_atleta` (`sesion_id`,`atleta_id`);

--
-- Indices de la tabla `planes_nutricion`
--
ALTER TABLE `planes_nutricion`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_plan_atleta` (`atleta_id`),
  ADD KEY `idx_plan_entrenador` (`entrenador_id`),
  ADD KEY `idx_plan_fecha` (`fecha_generacion`);

--
-- Indices de la tabla `sesiones_entrenamiento`
--
ALTER TABLE `sesiones_entrenamiento`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_entrenador_sesion` (`entrenador_id`),
  ADD KEY `idx_fecha` (`fecha`),
  ADD KEY `idx_estado_sesion` (`estado_sesion`);

--
-- Indices de la tabla `tokens_sesion`
--
ALTER TABLE `tokens_sesion`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_token` (`token`(64)),
  ADD KEY `idx_usuario_tk` (`usuario_id`),
  ADD KEY `idx_expires` (`expires_at`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_rut` (`rut`),
  ADD UNIQUE KEY `uq_email` (`email`),
  ADD KEY `idx_rol` (`rol`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `atletas`
--
ALTER TABLE `atletas`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `log_mqtt`
--
ALTER TABLE `log_mqtt`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `marcas_tiempo`
--
ALTER TABLE `marcas_tiempo`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT de la tabla `planes_nutricion`
--
ALTER TABLE `planes_nutricion`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `sesiones_entrenamiento`
--
ALTER TABLE `sesiones_entrenamiento`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `tokens_sesion`
--
ALTER TABLE `tokens_sesion`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `atletas`
--
ALTER TABLE `atletas`
  ADD CONSTRAINT `fk_atleta_entrenador` FOREIGN KEY (`entrenador_id`) REFERENCES `usuarios` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_atleta_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `marcas_tiempo`
--
ALTER TABLE `marcas_tiempo`
  ADD CONSTRAINT `fk_marca_atleta` FOREIGN KEY (`atleta_id`) REFERENCES `atletas` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_marca_sesion` FOREIGN KEY (`sesion_id`) REFERENCES `sesiones_entrenamiento` (`id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `planes_nutricion`
--
ALTER TABLE `planes_nutricion`
  ADD CONSTRAINT `fk_plan_atleta` FOREIGN KEY (`atleta_id`) REFERENCES `atletas` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_plan_entrenador` FOREIGN KEY (`entrenador_id`) REFERENCES `usuarios` (`id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `sesiones_entrenamiento`
--
ALTER TABLE `sesiones_entrenamiento`
  ADD CONSTRAINT `fk_sesion_entrenador` FOREIGN KEY (`entrenador_id`) REFERENCES `usuarios` (`id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `tokens_sesion`
--
ALTER TABLE `tokens_sesion`
  ADD CONSTRAINT `fk_token_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
