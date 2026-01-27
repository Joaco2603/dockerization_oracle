FROM oraclelinux:7-slim

ARG ORACLE_PWD=oracle
ENV ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe \
    ORACLE_SID=XE \
    ORACLE_PWD=${ORACLE_PWD}

COPY install /install
COPY entrypoint.sh /entrypoint.sh

RUN yum -y install unzip libaio bc && \
    if [ -f /install/OracleXE112_RPM.zip ]; then \
      unzip /install/OracleXE112_RPM.zip -d /install && \
      rpm -ivh /install/oracle-xe-11.2.0-1.0.x86_64.rpm || true; \
    else \
      echo "ERROR: coloca OracleXE112_RPM.zip en docker/oracle/install/" && exit 1; \
    fi && \
    yum -y remove unzip && yum clean all

RUN chmod +x /entrypoint.sh

EXPOSE 1521 8080

ENTRYPOINT ["/entrypoint.sh"]
