#!/bin/bash
set -e

# Construir imagen y levantar contenedor (Linux / WSL / Git Bash)
docker-compose build oracle-xe112
docker-compose up -d oracle-xe112
