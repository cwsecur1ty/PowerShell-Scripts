# Enter printer IP & Name
$printerIP = "0.0.0.0"
$printerName = "Printer-Name"

# Define printer Port Name and Printer Port
$portName = "IP_$printerIP"
Add-PrinterPort -Name $portName -PrinterHostAddress $printerIP

# Add the printer
Add-Printer -Name $printerName -PortName $portName -DriverName "Microsoft IPP Class Driver"

Write-Output "Printer '$printerName' added successfully at IP address '$printerIP'."
