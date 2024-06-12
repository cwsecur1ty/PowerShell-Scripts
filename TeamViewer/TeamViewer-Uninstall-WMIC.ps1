# Stop TeamViewer service if running
$service = Get-Service -Name "TeamViewer" -ErrorAction SilentlyContinue
if ($service -and $service.Status -ne 'Stopped') {
    Write-Host "Stopping TeamViewer service..."
    Stop-Service -Name "TeamViewer" -Force
    Write-Host "TeamViewer service stopped."
} else {
    Write-Host "TeamViewer service not found or already stopped."
}

# Terminate any running TeamViewer processes
$teamViewerProcesses = Get-Process -Name "TeamViewer" -ErrorAction SilentlyContinue
if ($teamViewerProcesses) {
    Write-Host "Terminating TeamViewer processes..."
    $teamViewerProcesses | Stop-Process -Force
    Write-Host "TeamViewer processes terminated."
} else {
    Write-Host "No TeamViewer processes found."
}

# Uninstall TeamViewer using WMIC
$teamViewerProduct = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'TeamViewer%'"
if ($teamViewerProduct) {
    Write-Host "TeamViewer found. Uninstalling..."
    $uninstallResult = $teamViewerProduct.Uninstall()
    if ($uninstallResult.ReturnValue -eq 0) {
        Write-Host "TeamViewer uninstalled successfully."
    } else {
        Write-Host "Failed to uninstall TeamViewer. ReturnValue: $($uninstallResult.ReturnValue)"
    }
} else {
    Write-Host "TeamViewer not found on this machine."
}

# End script
exit 0
