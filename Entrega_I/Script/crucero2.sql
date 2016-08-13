DROP TYPE barco_t FORCE;
DROP TYPE ruta_t FORCE;
DROP TABLE Ruta;
DROP TABLE Barco;

CREATE TYPE barco_t as Object (
    nombre 			varchar(50),
    capacidad 		int,
    nro_cabinas 	int,
    nro_cubiertas 	int,
    tonelaje 		int,
    eslora 			int
); 
/
CREATE TABLE Barco OF barco_t (PRIMARY KEY (nombre));

CREATE TYPE ruta_t AS object (
    nombre_ruta    varchar(100),
    regimen        varchar(50),
    destinos       varchar(100), /*multievaluado*/
    es_realizada   REF barco_t
); 
/
CREATE TABLE Ruta OF ruta_t (PRIMARY KEY (nombre_ruta));