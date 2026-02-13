# Oracle XE 11.2 Docker (plantilla)

Resumen rápido (español): este directorio contiene una plantilla para construir una imagen Docker de Oracle Database Express Edition 11.2 (XE). Por restricciones de licencia Oracle no permite distribuir el instalador directamente. Debes descargar el instalador oficial desde el sitio de Oracle y colocarlo en `docker/oracle/install/` como `OracleXE112_RPM.zip`.

Pasos:

1. Descarga: entra a la web oficial de Oracle y descarga "Oracle Database 11g Release 2 Express Edition" (el paquete RPM o el ZIP con el RPM).
2. Coloca el archivo descargado (el ZIP que contiene `oracle-xe-11.2.0-1.0.x86_64.rpm`) en:

   docker/oracle/install/OracleXE112_RPM.zip

3. Construir y levantar (WSL, Git Bash o Linux):

```bash
cd /ruta/al/proyecto
docker-compose build oracle-xe112
docker-compose up -d oracle-xe112
```

En Windows PowerShell:

```powershell
.\docker\oracle\build.ps1
```

4. Variables y puertos:
- Usuario de administrador: `SYS`/`SYSTEM` (contraseña que elijas en la variable `ORACLE_PWD`, por defecto `oracle`).
- Puerto Oracle listener: `1521`.
- Consola HTTP (si aplica): `8080`.

Notas importantes:
- Este repositorio contiene solo una plantilla. El instalador de Oracle no está incluido por motivos de licencia.
- Dependiendo del host y de la versión de Docker, pueden necesitarse ajustes de parámetros del kernel o compatibilidad (especialmente en Windows). Si aparecen errores de RPM o del demonio durante build, prueba a construir en WSL2 o en un host Linux.
- Si quieres cambiar la contraseña por defecto, overridea la variable de entorno `ORACLE_PWD` en `docker-compose.yml` o al ejecutar `docker run -e ORACLE_PWD=MiClave ...`.

## Ejecución de Scripts SQL con Spool (PowerShell)

Si deseas probar consultas SQL y generar un archivo de salida (spool) automáticamente conectándote al contenedor Docker:

1.  Configura tus credenciales y nombre de archivo deseado en el archivo `.env`:
    ```dotenv
    CREDENTIAL_NAME= "tu_usuario"
    CREDENTIAL_PASSWORD= "tu_password"
    RESULT_NAME= "resultado.txt"
    ```

2.  Coloca tus consultas SQL en un archivo de texto (ej. `entregahoy/clausula-where.txt`).

3.  Ejecuta el script de PowerShell:
    ```powershell
    .\scripts\run_query.ps1
    ```
    O para un archivo específico:
    ```powershell
    .\scripts\run_query.ps1 -InputFile "carpeta/mi_archivo.sql"
    ```

El script copiará tu archivo al contenedor, lo ejecutará mediante SQLPlus (mostrando las sentencias ejecutadas gracias a `SET ECHO ON`) y guardará el resultado en `results/` con el nombre definido en `RESULT_NAME`.

## Comandos Docker útiles
docker cp .\sql\insdb.sql  oracle-xe112:/tmp/insdb.sql

docker exec -i oracle-xe112 bash -c "/opt/oracle/product/21c/dbhomeXE/bin/sqlplus sys/oracle@//127.0.0.1:1521/XE as sysdba" <<'EOF'
ALTER SESSION SET CONTAINER = XEPDB1;
@/tmp/creadb.sql
@/tmp/insdb.sql
EXIT
EOF

docker exec -it --user oracle oracle-xe112 bash
. /opt/oracle/product/21c/dbhomeXE/bin/oraenv <<< XE
/opt/oracle/product/21c/dbhomeXE/bin/sqlplus sys/oracle@//127.0.0.1:1521/XE as sysdba
-- dentro de sqlplus:
ALTER SESSION SET CONTAINER = XEPDB1;
@/tmp/creadb.sql
@/tmp/insdb.sql

SPOOL /tmp/run_output.log
-- ejecutar los @scripts
SPOOL OFF