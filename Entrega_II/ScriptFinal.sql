/* -------------------------------------------- BORRADO -------------------------------------------- */

    DROP TYPE barco_t FORCE;
    DROP TYPE ruta_t FORCE;
    DROP TABLE Barco CASCADE CONSTRAINTS;                       
    DROP TABLE Ruta CASCADE CONSTRAINTS;

/* -------------------------------------------- CREACION -------------------------------------------- */

    CREATE TYPE barco_t AS Object (
        nombre VARCHAR(50),
        capacidad INTEGER,
        nro_cabinas INTEGER,
        nro_cubiertas INTEGER,
        tonelaje INTEGER,
        eslora INTEGER
    ); 
    /
    
    CREATE TYPE ruta_t AS Object (
        nombre    VARCHAR(100),
        regimen        VARCHAR(50),
        es_realizada   REF barco_t
    ); 
    /  

    ALTER TYPE barco_t add attribute (realiza_ruta REF ruta_t) CASCADE;

    CREATE TABLE Barco OF barco_t ( nombre NOT NULL, PRIMARY KEY (nombre) ) OBJECT IDENTIFIER IS SYSTEM GENERATED;
    CREATE TABLE Ruta OF ruta_t ( nombre NOT NULL, PRIMARY KEY (nombre) ) OBJECT IDENTIFIER IS SYSTEM GENERATED;

/* -------------------------------------------- TRIGGERS -------------------------------------------- */

/* -------------------- BARCO -------------------- */
/* INSERT */
/* En caso de que insertemos un nuevo barco con ruta asignada, debemos asegurarnos que dicha
ruta no tiene ruta asignada, y sino la tiene asignarle el nuevo barco */
CREATE OR REPLACE TRIGGER barco_insert_before
    BEFORE INSERT ON Barco FOR EACH ROW
    WHEN (NEW.realiza_ruta IS NOT NULL)
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        reference_Count INTEGER;
        referencia_Unica  EXCEPTION;  -- declare exception
    BEGIN
        SELECT COUNT(b.nombre) INTO reference_Count
        FROM Barco b
        WHERE b.realiza_ruta = :NEW.realiza_ruta;

        IF (reference_Count != 0) THEN
            RAISE referencia_Unica;
        END IF;

        COMMIT;

    EXCEPTION
        WHEN referencia_Unica THEN  -- handle exception
            DBMS_OUTPUT.PUT_LINE ('Esta ruta ya esta siendo realizada por otro barco');       
    END;
/
/* En caso de que insertemos una nueva ruta con barco asignado, debemos 
asignarle la ruta al nuevo barco */
CREATE OR REPLACE TRIGGER barco_insert_after
    AFTER INSERT ON Barco FOR EACH ROW
    WHEN (NEW.realiza_ruta IS NOT NULL)
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        /* Asignamos la nueva ruta al barco */
        UPDATE Ruta r 
        SET r.es_realizada = NULL
        WHERE REF(r) = :NEW.realiza_ruta;
        COMMIT;
        /* Asignamos la nueva ruta al barco */
        UPDATE Ruta r 
        SET r.es_realizada = (SELECT REF(b) FROM Barco b WHERE b.nombre = :NEW.nombre)
        WHERE REF(r) = :NEW.realiza_ruta;
        COMMIT;
    END;
/
/* UPDATE */
/* En caso de que dejemos a un barco sin ruta, debemos eliminar la referencia a ella 
en el barco a la que estaba asignada */
CREATE OR REPLACE TRIGGER barco_update_null
    AFTER UPDATE ON Barco FOR EACH ROW
    WHEN (NEW.realiza_ruta IS NULL AND OLD.realiza_ruta IS NOT NULL)
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE Ruta r 
        SET r.es_realizada = NULL 
        WHERE r.es_realizada = (SELECT REF(b) FROM Barco b WHERE b.nombre = :OLD.nombre);
        COMMIT;
    END;
/
/* DELETE */
/* En caso de que borremos un barco debemos cambiar la referencia inversa a la ruta que tenia asignada */
CREATE OR REPLACE TRIGGER barco_delete
    AFTER DELETE ON Barco FOR EACH ROW
    WHEN (OLD.realiza_ruta IS NOT NULL)
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        /*  */
        UPDATE Ruta r 
        SET r.es_realizada = NULL
        WHERE r.es_realizada = (select ref(b) from Barco b where b.nombre = :old.nombre);
        COMMIT;
    END;
/
/* -------------------- RUTA -------------------- */
/* INSERT */
/* En caso de que insertemos una nueva ruta con barco asignado, debemos 
asignarle la ruta al barco */
CREATE OR REPLACE TRIGGER ruta_insert_after
    AFTER INSERT ON Ruta FOR EACH ROW
    WHEN (NEW.es_realizada IS NOT NULL)
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        /* Le quitamos la ruta al barco deseado para que su propio trigger se encargue de dejar la ruta antigua en null */
        UPDATE Barco b 
        SET b.realiza_ruta = NULL 
        WHERE REF(b) = :NEW.es_realizada;
        /* Asignamos la nueva ruta al barco */
        UPDATE Barco b 
        SET b.realiza_ruta = (SELECT REF(r) FROM Ruta r WHERE r.nombre = :NEW.nombre)
        WHERE REF(b) = :NEW.es_realizada;
        COMMIT;
    END;
/

/* UPDATE */
/* En caso de que dejemos una ruta sin barco, debemos eliminar la referencia a ella 
en el barco a la que estaba asignada */
CREATE OR REPLACE TRIGGER ruta_update_null
    AFTER UPDATE ON Ruta FOR EACH ROW
    WHEN (NEW.es_realizada IS NULL AND OLD.es_realizada IS NOT NULL)
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE Barco b 
        SET b.realiza_ruta = NULL 
        WHERE b.realiza_ruta = (SELECT REF(r) FROM Ruta r WHERE r.nombre = :OLD.nombre);
        COMMIT;
    END;
/
/* En Caso de que cambiemos el barco de una ruta debemos dejar a la ruta que estaba asignada anteriormente
sin barco y actualizar la ruta del barco asignado */
CREATE OR REPLACE TRIGGER ruta_update_not_null
    AFTER UPDATE ON Ruta FOR EACH ROW
    WHEN (NEW.es_realizada IS NOT NULL)
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        /* Le quitamos la ruta al barco deseado para que su propio trigger se encargue de dejar la ruta antigua en null */
        UPDATE Barco b 
        SET b.realiza_ruta = NULL 
        WHERE REF(b) = :NEW.es_realizada;
        /* Actualizamos al barco con su nueva ruta */
        UPDATE Barco b
        SET b.realiza_ruta = (SELECT REF(r) FROM Ruta r WHERE r.nombre = :NEW.nombre) 
        WHERE REF(b) = :NEW.es_realizada;
        COMMIT;
    END;
/
/* DELETE */
/* En caso de que borremos una ruta debemos cambiar la referencia inversa al barco al que estaba asignada */
CREATE OR REPLACE TRIGGER ruta_delete
    AFTER DELETE ON Ruta FOR EACH ROW
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE Barco b 
        SET b.realiza_ruta = NULL
        WHERE b.realiza_ruta = (select ref(r) from Ruta r where r.nombre = :old.nombre);
        COMMIT;
    END;
/

ALTER TABLE Barco ENABLE ALL TRIGGERS;
ALTER TABLE Ruta ENABLE ALL TRIGGERS;

/* -------------------------------------------- INSERCIONES -------------------------------------------- */

/* INSTANCIAS PARA BARCOS */
    INSERT ALL 
        INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora,realiza_ruta) VALUES
                    ('Buque ZENITH-ZT', 1442, 720, 10, 46811, 208,NULL)
        INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora,realiza_ruta) VALUES
                    ('Buque MONARCH', 2766, 1193, 12, 73937, 268,NULL)
        INTO Barco (nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora,realiza_ruta) VALUES
                    ('Buque SOVEREIGN', 2733, 1162, 12, 73592, 268,NULL)
    SELECT * from dual;

/* INSTANCIAS PARA RUTAS */
    INSERT ALL
        INTO Ruta (nombre, regimen, es_realizada) VALUES 
                ('2 Noches - Andalucia', 'Todo Incluido',
                ( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque SOVEREIGN' ) )
        INTO Ruta (nombre, regimen, es_realizada) VALUES 
                ('2 Noches - Barcelona', 'Todo Incluido',
                ( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque ZENITH-ZT' ) )
        INTO Ruta (nombre, regimen, es_realizada) VALUES 
                ('4 Noches - Caribe Sur  (Puerto Limon)', 'Todo Incluido',
                ( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque MONARCH') )
    SELECT * from dual;

    UPDATE Barco
    SET realiza_ruta =  ( SELECT REF(oc) FROM Ruta oc WHERE oc.nombre = '2 Noches - Andalucia')
    WHERE nombre = 'Buque ZENITH-ZT';

    UPDATE Barco
    SET realiza_ruta =  ( SELECT REF(oc) FROM Ruta oc WHERE oc.nombre = '2 Noches - Barcelona')
    WHERE nombre = 'Buque MONARCH';

    UPDATE Barco
    SET realiza_ruta =  ( SELECT REF(oc) FROM Ruta oc WHERE oc.nombre = '4 Noches - Caribe Sur  (Puerto Limon)')
    WHERE nombre = 'Buque SOVEREIGN';


/* -------------------------------------------- CONSULTAS -------------------------------------------- */
