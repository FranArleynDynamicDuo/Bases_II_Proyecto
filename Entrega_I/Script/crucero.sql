DROP TYPE barco_t FORCE;
DROP TYPE ruta_t FORCE;
DROP TYPE entretenimiento_t FORCE;
DROP TYPE taller_t FORCE;
DROP TYPE restaurante_t FORCE;
DROP TYPE piscina_t FORCE;
DROP TYPE bailoterapia_t FORCE;
DROP TYPE es_ofrecido_T FORCE;
DROP TABLE Ruta;
DROP TABLE Barco;
DROP TABLE Entretenimiento;
DROP TABLE Es_Ofrecido;



CREATE TYPE barco_t as Object (
    nombre varchar(50),
    capacidad int,
    nro_cabinas int,
    nro_cubiertas int,
    tonelaje int,
    eslora int
); 
/
CREATE TABLE Barco OF barco_t (PRIMARY KEY (nombre));
CREATE TYPE ruta_t AS object (
    nombre_ruta   varchar(100),
    regimen        varchar(50),
    destinos       varchar(100), /*multievaluado*/
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

CREATE TYPE bailoterapia_t UNDER entretenimiento_t (
    instructor  varchar(50),
    duracion  int/*,
    se_realiza REF piscina_t SCOPE IS Piscina,*/
);
/
CREATE TABLE Entretenimiento OF entretenimiento_t (PRIMARY KEY(id_actividad));
CREATE TYPE es_ofrecido_T AS OBJECT (barco REF barco_t,entretenimiento REF entretenimiento_t);
/
CREATE TABLE Es_Ofrecido of es_ofrecido_T (foreign key (barco) references Barco, foreign key (entretenimiento) references Entretenimiento);
