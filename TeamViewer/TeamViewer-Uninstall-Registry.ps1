# Query the registry for TeamViewer uninstall string
$uninstallKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "TeamViewer*" }

if ($uninstallKey) {
    Write-Host "TeamViewer found. Uninstalling..."
    $uninstallString = $uninstallKey.UninstallString
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallString /quiet /norestart" -Wait -NoNewWindow
    Write-Host "TeamViewer uninstalled successfully."
} else {
    Write-Host "TeamViewer not found on this machine."
}

# End script
exit 0
