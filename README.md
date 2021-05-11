# ADR-PS

A Powershell based command-line tool for working with [Lightweight Architecture Decision Records (ADRs)][adr-blog-post].

> "Lightweight Architecture Decision Records is a technique for capturing important architectural decisions along with their context and consequences.
> We recommend storing these details in source control, instead of a wiki or website, as then they can provide a record that remains in sync with the code itself. - Thoughtworks"

[adr-blog-post]: http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions

## Quick Start

`adr-ps` is a powershell module you can import in a normal powershell session.
The default destination directory is `doc/adr`.

1. Open Powershell CLI and import module

    ```powershell
    Import-Module .\adr.psd1
    ```

1. Create or open an ADR repository in the desired location (the current working directory is the default location).
   Once started, all ADR logs in this session will use this path.
   Run `Start-AdrLog` again with a new path to change the ADR log location for the session.

    ```powershell
    Start-AdrLog -Path $repositoryPath
    ```

1. Create an architecture decision record.

    ```powershell
    New-Adr -Title "My New Adr"
    ```

    ```code
    Id Name       Status  FullName
    -- ----       ------  --------
     4 My New Adr Unknown /Users/joel/repos/Github/adr-ps/doc/adr/0004-my-new-adr.md
    ```

1. List current ADRs

    ```powershell
    Get-Adr
    ```

    ```code
    Id Name                          Status   FullName
    -- ----                          ------   --------
     1 Record Architecture Decisions Accepted /Users/joel/repos/Github/adr-ps/doc/adr/0001-record-architecture-decisions.md
     2 Implement As Powershell       Accepted /Users/joel/repos/Github/adr-ps/doc/adr/0002-implement-as-powershell.md
     3 Use Powershell Approved Verbs Accepted /Users/joel/repos/Github/adr-ps/doc/adr/0003-use-powershell-approved-verbs.md
     4 My New Adr                    Unknown  /Users/joel/repos/Github/adr-ps/doc/adr/0004-my-new-adr.md
    ```

1. Help

    ```powershell
    # Comment-based help available for all module functions
    Get-Help Start-AdrLog
    ```

## Motivation

ADR-PS aims to help document architecturally significant functional and non-functional decisions through out solution lifetime to benefit current and future teams.
I also hope to promote ADR-technique into greater audience with more choice of tools.

The decisions on this tool are recorded as [architecture decision records in repository](https://github.com/rdagumampan/adr-ps/tree/master/doc/adr)

## References

- [Documenting Architecture Decisions](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions)
- [Lightweight ADRs](https://www.thoughtworks.com/radar/techniques/lightweight-architecture-decision-records)
