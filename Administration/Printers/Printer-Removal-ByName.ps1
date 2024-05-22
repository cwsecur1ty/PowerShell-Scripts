# Enter the name of the printer to be removed from system/s
$printerName = "Retail Finance"

# Get printer obj
$printer = Get-Printer -Name $printerName -ErrorAction SilentlyContinue

if ($printer) {
    # Remove printer from system
    Remove-Printer -Name $printerName
    Write-Output "Printer '$printerName' removed successfully."
} else {
    Write-Output "Printer '$printerName' not found."
}
