    SET AUTOCOMMIT ON;
    SET SERVEROUTPUT ON;

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

    CREATE TABLE Barco OF barco_t (PRIMARY KEY (id));
    CREATE TABLE Ruta OF ruta_t (PRIMARY KEY (id));

/* Actualiza la referencia de la ruta al barco que la recorre */
CREATE OR REPLACE PROCEDURE actualizar_Ruta(ruta_Id IN int,barco_Ref IN REF barco_t) IS
pragma autonomous_transaction;
        tmp_int int;
BEGIN
    /* Desactivo el trigger del update contrario */
    EXECUTE IMMEDIATE 'ALTER TRIGGER ruta_update_after DISABLE';
    DBMS_OUTPUT.PUT_LINE('------------> actualizar_Ruta con: ');
    DBMS_OUTPUT.PUT_LINE('------------> ruta_Id=' || ruta_Id);
    /* Revision del estado actual de las tablas */
    SELECT COUNT(*) INTO tmp_int FROM RUTA;
    DBMS_OUTPUT.PUT_LINE('------------> Se encontraron rutas ---> ' || tmp_int);
    SELECT COUNT(*) INTO tmp_int FROM Barco;
    DBMS_OUTPUT.PUT_LINE('------------> Se encontraron barcos ---> ' || tmp_int);
    /* Efectuo la actualizacion */
	UPDATE Ruta r
	SET    r.es_realizada = barco_Ref
	WHERE  r.id = ruta_Id;
    /* Reactivo el trigger del update contrario */
    EXECUTE IMMEDIATE 'ALTER TRIGGER ruta_update_after ENABLE';
END;
/
CREATE OR REPLACE PROCEDURE actualizar_Ruta_Por_Ref(ruta_Ref IN REF ruta_t,barco_Ref IN REF barco_t) IS
pragma autonomous_transaction;
        tmp_int int;
        tmp_barco barco_t;
        tmp_ruta ruta_t;
BEGIN
    /* Desactivo el trigger del update contrario */
    DBMS_OUTPUT.PUT_LINE('------------> DESHABILITAR TRIGGER: ');
    EXECUTE IMMEDIATE 'ALTER TRIGGER ruta_update_after DISABLE';
    DBMS_OUTPUT.PUT_LINE('------------> DEREF ');
    -- SELECT DEREF(ruta_Ref) INTO tmp_ruta FROM DUAL;
    DBMS_OUTPUT.PUT_LINE('------------> actualizar_Ruta');
    /* Revision del estado actual de las tablas */
    SELECT COUNT(*) INTO tmp_int FROM RUTA;
    DBMS_OUTPUT.PUT_LINE('------------> Se encontraron rutas ---> ' || tmp_int);
    SELECT COUNT(*) INTO tmp_int FROM Barco;
    DBMS_OUTPUT.PUT_LINE('------------> Se encontraron barcos ---> ' || tmp_int);
    /* Efectuo la actualizacion */
	UPDATE Ruta r
	SET    r.es_realizada = barco_Ref
	WHERE  REF(r) = ruta_Ref;
    /* Reactivo el trigger del update contrario */
    EXECUTE IMMEDIATE 'ALTER TRIGGER ruta_update_after ENABLE';
END;
/
/* Actualiza la referencia del barco a la ruta que recorre */
CREATE OR REPLACE PROCEDURE actualizar_Barco(barco_Id IN int,ruta_Ref IN REF ruta_t) IS
pragma autonomous_transaction;
        tmp_int int;
BEGIN
    /* Desactivo el trigger del update contrario */
    EXECUTE IMMEDIATE 'ALTER TRIGGER barco_update_not_null DISABLE';
    DBMS_OUTPUT.PUT_LINE('------------> actualizar_Barco');
    DBMS_OUTPUT.PUT_LINE('------------> barco_Id= ' || barco_Id);
    /* Revision del estado actual de las tablas */
    SELECT COUNT(*) INTO tmp_int FROM RUTA;
    DBMS_OUTPUT.PUT_LINE('------------> Se encontraron rutas ---> ' || tmp_int);
    SELECT COUNT(*) INTO tmp_int FROM Barco;
    DBMS_OUTPUT.PUT_LINE('------------> Se encontraron barcos ---> ' || tmp_int);
    /* Efectuo la actualizacion */
	UPDATE Barco b
	SET    b.realiza_ruta = ruta_Ref
	WHERE  b.id = barco_Id;
    /* Reactivo el trigger del update contrario */
    EXECUTE IMMEDIATE 'ALTER TRIGGER barco_update_not_null ENABLE';
END;
/

CREATE OR REPLACE PROCEDURE actualizar_Barco_Por_Ref(barco_Ref IN REF barco_t,ruta_Ref IN REF ruta_t) IS
pragma autonomous_transaction;
        tmp_int int;
        tmp_barco barco_t;
        tmp_ruta ruta_t;
BEGIN
    /* Desactivo el trigger del update contrario */
    EXECUTE IMMEDIATE 'ALTER TRIGGER barco_update_not_null DISABLE';
    SELECT DEREF(barco_Ref) INTO tmp_barco FROM DUAL;
    DBMS_OUTPUT.PUT_LINE('------------> actualizar_Barco');
    DBMS_OUTPUT.PUT_LINE('------------> barco_Id= ' || tmp_barco.id);
    /* Revision del estado actual de las tablas */
    SELECT COUNT(*) INTO tmp_int FROM RUTA;
    DBMS_OUTPUT.PUT_LINE('------------> Se encontraron rutas ---> ' || tmp_int);
    SELECT COUNT(*) INTO tmp_int FROM Barco;
    DBMS_OUTPUT.PUT_LINE('------------> Se encontraron barcos ---> ' || tmp_int);
    /* Efectuo la actualizacion */
	UPDATE Barco b
	SET    b.realiza_ruta = ruta_Ref
	WHERE  b.id = tmp_barco.id;
    /* Reactivo el trigger del update contrario */
    EXECUTE IMMEDIATE 'ALTER TRIGGER barco_update_not_null ENABLE';
END;
/

/* -------------------------------------------- TRIGGERS -------------------------------------------- */

/* -------------------- BARCO -------------------- */
/* INSERT */
CREATE OR REPLACE TRIGGER barco_insert_after
    AFTER INSERT ON Barco FOR EACH ROW
    WHEN (NEW.realiza_ruta IS NOT NULL)
    DECLARE
        tmp varchar(200);
        tmp_int int;
        barco_tmp barco_t;
        ruta_tmp ruta_t;
        ref_tmp REF barco_t;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('---> barco_insert_after');    
        /* Obtnego la ruta que quiero que realice el barco */
        SELECT DEREF(:NEW.realiza_ruta) INTO ruta_tmp FROM DUAL;
        /*
            AQUI ESTA EL PROBLEMA, SI TRATO DE HACER EL DEREF FUERA DEL PROCEDIMIENTO
            ME DA TABLA MUTANTE, TRATE DE HACER EL DEREF DENTRO DEL PROCEDIMIENTO Y 
            SE QUEDA TRANCADO
        */
        /* Si la ruta anterior tenia un barco asociado debo liberarlo */
        IF(ruta_tmp.es_realizada IS NOT NULL) THEN
            DBMS_OUTPUT.PUT_LINE('---> MORI EN LA LLAMADA 1');
            actualizar_Barco_Por_Ref(ruta_tmp.es_realizada,NULL);           
        END IF;
        /* Obtengo la referncia a la ruta deseada */
        SELECT make_ref(Barco,:new.object_id) INTO  ref_tmp FROM DUAL;
        /* Asocio el nuevo barco a la ruta deseada */
        actualizar_Ruta(ruta_tmp.id,ref_tmp);
    END;
/
/* UPDATE */
CREATE OR REPLACE TRIGGER barco_update_not_null
    AFTER UPDATE OF realiza_ruta ON Barco FOR EACH ROW
    WHEN ((NEW.realiza_ruta IS NULL AND OLD.realiza_ruta IS NOT NULL) 
        OR (NEW.realiza_ruta IS NOT NULL AND NEW.realiza_ruta != OLD.realiza_ruta))
    DECLARE
        tmp varchar(200);
        tmp_int int;
        barco_tmp barco_t;
        ruta_tmp ruta_t;
        ref_tmp REF barco_t;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('---> ruta_update_after');
        /* Revision del estado actual de las tablas */
        SELECT COUNT(*) INTO tmp_int FROM RUTA;
        DBMS_OUTPUT.PUT_LINE('---> Se encontraron Rutas ---> ' || tmp_int);
        /* Revision de OLD y NEW */
        SELECT deref(:NEW.realiza_ruta) INTO ruta_tmp FROM dual;
        DBMS_OUTPUT.PUT_LINE('---> deref(:NEW.realiza_ruta) ---> ' || ruta_tmp.id);
        SELECT deref(:old.realiza_ruta) INTO ruta_tmp FROM dual;
        DBMS_OUTPUT.PUT_LINE('---> deref(:old.realiza_ruta) ---> ' || ruta_tmp.id);
        /* Obtengo la ruta a la cual estaba asociada anteriormente el barco deseado */
        SELECT DEREF(:OLD.realiza_ruta) INTO ruta_tmp FROM DUAL;
        /* Anulo la asociacion que tenia esa ruta al barco deseado */
        DBMS_OUTPUT.PUT_LINE('---> Libero a la ruta antigua');
        actualizar_Ruta(ruta_tmp.id,NULL);
        /* Si hay ruta nueva la actualizo */
        IF(:NEW.realiza_ruta IS NOT NULL) THEN
            /* Obtengo la ruta que realizara el barco deseado deseada */
            SELECT DEREF(:NEW.realiza_ruta) INTO ruta_tmp FROM DUAL; 
            /* Obtengo la ruta anterior que realizaba ese barco si la tiene */
            /*
                AQUI ESTA EL PROBLEMA, SI TRATO DE HACER EL DEREF FUERA DEL PROCEDIMIENTO
                ME DA TABLA MUTANTE, TRATE DE HACER EL DEREF DENTRO DEL PROCEDIMIENTO Y 
                SE QUEDA TRANCADO
            */
            /*
            IF (ruta_tmp.es_realizada IS NOT NULL) THEN
                DBMS_OUTPUT.PUT_LINE('---> MORI EN LA LLAMADA 1');
                actualizar_Barco_Por_Ref(ruta_tmp.es_realizada,NULL);
            END IF;
            */
            /* Anulo la referencia de la ruta a su barco antiguo */
            actualizar_Ruta(ruta_tmp.id,NULL);
            /* Obtengo la referncia a la ruta deseada */
            SELECT make_ref(Barco,:new.object_id) INTO  ref_tmp FROM DUAL;
            /* Asocio el nuevo barco a la ruta deseada */
            actualizar_Ruta(ruta_tmp.id,ref_tmp);
        END IF;
    END;
/


/* DELETE */
CREATE OR REPLACE TRIGGER barco_delete
    AFTER DELETE ON Barco FOR EACH ROW
    WHEN (OLD.realiza_ruta IS NOT NULL)
        DECLARE
        ruta_tmp ruta_t;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('---> barco_delete');   
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
        tmp varchar(200);
        tmp_int int;
        barco_tmp barco_t;
        ruta_tmp ruta_t;
        ref_tmp REF ruta_t;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('---> ruta_insert_after');    
        /* Obtengo obtengo el barco que quiero asociar a la ruta insertada */
        SELECT DEREF(:NEW.es_realizada) INTO barco_tmp FROM DUAL;
        /*
            AQUI ESTA EL PROBLEMA, SI TRATO DE HACER EL DEREF FUERA DEL PROCEDIMIENTO
            ME DA TABLA MUTANTE, TRATE DE HACER EL DEREF DENTRO DEL PROCEDIMIENTO Y 
            SE QUEDA TRANCADO
        */
        /* Si el barco deseado tenia una ruta asociada debemos liberarla */
        IF(barco_tmp.realiza_ruta IS NOT NULL) THEN
            DBMS_OUTPUT.PUT_LINE('---> MORI EN LA LLAMADA 1');
            actualizar_Ruta_Por_Ref(barco_tmp.realiza_ruta,NULL);           
        END IF;
        /* Obtengo la referencia a la ruta insertada */
        SELECT make_ref(Ruta,:new.object_id) INTO  ref_tmp FROM DUAL;
        /* Asocio el nuevo barco a la ruta insertada */
        actualizar_Barco(barco_tmp.id,ref_tmp);
    END;
/

/* UPDATE */
CREATE OR REPLACE TRIGGER ruta_update_after
    AFTER UPDATE ON Ruta FOR EACH ROW
    WHEN ((NEW.es_realizada IS NULL AND OLD.es_realizada IS NOT NULL) 
        OR (NEW.es_realizada IS NOT NULL AND NEW.es_realizada != OLD.es_realizada))
    DECLARE
        tmp varchar(200);
        tmp_int int;
        barco_tmp barco_t;
        ruta_tmp ruta_t;
        ref_tmp REF ruta_t;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('---> ruta_update_after');
        /* Revision del estado actual de las tablas */
        SELECT COUNT(*) INTO tmp_int FROM BARCO;
        DBMS_OUTPUT.PUT_LINE('---> Se encontraron barcos ---> ' || tmp_int);
        /* Revision de OLD y NEW */
        SELECT deref(:NEW.es_realizada) INTO barco_tmp FROM dual;
        DBMS_OUTPUT.PUT_LINE('---> deref(:NEW.es_realizada) ---> ' || barco_tmp.id);
        SELECT deref(:old.es_realizada) INTO barco_tmp FROM dual;
        DBMS_OUTPUT.PUT_LINE('---> deref(:old.es_realizada) ---> ' || barco_tmp.id);
        /* Obtengo el barco al cual estaba asociado anteriormente la ruta deseada */
        SELECT DEREF(:OLD.es_realizada) INTO barco_tmp FROM DUAL;
        /* Anulo la asociacion que tenia ese barco a la ruta deseada */
        DBMS_OUTPUT.PUT_LINE('---> Libero al barco antiguo');
        actualizar_Barco(barco_tmp.id,NULL);
        /* Si hay barco nuevo la actualizo */
        IF(:NEW.es_realizada IS NOT NULL) THEN
            /* Obtengo el barco por el cual sera realizada la ruta deseada */
            SELECT DEREF(:NEW.es_realizada) INTO barco_tmp FROM DUAL; 
            /* Obtengo la ruta anterior que realizaba ese barco si la tiene */
            /*
                AQUI ESTA EL PROBLEMA, SI TRATO DE HACER EL DEREF FUERA DEL PROCEDIMIENTO
                ME DA TABLA MUTANTE, TRATE DE HACER EL DEREF DENTRO DEL PROCEDIMIENTO Y 
                SE QUEDA TRANCADO
            */
            /*
            IF (barco_tmp.realiza_ruta IS NOT NULL) THEN
                DBMS_OUTPUT.PUT_LINE('---> MORI EN LA LLAMADA 1');
                actualizar_Ruta_Por_Ref(barco_tmp.realiza_ruta,NULL);
            END IF;
            */
            /* Anulo la referencia del barco a su ruta antigua */
            actualizar_Barco(barco_tmp.id,NULL);
            /* Obtengo la referncia a la ruta deseada */
            SELECT make_ref(Ruta,:new.object_id) INTO  ref_tmp FROM DUAL;
            /* Asocio el nuevo barco a la ruta deseada */
            actualizar_Barco(barco_tmp.id,ref_tmp);
        END IF;
    END;
/


/* DELETE */
CREATE OR REPLACE TRIGGER ruta_delete
    AFTER DELETE ON Ruta FOR EACH ROW
    WHEN (OLD.es_realizada IS NOT NULL)
    DECLARE
        barco_tmp barco_t;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('---> ruta_delete');   
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
/*
    UPDATE Ruta
    SET es_realizada = NULL
    WHERE id = 2;

    UPDATE Ruta
    SET es_realizada = (SELECT REF(oc) FROM Barco oc WHERE oc.id = 3)
    WHERE id = 4;

    UPDATE Barco
    SET realiza_ruta = NULL
    WHERE id = 1;

    UPDATE Barco
    SET realiza_ruta = (SELECT REF(oc) FROM Ruta oc WHERE oc.id = 3)
    WHERE id = 2;
    */

/* -------------------------------------------- PRUEBAS DELETE -------------------------------------------- */

    DELETE FROM Barco
    WHERE id=4;

    DELETE FROM Ruta
    WHERE id=1;

/* -------------------------------------------- CONSULTAS -------------------------------------------- */
