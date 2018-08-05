# Get drive letter from CLI args. If drive letter not specified, request it
[string]$driveletter = $args[0]

if (-not $driveletter) {
    Write-Host "No disk selected"
    [string]$driveletter = Read-Host "Please enter a drive letter"
}

# Using drive letter, get the full device path
# and extract the UUID using a surely sub-optimal regex
[object]$fulldiskid = (Get-Partition | 
    Where DriveLetter -eq $driveletter | 
    Select DiskId | 
    Select-String "(\\\\\?\\.*?#.*?#)(.*)(#{.*})"
)

# If no disk can be found, exit
if (-not $fulldiskid) {
    Write-Host "Invalid drive letter"
    Break
}

# Get the UUID from the list of regex matches
[string]$diskid = $fulldiskid.Matches.Groups[2].Value

# Find the disk which matches the UUID obtained above
# and return the raw SMART data from the VendorSpecific property
[object]$rawsmartdata = (Get-WmiObject -Namespace 'Root\WMI' -Class 'MSStorageDriver_ATAPISMartData' |
        Where-Object 'InstanceName' -like "*$diskid*" |
        Select-Object -ExpandProperty 'VendorSpecific'
)

[array]$output = @()

# Starting at the third number (first two are irrelevant)
# get the relevant data by iterating over every 12th number
# and saving the values from an offset of the SMART attribute ID
For ($i = 2; $i -lt $rawsmartdata.Length; $i++) {
    If (0 -eq ($i - 2) % 12 -And $rawsmartdata[$i] -ne "0") {
        # Construct the raw attribute value by combining the two bytes that make it up
        [double]$rawvalue = ($rawsmartdata[$i + 6] * [math]::Pow(2, 8) + $rawsmartdata[$i + 5])
        $data = [pscustomobject]@{
            ID       = $rawsmartdata[$i]
            Flags    = $rawsmartdata[$i + 1]
            Value    = $rawsmartdata[$i + 3]
            Worst    = $rawsmartdata[$i + 4]
            RawValue = $rawvalue
        }
        $output += $data
    }
}

$output
