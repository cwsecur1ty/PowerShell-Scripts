﻿# Function to check for updates and install them
function Install-WindowsUpdates {
    # Import the Update Session COM object
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $searchResult = $updateSearcher.Search("IsInstalled=0")

    if ($searchResult.Updates.Count -eq 0) {
        Write-Host "No updates available."
        return
    }

    Write-Host "$($searchResult.Updates.Count) updates found."

    # Create an UpdateCollection object
    $updatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl

    # Add each update to the collection
    for ($i = 0; $i -lt $searchResult.Updates.Count; $i++) {
        $updatesToInstall.Add($searchResult.Updates.Item($i))
    }

    # Download updates
    $downloader = $updateSession.CreateUpdateDownloader()
    $downloader.Updates = $updatesToInstall
    $downloadResult = $downloader.Download()

    if ($downloadResult.ResultCode -ne 2) {
        Write-Host "Error downloading updates."
        return
    }

    Write-Host "Updates downloaded."

    # Install updates
    $installer = $updateSession.CreateUpdateInstaller()
    $installer.Updates = $updatesToInstall
    $installationResult = $installer.Install()

    Write-Host "Installation Result: $($installationResult.ResultCode)"
    Write-Host "Reboot Required: $($installationResult.RebootRequired)"
    
    if ($installationResult.RebootRequired) {
        Restart-Computer -Force
    }
}

# Run the function to check for and install updates
Install-WindowsUpdates
