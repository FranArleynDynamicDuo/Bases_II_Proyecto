/* -------------------------------------------- CONFIGURACION -------------------------------------------- */
    SET AUTOCOMMIT ON;
/* -------------------------------------------- BORRADO -------------------------------------------- */
    /* Borramos los tipos y tablas para empezar desde 0 */
    DROP TYPE barco_t FORCE;
    DROP TYPE ruta_t FORCE;
    DROP TABLE Barco CASCADE CONSTRAINTS;                       
    DROP TABLE Ruta CASCADE CONSTRAINTS;
/* -------------------------------------------- CREACION -------------------------------------------- */
    /* Creamos el tipo Barco */
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
    /* Creamos el tipo ruta */
    CREATE TYPE ruta_t AS Object (
        id INTEGER,
        nombre    VARCHAR(100),
        regimen        VARCHAR(50),
        es_realizada   REF barco_t
    ); 
    /  
    /* Agregamos la referencia que a ruta en barco */
    ALTER TYPE barco_t add attribute (realiza_ruta REF ruta_t) CASCADE;
<<<<<<< HEAD

    CREATE TABLE Barco OF barco_t (PRIMARY KEY (id));
    CREATE TABLE Ruta OF ruta_t (PRIMARY KEY (id));

=======
    /* Creamos Las Tablas */
    CREATE TABLE Barco OF barco_t;
    CREATE TABLE Ruta OF ruta_t;
/* -------------------------------------------- STORED PROCEDURES -------------------------------------------- */
>>>>>>> df11b01077bb96010a30f9af4e01d4104b4e5f07
/* Actualiza la referencia de la ruta al barco que la recorre */
CREATE OR REPLACE PROCEDURE actualizar_Ruta(ruta_Id IN int,barco_Ref IN REF barco_t) IS
pragma autonomous_transaction;
BEGIN
    /* Desactivo el trigger del update contrario */
    EXECUTE IMMEDIATE 'ALTER TRIGGER ruta_update_after DISABLE';
    /* Efectuo la actualizacion */
	UPDATE Ruta r
	SET    r.es_realizada = barco_Ref
	WHERE  r.id = ruta_Id;
    /* Reactivo el trigger del update contrario */
    EXECUTE IMMEDIATE 'ALTER TRIGGER ruta_update_after ENABLE';
    COMMIT;
END;
/
/* Actualiza la referencia del barco a la ruta que recorre */
CREATE OR REPLACE PROCEDURE actualizar_Barco(barco_Id IN int,ruta_Ref IN REF ruta_t) IS
pragma autonomous_transaction;
BEGIN
    /* Desactivo el trigger del update contrario */
    EXECUTE IMMEDIATE 'ALTER TRIGGER barco_update_not_null DISABLE';
    /* Efectuo la actualizacion */
	UPDATE Barco b
	SET    b.realiza_ruta = ruta_Ref
	WHERE  b.id = barco_Id;
    /* Reactivo el trigger del update contrario */
    EXECUTE IMMEDIATE 'ALTER TRIGGER barco_update_not_null ENABLE';
    COMMIT;
END;
/
/* -------------------------------------------- TRIGGERS -------------------------------------------- */
/* -------------------- BARCO -------------------- */
/* INSERT */
CREATE OR REPLACE TRIGGER barco_insert_after
    AFTER INSERT ON Barco FOR EACH ROW
    WHEN (NEW.realiza_ruta IS NOT NULL)
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        tmp_int int;
        ruta_tmp ruta_t;
        ref_tmp REF barco_t;
    BEGIN   
        /* Obtnego la ruta que quiero que realice el barco */
        SELECT DEREF(:NEW.realiza_ruta) INTO ruta_tmp FROM DUAL;
        /* Si la ruta anterior tenia un barco asociado debo liberarlo */
        IF(ruta_tmp.es_realizada IS NOT NULL) THEN
            SELECT b.id INTO tmp_int
            FROM Barco b
            WHERE REF(b) = ruta_tmp.es_realizada;
            /* Libero el barco */
            UPDATE Barco
            SET realiza_ruta = NULL
            WHERE id =tmp_int ;         
        END IF;
        /* Obtengo la referncia a la ruta deseada */
        SELECT make_ref(Barco,:new.object_id) INTO  ref_tmp FROM DUAL;
        /* Asocio el nuevo barco a la ruta deseada */
        actualizar_Ruta(ruta_tmp.id,ref_tmp);
        COMMIT;
    END;
/
/* UPDATE */
CREATE OR REPLACE TRIGGER barco_update_not_null
    AFTER UPDATE OF realiza_ruta ON Barco FOR EACH ROW
    WHEN ((NEW.realiza_ruta IS NULL AND OLD.realiza_ruta IS NOT NULL) 
        OR (NEW.realiza_ruta IS NOT NULL AND NEW.realiza_ruta != OLD.realiza_ruta))
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        tmp_int int;
        ruta_tmp ruta_t;
        ref_tmp REF barco_t;
    BEGIN
        /* Obtengo la ruta a la cual estaba asociada anteriormente el barco deseado */
        SELECT DEREF(:OLD.realiza_ruta) INTO ruta_tmp FROM DUAL;
        /* Anulo la asociacion que tenia esa ruta al barco deseado */
        actualizar_Ruta(ruta_tmp.id,NULL);
        /* Si hay ruta nueva la actualizo */
        IF(:NEW.realiza_ruta IS NOT NULL) THEN
            /* Obtengo la ruta que realizara el barco deseado deseada */
            SELECT DEREF(:NEW.realiza_ruta) INTO ruta_tmp FROM DUAL; 
            /* Obtengo la ruta anterior que realizaba ese barco si la tiene */
            IF (ruta_tmp.es_realizada IS NOT NULL) THEN
                SELECT b.id INTO tmp_int
                FROM Barco b
                WHERE REF(b) = ruta_tmp.es_realizada;
                /* Libero el barco */
                UPDATE Barco
                SET realiza_ruta = NULL
                WHERE id =tmp_int ;
            END IF;
            /* Obtengo la referncia a la ruta deseada */
            SELECT make_ref(Barco,:new.object_id) INTO  ref_tmp FROM DUAL;
            /* Asocio el nuevo barco a la ruta deseada */
            actualizar_Ruta(ruta_tmp.id,ref_tmp);
        END IF;
        COMMIT;
    END;
/
/* DELETE */
CREATE OR REPLACE TRIGGER barco_delete
    AFTER DELETE ON Barco FOR EACH ROW
    WHEN (OLD.realiza_ruta IS NOT NULL)
        DECLARE
        ruta_tmp ruta_t;
    BEGIN  
        /* Busco la ruta asociada al barco que se va a eliminar */
        SELECT DEREF(:OLD.realiza_ruta) INTO ruta_tmp FROM DUAL;
        /* Libero a la ruta antigua */
        actualizar_Ruta(ruta_tmp.id,NULL);
    END;
/
/* -------------------- RUTA -------------------- */
/* INSERT */
CREATE OR REPLACE TRIGGER ruta_insert_after
    AFTER INSERT ON Ruta FOR EACH ROW
    WHEN (NEW.es_realizada IS NOT NULL)
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        tmp_int int;
        barco_tmp barco_t;
        ref_tmp REF ruta_t;
    BEGIN   
        /* Obtengo obtengo el barco que quiero asociar a la ruta insertada */
        SELECT DEREF(:NEW.es_realizada) INTO barco_tmp FROM DUAL;
        /* Si el barco deseado tenia una ruta asociada debemos liberarla */ 
        IF(barco_tmp.realiza_ruta IS NOT NULL) THEN
            SELECT r.id INTO tmp_int
            FROM Ruta r
            WHERE REF(r) = barco_tmp.realiza_ruta;
            /* Libero la ruta */
            UPDATE Ruta
            SET es_realizada = NULL
            WHERE id =tmp_int;          
        END IF;
        /* Obtengo la referencia a la ruta insertada */
        SELECT make_ref(Ruta,:new.object_id) INTO  ref_tmp FROM DUAL;
        /* Asocio el nuevo barco a la ruta insertada */
        actualizar_Barco(barco_tmp.id,ref_tmp);
        COMMIT;
    END;
/
/* UPDATE */
CREATE OR REPLACE TRIGGER ruta_update_after
    AFTER UPDATE ON Ruta FOR EACH ROW
    WHEN ((NEW.es_realizada IS NULL AND OLD.es_realizada IS NOT NULL) 
        OR (NEW.es_realizada IS NOT NULL AND NEW.es_realizada != OLD.es_realizada))
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        tmp_int int;
        barco_tmp barco_t;
        ref_tmp REF ruta_t;
    BEGIN
        /* Obtengo el barco al cual estaba asociado anteriormente la ruta deseada */
        SELECT DEREF(:OLD.es_realizada) INTO barco_tmp FROM DUAL;
        /* Anulo la asociacion que tenia ese barco a la ruta deseada */
        actualizar_Barco(barco_tmp.id,NULL);
        /* Si hay barco nuevo la actualizo */
        IF(:NEW.es_realizada IS NOT NULL) THEN
            /* Obtengo el barco por el cual sera realizada la ruta deseada */
            SELECT DEREF(:NEW.es_realizada) INTO barco_tmp FROM DUAL; 
            /* Obtengo la ruta anterior que realizaba ese barco si la tiene */      
            IF (barco_tmp.realiza_ruta IS NOT NULL) THEN
                SELECT r.id INTO tmp_int
                FROM Ruta r
                WHERE REF(r) = barco_tmp.realiza_ruta;
                /* Libero la ruta */
                UPDATE Ruta
                SET es_realizada = NULL
                WHERE id =tmp_int;
            END IF;
            /* Obtengo la referncia a la ruta deseada */
            SELECT make_ref(Ruta,:new.object_id) INTO  ref_tmp FROM DUAL;
            /* Asocio el nuevo barco a la ruta deseada */
            actualizar_Barco(barco_tmp.id,ref_tmp);
        END IF;
        COMMIT;
    END;
/
/* DELETE */
CREATE OR REPLACE TRIGGER ruta_delete
    AFTER DELETE ON Ruta FOR EACH ROW
    WHEN (OLD.es_realizada IS NOT NULL)
    DECLARE
        barco_tmp barco_t;
    BEGIN 
        /* Busco el barco asociado a la ruta que se va a eliminar */
        SELECT DEREF(:OLD.es_realizada) INTO barco_tmp FROM DUAL;
        /* Libero el barco antiguo */
        actualizar_Barco(barco_tmp.id,NULL);
    END;
/
ALTER TABLE Barco ENABLE ALL TRIGGERS;
ALTER TABLE Ruta ENABLE ALL TRIGGERS;
/* -------------------------------------------- PRUEBAS INSERT -------------------------------------------- */
    /* PODEMOS CREAR BARCOS SIN RUTAS ASIGNADAS */
    INSERT ALL 
        INTO Barco (id,nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora,realiza_ruta) VALUES
                    (1,'Buque ZENITH-ZT', 1442, 720, 10, 46811, 208,NULL)
        INTO Barco (id,nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora,realiza_ruta) VALUES
                    (2,'Buque MONARCH', 2766, 1193, 12, 73937, 268,NULL)
        INTO Barco (id,nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora,realiza_ruta) VALUES
                    (3,'Buque SOVEREIGN', 2733, 1162, 12, 73592, 268,NULL)
    SELECT * from dual;
    /* AL CREAR UNA RUTA CON BARCO ASIGNADO, SE ACTUALIZAN LAS REFERENCIAS EN LOS BARCOS CORRESPONDIENTES */
    INSERT ALL
        INTO Ruta (id,nombre, regimen, es_realizada) VALUES 
                (1,'2 Noches - Andalucia', 'Todo Incluido',
                ( SELECT REF(oc) FROM Barco oc WHERE oc.id = 1 ) )
        INTO Ruta (id,nombre, regimen, es_realizada) VALUES 
                (2,'2 Noches - Barcelona', 'Todo Incluido',
                ( SELECT REF(oc) FROM Barco oc WHERE oc.id = 2 ) )
        INTO Ruta (id,nombre, regimen, es_realizada) VALUES 
                (3,'4 Noches - Caribe Sur  (Puerto Limon)', 'Todo Incluido',
                ( SELECT REF(oc) FROM Barco oc WHERE oc.id = 3) )
    SELECT * from dual;
   
 /* PODEMOS CREAR RUTAS SIN BARCO ASIGNADO */
    INSERT INTO Ruta (id,nombre, regimen, es_realizada) VALUES 
        (4,'2 Noches - Venezuela', 'Todo Incluido',NULL );
    /* AL CREAR BARCOS CON RUTAS ASIGNADAS LAS REFERENCIAS DE LAS RUTAS A LOS BARCOS SE ACTUALIZA */
    INSERT INTO Barco (id,nombre, capacidad, nro_cabinas, nro_cubiertas, tonelaje, eslora,realiza_ruta) VALUES
                        (4,'Buque GOVERNANT', 2733, 1162, 12, 73592, 268,
                        (SELECT REF(oc) FROM Ruta oc WHERE oc.id = 4 ));

/* -------------------------------------------- PRUEBAS UPDATE -------------------------------------------- */
    /* Anulando una asociacion de ruta a barco */
    UPDATE Ruta
    SET es_realizada = NULL
    WHERE id = 2;
    /* Mostramos el estado de las tablas para verificar el efecto de la operacion */
    SELECT id, nombre, b.realiza_ruta.id, b.realiza_ruta.nombre
    FROM Barco b;
    SELECT id, nombre, r.es_realizada.id, r.es_realizada.nombre
    FROM Ruta r;

    /* Cambiando el barco de una ruta por otro barco */
    UPDATE Ruta
    SET es_realizada = (SELECT REF(oc) FROM Barco oc WHERE oc.id = 3)
    WHERE id = 4;
    /* Mostramos el estado de las tablas para verificar el efecto de la operacion */
    SELECT id, nombre, b.realiza_ruta.id, b.realiza_ruta.nombre
    FROM Barco b;
    SELECT id, nombre, r.es_realizada.id, r.es_realizada.nombre
    FROM Ruta r;

    /* Anulando una asociacion de barco a ruta */
    UPDATE Barco
    SET realiza_ruta = NULL
    WHERE id = 1;
    /* Mostramos el estado de las tablas para verificar el efecto de la operacion */
    SELECT id, nombre, b.realiza_ruta.id, b.realiza_ruta.nombre
    FROM Barco b;
    SELECT id, nombre, r.es_realizada.id, r.es_realizada.nombre
    FROM Ruta r;

    /* Cambiando la ruta de un barco por otra */
    UPDATE Barco
    SET realiza_ruta = (SELECT REF(oc) FROM Ruta oc WHERE oc.id = 3)
    WHERE id = 2;
    /* Mostramos el estado de las tablas para verificar el efecto de la operacion */
    SELECT id, nombre, b.realiza_ruta.id, b.realiza_ruta.nombre
    FROM Barco b;
    SELECT id, nombre, r.es_realizada.id, r.es_realizada.nombre
    FROM Ruta r;

/* -------------------------------------------- PRUEBAS DELETE -------------------------------------------- */
    /* Eliminando un barco */
    DELETE FROM Barco
    WHERE id=4;
    /* Mostramos el estado de las tablas para verificar el efecto de la operacion */
    SELECT id, nombre, b.realiza_ruta.id, b.realiza_ruta.nombre
    FROM Barco b;
    SELECT id, nombre, r.es_realizada.id, r.es_realizada.nombre
    FROM Ruta r;

    /* Eliminando una ruta */
    DELETE FROM Ruta
    WHERE id=1;
    /* Mostramos el estado de las tablas para verificar el efecto de la operacion */
    SELECT id, nombre, b.realiza_ruta.id, b.realiza_ruta.nombre
    FROM Barco b;
    SELECT id, nombre, r.es_realizada.id, r.es_realizada.nombre
    FROM Ruta r;

/* -------------------------------------------- CONSULTAS -------------------------------------------- */
