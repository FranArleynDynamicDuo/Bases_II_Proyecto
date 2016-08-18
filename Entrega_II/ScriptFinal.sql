/* -------------------------------------------- BORRADO -------------------------------------------- */

    DROP TYPE barco_t FORCE;
    DROP TYPE ruta_t FORCE;
    DROP TABLE Barco CASCADE CONSTRAINTS;                       
    DROP TABLE Ruta CASCADE CONSTRAINTS;

/* -------------------------------------------- CREACION -------------------------------------------- */

    CREATE TYPE barco_t AS Object (
        id INTEGER,
        nombre VARCHAR(50),
        capacidad INTEGER,
        nro_cabinas INTEGER,
        nro_cubiertas INTEGER,
        tonelaje INTEGER,
        eslora INTEGER
    ); 
    /
    
    CREATE TYPE ruta_t AS Object (
        id INTEGER,
        nombre    VARCHAR(100),
        regimen        VARCHAR(50),
        es_realizada   REF barco_t
    ); 
    /  

    ALTER TYPE barco_t add attribute (realiza_ruta REF ruta_t) CASCADE;

    CREATE TABLE Barco OF barco_t ( id NOT NULL, PRIMARY KEY (id) ) OBJECT IDENTIFIER IS SYSTEM GENERATED;
    CREATE TABLE Ruta OF ruta_t ( id NOT NULL, PRIMARY KEY (id) ) OBJECT IDENTIFIER IS SYSTEM GENERATED;

/* -------------------------------------------- TRIGGERS -------------------------------------------- */

/* -------------------- BARCO -------------------- */
/* INSERT */
/* En caso de que insertemos una nueva ruta con barco asignado, debemos 
asignarle la ruta al nuevo barco */

/* UPDATE */

/* DELETE */
/* En caso de que borremos un barco debemos cambiar la referencia inversa a la ruta que tenia asignada */
CREATE OR REPLACE TRIGGER barco_delete
    AFTER DELETE ON Barco FOR EACH ROW
    WHEN (OLD.realiza_ruta IS NOT NULL)
    BEGIN
        /*  */
        UPDATE Ruta r 
        SET r.es_realizada = NULL
        WHERE REF(r) = :OLD.realiza_ruta;
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
        reference_Count int;
        referencia_Unica  EXCEPTION;  -- declare exception
    BEGIN
        /* Si el barco deseado tenia una ruta asignada, libero esa ruta  */
        UPDATE Ruta r 
        SET r.es_realizada=NULL
        WHERE EXISTS (SELECT b.id FROM Barco b WHERE REF(b) = :NEW.es_realizada AND REF(r)=b.realiza_ruta);
        /* Libero el barco de su ruta actual */
        UPDATE Barco b 
        SET b.realiza_ruta=NULL
        WHERE REF(b) = :NEW.es_realizada;
        /* Actualizo el barco con su nueva ruta */
        UPDATE Barco b 
        SET b.realiza_ruta= (SELECT REF(r) FROM Ruta r WHERE r.id = :NEW.id)
        WHERE REF(b) = :NEW.es_realizada;

        SELECT COUNT(r.id) INTO reference_Count
        FROM Ruta r WHERE r.id = :NEW.id;
        
        DBMS_OUTPUT.PUT_LINE ('reference_Count = ' || reference_Count);
        DBMS_OUTPUT.PUT_LINE ('NEW.id = ' || :NEW.id);

        IF (reference_Count = 0) THEN
            RAISE referencia_Unica;
        END IF;

        COMMIT;

    EXCEPTION
        WHEN referencia_Unica THEN  -- handle exception
            DBMS_OUTPUT.PUT_LINE ('NO ENCONTRO NADA');       
    END;
/

/* UPDATE */

/* En Caso de que cambiemos el barco de una ruta debemos dejar a la ruta que estaba asignada anteriormente
sin barco y actualizar la ruta del barco asignado */
CREATE OR REPLACE TRIGGER ruta_update_after
    AFTER UPDATE ON Ruta FOR EACH ROW
    WHEN (NEW.es_realizada IS NOT NULL AND (NEW.es_realizada != OLD.es_realizada OR OLD.es_realizada IS NULL))
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        reference_Count int;
        referencia_Unica  EXCEPTION;  -- declare exception
    BEGIN
        /* Si el barco deseado tenia una ruta asignada, libero esa ruta  */
        UPDATE Ruta r 
        SET r.es_realizada=NULL
        WHERE EXISTS (SELECT b.id FROM Barco b WHERE REF(b) = :NEW.es_realizada AND REF(r)=b.realiza_ruta);
        /* Actualizo el barco con su nueva ruta */
        UPDATE Barco b 
        SET b.realiza_ruta= (SELECT REF(r) FROM Ruta r WHERE r.id = :NEW.id)
        WHERE REF(b) = :NEW.es_realizada;
        /* */
        SELECT COUNT(r.id) INTO reference_Count
        FROM Ruta r WHERE r.id = :NEW.id;
        
        DBMS_OUTPUT.PUT_LINE ('reference_Count = ' || reference_Count);
        DBMS_OUTPUT.PUT_LINE ('NEW.id = ' || :NEW.id);
        DBMS_OUTPUT.PUT_LINE ('OLD.id = ' || :OLD.id);

        IF (reference_Count = 0) THEN
            RAISE referencia_Unica;
        END IF;

        COMMIT;

    EXCEPTION
        WHEN referencia_Unica THEN  -- handle exception
            DBMS_OUTPUT.PUT_LINE ('ERROR: NO ENCONTRO NADA');       
    END;
/

/* DELETE */
/* En caso de que borremos una ruta debemos cambiar la referencia inversa al barco al que estaba asignada */
CREATE OR REPLACE TRIGGER ruta_delete
    AFTER DELETE ON Ruta FOR EACH ROW
    WHEN (OLD.es_realizada IS NOT NULL)
    BEGIN
        UPDATE Barco b 
        SET b.realiza_ruta = NULL
        WHERE REF(b) = :OLD.es_realizada;
    END;
/

ALTER TABLE Barco ENABLE ALL TRIGGERS;
ALTER TABLE Ruta ENABLE ALL TRIGGERS;

/* -------------------------------------------- INSERCIONES -------------------------------------------- */

/* INSTANCIAS PARA BARCOS */
    INSERT ALL 
        INTO Barco (id,nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora,realiza_ruta) VALUES
                    (1,'Buque ZENITH-ZT', 1442, 720, 10, 46811, 208,NULL)
        INTO Barco (id,nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora,realiza_ruta) VALUES
                    (2,'Buque MONARCH', 2766, 1193, 12, 73937, 268,NULL)
        INTO Barco (id,nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora,realiza_ruta) VALUES
                    (3,'Buque SOVEREIGN', 2733, 1162, 12, 73592, 268,NULL)
    SELECT * from dual;

/* INSTANCIAS PARA RUTAS */
    INSERT ALL
        INTO Ruta (id,nombre, regimen, es_realizada) VALUES 
                (1,'2 Noches - Andalucia', 'Todo Incluido',
                ( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque SOVEREIGN' ) )
        INTO Ruta (id,nombre, regimen, es_realizada) VALUES 
                (2,'2 Noches - Barcelona', 'Todo Incluido',
                ( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque ZENITH-ZT' ) )
        INTO Ruta (id,nombre, regimen, es_realizada) VALUES 
                (3,'4 Noches - Caribe Sur  (Puerto Limon)', 'Todo Incluido',
                ( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque MONARCH') )
    SELECT * from dual;


/* -------------------------------------------- CONSULTAS -------------------------------------------- */
