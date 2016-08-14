/* DROP FOREING KEY ? */

DROP TYPE barco_t FORCE;
DROP TYPE destino_t FORCE;
DROP TYPE destinos_mult FORCE;
DROP TYPE taller_t FORCE;
DROP TYPE restaurante_t FORCE;
DROP TYPE piscina_t FORCE;
DROP TYPE bailoterapia_t FORCE;
DROP TYPE entretenimiento_t FORCE;
DROP TYPE Ofrece_inT; 
DROP TABLE Destino;
DROP TABLE Ruta;
DROP TABLE ofrece_in;
DROP TABLE Barco;
DROP TABLE Entretenimiento;
DROP TABLE Bailoterapia;
DROP TABLE Piscina;

CREATE TYPE barco_t as Object (
    nombre varchar(50),
    capacidad int,
    nro_cabinas int,
    nro_cubiertas int,
    tonelaje int,
    eslora int
); 
/
CREATE TABLE Barco OF barco_t ( nombre NOT NULL, PRIMARY KEY (nombre) ) OBJECT ID PRIMARY KEY;

CREATE TYPE destino_t AS OBJECT(
    ubicacion varchar(50)
);
/
CREATE TABLE Destino OF destino_t;

CREATE TYPE destinos_mult AS VARRAY(20) OF destino_t;
/

CREATE TABLE Ruta(
    nombre_ruta    varchar(100) PRIMARY KEY,
    regimen        varchar(50),
    destinos       destinos_mult, /*multievaluado*/
    es_realizada   REF barco_t SCOPE IS Barco
); 
/

CREATE TYPE entretenimiento_t AS OBJECT (
    id_actividad    int,
    nombre          varchar(100),
    descripcion     varchar(500),
    capacidad       int) NOT FINAL;
/

CREATE TYPE taller_t UNDER entretenimiento_t (
    instructor  varchar(50)
);
/

CREATE TYPE restaurante_t UNDER entretenimiento_t (
    nro_mesas   int
);
/

CREATE TYPE piscina_t UNDER entretenimiento_t (
    profundidad int
);
/

CREATE TYPE bailoterapia_t UNDER entretenimiento_t ( /*n*/
    instructor      varchar(50),
    duracion        int,
    piscina_bai     REF piscina_t
);
/

CREATE TABLE Piscina OF piscina_t (
    id_actividad NOT NULL, 
    PRIMARY KEY(id_actividad)
);

CREATE TABLE Bailoterapia OF bailoterapia_t (
    id_actividad NOT NULL, 
    PRIMARY KEY (id_actividad),
    foreign key(piscina_bai) references Piscina);
    
CREATE TABLE Entretenimiento OF entretenimiento_t ( 
    id_actividad NOT NULL, PRIMARY KEY(id_actividad)) OBJECT ID PRIMARY KEY;

CREATE TYPE Ofrece_inT AS OBJECT (
    entretenimiento_typ REF entretenimiento_t,
    barco_typ           REF barco_t
);
/

CREATE TABLE ofrece_in of Ofrece_inT (
    foreign key (entretenimiento_typ)   references Entretenimiento,
    foreign key (barco_typ)             references Barco
);