/* -------------------------------------------- BORRADO -------------------------------------------- */

    DROP TYPE barco_t FORCE;
    DROP TYPE destino_t FORCE;
    DROP TYPE destinos_mult FORCE;
    DROP TYPE taller_t FORCE;
    DROP TYPE restaurante_t FORCE;
    DROP TYPE piscina_t FORCE;
    DROP TYPE bailoterapia_t FORCE;
    DROP TYPE entretenimiento_t FORCE;
    DROP TYPE Ofrece_inT; 
    DROP TABLE Destino CASCADE CONSTRAINTS;                       
    DROP TABLE ofrece_in CASCADE CONSTRAINTS;
    DROP TABLE Ruta CASCADE CONSTRAINTS;
    DROP TABLE Entretenimiento CASCADE CONSTRAINTS;
    DROP TABLE Barco CASCADE CONSTRAINTS;

/* -------------------------------------------- CREACION -------------------------------------------- */

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
    /* Multivaluado */
    /* Para implementar el atributo multivaluado creamos un tipo primitivo llamado destino_t el cual sera
    el tipo de cada valor del multivaluado, luego creamos un tipo llamado destinos_mult que es una tabla de 
    los destinos_t y luego agregamos un atributo en el objeto ruta de este tipo para almacenar todos los destinos
    de la ruta en una tabla anidada
    
    Se implemento de esta manera ya que simula de manera mas correcta el comportamiento de un multivaluado en un esquema
     */
    CREATE TYPE destino_t AS OBJECT(
        ubicacion varchar(50)
    );
    /
    CREATE TABLE Destino OF destino_t;
    CREATE TYPE destinos_mult AS TABLE OF destino_t;
    /
    CREATE TABLE Ruta (
        nombre_ruta    varchar(100) PRIMARY KEY,
        regimen        varchar(50),
        destinos       destinos_mult,
        es_realizada   REF barco_t SCOPE IS Barco
    ) NESTED TABLE destinos STORE AS destinos_store; 
    /
    /* Super clase y sub clases */
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
    /* Relacion entre dos subclases 1:N */
    /* Se implemento con una referencia en el tipo bailoterapia_t a la piscina ya que
    nos parecio la forma mas sencilla para implementar la relacion y ademas se facilita
    el mantenimiento de la tabla ya que actua como una llave foranea la cual es sencilla de
    cambiar si es necesario */
    CREATE TYPE piscina_t UNDER entretenimiento_t (
        profundidad varchar(15)
    );
    /
    CREATE TYPE bailoterapia_t UNDER entretenimiento_t (
        instructor      varchar(50),
        duracion        varchar(15),
        piscina_bai     REF entretenimiento_t
    );
    /
    CREATE TABLE Entretenimiento OF entretenimiento_t ( 
        id_actividad NOT NULL, PRIMARY KEY(id_actividad)) OBJECT IDENTIFIER IS SYSTEM GENERATED;
    /* Relacion M:N */
    /* Se implemento con el uso de una tabla intermedia, para asi conservar la simplicidad de la estructura
    de las tablas y hacer uso de las estructuras mas sencillas para representar una relacion M:N */
    CREATE TYPE Ofrece_inT AS OBJECT (
        entretenimiento_typ REF entretenimiento_t,
        barco_typ           REF barco_t
    );
    /
    CREATE TABLE ofrece_in of Ofrece_inT (
        foreign key (entretenimiento_typ)   references Entretenimiento,
        foreign key (barco_typ)             references Barco
    );

/* -------------------------------------------- INSERCIONES -------------------------------------------- */

/* INSTANCIAS PARA BARCOS */
    INSERT ALL 
        INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora) VALUES
                    ('Buque ZENITH-ZT', 1442, 720, 10, 46811, 208)
        INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora) VALUES
                    ('Buque MONARCH', 2766, 1193, 12, 73937, 268)
        INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora) VALUES
                    ('Buque SOVEREIGN', 2733, 1162, 12, 73592, 268)
    SELECT * from dual;

/* INSTANCIAS PARA RUTAS */
    INSERT ALL
        INTO Ruta (nombre_ruta, regimen, destinos, es_realizada) VALUES 
                ('2 Noches - Andalucia', 'Todo Incluido', destinos_mult(destino_t('Marsella'),destino_t('Malaga')), 
                ( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque SOVEREIGN' ) )
        INTO Ruta (nombre_ruta, regimen, destinos, es_realizada) VALUES 
                ('2 Noches - Barcelona', 'Todo Incluido', destinos_mult(destino_t('Marsella'),destino_t('Barcelona')), 
                ( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque ZENITH-ZT' ) )
        INTO Ruta (nombre_ruta, regimen, destinos, es_realizada) VALUES 
                ('4 Noches - Caribe Sur  (Puerto Limon)', 'Todo Incluido', destinos_mult(destino_t('Puerto Limon'),destino_t('Colon'),destino_t('Cartagena de Indias')), 
                ( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque MONARCH') )
    SELECT * from dual;

	

/* INSTANCIAS PARA ENTRETENIMIENTO */
    INSERT ALL
        INTO Entretenimiento VALUES 
            (entretenimiento_t(1,'Masajes','Obten un Masaje en el Spa Del Crucero',1))
        INTO Entretenimiento VALUES 
            (entretenimiento_t(2,'Dicoteca','Baila toda la noche hasta las 4 am con nuestro Dj',800))
        INTO Entretenimiento VALUES 
            (entretenimiento_t(3,'Teatro','Acercate al Teatro y disfruta nuestras funciones',400))
    SELECT * FROM dual;

/* INSTANCIAS PARA ENTRETENIMIENTO-TALLER */
    INSERT ALL
        INTO Entretenimiento
        VALUES (taller_t(4,'Taller de Origame','Aprende a hacer Origami en poco Tiempo',100,'Instructor1'))
        INTO Entretenimiento
        VALUES (taller_t(5,'Taller de Yoga','Relajate y aprende yoga en la cubierta mientras te pega el sol.',50,'Instructor2'))
        INTO Entretenimiento
        VALUES (taller_t(6,'Taller de Comida Asiatica','Aprende a Cocinar comida Asiatica con nuestro instructor proveniente de China',100,'Instructor3'))
    SELECT * FROM dual;

/* INSTANCIAS PARA ENTRETENIMIENTO-RESTAURANTE */
    INSERT ALL
        INTO Entretenimiento
        VALUES (restaurante_t(7,'Cena de Gala','Vistete de Elegante y tomate una foto con el Capitan',1000,120))
        INTO Entretenimiento
        VALUES (restaurante_t(8,'Buffet de Comida Latinoamericana','Acercate al restaurante y disfruta comida proveniente de latinoamerica',1500,120))
        INTO Entretenimiento
        VALUES (restaurante_t(9,'Monumentos de Hielo','Presentacion de esculturas de hielo, acercate y disfruta de la presentacion',1500,120))
    SELECT * FROM dual;

/* INSTANCIAS PARA ENTRETENIMIENTO-PISCINA */
    INSERT ALL
        INTO Entretenimiento
        VALUES (piscina_t(10,'Piscina para ninos','Piscina para ninos de 5 - 13 anos, para que difruten los dias de navegacion',1000,'30 metros'))
        INTO Entretenimiento
        VALUES (piscina_t(11,'Jacuzzi','Relajate en el Jacuzzi en la cubierta 10',1000,'20 metros'))
        INTO Entretenimiento
        VALUES (piscina_t(12,'Piscina para Adultos','Piscina para mayores de 15 anos, para que difruten los dias de navegacion',1000,'70 metros'))
    SELECT * FROM dual;


/* INSTANCIAS PARA ENTRETENIMIENTO-BAILOTERAPIA */
    INSERT ALL
    INTO Entretenimiento
        VALUES (bailoterapia_t(13,'Bailoterapia','Bailoterapia',100,'Instructor1','1 hora',
            ( SELECT REF(p) FROM Entretenimiento p WHERE p.id_actividad = 10)
            ))
        INTO Entretenimiento
        VALUES (bailoterapia_t(14,'Bailoterapia Tropical','Bailoterapia Tropical',100,'Instructor1','1 hora y media',
            ( SELECT REF(p)  FROM Entretenimiento p WHERE p.id_actividad = 11 )
            ))
        INTO Entretenimiento
        VALUES (bailoterapia_t(15,'Bailoterapia Nocturna','Bailoterapia Nocturna',100,'Instructor1','45 min',
            ( SELECT REF(p) FROM Entretenimiento p WHERE p.id_actividad = 10 )
            ))
    SELECT * FROM dual;

    /* INSTANCIAS PARA OFRECE_IN */
    INSERT ALL
    INTO ofrece_in
        VALUES 
        (Ofrece_inT(( SELECT REF(e) FROM Entretenimiento e WHERE e.id_actividad = 1),
        ((SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque SOVEREIGN'))
        ))
    INTO ofrece_in
        VALUES 
        (Ofrece_inT(( SELECT REF(e) FROM Entretenimiento e WHERE e.id_actividad = 2),
        ((SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque SOVEREIGN'))
        ))
    INTO ofrece_in
        VALUES 
        (Ofrece_inT(( SELECT REF(e) FROM Entretenimiento e WHERE e.id_actividad = 3),
        ((SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque SOVEREIGN'))
        ))
    SELECT * FROM dual;

/* -------------------------------------------- CONSULTAS -------------------------------------------- */

/* SUBCLASE */

	SELECT *
	FROM Entretenimiento e
	WHERE (VALUE(e) IS OF (ONLY piscina_t));

/* NESTED TABLE */

    /* SELECT CON MULTIVALUADO */
	SELECT e.nombre_ruta, e.regimen, e.es_realizada.nombre,e.destinos
	FROM Ruta e
    WHERE e.nombre_ruta='4 Noches - Caribe Sur  (Puerto Limon)';
    /* SELECT CON MULTIVALUADO */
	SELECT d.ubicacion
	FROM Ruta e, table(destinos) d
    WHERE e.nombre_ruta='4 Noches - Caribe Sur  (Puerto Limon)';