New-Item -ItemType Directory -Force -Path evidence | Out-Null
Start-Transcript -Path 'evidence/10-git.txt' -Force
Write-Host '=== git --version ==='; git --version
Write-Host '=== git config (selected) ==='; git config --get user.name; git config --get user.email; git config --get init.defaultBranch
Write-Host '=== git config --list (required) ==='; git config --list
Write-Host '=== git remote -v ==='; git remote -v
Write-Host '=== git status ==='; git status
Stop-Transcript
Write-Host 'IMPORTANT: Review and redact tokens / sensitive data before pushing evidence/10-git.txt.'
