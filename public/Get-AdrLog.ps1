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
