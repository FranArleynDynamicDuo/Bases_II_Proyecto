CREATE OR REPLACE TYPE ruta_t AS object (
    nombre_ruta   varchar(100) not null,
    regimen        varchar(50),
    destinos       varchar(100), /*multievaluado*/
    member function getBarco return barco_t
); 
/
CREATE TABLE Ruta OF ruta_t (PRIMARY KEY (nombre_ruta));

CREATE OR REPLACE TYPE barco_t as Object (
    nombre varchar(50) not null,
    capacidad int,
    nro_cabinas int,
    nro_cubiertas int,
    tonelaje int,
    eslora int,
    realiza REF ruta_t scope is Ruta,
    member function getEntretenimiento return entretenimiento_Col,
); 
/

CREATE TABLE Barco OF barco_t (PRIMARY KEY (nombre));


CREATE OR REPLACE TYPE entretenimiento AS Object (
    id_actividad    int not null,
    nombre          varchar(100),
    descripcion     varchar(500),
    capacidad       int,
    ofrece          barco_Col) NOT FINAL; 
    /

CREATE OR REPLACE TYPE taller_t UNDER entretenimiento (
    instructor  varchar(50),
); 
/

CREATE OR REPLACE TYPE restaurante_t UNDER entretenimiento (
    nro_mesas   int,
); 
/

CREATE OR REPLACE TYPE piscina_t UNDER entretenimiento (
    profundidad int,
    member function getBailoterapia return bailoterapia_t,
); 
/

CREATE OR REPLACE TYPE bailoterapia_t UNDER entretenimiento (
    instructor  varchar(50),
    duracion  int,
    se_realiza REF piscina_t SCOPE IS Piscina,
);
/

/*    
CREATE OR REPLACE TYPE barco_Col AS TABLE OF REF Barco; 
/
CREATE OR REPLACE TYPE entretenimiento_Col AS TABLE entretenimiento (PRIMARY KEY (id_actividad)); 
/
*/
