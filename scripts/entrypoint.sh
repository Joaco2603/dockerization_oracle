#!/bin/bash
set -e

if [ ! -d "/u01/app/oracle/product/11.2.0/xe" ]; then
  echo "Oracle XE aparentemente no está instalado en la imagen. Abortando." >&2
  exit 1
fi

if [ ! -f /var/opt/oracle/.configured ]; then
  echo "Configurando Oracle XE (respuesta automática)..."
  /etc/init.d/oracle-xe configure <<EOF
8080
1521
${ORACLE_PWD}
${ORACLE_PWD}
y
EOF
  touch /var/opt/oracle/.configured
fi

echo "Iniciando Oracle XE..."
/etc/init.d/oracle-xe start || true

# Mantener el contenedor en primer plano
tail -f /dev/null
