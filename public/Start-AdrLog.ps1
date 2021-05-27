function Start-AdrLog {
    <#
        .SYNOPSIS
        Starts a new ADR decision log for a repository or workspace, or resumes
        working in an existing ADR decision log folder.

        .DESCRIPTION
        If it doesn't exist, creates the necessary folder structure for holding
        an ADR decision log in the target location, along with a README.md file.

        If the folder already exists, the command simply updates its default
        ADR log path to simplify working with other module commands.
    #>
    [Alias('Adr-Init')]
    [CmdletBinding()]
    param(
        # Path to the repository root. Defaults to the current location.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path = (Get-Location -PSProvider FileSystem).Path,

        # Relative path where ADRs will be kept. Defaults to doc\adr.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $AdrFolderPath = 'doc/adr'
    )

    $adrPath = Join-Path -Path $Path -ChildPath $AdrFolderPath |
        Set-AdrLog -PassThru

    if (-not (Test-Path -Path $adrPath)) {
        New-Item -ItemType Directory -Force -Path $adrPath

        $readmePath = "$script:ModuleRoot/templates/ADR-Readme.md"
        if (-not (Test-Path $readmePath)) {
            Copy-Item -Path $readmePath -Destination "$adrPath/README.md"
        }
    }

    Get-AdrLog
}
