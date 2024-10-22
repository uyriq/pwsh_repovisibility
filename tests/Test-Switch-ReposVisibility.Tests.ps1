Describe 'Switch-ReposVisibility' {
    BeforeAll {
        # Mock the GitHub CLI commands
        Mock -CommandName 'gh' -MockWith {
            param ($args)
            if ($args -contains 'repo' -and $args -contains 'list') {
                return '[{"name":"repo1","visibility":"PUBLIC","description":"Test repo 1"},{"name":"repo2","visibility":"PUBLIC","description":"Test repo 2"}]'
            }
            elseif ($args -contains 'repo' -and $args -contains 'view') {
                return '{"visibility":"PRIVATE"}'
            }
            elseif ($args -contains 'repo' -and $args -contains 'edit') {
                return '✓ Edited repository'
            }
            elseif ($args -contains 'api') {
                return '{"created_at":"2021-01-01T00:00:00Z","stargazers_count":10}'
            }
        }
    }

    It 'Should change the visibility of selected repos' {
        # Arrange
        $ghUser = "testuser"
        $visibility = "PRIVATE"
        $descpattern = $null

        # Act
        . ./reposvisibilitychange.ps1
        Switch-ReposVisibility -ghUser $ghUser -visibility $visibility -descpattern $descpattern

        # Assert
        Assert-MockCalled -CommandName 'gh' -Times 3
    }
}