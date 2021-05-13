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
