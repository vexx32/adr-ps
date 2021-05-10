# 0003. Use PowerShell Approved verbs

Date: 2021-05-10

## Status

Accepted

## Context

See [PowerShell Approved Verbs][approved-verbs].

[approved-verbs]: https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.1

## Decision

The decision was made to adopt the PowerShell approved verbs to improve discoverability and clarity of module command names.
Existing commands will retain aliases which allow the old command names to be used if the user prefers.

## Consequences

- Module functions will need to be renamed.
- Commands will use a standardized verb which describes their behaviour, improving the accessibility and predictability of the commands.
