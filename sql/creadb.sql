--  Version 2017

Prompt ******  REGIONES  ....

CREATE TABLE continentes
    ( IDcont  NUMBER(1) primary key,
      nombre    VARCHAR2(25)  );

Prompt ******  PAISES ....

CREATE TABLE paises 
   (IDpais      CHAR(2) NOT NULL,
    nombre      VARCHAR2(40),
    IDcont      NUMBER(1), 
    CONSTRAINT  PKpais PRIMARY KEY (IDpais) ); 


ALTER TABLE paises
ADD ( CONSTRAINT FKpais_continente FOREIGN KEY (IDcont)
          	  REFERENCES continentes(IDcont)  ) ;


Prompt ******  OFICINAS ....

CREATE TABLE oficinas
    (IDoficina  NUMBER(4) NOT NULL,
     direccion  VARCHAR2(40),
     codpostal  VARCHAR2(10),
     ciudad     VARCHAR2(25),
     estado     VARCHAR2(25),
     IDpais     CHAR(2),
     CONSTRAINT PKoficina PRIMARY KEY (IDoficina),
     CONSTRAINT FKoficina_pais FOREIGN KEY (IDpais) REFERENCES paises(IDpais)  ) ;

Prompt ******  DEPARTMENTOS ....

CREATE TABLE departamentos
    ( IDdep    NUMBER(4),
     nombre  VARCHAR2(30) NOT NULL,
     IDdirector     NUMBER(6),
     IDoficina    NUMBER(4),
     CONSTRAINT PKdep PRIMARY KEY (IDdep),
     CONSTRAINT FKdep_Oficina FOREIGN KEY (IDoficina) REFERENCES oficinas (IDoficina)  ) ;


Prompt ******  PUESTOS ....

CREATE TABLE puestos
    ( IDpuesto VARCHAR2(4),
     titulo      VARCHAR2(35) NOT NULL,
     salario_min    NUMBER(11,2),  
     salario_max    NUMBER(11,2),
     CONSTRAINT PKpuestos PRIMARY KEY (IDpuesto) ) ;


Prompt ******  EMPLEADOS ....

CREATE TABLE empleados
    ( IDemp NUMBER(6),
     nombre     VARCHAR2(20),
     apellido   VARCHAR2(25) not null,
     sexo       CHAR(1),
     email      VARCHAR2(50),
     dianacimiento DATE not null,
     Diaingreso  DATE not null,
     IDpuesto  VARCHAR2(4) not null,
     salario   NUMBER(8),
     bono      NUMBER(6),
     IDjefe    NUMBER(6),
     IDdep     NUMBER(4),
     CONSTRAINT   CKemp_salario_min CHECK (salario > 0), 
--     CONSTRAINT   UKemp_email UNIQUE (email),
     CONSTRAINT   PKempleados PRIMARY KEY (IDemp),
     CONSTRAINT   FKemp_dep  FOREIGN KEY (IDdep) REFERENCES departamentos(IDdep),
     CONSTRAINT   FKemp_puesto FOREIGN KEY (IDpuesto) REFERENCES puestos (IDpuesto),
     CONSTRAINT   FKemp_jefe  FOREIGN KEY (IDjefe) REFERENCES empleados (IDemp)  ) ;

ALTER TABLE departamentos 
ADD ( CONSTRAINT FKdep_director FOREIGN KEY (IDdirector) REFERENCES empleados(IDemp)  ) ;

Prompt ******  MOVIMIENTOS ....

CREATE TABLE movimientos
    (IDemp      NUMBER(6) NOT NULL,
     Diacambio  DATE not null,
     IDpuestoAnterior  VARCHAR2(4),
     IDpuestoNuevo     Varchar2(4),
     IDdepAnterior NUMBER(4),
     IDdepNuevo    NUMBER(4),
     CONSTRAINT    PKmovimientos PRIMARY KEY (IDemp,Diacambio),
     CONSTRAINT    FKmov_puestoAnt FOREIGN KEY (IDpuestoAnterior) references puestos(IDpuesto),
     CONSTRAINT    FKmov_puestoNuevo FOREIGN KEY (IDpuestoNuevo) references puestos(IDpuesto),
     CONSTRAINT    FKMov_depAnt FOREIGN KEY (IDdepAnterior) references departamentos(IDdep),
     CONSTRAINT    FKMov_depNuevo FOREIGN KEY (IDdepNuevo) references departamentos(IDdep)   ) ;

select * from cat;
