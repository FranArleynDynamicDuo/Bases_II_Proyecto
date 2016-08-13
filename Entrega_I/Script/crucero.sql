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

CREATE TYPE ruta_t AS OBJECT (
    nombre_ruta   	varchar(100),
    regimen        	varchar(50),
    destinos       	varchar(100), /*multievaluado*/
    MEMBER FUNCTION get_Barco return barco_t );
/
CREATE TABLE Ruta AS TABLE OF ruta_t (PRIMARY KEY(nombre_ruta));

CREATE TYPE barco_t as Object (
    nombre 	        varchar(50),
    capacidad 		int,
    nro_cabinas 	int,
    nro_cubiertas 	int,
    tonelaje 		int,
    eslora 		int,
    realiza REF ruta_t SCOPE IS Ruta,
    member function get_entretenimiento return entretenimiento_Col);
/
CREATE TABLE Barco AS TABLE OF barco_t (PRIMARY KEY (nombre));


CREATE TYPE entretenimiento AS Object (
    id_actividad    int,
    nombre          varchar(100),
    descripcion     varchar(500),
    capacidad       int,
    ofrece          barco_Col) NOT FINAL;

CREATE TYPE taller_t UNDER entretenimiento (
    instructor  varchar(50));

CREATE TYPE restaurante_t UNDER entretenimiento (
    nro_mesas   int);

CREATE TYPE piscina_t UNDER entretenimiento (
    profundidad int,
    member function get_Bailoterapia return bailoterapia_t);

CREATE TYPE bailoterapia_t UNDER entretenimiento (
    instructor 	varchar(50),
    duracion 	int,
    se_realiza REF piscina_t SCOPE IS Piscina);
    
CREATE TYPE barco_Col AS TABLE OF REF Barco;
CREATE TYPE entretenimiento_Col AS TABLE OF entretenimiento (PRIMARY KEY (id_actividad));