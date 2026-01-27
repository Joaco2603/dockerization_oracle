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
