# scripts/run_query.ps1

param(
    [string]$InputFile = $Env:QUERIES_DIRECTORY
)

$ErrorActionPreference = "Stop"

# Define paths relative to the script location
$ScriptDir = $PSScriptRoot
$ProjectRoot = Join-Path $ScriptDir ".."
$EnvPath = Join-Path $ProjectRoot ".env"

# 1. Load .env variables
if (Test-Path $EnvPath) {
    Write-Host "Loading environment variables from $EnvPath"
    Get-Content $EnvPath | ForEach-Object {
        if ($_ -match '^\s*([^#=]+)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            # Remove surrounding quotes if present
            if ($value -match '^"(.+)"$') { $value = $matches[1] }
            
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
        }
    }
} else {
    Write-Warning ".env file not found at $EnvPath"
}

# 2. Validate variables
$User = $env:CREDENTIAL_NAME
$Pass = $env:CREDENTIAL_PASSWORD
$InputFile = $env:INPUT_FILE
$ResultName = $env:RESULT_NAME

if ([string]::IsNullOrWhiteSpace($User) -or [string]::IsNullOrWhiteSpace($Pass)) {
    Write-Error "Credentials (CREDENTIAL_NAME, CREDENTIAL_PASSWORD) are missing in .env"
    exit 1
}

if([string]::IsNullOrWhiteSpace($InputFile)) {
    Write-Error "INPUT_FILE is missing in .env"
    exit 1
}

if ([string]::IsNullOrWhiteSpace($ResultName)) {
    Write-Warning "RESULT_NAME not found in .env, defaulting to 'output.txt'"
    $ResultName = "output.txt"
}

$AbsInputPath = Join-Path $ProjectRoot $InputFile
$AbsOutputPath = Join-Path $ProjectRoot "results\$ResultName"

if (-not (Test-Path $AbsInputPath)) {
    Write-Error "Input file not found: $AbsInputPath"
    exit 1
}

# Create results directory if it doesn't exist
$ResultsDir = Split-Path $AbsOutputPath
if (-not (Test-Path $ResultsDir)) {
    New-Item -ItemType Directory -Path $ResultsDir -Force | Out-Null
}

Write-Host "---------------------------------------------------"
Write-Host "Database:   oracle-xe112 (Docker)"
Write-Host "User:       $User"
Write-Host "Input SQL:  $InputFile"
Write-Host "Output:     results\$ResultName"
Write-Host "---------------------------------------------------"

# 3. Prepare SQL formatting
# Add some formatting options to make the output cleaner if desired, 
# or strictly run the file as is. 
# We'll prepend some formatting commands to the input stream.
$SqlHeader = @"
SET PAGESIZE 50000
SET LINESIZE 32000
SET FEEDBACK ON
SET HEADING ON
SET TRIMSPOOL ON
SET TAB OFF
SET ECHO ON
SET VERIFY OFF
"@

# 4. Execute (run sqlplus inside Docker container)
# Copy the input SQL into the container, create a wrapper that references it, copy wrapper, then exec sqlplus inside container.
$Content = Get-Content $AbsInputPath -Raw

$RemoteTempPath = "/tmp/query_script.sql"

# Copy the input SQL to the container
docker cp $AbsInputPath "oracle-xe112:$RemoteTempPath"

$WrapperFile = Join-Path $ScriptDir "temp_wrapper.sql"
$WrapperContent = $SqlHeader + "`n@" + $RemoteTempPath + "`nEXIT;"

# Write file without BOM
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($WrapperFile, $WrapperContent, $Utf8NoBom)

# Copy wrapper to container
docker cp $WrapperFile "oracle-xe112:/tmp/wrapper.sql"

# Connection URL requested by the user
$sqlUrl = "joaco/1234@//localhost:1521/XEPDB1"

# Execute sqlplus inside container and capture output
docker exec -i oracle-xe112 sqlplus "$sqlUrl" "@/tmp/wrapper.sql" | Set-Content $AbsOutputPath -Encoding UTF8

# Cleanup local wrapper
Remove-Item $WrapperFile -Force


if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! Results saved to $AbsOutputPath"
} else {
    Write-Error "Execution failed with exit code $LASTEXITCODE"
}
