# PowerShell 7 or Windows PowerShell. Run from the project root.
# Captures actual CLI output; does not fabricate results.
$ErrorActionPreference = 'Continue'
New-Item -ItemType Directory -Force -Path evidence | Out-Null
Start-Transcript -Path 'evidence/03-docker.txt' -Force
Write-Host '=== docker --version ==='; docker --version
Write-Host '=== docker info ==='; docker info
Write-Host '=== docker images ==='; docker images
Write-Host '=== docker ps -a ==='; docker ps -a
Write-Host '=== docker logs lab-web-8080 ==='; docker logs lab-web-8080
Write-Host '=== docker stats --no-stream ==='; docker stats --no-stream
Stop-Transcript
