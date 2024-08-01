function Remove-UserProfiles {
    # Get all user profiles (excluding system profiles)
    $profiles = Get-WmiObject Win32_UserProfile | Where-Object {
        $_.Special -eq $false -and $_.LocalPath -notmatch 'C:\\Users\\(Default|Public)'
    }

    foreach ($profile in $profiles) {
        try {
            Write-Host "Removing profile for user: $($profile.LocalPath)"
            Remove-WmiObject -Path "Win32_UserProfile.SID='$($profile.SID)'"
        } catch {
            Write-Warning "Failed to remove profile: $($profile.LocalPath). Error: $_"
        }
    }
}

Remove-UserProfiles
Write-Host "User profile cleanup completed"

# Remove-UserProfiles Function: This function retrieves all user profiles excluding system profiles ("Default" and "Public") using WMI (Win32_UserProfile).
# Filtering Profiles: Profiles are filtered to exclude system profiles.
# Removing Profiles: For each non-system profile, tries to remove the profile using Remove-WmiObject.