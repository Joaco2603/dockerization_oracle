# Build and run using Docker Compose (modern CLI).
# Use --no-cache to ensure Dockerfile changes are applied and
# --progress=plain to show full build logs for easier debugging.
docker compose build --no-cache --progress=plain oracle-xe112
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
docker compose up -d oracle-xe112
