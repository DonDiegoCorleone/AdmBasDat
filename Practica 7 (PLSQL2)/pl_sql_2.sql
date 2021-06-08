--a
CREATE TABLE NUEVO_INGRESO 
   (	"DOCUMENTO" VARCHAR2(20 BYTE), 
	"EXPEDIENTE" VARCHAR2(100 BYTE), 
	"ARCHIVO" VARCHAR2(100 BYTE), 
	"ASIG_INGLES" VARCHAR2(200 BYTE)
   );

--b
CREATE TABLE ERRORES
(FECHA DATE,
motivo varchar2(100),
CODIGO_ASIGNATURA VARCHAR2(20 BYTE),
CURSO_ACADEMICO VARCHAR2(10 BYTE),
GRUPO VARCHAR2(10 BYTE),
INGLES VARCHAR2(4 BYTE),
EXPEDIENTE NUMBER,
TITULACION NUMBER);

--c
ALTER TABLE GRUPOS_POR_ASIGNATURA ADD (NUM_ALUMNOS NUMBER, NUM_REAL NUMBER);

--d
update GRUPOS_POR_ASIGNATURA set
    num_alumnos = 0,
    num_real =0;

commit;

create or replace trigger control_asignatura_matricula after insert or
delete or update on ASIGNATURAS_MATRICULA
for each row 
declare
vpadre varchar2(20);
vcodigo_asig number;
vcodigo_titu number;
vreferencia_asig varchar2(20);
voldpadre varchar2(20);
voldcodigo_asig number;
voldcodigo_titu number;
voldreferencia_asig varchar2(20);

cursor cgrupo_asignatura is select num_alumnos,num_real,asignatura_referencia,grupo_id from GRUPOS_POR_ASIGNATURA for update ;
begin
    if (inserting and :new.grupo_id IS NOT NULL) then 
        select grupo_id into vpadre from grupo where ID =:new.grupo_id and titulacion_codigo = to_number(substr(TO_CHAR(:new.MATRICULA_EXPEDIENTES_NEXP),1,4));
            UPDATE GRUPOS_POR_ASIGNATURA
                SET 
                    num_alumnos= num_alumnos+1,
                    num_real= num_real+1
            WHERE grupo_id =:new.grupo_id and asignatura_referencia =:new.asignatura_referencia;
            if vpadre is not null then
                select titulacion_codigo into vcodigo_titu from grupo where id = vpadre;
                select codigo into vcodigo_asig from asignatura where referencia = :new.asignatura_referencia;
                select referencia into vreferencia_asig from asignatura where titulacion_codigo=vcodigo_titu and codigo=vcodigo_asig;
                    UPDATE GRUPOS_POR_ASIGNATURA
                        SET num_real= num_real+1
                    WHERE grupo_id = vpadre and asignatura_referencia = vreferencia_asig;
            end if;
    end if;
    if (deleting and :old.grupo_id is not null) then
        select grupo_id into vpadre from grupo where ID =:old.grupo_id and titulacion_codigo = to_number(substr(TO_CHAR(:old.MATRICULA_EXPEDIENTES_NEXP),1,4));
            UPDATE GRUPOS_POR_ASIGNATURA
                SET 
                    num_alumnos= num_alumnos-1,
                    num_real= num_real-1
            where grupo_id =:old.grupo_id and asignatura_referencia =:old.asignatura_referencia;
            if vpadre is not null then
                select titulacion_codigo into vcodigo_titu from grupo where id = vpadre;
                select codigo into vcodigo_asig from asignatura where referencia = :old.asignatura_referencia;
                select referencia into vreferencia_asig from asignatura where titulacion_codigo=vcodigo_titu and codigo=vcodigo_asig;
                update grupos_por_asignatura
                    set num_real = num_real-1
                where grupo_id = vpadre and asignatura_referencia = vreferencia_asig;
            end if;
    end if;

    if updating and :old.grupo_id is null then
        if :new.grupo_id is not null then
            select grupo_id into vpadre from grupo where ID =:new.grupo_id and titulacion_codigo = to_number(substr(TO_CHAR(:new.MATRICULA_EXPEDIENTES_NEXP),1,4));
            UPDATE GRUPOS_POR_ASIGNATURA
                SET 
                    num_alumnos= num_alumnos+1,
                    num_real= num_real+1
            WHERE grupo_id =:new.grupo_id and asignatura_referencia =:new.asignatura_referencia;
            if vpadre is not null then
                select titulacion_codigo into vcodigo_titu from grupo where id = vpadre;
                select codigo into vcodigo_asig from asignatura where referencia = :new.asignatura_referencia;
                select referencia into vreferencia_asig from asignatura where titulacion_codigo=vcodigo_titu and codigo=vcodigo_asig;
                    UPDATE GRUPOS_POR_ASIGNATURA
                        SET num_real= num_real+1
                    WHERE grupo_id = vpadre and asignatura_referencia = vreferencia_asig;
            end if;

        end if;
    end if;
    if updating and :old.grupo_id is not null then
        UPDATE GRUPOS_POR_ASIGNATURA
            SET 
                num_alumnos= num_alumnos-1,
                num_real= num_real-1
        where grupo_id =:old.grupo_id and asignatura_referencia =:old.asignatura_referencia;
        select grupo_id into voldpadre from grupo where ID =:old.grupo_id and titulacion_codigo = to_number(substr(TO_CHAR(:old.MATRICULA_EXPEDIENTES_NEXP),1,4));
        if voldpadre is not null then
            select titulacion_codigo into vcodigo_titu from grupo where id = voldpadre;
            select codigo into vcodigo_asig from asignatura where referencia = :old.asignatura_referencia;
            select referencia into vreferencia_asig from asignatura where titulacion_codigo=vcodigo_titu and codigo=vcodigo_asig;
            update grupos_por_asignatura
                set num_real = num_real-1
            where grupo_id = voldpadre and asignatura_referencia = vreferencia_asig;
        end if;
        if :new.grupo_id is not null then
            UPDATE GRUPOS_POR_ASIGNATURA
                SET 
                    num_alumnos= num_alumnos+1,
                    num_real= num_real+1
            WHERE grupo_id =:new.grupo_id and asignatura_referencia =:new.asignatura_referencia;
            select grupo_id into vpadre from grupo where ID =:new.grupo_id and titulacion_codigo = to_number(substr(TO_CHAR(:new.MATRICULA_EXPEDIENTES_NEXP),1,4));
            if vpadre is not null then
                select titulacion_codigo into vcodigo_titu from grupo where id = vpadre;
                select codigo into vcodigo_asig from asignatura where referencia = :new.asignatura_referencia;
                select referencia into vreferencia_asig from asignatura where titulacion_codigo=vcodigo_titu and codigo=vcodigo_asig;
                    UPDATE GRUPOS_POR_ASIGNATURA
                        SET num_real= num_real+1
                    WHERE grupo_id = vpadre and asignatura_referencia = vreferencia_asig;
            end if;
        end if;
    end if;
end control_asignatura_matricula;
/

--e
create or replace PACKAGE PK_ASIGNACION_GRUPOS as
PROCEDURE PR_ASIGNA_ASIGNADOS;
END PK_ASIGNACION_GRUPOS;
/
create or replace PACKAGE BODY PK_ASIGNACION_GRUPOS AS
PROCEDURE PR_ASIGNA_ASIGNADOS IS

CURSOR c_nuevo_ingreso IS SELECT A.GRUPOS_ASIGNADOS,A.NEXPEDIENTE FROM ALUMNOS_EXT A 
JOIN NUEVO_INGRESO P ON A.DOCUMENTO=P.DOCUMENTO
where regexp_like (A.GRUPOS_ASIGNADOS,'[A-Z]');

CURSOR c_asignaturas IS SELECT CODIGO,GRUPO FROM TEMP_ASIGNATURAS;

TITULACION VARCHAR2(200);
ASIG_REF VARCHAR2(200);
BEGIN

    FOR varAlumno in c_nuevo_ingreso loop
    
        TITULACION:=SUBSTR(varAlumno.nexpediente,1,4);
        
        NORMALIZA_ASIGNATURAS(varAlumno.grupos_asignados,TITULACION);
        
        FOR varAsignaturas in c_asignaturas loop
            IF varAsignaturas.grupo is NULL THEN
                INSERT INTO ERRORES VALUES (sysdate,'Asignatura sin grupo',varAsignaturas.codigo,CURSO_ACTUAL(),null,null,varAlumno.nexpediente,TITULACION);
            ELSE
                SELECT REFERENCIA INTO ASIG_REF FROM ASIGNATURA WHERE CODIGO=varAsignaturas.codigo;
                UPDATE ASIGNATURAS_MATRICULA SET GRUPO_ID=varAsignaturas.grupo WHERE ASIGNATURA_REFERENCIA=ASIG_REF AND MATRICULA_EXPEDIENTES_NEXP=varAlumno.nexpediente;
            END IF;
        END LOOP;
    END LOOP;
END PR_ASIGNA_ASIGNADOS;
END PK_ASIGNACION_GRUPOS;
/

--f
create or replace function OBTEN_LETRA_INGLES (CodTitulacion NUMBER, CodAsig Number) RETURN VARCHAR2 AS
vletra VARCHAR2(1);
vtemp VARCHAR2(70);
BEGIN
    select idiomas_de_imparticion into vtemp from asignatura where titulacion_codigo = CodTitulacion and codigo = CodAsig;
    if vtemp is not null then
        select letra into vletra from grupo where titulacion_codigo = CodTitulacion and ingles='si' and curso like substr(CodAsig,1,1);
    else
        return null;
    end if;
    return vletra;
END OBTEN_LETRA_INGLES;
/

--g
create or replace procedure PR_ASIGNA_INGLES_NUEVO is
vcodigo_titu number;
vcur number;
vgrupoid varchar(20);
vreferencia_asig varchar(20);
vgrupoes varchar(20);
cont number;
vcodigo number;
vmensaje varchar2(200);
cursor cnuevo_ingreso is select * from nuevo_ingreso where asig_ingles is not null;
begin
    cont:=0;
    For var_ingreso in cnuevo_ingreso loop
    begin
        vcodigo_titu :=to_number(substr(var_ingreso.expediente,1,4));
           For var_ingle in (select regexp_substr(var_ingreso.asig_ingles,'[^,]+', 1, level) ingle from dual connect by regexp_substr(var_ingreso.asig_ingles, '[^,]+', 1, level) is not null) loop
                --select to_number(substr(var_ingle.ingle,1,1)) into cur from dual;
                vcur:= to_number(substr(var_ingle.ingle,1,1));
                begin
                    select id into vgrupoid from grupo where curso=vcur and titulacion_codigo =vcodigo_titu and ingles= 'si';
                    select referencia into vreferencia_asig from asignatura where titulacion_codigo = vcodigo_titu and to_char(codigo)= var_ingle.ingle;
                    --DBMS_OUTPUT.PUT_LINE (var_ingreso.expediente || ' '|| var_ingle.ingle|| ' '||vgrupoid ||' '|| vreferencia_asig);
                    update asignaturas_matricula set grupo_id = vgrupoid
                    where asignatura_referencia = vreferencia_asig and MATRICULA_EXPEDIENTES_NEXP = var_ingreso.expediente;
                    cont:=cont+1;
                    COMMIT;
                exception
                    when no_data_found THEN
                    /*
                        vcodigo:= sqlcode;
                        vmensaje:= substr(sqlerrm,1,100);
                    DBMS_OUTPUT.PUT_LINE ('referencia o grupoid no encontrado ' || var_ingreso.expediente || ' ' ||vreferencia_asig );
                    DBMS_OUTPUT.PUT_LINE (vcodigo|| ' '|| vmensaje);
                    */
                    insert into errores values(sysdate,'referencia o grupoid no encontrado',vreferencia_asig,null,vgrupoid,'si',var_ingreso.EXPEDIENTE,vcodigo_titu);
                end;
            end loop;
            begin
            select id into vgrupoes from grupo where titulacion_codigo = vcodigo_titu and curso=vcur and sustituye_ingles= 'si';
            --DBMS_OUTPUT.PUT_LINE ('grupo Espa�ol' || ' '||vgrupoes);
            update asignaturas_matricula set grupo_id = vgrupoes where Matricula_expedientes_nexp = var_ingreso.expediente and grupo_id is null;
            exception 
                when NO_DATA_FOUND then
                --DBMS_OUTPUT.PUT_LINE ('grupo Espa�ol no encontrado'|| ' ' || var_ingreso.expediente);
                    insert into errores values(sysdate,'referencia o grupoid no encontrado',null,null,vgrupoes,'no',var_ingreso.EXPEDIENTE,vcodigo_titu);
            end;
    end;
    end loop;
    DBMS_OUTPUT.PUT_LINE (cont);
end;
/

--h
create or replace procedure PR_ASIGNA_TARDE_NUEVO is
cursor cnuevo_ingreso is select * from nuevo_ingreso where asig_ingles is null;
turnop varchar(20);
grupoid varchar(10);
codigo_titu number;
begin
    For var_ingreso in cnuevo_ingreso loop
        select turno_preferente into turnop from matricula where EXPEDIENTES_NUM_EXPEDIENTE= var_ingreso.expediente;
        codigo_titu := to_number(substr(var_ingreso.EXPEDIENTE,1,4));
        if upper(turnop) = 'TARDE' then
            begin
                --DBMS_OUTPUT.PUT_LINE (codigo_titu);
                select id into grupoid from grupo where curso = 1 and upper(TURNO_MANNANA_TARDE)= 'TARDE' and TITULACION_CODIGO= codigo_titu;
                DBMS_OUTPUT.PUT_LINE (grupoid ||' ' || codigo_titu || ' ' || turnop || ' ' || var_ingreso.EXPEDIENTE);
                update asignaturas_matricula 
                    set grupo_id = grupoid
                where matricula_expedientes_nexp = var_ingreso.EXPEDIENTE;
                commit;
            Exception 
                when NO_DATA_FOUND then
                insert into errores values(sysdate,'NO EXISTE GRUPO POR LA TARDE',null,null,grupoid,'no',var_ingreso.EXPEDIENTE,codigo_titu);
                commit;
                --DBMS_OUTPUT.PUT_LINE ('Datos no encontrado');
            continue;
            end;

        end if;
    end loop;
end PR_ASIGNA_TARDE_NUEVO;
/

--i
create or replace PROCEDURE PR_ASIGNA_RESTO_NUEVO IS
CURSOR c_nuevo_ingreso IS SELECT * FROM NUEVO_INGRESO N
JOIN MATRICULA M ON M.NUM_ARCHIVO=N.ARCHIVO
WHERE N.ASIG_INGLES IS NULL AND M.TURNO_PREFERENTE='Ma�ana'
OR M.TURNO_PREFERENTE IS NULL
ORDER BY M.FECHA_DE_MATRICULA ASC;

nMenor number;
nPlazas number;
vGrupo varchar2(10);
TITULACION NUMBER;
nReal number;
--cont number;
BEGIN
--cont :=0;
FOR varNIngreso IN c_nuevo_ingreso LOOP

	TITULACION:= to_number(SUBSTR(varNIngreso.EXPEDIENTE,1,4));
	nMenor:=0;
	FOR varGrupos in ( SELECT * FROM GRUPO WHERE TITULACION_CODIGO=TITULACION AND INGLES='no' AND TURNO_MANNANA_TARDE='MA�ANA') loop
		SELECT MAX(NUM_REAL) INTO nReal FROM GRUPOS_POR_ASIGNATURA
		WHERE GRUPO_ID=varGrupos.ID;
        IF varGrupos.plazas_nuevo_ingreso is not null THEN
            nPlazas:=varGrupos.plazas_nuevo_ingreso - nReal;
        ELSE
            nPlazas:=0;
        END IF;
		IF nPlazas>=nMenor THEN
			vGrupo:=varGrupos.ID;
			nMenor:=nPlazas;
		END IF;
	END LOOP;
	UPDATE asignaturas_matricula SET GRUPO_ID=vGrupo WHERE MATRICULA_EXPEDIENTES_NEXP=varNIngreso.EXPEDIENTE;
    --cont := cont+1;
    --DBMS_OUTPUT.PUT_LINE (cont);
END LOOP;
end PR_ASIGNA_RESTO_NUEVO;
/

--j
CREATE TABLE ENCUESTA_NUEVA (
DOCUMENTO VARCHAR2(20 BYTE),
EXPEDIENTE VARCHAR2(100 BYTE),
ARCHIVO VARCHAR2(100 BYTE),
PREFERENCIAS VARCHAR2(200 BYTE),
FECHA VARCHAR2(40 BYTE)
);

--k
create or replace PROCEDURE PR_ASIGNA_INGLES_ANTIGUO IS
vtitulacion number;
vimpart varchar2(70);
vcurso number;
gr_id varchar2(10);
vgrupoes varchar2(10);
REF_ASIG varchar2(20);
cont number;
CURSOR c_alum_matriculas is (SELECT * FROM MATRICULA M 
JOIN (SELECT * FROM ALUMNOS_EXT A
LEFT OUTER JOIN NUEVO_INGRESO N
ON A.DOCUMENTO=N.DOCUMENTO) P
ON M.EXPEDIENTES_NUM_EXPEDIENTE=P.NEXPEDIENTE);

BEGIN
    cont:=0;
    FOR varAlumno in c_alum_matriculas LOOP
        vtitulacion:=to_number(SUBSTR(varAlumno.EXPEDIENTES_NUM_EXPEDIENTE,1,4));
        NORMALIZA_ASIGNATURAS(varAlumno.LISTADO_ASIGNATURAS,vtitulacion);
        FOR varAsignaturas in (select codigo from TEMP_ASIGNATURAS) LOOP
            begin
                SELECT REFERENCIA,IDIOMAS_DE_IMPARTICION,curso INTO REF_ASIG,vimpart,vcurso FROM ASIGNATURA WHERE CODIGO=varAsignaturas.codigo AND TITULACION_CODIGO=vtitulacion;
                IF(vimpart= 'Solo un grupo') THEN 
                    SELECT ID INTO GR_ID FROM GRUPO WHERE INGLES='si'AND TITULACION_CODIGO=VTITULACION and curso = vcurso;
                    DBMS_OUTPUT.PUT_LINE (ref_asig||' ' ||vimpart||' '||vcurso || ' '|| gr_id);
                    UPDATE ASIGNATURAS_MATRICULA SET GRUPO_ID=GR_ID where asignatura_referencia = REF_ASIG and matricula_expedientes_nexp= varAlumno.expedientes_num_expediente;
                    cont := cont+1;
                    DBMS_OUTPUT.PUT_LINE (cont);
                end if;
            exception
            when no_data_found THEN
                 --DBMS_OUTPUT.PUT_LINE ('no ecuentra grupo ingles');
                 insert into errores values(sysdate,'grupo ingles no encontrado',ref_asig,null,gr_id,'si',varAlumno.EXPEDIENTES_NUM_EXPEDIENTE,vtitulacion);
            end;
        end loop;
        begin
            SELECT ID INTO vgrupoes FROM GRUPO WHERE SUSTITUYE_INGLES='si' AND TITULACION_CODIGO=VTITULACION and curso = vcurso;
            UPDATE ASIGNATURAS_MATRICULA SET GRUPO_ID=vgrupoes where Matricula_expedientes_nexp =varAlumno.expedientes_num_expediente and grupo_id is null;
        exception
            when others then
                 --DBMS_OUTPUT.PUT_LINE ('no encuentra grupo sustituyente de ingles');
                insert into errores values(sysdate,'grupo susutituyente de ingles no encontrado',null,null,vgrupoes,'no',varAlumno.EXPEDIENTES_NUM_EXPEDIENTE,vtitulacion);
        end;
    end loop;
end PR_ASIGNA_INGLES_ANTIGUO;
/

--l
create or replace PROCEDURE PR_ASIGNA_RESTO_ANTIGUO IS
vtitulacion number;
vimpart varchar2(70);
vcurso number;
gr_id varchar2(10);
vgrupoes varchar2(10);
REF_ASIG varchar2(20);
alguna boolean;
cont number;
CURSOR c_alum_encuestas is (SELECT M.expediente, M.PREFERENCIAS FROM ENCUESTA_NUEVA M 
JOIN (SELECT * FROM ALUMNOS_EXT A
LEFT OUTER JOIN NUEVO_INGRESO N
ON A.DOCUMENTO=N.DOCUMENTO) P
ON M.EXPEDIENTE=P.NEXPEDIENTE);
BEGIN
    cont :=0;
    FOR varAlumno in c_alum_encuestas LOOP
        vtitulacion := to_number(substr(varAlumno.expediente,1,4));
         DBMS_OUTPUT.PUT_LINE (varAlumno.Preferencias);
         DBMS_OUTPUT.PUT_LINE (vtitulacion);
        NORMALIZA_ASIGNATURAS(varAlumno.Preferencias,vtitulacion);

        FOR varAsignaturas in (select codigo from TEMP_ASIGNATURAS) LOOP
            begin
                SELECT IDIOMAS_DE_IMPARTICION INTO vimpart FROM ASIGNATURA WHERE CODIGO=varAsignaturas.codigo AND TITULACION_CODIGO=vtitulacion;
                exception
                when no_data_found THEN
                --DBMS_OUTPUT.PUT_LINE ('no ecuentra grupo1');
                insert into errores values(sysdate,'grupo no encontrado1',ref_asig,null,gr_id,'si',varAlumno.EXPEDIENTE,vtitulacion);
                vimpart := null;
            end;
                IF(vimpart= 'Solo un grupo') THEN 
                   alguna := TRUE;
                end if;
            
        end loop;

        IF(alguna = FALSE) THEN
            FOR varAsignaturas in (select * from TEMP_ASIGNATURAS) LOOP
                begin
                    SELECT REFERENCIA,curso INTO REF_ASIG,vcurso FROM ASIGNATURA WHERE CODIGO=varAsignaturas.codigo AND TITULACION_CODIGO=vtitulacion;
                    SELECT ID into gr_id from GRUPO where TITULACION_CODIGO=vtitulacion and curso=vcurso and letra = varAsignaturas.grupo;

                    UPDATE ASIGNATURAS_MATRICULA SET GRUPO_ID = gr_id where Matricula_expedientes_nexp = varAlumno.expediente and asignatura_referencia = ref_asig;
                    DBMS_OUTPUT.PUT_LINE (cont);
                exception
                    when no_data_found THEN
                     DBMS_OUTPUT.PUT_LINE ('no ecuentra grupo');
                    insert into errores values(sysdate,'grupo no encontrado',ref_asig,null,gr_id,'si',varAlumno.EXPEDIENTE,vtitulacion);
                end;
            end loop;
        END IF;
    end loop;
end PR_ASIGNA_RESTO_ANTIGUO;
/

--m
CREATE OR REPLACE PROCEDURE PR_ASIGNA IS
BEGIN
    PR_ASIGNA_ASIGNADOS;
    PR_ASIGNA_INGLES_NUEVO;
    PR_ASIGNA_TARDE_NUEVO;
    PR_ASIGNA_RESTO_NUEVO;
    PR_ASIGNA_INGLES_ANTIGUO;
    PR_ASIGNA_RESTO_ANTIGUO;
END PR_ASIGNA;
/

--n
CREATE OR REPLACE VIEW V_ASIGNACION AS
SELECT e.TITULACION_CODIGO AS Titulacion, 
e.NUM_EXPEDIENTE AS Expediente,
a.DNI,
a.APELLIDO1 ||' '||a.APELLIDO2||', '||a.NOMBRE AS "Apellidos y Nombre",
asig.curso AS Curso, 
asig.CODIGO AS Asignatura,
substr(am.GRUPO_ID,4,1) AS Grupo
FROM ALUMNO a, EXPEDIENTES e, MATRICULA m, ASIGNATURA asig, TITULACION t, ASIGNATURAS_MATRICULA am
WHERE a.ID = e.ALUMNO_ID 
AND m.EXPEDIENTES_NUM_EXPEDIENTE = e.NUM_EXPEDIENTE
AND t.CODIGO = asig.TITULACION_CODIGO
AND t.CODIGO = e.TITULACION_CODIGO
AND am.ASIGNATURA_REFERENCIA = asig.REFERENCIA
AND am.MATRICULA_EXPEDIENTES_NEXP = m.EXPEDIENTES_NUM_EXPEDIENTE
;