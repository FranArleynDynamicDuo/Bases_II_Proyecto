DROP TYPE ruta_t
DROP TYPE barco_t
DROP TYPE entretenimiento
DROP TYPE restaurante_t
DROP TYPE piscina_t
DROP TYPE bailoterapia_t
DROP TYPE barco_Col
DROP TYPE entretenimiento_Col
DROP TABLE Ruta
DROP TABLE Barco
DROP TABLE Taller
DROP TABLE Restaurante
DROP TABLE Piscina
DROP TABLE Bailoterapia
DROP TABLE entretenimiento

CREATE TYPE ruta_t AS object (
    nombre_ruta   varchar(100) not null,
    regimen        varchar(50),
    destinos       varchar(100), /*multievaluado*/
    member function get Barco return barco_t,
)
CREATE TABLE Ruta AS TABLE OF ruta_t (PRIMARY KEY (nombre_ruta))

CREATE TYPE barco_t as Object (
    nombre varchar(50) not null,
    capacidad int,
    nro_cabinas int,
    nro_cubiertas int,
    tonelaje int,
    eslora int,
    realiza REF ruta_t scope is Ruta,
    member function get entretenimiento return entretenimiento_Col,
)
CREATE TABLE Barco AS TABLE OF barco_t (PRIMARY KEY (nombre))


CREATE TYPE entretenimiento AS Object (
    id_actividad    int not null,
    nombre          varchar(100),
    descripcion     varchar(500),
    capacidad       int,
    ofrece          barco_Col,
    NOT FINAL,

    CREATE TYPE taller_t UNDER entretenimiento (
        instructor  varchar(50),
    )
    
    CREATE TYPE restaurante_t UNDER entretenimiento (
        nro_mesas   int,
    )
    
    CREATE TYPE piscina_t under entretenimiento (
        profundidad int,
        member function get Bailoterapia return bailoterapia_t,
    )
    
    CREATE TYPE bailoterapia_t under entretenimiento (
        instructor varchar(50),
        duracion int,
        se_realiza REF piscina_t scope is Piscina,
    )

)
    CREATE TABLE OF Taller AS TABLE OF taller_t 
    CREATE TABLE OF Restaurante AS TABLE OF restaurante_t 
    CREATE TABLE OF Piscina AS TABLE OF piscina_t 
    CREATE TABLE OF Bailoterapia AS TABLE OF bailoterapia_t 
    
    CREATE TYPE barco_Col AS TABLE OF REF Barco
    CREATE TYPE entretenimiento_Col AS TABLE entretenimiento (PRIMARY KEY (id_actividad))

