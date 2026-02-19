FROM oraclelinux:8-slim

ARG ORACLE_PWD=oracle
ENV ORACLE_BASE=/opt/oracle \
    ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE \
    ORACLE_SID=XE \
    ORACLE_PWD=${ORACLE_PWD} \
    PATH=$PATH:/opt/oracle/product/21c/dbhomeXE/bin

COPY install /install
COPY scripts/entrypoint.sh /entrypoint.sh

# Convertir finales de línea a Unix (LF) y dar permisos
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

# Instalar dependencias necesarias e instalar Oracle XE 21c
RUN microdnf install -y dnf && \
    dnf -y install libaio bc net-tools procps openssl && \
    if [ ! -f /install/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm ]; then \
      echo "ERROR: coloca oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm en install/" && exit 1; \
    fi && \
    echo "Instalando Oracle XE 21c RPM..." && \
    dnf -y localinstall /install/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm && \
    rm -rf /install/* && \
    dnf clean all

# Crear directorios necesarios
RUN mkdir -p /var/lock/subsys && \
    chmod +x /entrypoint.sh

EXPOSE 1521 8080

ENTRYPOINT ["/entrypoint.sh"]