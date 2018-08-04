$driveletter = $args[0]

if (-not $driveletter) {
    Write-Host "No disk selected"
    $driveletter = Read-Host "Please enter a drive letter"
}

$fulldiskid = Get-Partition | Where DriveLetter -eq $driveletter | Select DiskId | Select-String "(\\\\\?\\.*?#.*?#)(.*)(#{.*})"

if (-not $fulldiskid) {
    Write-Host "Invalid drive letter"
    Break
}

$diskid = $fulldiskid.Matches.Groups[2].Value

Write-Host $diskid

[object]$rawsmartdata = (Get-WmiObject -Namespace 'Root\WMI' -Class 'MSStorageDriver_ATAPISMartData' |
        Where-Object 'InstanceName' -like "*$diskid*" |
        Select-Object -ExpandProperty 'VendorSpecific'
)

[array]$output = @()

For ($i = 2; $i -lt $rawsmartdata.Length; $i++) {
    If (0 -eq ($i - 2) % 12 -And $rawsmartdata[$i] -ne "0") {
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

$output | Format-Table
