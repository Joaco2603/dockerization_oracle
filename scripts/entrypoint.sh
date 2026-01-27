#!/bin/bash
set -e

echo "=== Iniciando Oracle XE 11g ==="

# Verificar que Oracle XE esté instalado
if [ ! -f /u01/app/oracle/product/11.2.0/xe/bin/sqlplus ]; then
    echo "ERROR: Oracle XE no está instalado correctamente"
    exit 1
fi

# Configurar Oracle si es la primera vez (verificar si ya está configurado)
if [ ! -f /u01/app/oracle/product/11.2.0/xe/dbs/spfileXE.ora ]; then
    echo "=== Configurando Oracle XE por primera vez ==="
    
    # Configurar Oracle XE automáticamente
    # Formato: puerto HTTP, puerto listener, contraseña SYS, contraseña SYSTEM, iniciar en boot
    printf "8080\n1521\n${ORACLE_PWD}\n${ORACLE_PWD}\ny\n" | /etc/init.d/oracle-xe configure
    
    if [ $? -ne 0 ]; then
        echo "ERROR: La configuración de Oracle XE falló"
        echo "=== Volcando logs disponibles ==="
        if [ -d /u01/app/oracle/product/11.2.0/xe/config/log ]; then
            ls -la /u01/app/oracle/product/11.2.0/xe/config/log/
            for logfile in /u01/app/oracle/product/11.2.0/xe/config/log/*.log; do
                if [ -f "$logfile" ]; then
                    echo "=== $logfile ==="
                    cat "$logfile"
                fi
            done
        fi
        exit 1
    fi
    
    echo "=== Oracle XE configurado exitosamente ==="
else
    echo "=== Oracle XE ya está configurado, iniciando servicios ==="
    /etc/init.d/oracle-xe start
fi

# Verificar que Oracle esté corriendo
echo "=== Verificando estado de Oracle ==="
su -p oracle -c "sqlplus -v"

# Mantener el contenedor corriendo y mostrar logs
echo "=== Oracle XE está listo ==="
echo "Conexión: localhost:1521/XE"
echo "Usuario SYS/SYSTEM, Password: ${ORACLE_PWD}"

# Seguir los logs
tail -f /u01/app/oracle/diag/rdbms/xe/XE/trace/alert_XE.log 2>/dev/null || tail -f /dev/null