[![Release](https://github.com/uyriq/pwsh_repovisibility/actions/workflows/release_gh.yml/badge.svg)](https://github.com/uyriq/pwsh_repovisibility/actions/workflows/release_gh.yml)
[![Pester](https://github.com/uyriq/pwsh_repovisibility/actions/workflows/pester.yml/badge.svg)](https://github.com/uyriq/pwsh_repovisibility/actions/workflows/pester.yml)
[![License: Unlicense](https://img.shields.io/badge/License-Unlicense-blue.svg)](https://unlicense.org/)
[![GitHub release](https://img.shields.io/github/release/uyriq/pwsh_repovisibility.svg)](https://https://github.com/uyriq/pwsh_repovisibility/releases/)

# Switch-ReposVisibility.ps1

1. **Overview**: Provides a brief description of the script and its functionality.
2. **Prerequisites**: Lists the prerequisites for running the script, including the GitHub CLI.
3. **Usage**: Provides examples of how to use the script with different parameters.
4. **Notes**: Includes additional information about the script, such as the file name, author, and prerequisites.
5. **License**: Mentions the license under which the project is distributed.

## Overview

`Switch-ReposVisibility.ps1` is a PowerShell script that lists all repositories of a given GitHub user using the GitHub CLI and allows toggling their visibility between public and private. The script can be run interactively or in batch mode by providing a pattern to match repository descriptions or names.

## Prerequisites

- **GitHub CLI (gh)**: The GitHub CLI must be installed and authenticated.
  - [GitHub CLI Installation Guide](https://cli.github.com/)

## Usage

The script is supplied as a function, which means that it must be imported in your shell in a convenient way before you can use it

```Pwsh
. . \Switch-ReposVisibility.ps1
# or
source ./Switch-ReposVisibility.ps1
```

then

Switch-ReposVisibility <supported parameters>

### Parameters

- `ghUser`: The GitHub username whose repositories will be listed. Default is `"uyriq"`, you need to change this.
- `visibility`: The visibility to set for the repositories. Default is `"PRIVATE"`. This will list all public repos and allow you to set them to private.
- `descpattern`: A pattern to partially match with the description or repository name. If provided, only repositories matching this pattern will be processed in batch non-interactive mode.

### Examples

#### Example 1: Default Parameters

```powershell
Switch-ReposVisibility

```

This will list all public repositories for the user `uyriq` and allow you to set them to private interactively.

#### Example 2: Custom Parameters

```powershell
Switch-ReposVisibility -ghUser "your_github_username" -visibility "PUBLIC"
```

This will list all private repositories for the user `your_github_username` and allow you to set them to public interactively.

#### Example 3: Description Pattern

```powershell
Switch-ReposVisibility -ghUser "your_github_username" -descpattern "some repeated text in repo description section"
```

This will process all repositories for the user `your_github_username` that have "text pattern" in their description or name and toggle their visibility to the specified value in batch mode.

### Notes

To change the visibility of a repository, the script uses the GITHUB API with the command `gh repo edit $ghUser/$repoName --visibility $visibility`. Not in all cases does the output of the `✓ Edited repository` of this API command mean that the repository visibility parameter has actually been changed. I don't know yet why, but I can say that my pinned repositories and a few others are not handled by this command, so the only thing to do is to go into the reponame/settings danger zone and fix the problem manually.

### License

This project is licensed under the Unlicense. See the [LICENSE.txt](#file:LICENSE.txt-context) file for details.
