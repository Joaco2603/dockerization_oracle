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
$ResultName = $env:RESULT_NAME

if ([string]::IsNullOrWhiteSpace($User) -or [string]::IsNullOrWhiteSpace($Pass)) {
    Write-Error "Credentials (CREDENTIAL_NAME, CREDENTIAL_PASSWORD) are missing in .env"
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

# 4. Execute
# We combine header + file content and pipe to docker exec
$Content = Get-Content $AbsInputPath -Raw
# Transform content to ensure echo works better by repeating the query?
# No, simpler approach: we print the query in the spool by enabling input echoing.
# Note: With 'sqlplus -S' and piped input, 'SET ECHO ON' might not behave as expected for standard input.
# A common trick is to copy the file to the container and run it with @file.
# Let's switch to that approach to ensure reliable spooling with visible queries.

$RemoteTempPath = "/tmp/query_script.sql"

# Copy file to container
docker cp $AbsInputPath "oracle-xe112:$RemoteTempPath"

# Run sqlplus executing the file
# We add header configuration dynamically by creating a wrapper script or just prepending config to the file.
# Easier: Create a temporary local wrapper file.

$WrapperFile = Join-Path $ScriptDir "temp_wrapper.sql"
$WrapperContent = $SqlHeader + "`n@" + $RemoteTempPath + "`nEXIT;"

# Write file without BOM (PowerShell 5.1 Set-Content adds BOM, causing SP2-0734)
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($WrapperFile, $WrapperContent, $Utf8NoBom)

docker cp $WrapperFile "oracle-xe112:/tmp/wrapper.sql"

# Execute
# remove -S (Silent) so ECHO works
# quote the @ argument to avoid PowerShell parsing issues.
docker exec -i oracle-xe112 sqlplus "$User/$Pass" "@/tmp/wrapper.sql" | Set-Content $AbsOutputPath -Encoding UTF8

# Cleanup local wrapper
Remove-Item $WrapperFile -Force


if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! Results saved to $AbsOutputPath"
} else {
    Write-Error "Execution failed with exit code $LASTEXITCODE"
}
