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
