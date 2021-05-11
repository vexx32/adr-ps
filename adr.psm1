$script:AdrLogFolder = "doc/adr"
$script:AdrDateFormat = "yyyy-MM-dd"

function Get-AdrLog {
    <#
        .SYNOPSIS
        Gets the current ADR log folder.

        .EXAMPLE
        PS> Get-AdrLog

            Directory: /example/folder/adr-ps/doc

        Mode                 LastWriteTime         Length Name
        ----                 -------------         ------ ----
        d----           5/11/2021  4:57 PM                adr

    #>
    [CmdletBinding()]
    param()

    Get-Item -LiteralPath $script:AdrLogFolder
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

    Get-AdrLog
}

function New-Adr {
    <#
        .SYNOPSIS
        Creates a new ADR from a template and adds it to the decision log.

        .DESCRIPTION
        Creates a new ADR file in the decision log with today's date and the
        next sequential number in the log.

        .EXAMPLE
        PS> New-Adr -Title "My New Adr"

        Id Name       Status  Path
        -- ----       ------  ----
         4 My New Adr Unknown /Users/joel/repos/Github/adr-ps/doc/adr/0004-my-new-adr.md
    #>
    [Alias('Adr-New')]
    param(
        # The title of the new ADR.
        [Parameter(Mandatory)]
        [string]
        $Title
    )

    $adrPath = Get-AdrLog
	$latestFile = Get-ChildItem -LiteralPath $adrPath.FullName -Filter "*.md" -File |
        Where-Object Name -match '^[0-9]+-' |
        Sort-Object -Descending |
        Select-Object -First 1

    $nextSequenceInt = if ($latestFile) {
        [int]($latestFile.Name -split '-')[0] + 1
	}
    else {
        1
    }

    $nextSequenceNum = $nextSequenceInt.ToString("0000")

	$slugifiedTitle = $title.ToLower().Replace(" ","-")
    $datePosted = Get-Date -Format $script:AdrDateFormat

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

    Get-Adr -Id $nextSequenceInt
}

function Get-Adr {
    <#
        .SYNOPSIS
        Gets ADRs from the current ADR log.

        .DESCRIPTION
        Gets one or more ADRs from the current ADR log folder, displaying its Id, Status, Name, and Path.
        ADRs can be filtered by Name, ID, and State.

        .EXAMPLE
        PS> Get-Adr

        Id Name                          Status   Path
        -- ----                          ------   ----
         1 Record Architecture Decisions Accepted /Users/joel/repos/Github/adr-ps/doc/adr/0001-record-architecture-decisions.md
         2 Implement As Powershell       Accepted /Users/joel/repos/Github/adr-ps/doc/adr/0002-implement-as-powershell.md
         3 Use Powershell Approved Verbs Accepted /Users/joel/repos/Github/adr-ps/doc/adr/0003-use-powershell-approved-verbs.md
         4 My New Adr                    Unknown  /Users/joel/repos/Github/adr-ps/doc/adr/0004-my-new-adr.md
    #>
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        # Name(s) of the ADR to look for. Accepts wildcard patterns.
        [Parameter(ParameterSetName = 'Name', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name = '*',

        # Id(s) of the ADRs to look for.
        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipelineByPropertyName)]
        [ValidateRange(1, 9999)]
        [int[]]
        $Id,

        # Filter ADRs retrieved by the state of the ADR.
        [Parameter()]
        [ValidateSet('Proposed', 'Accepted', 'Rejected', 'Superseded', 'Deprecated')]
        $State
    )
    begin {
        $filterParams = @{ Filter = '*.md' }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Name' {
                $filterParams['Include'] = $Name | ForEach-Object { "*-$_.md" }
            }
            'Id' {
                $filterParams['Include'] = $Id | ForEach-Object { "$($_.ToString('0000'))-*.md" }
            }
        }

        Get-AdrLog |
            Get-ChildItem @filterParams |
            Where-Object {
                $_.Name -Match '^[0-9]+-' -and (
                    -not $State -or
                    (Get-Content -Raw -LiteralPath $_.FullName) -match "## Status[\r\n\s]+$State"
                )
            } |
            Select-Object -Property @(
                @{ Name = 'Id'; Expression = { $_.BaseName -replace '[^0-9]' -as [int] } }
                @{
                    Name = 'Name'
                    Expression = {
                        $name = ($_.BaseName -replace '[0-9]' -replace '-', ' ').Trim()
                        [cultureinfo]::CurrentCulture.TextInfo.ToTitleCase($name)
                    }
                }
                @{
                    Name = 'Status'
                    Expression = {
                        $adrText = Get-Content -Raw -LiteralPath $_.FullName
                        if ($adrText -match "## Status[\r\n\s]+(?<Status>[a-z]+)") {
                            $matches.Status
                        }
                        else {
                            'Unknown'
                        }
                    }
                }
                @{ Name = 'Path'; Expression = 'FullName' }
            )
    }
}

function Set-Adr {
    <#
        .SYNOPSIS
        Updates the status of an existing ADR by ID.

        .EXAMPLE
        PS> Set-Adr -Id 4 -Status Rejected -PassThru

        Id Name                          Status   Path
        -- ----                          ------   ----
         4 My New Adr                    Rejected /Users/joel/repos/Github/adr-ps/doc/adr/0004-my-new-adr.md
    #>
    [CmdletBinding()]
    param(
        # ID(s) of the ADR(s) to update the status of.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int[]]
        $Id,

        # The status to update the ADR(s) with.
        [Parameter(Mandatory)]
        [ValidateSet('Proposed', 'Accepted', 'Rejected', 'Superseded', 'Deprecated')]
        [string]
        $Status,

        [Parameter()]
        [switch]
        $PassThru
    )
    process {
        Get-Adr -Id $Id | ForEach-Object {
            $adrText = Get-Content -Path $_.Path -Raw
            $adrText -replace '(?<=## Status[\r\n\s]+)[a-z]+(?=[\r\n\s]+##)', $Status |
                Set-Content -Path $_.Path -NoNewline

            if ($PassThru) {
                Get-Adr -Id $_.Id
            }
        }
    }
}
