# Regenerates lib/gen from ../PetBridge_backend/api/openapi.yaml.
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
dart run swagger_parser
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
dart run build_runner build
exit $LASTEXITCODE
