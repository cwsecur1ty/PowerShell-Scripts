$adminEmail = "admin@company.com"
$alertEmail = "alerts@company.com"
$smtpServer = "smtp.company.com"

function Monitor-DiskSpace {
    param (
        [string]$driveLetter,
        [int]$threshold
    )

    $drive = Get-PSDrive -Name $driveLetter
    $freeSpace = $drive.Used

    if ($drive.Free -lt $threshold) {
        $emailBody = "Disk space on drive $driveLetter is below $threshold MB."
        Send-MailMessage -To $adminEmail -From $alertEmail -Subject "Disk Space Alert" -Body $emailBody -SmtpServer $smtpServer
        Write-Output "[Disk Monitor] Alert sent."
    } else {
        Write-Output "[Disk Monitor] Disk space is sufficient."
    }
}

# Example usage
# .\disk-monitor.ps1 -driveLetter "C" -threshold 1024

