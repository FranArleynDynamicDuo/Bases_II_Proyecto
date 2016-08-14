/* INSTANCIAS PARA BARCOS */
INSERT ALL 
    INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora) VALUES
                ('Buque ZENITH-ZT', 1442, 720, 10, 46811, 208)
    INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora) VALUES
                ('Buque MONARCH', 2766, 1193, 12, 73937, 268)
    INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora) VALUES
                ('Buque SOVEREIGN', 2733, 1162, 12, 73592, 268)
SELECT * from dual;

SELECT * FROM Barco;

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

SELECT * FROM Entretenimiento;

/* INSTANCIAS PARA ENTRETENIMIENTO-TALLER */
INSERT ALL
    INTO Taller
    VALUES (taller_t(4,'Taller de Origame','Aprende a hacer Origami en poco Tiempo',100,'Instructor1'))
    INTO Taller
    VALUES (taller_t(5,'Taller de Yoga','Relajate y aprende yoga en la cubierta mientras te pega el sol.',50,'Instructor2'))
    INTO Taller
    VALUES (taller_t(6,'Taller de Comida Asiatica','Aprende a Cocinar comida Asiatica con nuestro instructor proveniente de China',100,'Instructor3'))
SELECT * FROM dual;

SELECT * FROM Taller;

/* INSTANCIAS PARA ENTRETENIMIENTO-RESTAURANTE */
INSERT ALL
    INTO Restaurante
    VALUES (restaurante_t(7,'Cena de Gala','Vistete de Elegante y tomate una foto con el Capitan',1000,120))
    INTO Restaurante
    VALUES (restaurante_t(8,'Buffet de Comida Latinoamericana','Acercate al restaurante y disfruta comida proveniente de latinoamerica',1500,120))
    INTO Restaurante
    VALUES (restaurante_t(9,'Monumentos de Hielo','Presentacion de esculturas de hielo, acercate y disfruta de la presentacion',1500,120))
SELECT * FROM dual;

SELECT * FROM Restaurante;

/* INSTANCIAS PARA ENTRETENIMIENTO-PISCINA */
INSERT ALL
    INTO Piscina
    VALUES (piscina_t(10,'Piscina para ninos','Piscina para ninos de 5 - 13 anos, para que difruten los dias de navegacion',1000,'30 metros'))
    INTO Piscina
    VALUES (piscina_t(11,'Jacuzzi','Relajate en el Jacuzzi en la cubierta 10',1000,'20 metros'))
    INTO Piscina
    VALUES (piscina_t(12,'Piscina para Adultos','Piscina para mayores de 15 anos, para que difruten los dias de navegacion',1000,'70 metros'))
SELECT * FROM dual;

SELECT * FROM Piscina;


/* INSTANCIAS PARA ENTRETENIMIENTO-BAILOTERAPIA */
INTO Bailoterapia
	VALUES (bailoterapia_t(13,'Bailoterapia','Bailoterapia',100,'Instructor1','1 hora',
		( SELECT REF(p) FROM Piscina p WHERE p.id_actividad = 10) ))
	INTO Bailoterapia
	VALUES (bailoterapia_t(14,'Bailoterapia Tropical','Bailoterapia Tropical',100,'Instructor1','1 hora y media',
		( SELECT REF(p) FROM Piscina p WHERE p.id_actividad = 11) ))
	INTO Bailoterapia
	VALUES (bailoterapia_t(15,'Bailoterapia Nocturna','Bailoterapia Nocturna',100,'Instructor1','45 min',
		( SELECT REF(p) FROM Piscina p WHERE p.id_actividad = 10) ))
SELECT * FROM dual;

SELECT duracion, e.piscina_bai.id_actividad, e.piscina_bai.descripcion
FROM Bailoterapia e
WHERE instructor='Instructor1';

