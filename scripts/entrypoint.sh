#!/bin/bash
set -e

echo "=== Iniciando Oracle XE 21c ==="

ORACLE_BASE=/opt/oracle
ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
ORACLE_SID=XE

export ORACLE_BASE ORACLE_HOME ORACLE_SID

# Verificar que Oracle XE esté instalado
if [ ! -f ${ORACLE_HOME}/bin/sqlplus ]; then
    echo "ERROR: Oracle XE no está instalado correctamente"
    exit 1
fi

# Configurar Oracle si es la primera vez
if [ ! -f /opt/oracle/oradata/XE/system01.dbf ]; then
    echo "=== Configurando Oracle XE 21c por primera vez ==="
    
    # Ejecutar la configuración de Oracle XE 21c
    (echo "${ORACLE_PWD}"; echo "${ORACLE_PWD}";) | /etc/init.d/oracle-xe-21c configure
    
    if [ $? -ne 0 ]; then
        echo "ERROR: La configuración de Oracle XE falló"
        echo "=== Volcando logs disponibles ==="
        if [ -d ${ORACLE_BASE}/cfgtoollogs ]; then
            find ${ORACLE_BASE}/cfgtoollogs -name "*.log" -exec cat {} \;
        fi
        exit 1
    fi
    
    echo "=== Oracle XE 21c configurado exitosamente ==="
else
    echo "=== Oracle XE ya está configurado, iniciando servicios ==="
    /etc/init.d/oracle-xe-21c start
fi

# Verificar que Oracle esté corriendo
echo "=== Verificando estado de Oracle ==="
su - oracle -c "source /opt/oracle/product/21c/dbhomeXE/bin/oraenv <<< XE; sqlplus -v"

# Mantener el contenedor corriendo y mostrar logs
echo "=== Oracle XE 21c está listo ==="
echo "Conexión: localhost:1521/XE"
echo "PDB: localhost:1521/XEPDB1"
echo "Usuario SYS/SYSTEM, Password: ${ORACLE_PWD}"

# Seguir los logs
tail -f ${ORACLE_BASE}/diag/rdbms/xe/XE/trace/alert_XE.log 2>/dev/null || tail -f /dev/null
