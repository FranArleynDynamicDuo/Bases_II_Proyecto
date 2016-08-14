
INSERT INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora) VALUES
('Buque ZENITH-ZT', 1442, 720, 10, 46811, 208);
INSERT INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora) VALUES
('Buque MONARCH', 2766, 1193, 12, 73937, 268);
INSERT INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora) VALUES
('Buque SOVEREIGN', 2733, 1162, 12, 73592, 268);

SELECT * from Barco;

INSERT INTO Ruta (nombre_ruta, regimen, destinos, es_realizada) VALUES 
('2 Noches - Andalucia', 'Todo Incluido', destinos_mult(destino_t('Marsella'),destino_t('Malaga')), 
	( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque ZENITH-ZT' ) );
INSERT INTO Ruta (nombre_ruta, regimen, destinos, es_realizada) VALUES 
('2 Noches - Barcelona', 'Todo Incluido', destinos_mult(destino_t('Marsella'),destino_t('Barcelona')), 
	( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque ZENITH-ZT' ) );
INSERT INTO Ruta (nombre_ruta, regimen, destinos, es_realizada) VALUES 
('4 Noches - Caribe Sur  (Puerto Limon)', 'Todo Incluido', destinos_mult(destino_t('Puerto Limon'),destino_t('Colon'),destino_t('Cartagena de Indias')), 
	( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque MONARCH') );