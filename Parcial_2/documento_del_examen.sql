-- =====================================================================
-- UNIVERSIDAD DE LA SALLE
-- Asignatura: Bases de Datos I
-- Docente: Gabriel Barrera González
-- Estudiante: Ricardo Jaraba Gallego (Doc: 1021924992)
-- Grupo: Ing. Informática
-- Caso de estudio: Librería Digital S.A.
-- =====================================================================

DROP DATABASE IF EXISTS libreria_digital;
CREATE DATABASE libreria_digital
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE libreria_digital;

-- =====================================================================
-- PARTE 1 & 2: DDL - CREACIÓN DE TABLAS (MODELO 3FN)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Tabla: CLIENTE
-- ---------------------------------------------------------------------
CREATE TABLE cliente (
    id_cliente      INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(100)    NOT NULL,
    email           VARCHAR(100)    NOT NULL,
    ciudad          VARCHAR(50)     NOT NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_email UNIQUE (email)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- 2. Tabla: CATEGORIA
-- ---------------------------------------------------------------------
CREATE TABLE categoria (
    id_categoria        INT             NOT NULL AUTO_INCREMENT,
    nombre_categoria    VARCHAR(50)     NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre_categoria)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- 3. Tabla: LIBRO
-- ---------------------------------------------------------------------
CREATE TABLE libro (
    id_libro        INT             NOT NULL AUTO_INCREMENT,
    titulo          VARCHAR(150)    NOT NULL,
    id_categoria    INT             NOT NULL,
    precio_actual   DECIMAL(10,2)   NOT NULL,
    CONSTRAINT pk_libro PRIMARY KEY (id_libro),
    CONSTRAINT fk_libro_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- 4. Tabla: VENTA
-- ---------------------------------------------------------------------
CREATE TABLE venta (
    id_venta        INT             NOT NULL,
    id_cliente      INT             NOT NULL,
    fecha_venta     DATE            NOT NULL,
    CONSTRAINT pk_venta PRIMARY KEY (id_venta),
    CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- 5. Tabla: DETALLE_VENTA (Resolución N:M entre Venta y Libro)
-- ---------------------------------------------------------------------
CREATE TABLE detalle_venta (
    id_venta        INT             NOT NULL,
    id_libro        INT             NOT NULL,
    precio_unitario DECIMAL(10,2)   NOT NULL,
    cantidad        INT             NOT NULL,
    CONSTRAINT pk_detalle_venta PRIMARY KEY (id_venta, id_libro),
    CONSTRAINT fk_detalle_venta FOREIGN KEY (id_venta)
        REFERENCES venta (id_venta)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_detalle_libro FOREIGN KEY (id_libro)
        REFERENCES libro (id_libro)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_cantidad_positiva CHECK (cantidad > 0),
    CONSTRAINT chk_precio_positivo CHECK (precio_unitario >= 0)
) ENGINE = InnoDB;


-- =====================================================================
-- PARTE 3: DML - INSERCIÓN DE DATOS
-- =====================================================================

-- 1. Insertar Categorías
INSERT INTO categoria (id_categoria, nombre_categoria) VALUES
    (1, 'Ficción'),
    (2, 'Infantil');

-- 2. Insertar Clientes
INSERT INTO cliente (id_cliente, nombre, email, ciudad) VALUES
    (1, 'Ana Gómez', 'ana@mail.com', 'Medellín'),
    (2, 'Carlos Ruiz', 'carlos@mail.com', 'Bogotá');

-- 3. Insertar Libros (incluyendo libros del catálogo sin ventas: Ficciones y Matilda)
INSERT INTO libro (id_libro, titulo, id_categoria, precio_actual) VALUES
    (1, 'Cien Años de Soledad', 1, 50000.00),
    (2, 'El Principito',        2, 30000.00),
    (3, 'Rayuela',              1, 45000.00),
    (4, 'Ficciones',            1, 40000.00),
    (5, 'Matilda',              2, 35000.00);

-- 4. Insertar Ventas
INSERT INTO venta (id_venta, id_cliente, fecha_venta) VALUES
    (101, 1, '2026-10-15'),
    (102, 2, '2026-10-16'),
    (103, 1, '2026-10-18');

-- 5. Insertar Detalle de Ventas
INSERT INTO detalle_venta (id_venta, id_libro, precio_unitario, cantidad) VALUES
    (101, 1, 50000.00, 1),
    (101, 2, 30000.00, 2),
    (102, 3, 45000.00, 1),
    (103, 3, 45000.00, 3);


-- =====================================================================
-- PARTE 4: CONSULTAS SQL REQUERIDAS
-- =====================================================================

-- ---------------------------------------------------------------------
-- Consulta 1: INNER JOIN (10 puntos)
-- ¿Qué libros se han vendido, a quién, cuándo y en qué cantidad?
-- Resultado esperado: 4 filas, ordenado por fecha_venta ascendente.
-- ---------------------------------------------------------------------
SELECT 
    v.id_venta,
    c.nombre AS cliente,
    l.titulo AS libro,
    dv.cantidad,
    dv.precio_unitario,
    v.fecha_venta
FROM detalle_venta dv
INNER JOIN venta v ON dv.id_venta = v.id_venta
INNER JOIN cliente c ON v.id_cliente = c.id_cliente
INNER JOIN libro l ON dv.id_libro = l.id_libro
ORDER BY v.fecha_venta ASC, v.id_venta ASC;

-- ---------------------------------------------------------------------
-- Consulta 2: LEFT JOIN (10 puntos)
-- ¿Cuántas unidades se han vendido de cada libro del catálogo, incluidos
-- los que nunca se han vendido?
-- Resultado esperado: 5 filas; Ficciones y Matilda con 0.
-- ---------------------------------------------------------------------
SELECT 
    l.id_libro,
    l.titulo AS libro,
    cat.nombre_categoria AS categoria,
    COALESCE(SUM(dv.cantidad), 0) AS total_unidades_vendidas
FROM libro l
INNER JOIN categoria cat ON l.id_categoria = cat.id_categoria
LEFT JOIN detalle_venta dv ON l.id_libro = dv.id_libro
GROUP BY l.id_libro, l.titulo, cat.nombre_categoria
ORDER BY total_unidades_vendidas DESC, l.titulo ASC;

-- ---------------------------------------------------------------------
-- Consulta 3: JOIN + Funciones de Agregación (10 puntos)
-- ¿Cuánto dinero ha gastado en total cada cliente?
-- Resultado esperado: 2 filas; Ana Gómez suma 245.000 y Carlos Ruiz 45.000.
-- ---------------------------------------------------------------------
SELECT 
    c.id_cliente,
    c.nombre AS cliente,
    c.email,
    c.ciudad,
    SUM(dv.cantidad * dv.precio_unitario) AS total_gastado
FROM cliente c
INNER JOIN venta v ON c.id_cliente = v.id_cliente
INNER JOIN detalle_venta dv ON v.id_venta = dv.id_venta
GROUP BY c.id_cliente, c.nombre, c.email, c.ciudad
ORDER BY total_gastado DESC;
