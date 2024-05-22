# Enter the IP of printer to be removed
$printerIP = "0.0.0.0"

# Get printers
$printers = Get-Printer

# Locate printer by given printerIP
$printerToRemove = $printers | Where-Object { $_.PortName -eq $printerIP }

if ($printerToRemove) {
    # Delete the printer
    Remove-Printer -Name $printerToRemove.Name
    Write-Output "Printer with IP address '$printerIP' removed successfully."
} else {
    Write-Output "No printer found with IP address '$printerIP'."
}
