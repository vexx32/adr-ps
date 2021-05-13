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
                    Name       = 'Name'
                    Expression = {
                        $name = ($_.BaseName -replace '[0-9]' -replace '-', ' ').Trim()
                        [cultureinfo]::CurrentCulture.TextInfo.ToTitleCase($name)
                    }
                }
                @{
                    Name       = 'Status'
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
