$report = @()

# Check IP Config /all
$ipConfig = ipconfig /all
$report += "IP Configuration:`n$ipConfig"

# Ping Default Gateway
$gateway = (Get-NetRoute | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' }).NextHop
if (Test-Connection -ComputerName $gateway -Count 2 -Quiet) {
    $report += "Successfully pinged the default gateway ($gateway)."
} else {
    $report += "Failed to ping the default gateway ($gateway)."
    # Attempt to reset network adapter
    Write-Output "Resetting network adapter..."
    Get-NetAdapter | Disable-NetAdapter -Confirm:$false
    Start-Sleep -Seconds 5
    Get-NetAdapter | Enable-NetAdapter -Confirm:$false
    $report += "Network adapter reset attempted."
}
$report += ""

# DNS
try {
    $dnsTest = Resolve-DnsName www.google.com -ErrorAction Stop
    $report += "DNS resolution is working."
} catch {
    $report += "DNS resolution failed."
    # Attempt to flush DNS
    Write-Output "Flushing DNS cache..."
    ipconfig /flushdns
    $report += "DNS cache flushed."
    # Retry DNS resolution
    try {
        $dnsTestRetry = Resolve-DnsName www.google.com -ErrorAction Stop
        if ($dnsTestRetry) {
            $report += "DNS resolution working after flushing DNS."
        }
    } catch {
        $report += "DNS resolution still failing after flushing DNS."
    }
}
$report += ""

# Connectivity Test
if (Test-Connection -ComputerName www.google.com -Count 2 -Quiet) {
    $report += "Internet connectivity is working."
} else {
    $report += "Internet connectivity failed."
    # Attempt to restart network adapter
    Write-Output "Restarting network adapter..."
    Get-NetAdapter | Disable-NetAdapter -Confirm:$false
    Start-Sleep -Seconds 5
    Get-NetAdapter | Enable-NetAdapter -Confirm:$false
    # Retry internet connectivity test
    if (Test-Connection -ComputerName www.google.com -Count 2 -Quiet) {
        $report += "Internet connectivity working after restarting network adapter."
    } else {
        $report += "Internet connectivity still failing after restarting network adapter."
    }
}
$report += ""

# Output the results to a file
$reportContent = $report -join "`n"
$reportContent | Out-File -FilePath "C:\NetworkTroubleshootReport.txt"
Write-Output "Network troubleshooting report generated at C:\NetworkTroubleshootReport.txt"
