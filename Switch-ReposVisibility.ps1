#!/usr/bin/env pwsh

<#
.SYNOPSIS
    List given user repos that are private or public and allow toggling their visibility using GitHub CLI interactivelly or in batch by given pattern.

.DESCRIPTION
    The script lists all repositories of a given user using the GitHub CLI and allows toggling their visibility between public and private.

.NOTES 
    File Name      : Switch-ReposVisibility.ps1
    Author         : Uyriq
    Prerequisite   : GitHub CLI (gh) must be installed and authenticated.
    GitHub CLI     : https://cli.github.com/
    
.PARAMETER ghUser
    The GitHub username whose repositories will be listed. Default is "uyriq".

.PARAMETER visibility
    The visibility to set for the repositories. Default is "PRIVATE". So list all public repos and allow you to set them to private.

.PARAMETER descpattern
    A pattern to partially match with the description or repository name. If provided, only repositories matching this pattern will be processed in batch non-interactive.

.EXAMPLE
    # Example usage with default parameters
    Switch-ReposVisibility

.EXAMPLE
    # Example usage with custom parameters
    Switch-ReposVisibility -ghUser "your_github_username" -visibility "PUBLIC"

.EXAMPLE
    # Example usage with description pattern
    Switch-ReposVisibility -ghUser "your_github_username" -descpattern "Created with"
#>

function Switch-ReposVisibility {
    param (
        [string]$ghUser = "uyriq",
        [string]$visibility = "private",
        [string]$descpattern = $null
    )
    
   

    # Set output encoding to UTF-8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    # Check GitHub CLI authentication status
    $authStatus = Invoke-Expression "gh auth status --active 2>&1"
    
    $loggedInUser = $authStatus | Select-String -Pattern "Logged in to github.com account (\w+)" | ForEach-Object {
        if ($_ -match "Logged in to github.com account (\w+)") {
            $matches[1]
        }
    }

    if ($loggedInUser) {
        Write-Host "GitHub CLI authentication successful. Logged in as: $loggedInUser"
        if ($loggedInUser -ne $ghUser) {
            Write-Host "Warning: The logged-in user ($loggedInUser) does not match the provided user ($ghUser)."
            return
        }
    }
    else {
        Write-Host "GitHub CLI authentication failed. Please log in using 'gh auth login'."
        return
    }

    # begin work
    Write-Host "Switching visibility for user: $ghUser to $visibility"

    # Get list of repos
    $reposJson = Invoke-Expression "gh repo list $ghUser --json name,visibility,description"
    $repos = $reposJson | ConvertFrom-Json
    
    # Filter repos based on description pattern if provided
    if ($descpattern) {
        $repos = $repos | Where-Object { $_.description -match $descpattern -or $_.name -match $descpattern }
    }

    # Function to check the visibility of a repository
    function Check-RepoVisibility {
        param (
            [string]$repoName
        )
        $actualVisibility = Invoke-Expression "gh repo view $ghUser/$repoName --json visibility --jq '.visibility'"
        return $actualVisibility
    }

    # Function to get additional repo details
    function Get-RepoDetails {
        param (
            [string]$repoName
        )
        $detailsJson = Invoke-Expression "gh api --method GET repos/$ghUser/$repoName --jq '{created_at: .created_at, stargazers_count: .stargazers_count}'"
        $details = $detailsJson | ConvertFrom-Json
        return $details
    }

    # If descpattern is provided, toggle visibility directly
    if ($descpattern) {
        $repos | ForEach-Object {
            $repo = $_
            $repoName = $repo.name
            $command = "gh repo edit $ghUser/$repoName --visibility $visibility"
            Write-Host "Executing: $command"
            try {
                $result = Invoke-Expression $command
                Write-Host "Command result: $result"
                if ($LASTEXITCODE -eq 0) {
                    # Verify the visibility change
                    $newVisibility = Check-RepoVisibility -repoName $repoName
                    Write-Host "Expected visibility: $visibility, Actual visibility: $newVisibility"
                    if ($newVisibility -eq $visibility) {
                        Write-Host "Changed visibility of $repoName to $newVisibility"
                    }
                    else {
                        Write-Host "Failed to change visibility of $repoName. Expected: $visibility, Actual: $newVisibility"
                    }
                }
                else {
                    Write-Host "Failed to change visibility of $repoName. Command: $command"
                }
            }
            catch {
                Write-Host "Error executing command: $command"
                Write-Host "Error details: $_"
            }
        }
        # Exit the function
        return
    }
    else {
        # Filter repos to display only those with visibility not matching the desired visibility
        $reposToDisplay = $repos | Where-Object { $_.visibility -ne $visibility }

        # Display list with numbers and additional details
        $reposToDisplay | ForEach-Object -Begin { $i = 0 } -Process {
            $repo = $_
            $repoName = $repo.name
            $repoVisibility = $repo.visibility
            $repoDescription = $repo.description
            $repoDetails = Get-RepoDetails -repoName $repoName
            $createdAt = $repoDetails.created_at
            $stars = $repoDetails.stargazers_count
            Write-Host "$i. $repoName ($repoVisibility): $repoDescription"
            Write-Host "   Created at: $createdAt, Stars: $stars"
            $i++
        }

        # Prompt user to select repos to change visibility
        $selectedNumbers = Read-Host "Enter the numbers of the repos to change visibility to $visibility (comma-separated, ranges allowed e.g., 1,3,5-7) or press Control+C to exit"
        $selectedNumbersArray = @()

        # Parse the input to handle ranges and individual numbers
        $selectedNumbers -split "," | ForEach-Object {
            if ($_ -match "^(\d+)-(\d+)$") {
                $start = [int]$matches[1]
                $end = [int]$matches[2]
                $selectedNumbersArray += $start..$end
            }
            elseif ($_ -match "^\d+$") {
                $selectedNumbersArray += [int]$_.Trim()
            }
            else {
                Write-Host "Invalid selection is: $_"
            }
        }
 
        # Change visibility of selected repos
        $selectedNumbersArray | ForEach-Object {
            $index = $_
            if ($index -ge 0 -and $index -lt $reposToDisplay.Count) {
                $repo = $reposToDisplay[$index]
                $repoName = $repo.name
                # get current state of visibility of repo with Check-RepoVisibility -repoName $repoName
                $curVisibility = Check-RepoVisibility -repoName $repoName
                $command = "gh repo edit $ghUser/$repoName --visibility $visibility"
                Write-Host "Executing: $command"
                try {
                    $result = Invoke-Expression $command
                    Write-Host "Command result: $result"
                    if ($LASTEXITCODE -eq 0) {
                        # Verify the visibility change
                        $newVisibility = Check-RepoVisibility -repoName $repoName
                        Write-Host "Expected visibility: $visibility, Actual visibility: $newVisibility"
                        if ($curVisibility -ne $newVisibility) {
                            Write-Host "Changed visibility of $repoName to $newVisibility"
                        }
                        else {
                            Write-Host "Result: $result The visibility of $repoName stays unchanged. Command: $command"
                        }
                    }
                    else {
                        Write-Host "Failed to change visibility of $repoName. Command: $command"
                    }
                }
                catch {
                    Write-Host "Error executing command: $command"
                    Write-Host "Error details: $_"
                }
            }
            else {
                Write-Host "Invalid selection: $index"
            }
        }
    }
}
