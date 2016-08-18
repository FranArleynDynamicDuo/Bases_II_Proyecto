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

    CREATE TABLE Barco OF barco_t;
    CREATE TABLE Ruta OF ruta_t;

/* -------------------------------------------- TRIGGERS -------------------------------------------- */

/* -------------------- BARCO -------------------- */
/* INSERT */
/* En caso de que insertemos una nueva ruta con barco asignado, debemos 
asignarle la ruta al nuevo barco */
CREATE OR REPLACE TRIGGER barco_insert_after
    AFTER INSERT ON Barco FOR EACH ROW
    WHEN (NEW.realiza_ruta IS NOT NULL)
    BEGIN
        /* Si el barco deseado tenia una ruta asignada, libero esa ruta  */
        /* Actualizo el barco con su nueva ruta */
        UPDATE Ruta r 
        SET r.es_realizada = make_ref(Barco,:new.object_id)
        WHERE REF(r) = :NEW.realiza_ruta;   
    END;
/
/* UPDATE */
CREATE OR REPLACE TRIGGER barco_update_not_null
    AFTER UPDATE OF realiza_ruta ON Barco FOR EACH ROW
    WHEN (NEW.realiza_ruta IS NOT NULL AND NEW.realiza_ruta != OLD.realiza_ruta)
    BEGIN
        /* Libero la ruta antigua  */
        UPDATE Ruta r 
        SET r.es_realizada = NULL
        WHERE REF(r) = :OLD.realiza_ruta;
        /* */
        UPDATE Ruta r
        SET r.es_realizada = make_ref(Barco,:new.object_id)
        WHERE REF(r) = :NEW.realiza_ruta;
    END;
/

CREATE OR REPLACE TRIGGER barco_update_null
    AFTER UPDATE OF realiza_ruta ON Barco FOR EACH ROW
    WHEN (NEW.realiza_ruta IS NULL)
    BEGIN
        /* Libero la ruta antigua  */
        UPDATE Ruta r 
        SET r.es_realizada = NULL
        WHERE REF(r) = :OLD.realiza_ruta;
    END;
/

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
    BEGIN
        /* Si el barco deseado tenia una ruta asignada, libero esa ruta  */
        /* Actualizo el barco con su nueva ruta */
        UPDATE Barco b 
        SET b.realiza_ruta= make_ref(Ruta, :NEW.object_id)
        WHERE REF(b) = :NEW.es_realizada;   
    END;
/

/* UPDATE */

/* En Caso de que cambiemos el barco de una ruta debemos dejar a la ruta que estaba asignada anteriormente
sin barco y actualizar la ruta del barco asignado */
CREATE OR REPLACE TRIGGER ruta_update_after
    AFTER UPDATE ON Ruta FOR EACH ROW
    WHEN (NEW.es_realizada IS NOT NULL AND NEW.es_realizada != OLD.es_realizada)
    BEGIN
        /* Libero la ruta antigua  */
        UPDATE Barco b 
        SET b.realiza_ruta = NULL
        WHERE REF(b) = :OLD.es_realizada;
        /* */
        UPDATE Barco b
        SET b.realiza_ruta = make_ref(Ruta,:new.object_id)
        WHERE REF(b) = :NEW.es_realizada;
    END;
/

CREATE OR REPLACE TRIGGER ruta_update_after_null
    AFTER UPDATE ON Ruta FOR EACH ROW
    WHEN (NEW.es_realizada IS NULL)
    BEGIN
        /* Libero la ruta antigua  */
        UPDATE Barco b 
        SET b.realiza_ruta = NULL
        WHERE REF(b) = :OLD.es_realizada;
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
