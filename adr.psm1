$script:AdrLogFolder = "doc/adr"

function Get-AdrLog {
    [CmdletBinding()]
    param()

    $script:AdrLogFolder
}

function Set-AdrLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('PSPath')]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $PassThru
    )
    process {
        $script:AdrLogFolder = $Path

        if ($PassThru) {
            $script:AdrLogFolder
        }
    }
}

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

        $readmePath = "$PSScriptRoot/templates/ADR-Readme.md"
        if (-not (Test-Path $readmePath)) {
            Copy-Item -Path $readmePath -Destination "$adrPath/README.md"
        }
	}

    Get-Item -Path $adrPath
}

function New-Adr {
    <#
        .SYNOPSIS
        Creates a new ADR from a template and adds it to the decision log.

        .DESCRIPTION
        Creates a new ADR file in the decision log with today's date and the
        next sequential number in the log.
    #>
    [Alias('Adr-New')]
    param(
        # The title of the new ADR.
        [Parameter(Mandatory)]
        [string]
        $Title,

        # Path to the ADR decision log folder.
        [Parameter()]
        [string]
        $Path
    )

    $adrPath = Get-AdrLog
	$latestFile = Get-ChildItem -Path $adrPath -Filter "*.md" -Name -File |
        Where-Object Name -match '^[0-9]+-' |
        Sort-Object -Descending |
        Select-Object -First 1

	$nextSequenceNum = if ($latestFile) {
        $nextSequenceInt = [int]($latestFile.Name -split '-')[0] + 1
        $nextSequenceInt.ToString("0000")
	}
    else {
        "0000"
    }

	$slugifiedTitle = $title.ToLower().Replace(" ","-")
	$datePosted = Get-Date -Format "yyyy-MM-dd"

    $template = Get-Content -Path "$PSScriptRoot/templates/ADR-Template.md"
    $replacementTokens = @(
        @{ Token = '{{NUM}}'; Value = $nextSequenceNum }
        @{ Token = '{{DATE}}'; Value = $datePosted }
        @{ Token = '{{TITLE}}'; Value = $Title }
    )

    $newAdr = $template
    foreach ($token in $replacementTokens) {
        $newAdr = $newAdr -replace $token.Token, $token.Value
    }

    $newAdrPath = "${adrPath}/${nextSequenceNum}-${slugifiedTitle}.md"
    $newAdr | Set-Content -Path $newAdrPath

    Get-Item -Path $newAdrPath
}

$members = @{
    Function = 'Start-AdrLog', 'Get-AdrLog', 'New-Adr'
    Alias    = 'Adr-New', 'Adr-Init'
}
Export-ModuleMember @members
