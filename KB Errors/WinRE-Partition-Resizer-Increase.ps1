# This .PS1 resizes the WinRE partition to get around update errors with: KB5028997, KB5034441
# Error code given from Windows Updates: 0x80070643 
# https://support.microsoft.com/en-gb/topic/kb5028997-instructions-to-manually-resize-your-partition-to-install-the-winre-update-400faa27-9343-461c-ada9-24c8229763bf

# Function to run commands and handle errors
function Run-Command {
    param (
        [string]$cmd,
        [string]$errorMsg
    )
    try {
        Invoke-Expression $cmd
    } catch {
        Write-Host $errorMsg -ForegroundColor Red
        exit
    }
}

# Function to run DiskPart commands
function Run-DiskPart {
    param (
        [string]$script
    )
    return diskpart /s $script
}

# Check WinRE status
$winreInfo = Run-Command "reagentc /info" "Failed to check WinRE status."
$winreLocation = ($winreInfo | Select-String -Pattern "Windows RE location").Line

if (-not $winreLocation) {
    Write-Host "Failed to determine the WinRE location." -ForegroundColor Red
    exit
}

$diskIndex = $winreLocation -match "harddisk(\d+)" | Out-Null; $matches[1]
$partitionIndex = $winreLocation -match "partition(\d+)" | Out-Null; $matches[1]

# Disable WinRE
Run-Command "reagentc /disable" "Failed to disable WinRE."

# List disks and find OS disk index
$diskpartScript = @"
list disk
"@
$diskpartOutput = Run-DiskPart $diskpartScript

$osDiskIndex = ($diskpartOutput | Select-String -Pattern "\*.*GPT").Line.Split()[0]

if (-not $osDiskIndex) {
    Write-Host "Failed to determine the OS disk index." -ForegroundColor Red
    exit
}

# List partitions and find OS partition index
$diskpartScript = @"
sel disk $osDiskIndex
list part
"@
$diskpartOutput = Run-DiskPart $diskpartScript

$osPartitionIndex = ($diskpartOutput | Select-String -Pattern "Primary").Line.Split()[0]

if (-not $osPartitionIndex) {
    Write-Host "Failed to determine the OS partition index." -ForegroundColor Red
    exit
}

# Shrink OS partition
$diskpartScript = @"
sel disk $osDiskIndex
sel part $osPartitionIndex
shrink desired=250 minimum=250
"@
Run-Command "diskpart /s `$diskpartScript" "Failed to shrink the OS partition."

# Select and delete WinRE partition
$diskpartScript = @"
sel disk $osDiskIndex
sel part $partitionIndex
delete partition override
"@
Run-Command "diskpart /s `$diskpartScript" "Failed to delete the WinRE partition."

# Check if disk is GPT or MBR
$diskpartScript = @"
list disk
"@
$diskpartOutput = Run-DiskPart $diskpartScript

$isGPT = ($diskpartOutput | Select-String -Pattern "\*.*GPT").Count -gt 0

# Create new recovery partition
if ($isGPT) {
    $diskpartScript = @"
sel disk $osDiskIndex
create partition primary id=de94bba4-06d1-4d40-a16a-bfd50179d6ac
gpt attributes=0x8000000000000001
"@
} else {
    $diskpartScript = @"
sel disk $osDiskIndex
create partition primary id=27
"@
}
Run-Command "diskpart /s `$diskpartScript" "Failed to create the new recovery partition."

# Format the partition
$diskpartScript = @"
sel disk $osDiskIndex
sel part $partitionIndex
format quick fs=ntfs label='Windows RE tools'
"@
Run-Command "diskpart /s `$diskpartScript" "Failed to format the recovery partition."

if (-not $isGPT) {
    $diskpartScript = @"
sel disk $osDiskIndex
sel part $partitionIndex
set id=27
"@
    Run-Command "diskpart /s `$diskpartScript" "Failed to set the partition ID."
}

# Confirm the new WinRE partition
$diskpartScript = @"
list vol
"@
Run-Command "diskpart /s `$diskpartScript" "Failed to list volumes."

# Re-enable WinRE
Run-Command "reagentc /enable" "Failed to re-enable WinRE."

# Confirm WinRE status
Run-Command "reagentc /info" "Failed to check WinRE status."
