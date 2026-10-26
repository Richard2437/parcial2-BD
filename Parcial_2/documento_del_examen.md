# UNIVERSIDAD DE LA SALLE
## Diseño y Consulta de Bases de Datos Relacionales en MySQL
**Asignatura:** Bases de Datos I  
**Docente:** Gabriel Barrera González  
**Estudiante:** Ricardo Jaraba Gallego  
**Documento:** 1021924992  
**Grupo:** Ing. Informática  
**Fecha:** 2/01/2025  

---

## Parte 1. Normalización de Datos (30 puntos)

### 1.1 Primera Forma Normal (1FN) — 10 puntos

**Explicación:**
La Tabla 1 viola la 1FN porque las columnas `Libros_Comprados`, `Categoria_Libro`, `Precio_Unitario` y `Cantidad` contienen valores no atómicos (múltiples elementos separados por punto y coma `;` dentro de una misma celda). Para cumplir con la 1FN, se atomizan los datos generando una fila individual por cada artículo comprado en cada venta.

**Tabla en 1FN con datos atomizados:**

| ID_Venta | Cliente | Email_Cliente | Ciudad_Cliente | Libro | Categoria_Libro | Precio_Unitario | Cantidad | Fecha_Venta |
| :---: | :--- | :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| 101 | Ana Gómez | ana@mail.com | Medellín | Cien Años de Soledad | Ficción | 50000 | 1 | 2026-10-15 |
| 101 | Ana Gómez | ana@mail.com | Medellín | El Principito | Infantil | 30000 | 2 | 2026-10-15 |
| 102 | Carlos Ruiz | carlos@mail.com | Bogotá | Rayuela | Ficción | 45000 | 1 | 2026-10-16 |
| 103 | Ana Gómez | ana@mail.com | Medellín | Rayuela | Ficción | 45000 | 3 | 2026-10-18 |

**Clave Primaria Compuesta:** `{ID_Venta, Libro}`

---

### 1.2 Segunda Forma Normal (2FN) — 10 puntos

**Dependencias Funcionales Identificadas:**
1. `{ID_Venta, Libro} → Cantidad, Precio_Unitario` *(Dependencia funcional total sobre la clave compuesta)*
2. `ID_Venta → Email_Cliente, Fecha_Venta` *(Dependencia parcial)*
3. `Email_Cliente → Cliente, Ciudad_Cliente` *(Dependencia parcial respecto a la clave primaria del registro)*
4. `Libro → Categoria_Libro` *(Dependencia parcial)*

**Identificación de Dependencias Parciales:**
Atributos como `Email_Cliente`, `Cliente`, `Ciudad_Cliente` y `Fecha_Venta` dependen únicamente de `ID_Venta` y no de `Libro`. Del mismo modo, `Categoria_Libro` depende de `Libro` y no del `ID_Venta`.

**Tablas Resultantes en 2FN:**

* **Venta_2FN** (`id_venta` [PK], `email_cliente`, `cliente`, `ciudad_cliente`, `fecha_venta`)
* **Libro_2FN** (`libro` [PK], `categoria_libro`)
* **Detalle_Venta_2FN** (`id_venta` [PK, FK → Venta_2FN], `libro` [PK, FK → Libro_2FN], `precio_unitario`, `cantidad`)

---

### 1.3 Tercera Forma Normal (3FN) — 10 puntos

**Dependencias Transitivas Identificadas:**
1. En `Venta_2FN`: `id_venta → email_cliente → {cliente, ciudad_cliente}`  
   *(El nombre y la ciudad del cliente dependen del email del cliente, no directamente de la venta).*
2. En `Libro_2FN`: `id_libro → id_categoria → nombre_categoria`  
   *(La categoría pertenece a una entidad independiente dentro del catálogo).*

**Esquema Final en 3FN:**

* **Cliente** (`id_cliente` [PK], `nombre`, `email`, `ciudad`)
* **Categoria** (`id_categoria` [PK], `nombre_categoria`)
* **Libro** (`id_libro` [PK], `titulo`, `id_categoria` [FK → Categoria], `precio_actual`)
* **Venta** (`id_venta` [PK], `id_cliente` [FK → Cliente], `fecha_venta`)
* **Detalle_Venta** (`id_venta` [PK, FK → Venta], `id_libro` [PK, FK → Libro], `precio_unitario`, `cantidad`)

---

## Parte 2. Modelo Entidad-Relación (20 puntos)

### 2.1 Entidades, Atributos y Claves (8 puntos)

| Entidad | Atributos (todos) | Clave Primaria (PK) | Clave(s) Foránea(s) (FK) |
| :--- | :--- | :--- | :--- |
| **Cliente** | `id_cliente`, `nombre`, `email`, `ciudad` | `id_cliente` | Ninguna |
| **Categoria** | `id_categoria`, `nombre_categoria` | `id_categoria` | Ninguna |
| **Libro** | `id_libro`, `titulo`, `id_categoria`, `precio_actual` | `id_libro` | `id_categoria` → Categoria |
| **Venta** | `id_venta`, `id_cliente`, `fecha_venta` | `id_venta` | `id_cliente` → Cliente |
| **Detalle_Venta** | `id_venta`, `id_libro`, `precio_unitario`, `cantidad` | (`id_venta`, `id_libro`) | `id_venta` → Venta<br>`id_libro` → Libro |

---

### 2.2 Relaciones y Cardinalidad (6 puntos)

| Relación | Cardinalidad | Justificación |
| :--- | :---: | :--- |
| **Cliente – Venta** | 1:N | Un cliente puede realizar muchas ventas y cada venta pertenece a un solo cliente. |
| **Categoria – Libro** | 1:N | Una categoría agrupa muchos libros y cada libro pertenece a una sola categoría. |
| **Venta – Libro** | N:M | En una venta se pueden comprar varios libros y un libro puede aparecer en muchas ventas. |

---

### 2.3 Resolución de la Relación Muchos a Muchos (N:M) y Diagrama E-R (6 puntos)

**Explicación de la resolución N:M:**  
La relación muchos a muchos ($N:M$) entre `Venta` y `Libro` se resolvió creando la tabla intermedia `Detalle_Venta`. Su clave primaria es compuesta por (`id_venta`, `id_libro`), las cuales actúan simultáneamente como claves foráneas hacia sus respectivas tablas padre. Además, esta tabla almacena los atributos atómicos propios de la transacción: `cantidad` y `precio_unitario`, garantizando la conservación del precio histórico de cada libro vendido.

*(Nota: Adjunte aquí la imagen/captura de su diagrama Entidad-Relación dibujado o generado en MySQL Workbench/Draw.io).*

---

## Parte 4. Capturas de Resultados de Consultas SQL

### Consulta 1: INNER JOIN
*(Anexar captura de pantalla de la ejecución de la Consulta 1 en Workbench/Console)*

### Consulta 2: LEFT JOIN
*(Anexar captura de pantalla de la ejecución de la Consulta 2 en Workbench/Console)*

### Consulta 3: JOIN + Funciones de Agregación
*(Anexar captura de pantalla de la ejecución de la Consulta 3 en Workbench/Console)*