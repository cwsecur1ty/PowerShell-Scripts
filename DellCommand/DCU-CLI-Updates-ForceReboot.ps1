# Run DCU-CLI -> Apply Updates & Force Reboot
function Update-DellWithReboot {
    # Define the path to the Dell Command Update CLI (change based on install location)
    $dcuCliPath = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"

    # Check if DCU-CLI Exists
    if (-Not (Test-Path $dcuCliPath)) {
        Write-Error "Dell Command Update CLI not found at $dcuCliPath"
        return
    }

    Write-Output "Starting Dell Command Update with forced reboot..."

    # Run the Dell Command Update to apply updates and force reboot
    $process = Start-Process -FilePath $dcuCliPath -ArgumentList "/applyUpdates -reboot=enable -silent" -NoNewWindow -PassThru -Wait -ErrorAction Stop

    Write-Output "Dell Command Update process started with ID $($process.Id). Waiting for it to complete..."

    # Capture Exit Code
    $exitCode = $process.ExitCode

    if ($null -eq $exitCode) {
        Write-Error "Failed to retrieve the exit code. The process may not have completed correctly."
        return
    }

    switch ($exitCode) {
        0 { Write-Output "Dell updates applied successfully with forced reboot." }
        1 { Write-Warning "A reboot was required from the execution of an operation. Please reboot the system to complete the operation." }
        2 { Write-Error "An unknown application error has occurred." }
        3 { Write-Error "The current system manufacturer is not Dell. Dell Command | Update can only be run on Dell systems." }
        4 { Write-Error "The CLI was not launched with administrative privilege. Please run the script with administrative privileges." }
        5 { Write-Warning "A reboot was pending from a previous operation. Please reboot the system to complete the operation." }
        6 { Write-Error "Another instance of the same application (UI or CLI) is already running. Close any running instance of Dell Command | Update UI or CLI and retry the operation." }
        7 { Write-Error "The application does not support the current system model. Contact your administrator for support." }
        8 { Write-Error "No update filters have been applied or configured. Supply at least one update filter." }
        500 { Write-Output "No updates were found for the system. The system is up to date or no updates matched the provided filters." }
        501 { Write-Error "An error occurred while determining the available updates for the system. Retry the operation." }
        502 { Write-Error "The scan operation was canceled. Retry the operation." }
        503 { Write-Error "An error occurred while downloading a file during the scan operation. Check your network connection and retry the command." }
        default { Write-Error "Dell Command Update failed with exit code $exitCode." }
    }
}

Update-DellWithReboot
