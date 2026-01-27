FROM oraclelinux:7-slim

ARG ORACLE_PWD=oracle
ENV ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe \
    ORACLE_SID=XE \
    ORACLE_PWD=${ORACLE_PWD} \
    PATH=$PATH:/u01/app/oracle/product/11.2.0/xe/bin

COPY install /install
COPY scripts/entrypoint.sh /entrypoint.sh

# Instalar todas las dependencias necesarias
RUN yum -y install unzip libaio bc net-tools procps && \
    if [ ! -f /install/OracleXE112_RPM.zip ]; then \
      echo "ERROR: coloca OracleXE112_RPM.zip en install/" && exit 1; \
    fi && \
    echo "Descomprimiendo Oracle XE..." && \
    unzip /install/OracleXE112_RPM.zip -d /install && \
    echo "Buscando archivos .rpm en /install..." && \
    rpm_files=$(find /install -type f -iname "*.rpm" -print) && \
    if [ -z "$rpm_files" ]; then \
      echo "ERROR: no se encontraron archivos .rpm" && exit 1; \
    fi && \
    echo "Instalando Oracle XE RPM..." && \
    yum -y localinstall $rpm_files && \
    rm -rf /install/* && \
    yum -y remove unzip && \
    yum clean all

# Crear directorios necesarios
RUN mkdir -p /var/lock/subsys && \
    chmod +x /entrypoint.sh

EXPOSE 1521 8080

ENTRYPOINT ["/entrypoint.sh"]