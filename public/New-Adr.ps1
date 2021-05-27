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
        Where-Object Name -Match '^[0-9]+-' |
        Sort-Object -Descending |
        Select-Object -First 1

    $nextSequenceInt = if ($latestFile) {
        [int]($latestFile.Name -split '-')[0] + 1
    }
    else {
        1
    }

    $nextSequenceNum = $nextSequenceInt.ToString("0000")

    $slugifiedTitle = $title.ToLower().Replace(" ", "-")
    $datePosted = Get-Date -Format $script:AdrDateFormat

    $template = Get-Content -Path "$script:ModuleRoot/templates/ADR-Template.md"
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
