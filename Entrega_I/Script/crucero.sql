DROP TYPE barco_t FORCE;
DROP TYPE ruta_t FORCE;
DROP TYPE entretenimiento_t FORCE;
DROP TYPE taller_t FORCE;
DROP TYPE restaurante_t FORCE;
DROP TYPE piscina_t FORCE;
DROP TYPE bailoterapia_t FORCE;
DROP TYPE es_ofrecido_T FORCE;
DROP TYPE destino_t FORCE;
DROP TYPE destinos_mult FORCE;
DROP TABLE Es_Ofrecido;
DROP TABLE Ruta;
DROP TABLE Barco;
DROP TABLE Entretenimiento;
DROP TABLE Destino;

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

CREATE TYPE ruta_t AS object (
    nombre_ruta   varchar(100),
    regimen        varchar(50),
    destinos        destinos_mult, /*multievaluado*/
    es_realizada   REF barco_t
); 
/
CREATE TABLE Ruta OF ruta_t (PRIMARY KEY (nombre_ruta));

CREATE TYPE entretenimiento_t AS Object (
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
    profundidad int/*,
    member function getBailoterapia return bailoterapia_t,*/
); 
/

CREATE TYPE bailoterapia_t UNDER entretenimiento_t ( /*n*/
    instructor      varchar(50),
    duracion        int,
    piscina_bai     REF piscina_t
);
/

CREATE TABLE Entretenimiento OF entretenimiento_t (
	PRIMARY KEY(id_actividad)
);

CREATE TYPE es_ofrecido_T AS OBJECT (
	barco REF barco_t,
	entretenimiento REF entretenimiento_t
);
/

CREATE TABLE Es_Ofrecido of es_ofrecido_T (
	foreign key (barco) references Barco, 
	foreign key (entretenimiento) references Entretenimiento
);
