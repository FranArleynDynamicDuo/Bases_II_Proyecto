/* INSTANCIAS PARA BARCOS */
INSERT INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora) VALUES
('Buque ZENITH-ZT', 1442, 720, 10, 46811, 208);
INSERT INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora) VALUES
('Buque MONARCH', 2766, 1193, 12, 73937, 268);
INSERT INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora) VALUES
('Buque SOVEREIGN', 2733, 1162, 12, 73592, 268);

SELECT * from Barco;

/* INSTANCIAS PARA RUTAS */
INSERT INTO Ruta (nombre_ruta, regimen, destinos, es_realizada) VALUES 
('2 Noches - Andalucia', 'Todo Incluido', destinos_mult(destino_t('Marsella'),destino_t('Malaga')), 
	( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque ZENITH-ZT' ) );
INSERT INTO Ruta (nombre_ruta, regimen, destinos, es_realizada) VALUES 
('2 Noches - Barcelona', 'Todo Incluido', destinos_mult(destino_t('Marsella'),destino_t('Barcelona')), 
	( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque ZENITH-ZT' ) );
INSERT INTO Ruta (nombre_ruta, regimen, destinos, es_realizada) VALUES 
('4 Noches - Caribe Sur  (Puerto Limon)', 'Todo Incluido', destinos_mult(destino_t('Puerto Limon'),destino_t('Colon'),destino_t('Cartagena de Indias')), 
	( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque MONARCH') );


/* INSTANCIAS PARA ENTRETENIMIENTO */
INSERT INTO Entretenimiento
VALUES (entretenimiento_t(1,'Masajes','Obten un Masaje en el Spa Del Crucero',1));
INSERT INTO Entretenimiento
VALUES (entretenimiento_t(2,'Dicoteca','Baila toda la noche hasta las 4 am con nuestro Dj',800));
INSERT INTO Entretenimiento
VALUES (entretenimiento_t(3,'Teatro','Acercate al Teatro y disfruta nuestras funciones',400));

/* INSTANCIAS PARA ENTRETENIMIENTO-TALLER */
INSERT INTO Entretenimiento
VALUES (taller_t(4,'Taller de Origame','Aprende a hacer Origami en poco Tiempo',100,'Instructor1'));
INSERT INTO Entretenimiento
VALUES (taller_t(5,'Taller de Yoga','Relajate y aprende yoga en la cubierta mientras te pega el sol.',50,'Instructor2'));
INSERT INTO Entretenimiento
VALUES (taller_t(6,'Taller de Comida Asiatica','Aprende a Cocinar comida Asiatica con nuestro instructor proveniente de China',100,'Instructor3'));

/* INSTANCIAS PARA ENTRETENIMIENTO-RESTAURANTE */
INSERT INTO Entretenimiento
VALUES (restaurante_t(7,'Cena de Gala','Vistete de Elegante y tomate una foto con el Capitan',1000,120));
INSERT INTO Entretenimiento
VALUES (restaurante_t(8,'Buffet de Comida Latinoamericana','Acercate al restaurante y disfruta comida proveniente de latinoamerica',1500,120));
INSERT INTO Entretenimiento
VALUES (restaurante_t(9,'Monumentos de Hielo','Presentacion de esculturas de hielo, acercate y disfruta de la presentacion',1500,120));