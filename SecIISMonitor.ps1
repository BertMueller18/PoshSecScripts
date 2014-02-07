﻿<#
.Synopsis
  A PoshSec Framework function that monitors the current IIS log and generates alerts on specified criteria.  The alerts display the log's timestamp, the client IP, the URL accessed, and the user agent string.

.PARAMETER IP
  Client IP address to isolate in the log file.  Generates alerts for those records.
  
.PARAMETER Filter
  A string to search for to limit the log files returned

.PARAMETER Limit
  An integer value to indicate how many records to return from the log file.  Default is the most recent 100.

.PARAMETER Path
  Path to the IIS log files.  Default is C:\inetpub\logs\LogFiles\W3SVC1\
  
.PARAMETER Poll
  Integer indicating number of seconds to elapse between chacks on the log.  Default is 10.
  
.EXAMPLE
  Get an alert if anyone tries to view your robots.txt file.
   Start-SecIISMonitor -filter "robots.txt"

#>
param(
  [String]$IP = "",
  [String]$filter = "",
  [Int]$limit = 100,
  [String]$path = "C:\inetpub\logs\LogFiles\W3SVC1\",
  [int]$poll = 10
)

#Required to use PoshSec functions
Import-Module $PSModRoot\PoshSec

while($true){
  if([System.Net.IPAddress]::TryParse($IP,[ref] $null)){
     Get-SECIISlog -path $path -filter $filter -limit $limit | ForEach-Object {
      if($_.cIP -eq $IP){
        $PSAlert.Add($_.cIP + " " + $_.URL + " " + $_.Agent ,2)
      }
     }
   }
  else{ 
    Get-SECIISlog -path $path -filter $filter -limit $limit | ForEach-Object {
      $PSAlert.Add($_.LogDate + " " + $_.cIP + " " + $_.URL + " " + $_.Agent,2)
    }  
  }
  
  Start-Sleep -Second $poll
}


