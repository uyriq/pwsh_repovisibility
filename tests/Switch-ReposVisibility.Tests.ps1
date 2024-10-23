Describe 'Switch-ReposVisibility' {
  BeforeAll {
    # Mock the GitHub CLI commands

    # Mock for getting the list of repos
    Mock -CommandName 'gh' -ParameterFilter { $args -contains 'repo' -and $args -contains 'list' } -MockWith {
      return @'
[
    {
        "description": "I’m currently learning React",
        "name": "uyriq",
        "visibility": "PUBLIC"
    },
    {
        "description": "",
        "name": "pwsh_repovisibility",
        "visibility": "PUBLIC"
    },
    {
        "description": "nextjs 14.2.10 test react-floater popups using boilerplate",
        "name": "react-floater-example",
        "visibility": "PRIVATE"
    },
    {
        "description": "Created with CodeSandbox",
        "name": "react-redux-1",
        "visibility": "PRIVATE"
    },
    {
        "description": "Created with CodeSandbox",
        "name": "react-use-reducer",
        "visibility": "PRIVATE"
    }
]
'@
    }

    # Mock for checking the visibility of a repository
    Mock -CommandName 'gh' -ParameterFilter { $args -contains 'repo' -and $args -contains 'view' } -MockWith {
      return '{"visibility":"PRIVATE"}'
    }

    # Mock for getting additional repo details
    Mock -CommandName 'gh' -ParameterFilter { $args -contains 'api' } -MockWith {
      return '{"created_at":"2022-05-05T16:16:27Z","stargazers_count":0}'
    }

    # Mock for editing the visibility of a repository
    Mock -CommandName 'gh' -ParameterFilter { $args -contains 'repo' -and $args -contains 'edit' } -MockWith {
      param ($ghUser, $repoName, $visibility)
      return "✓ Edited repository $ghUser/$repoName"
    }

    # Mock user input for Read-Host to return a valid selection
    Mock -CommandName 'Read-Host' -MockWith { '0,1' }
  }

  It 'Should change the visibility of selected repos' {
    # Arrange
    $ghUser = "testuser"
    $visibility = "PRIVATE"
    $descpattern = $null

    # Act
    try {
      . "$PSScriptRoot/../Switch-ReposVisibility.ps1"
      Write-Host "Debug: Successfully sourced Switch-ReposVisibility.ps1"
    }
    catch {
      Write-Host "Debug: Failed to source Switch-ReposVisibility.ps1"
      Write-Host "Error details: $_"
      throw
    }
        
    Switch-ReposVisibility -ghUser $ghUser -visibility $visibility -descpattern $descpattern

    # Assert
    Assert-MockCalled -CommandName 'gh' -ParameterFilter { $args -contains 'repo' -and $args -contains 'list' } -Times 1
    Assert-MockCalled -CommandName 'gh' -ParameterFilter { $args -contains 'repo' -and $args -contains 'view' } -Times 2
    Assert-MockCalled -CommandName 'gh' -ParameterFilter { $args -contains 'repo' -and $args -contains 'edit' } -Times 2
    Assert-MockCalled -CommandName 'gh' -ParameterFilter { $args -contains 'api' } -Times 2
  }
}
