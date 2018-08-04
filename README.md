# GetSmartWin
A pure-Powershell solution for reading S.M.A.R.T. attributes from a hard drive.

Example usage:

Get all available SMART attributes:
```
getsmartwin.ps1 C | Format-Table

 ID Flags Value Worst RawValue
 -- ----- ----- ----- --------
  1    10   100   100        0
  2     5   100   100        0
  3     7   100   100        0
  5    19   100   100        0
  7    11   100   100        0
  8     5   100   100        0
  9    18   100   100     8966
 10    19   100   100        0
 12    18   100   100     1437
167    34   100   100        0
168    18   100   100        0
169    19   100   100      100
170    19   100   100        0
173    18   183   183        0
175    19   100   100        0
192    18   100   100      130
194    34    71    56       29
197    18   100   100        0
240    19   100   100        0
```

Get specific SMART attribute.
```
getsmartwin.ps1 C | Where-Object { $_.ID -eq 5 } | Format-Table

ID Flags Value Worst RawValue
-- ----- ----- ----- --------
 5    19   100   100        0
 ```
 
 Get disk power cycle count:
```
getsmartwin.ps1 C | Where-Object { $_.ID -eq 12 } | Select-Object -ExpandProperty R
awValue
1437
 ```
 
This was made as an offshoot of a different project that needed simple programatically-available SMART raw values without dependencies so it's very simple. Data display could be better. Providing names for SMART attributes, parsing the "Flags" values into useful output, and displaying other drive statistics are all areas of potential improvement. It could also gracefully handle drives that do not support the MSStorageDriver_ATAPISMartData WMI object but I don't have any to test on. Feel free to submit pull requests with improvements.

I tested this on a handfull of drives I had laying around, and compared data from several helpful members of the community at reddit.com/r/usefulscripts to see if there were any common outliers to account for. If you have a disk that does something unexpected, please open an issue with the results.
