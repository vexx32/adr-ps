# 0004. Separate Functions into Files

Date: 2021-05-13

## Status

Accepted

## Context

For development purposes, it's significantly easier to work with functions as individual files.
This simplifies any review processes, as well as keeping things organized and easy to find in the repository.

For development purposes, we can streamline the process by having an interim psm1 file stored in the repository.
This file simply manually imports everything the module uses, without requiring a build process.

For building the module for publishing purposes, a small build script can roll all the functions and setup code into a single-file PSM1.

## Decision

We will:

- Separate all current functions into files, placed in `public` or `private` folders as appropriate.
- Move module setup code or module-scope variable declarations into individual files in a `module-init` folder.
- Create a custom PSM1 used for development only, which automatically imports the individual files to streamline development and testing.
- Create a `build.ps1` script which will collate all the files necessary into a single PSM1 and copy the necessary templates to a built module folder, placed under a `.build` directory.
- Treat this `.build` directory as ephemeral, adding it to a `.gitignore` file.

## Consequences

We expect this to simplify code review and make developing and maintaining the module easier in future.
Users should not be impacted, as the built version of the module should end up identical to the previous design.
