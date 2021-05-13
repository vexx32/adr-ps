$moduleFolder = "$PSScriptRoot/.build/adr"

if (Test-Path $moduleFolder) {
    Remove-Item -Path $moduleFolder -Recurse -Force
}

New-Item -ItemType Directory -Path $moduleFolder
Copy-Item -Path "$PSScriptRoot/templates" -Recurse -Destination $moduleFolder
Copy-Item -Path "$PSScriptRoot/adr.psd1" -Destination $moduleFolder

$ModuleCode = @(
    "module-init"
    "private"
    "public"
) |
    Join-Path -Path $PSScriptRoot -ChildPath { $_ } |
    Get-ChildItem -File -Recurse -Include '*.ps1' |
    Get-Content -Raw

$ModuleCode -join "`r`n" | Set-Content -Path "$moduleFolder/adr.psm1" -NoNewline

Import-Module "$moduleFolder/adr.psd1"
