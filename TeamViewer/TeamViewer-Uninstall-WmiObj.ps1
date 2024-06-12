if ($env:PROCESSOR_ARCHITECTURE -eq "x86" -and $env:PROCESSOR_ARCHITEW6432) {
    Write-Host "Restarting script in 64-bit context..."
    & "$env:WINDIR\sysnative\WindowsPowerShell\v1.0\powershell.exe" -File $PSCommandPath
    exit
}

# Find & Uninstall TV
$teamViewer = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "TeamViewer*" }

if ($teamViewer) {
    Write-Host "Found TeamViewer. Attempting to uninstall..."
    $teamViewer.Uninstall() | Out-Null
    Write-Host "TeamViewer uninstalled successfully."
} else {
    Write-Host "TeamViewer is not on this machine."
}

# Exit script
exit 0
