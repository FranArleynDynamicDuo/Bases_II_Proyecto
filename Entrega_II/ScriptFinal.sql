/* -------------------------------------------- BORRADO -------------------------------------------- */

    DROP TYPE barco_t FORCE;
    DROP TYPE ruta_t FORCE;
    DROP TABLE Barco CASCADE CONSTRAINTS;                       
    DROP TABLE Ruta CASCADE CONSTRAINTS;

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
    
    CREATE TYPE ruta_t as Object (
        nombre_ruta    varchar(100),
        regimen        varchar(50),
        es_realizada   REF barco_t
    ); 
    /  

    ALTER TYPE barco_t add attribute (realiza_ruta REF ruta_t) CASCADE;

    CREATE TABLE Barco OF barco_t ( nombre NOT NULL, PRIMARY KEY (nombre) ) OBJECT IDENTIFIER IS SYSTEM GENERATED;
    CREATE TABLE Ruta OF ruta_t ( nombre_ruta NOT NULL, PRIMARY KEY (nombre_ruta) ) OBJECT IDENTIFIER IS SYSTEM GENERATED;

/* -------------------------------------------- TRIGGERS -------------------------------------------- */

/* -------------------- BARCO -------------------- */

CREATE OR REPLACE TRIGGER barco_insert
    BEFORE INSERT ON Barco FOR EACH ROW
    WHEN (NEW.realiza_ruta IS NOT NULL)
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        reference_Count int;
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

CREATE OR REPLACE TRIGGER barco_delete
    AFTER UPDATE ON Barco FOR EACH ROW
    WHEN (NEW.job_id = 'SA_REP')
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE Ruta r 
        SET r.es_realizada = NULL 
        WHERE r.es_realizada = (SELECT ref(b) FROM Barco b WHERE b.nombre = :old.nombre);
        COMMIT;
    END;
/



CREATE OR REPLACE TRIGGER barco_delete
    AFTER DELETE ON Barco FOR EACH ROW
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE Ruta r 
        SET r.es_realizada = NULL 
        WHERE r.es_realizada = (SELECT ref(b) FROM Barco b WHERE b.nombre = :old.nombre);
        COMMIT;
    END;
/
/* -------------------- RUTA -------------------- */

CREATE OR REPLACE TRIGGER barco_insert
    BEFORE INSERT ON Barco FOR EACH ROW
    WHEN (NEW.realiza_ruta IS NOT NULL)
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        reference_Count int;
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


CREATE OR REPLACE TRIGGER ruta_delete
    AFTER DELETE ON Ruta FOR EACH ROW
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE Barco b 
        SET b.realiza_ruta = NULL 
        WHERE b.realiza_ruta = (SELECT ref(r) FROM Ruta r WHERE r.nombre_ruta = :old.nombre_ruta);
        COMMIT;
    END;
/

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
        INTO Ruta (nombre_ruta, regimen, es_realizada) VALUES 
                ('2 Noches - Andalucia', 'Todo Incluido',
                ( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque SOVEREIGN' ) )
        INTO Ruta (nombre_ruta, regimen, es_realizada) VALUES 
                ('2 Noches - Barcelona', 'Todo Incluido',
                ( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque ZENITH-ZT' ) )
        INTO Ruta (nombre_ruta, regimen, es_realizada) VALUES 
                ('4 Noches - Caribe Sur  (Puerto Limon)', 'Todo Incluido',
                ( SELECT REF(oc) FROM Barco oc WHERE oc.nombre = 'Buque MONARCH') )
    SELECT * from dual;


/* -------------------------------------------- CONSULTAS -------------------------------------------- */
