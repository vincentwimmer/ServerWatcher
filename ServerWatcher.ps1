function Get-ComputerStats {
      param(
            [Parameter(Mandatory = $true, Position = 0, 
                  ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
            [ValidateNotNull()]
            [string[]]$ComputerName
      )
  
      process {
            foreach ($c in $ComputerName ) {
                  if ([bool](Test-Connection $ComputerName -Count 1 -ErrorAction SilentlyContinue)) {
                        $cpu = (Get-WmiObject win32_processor -computername $c | Measure-Object -property LoadPercentage -Average | Foreach { $_.Average })

                        #Weird powershell fix.
                        $avg = "" + $cpu + "%"

                        $mem = Get-WmiObject win32_operatingsystem -ComputerName $c |
                        Foreach { "{0:N2}" -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) * 100) / $_.TotalVisibleMemorySize) }

                        $freeC = Get-WmiObject Win32_Volume -ComputerName $c -Filter "DriveLetter = 'C:'" |
                        Foreach { "{0:N2}" -f ($_.FreeSpace / 1GB) }

                        $freeD = Get-WmiObject Win32_Volume -ComputerName $c -Filter "DriveLetter = 'D:'" |
                        Foreach { "{0:N2}" -f ($_.FreeSpace / 1GB) }

                        $net = if ([bool](Test-Connection -ComputerName google.com -Source $c -Count 1 -ErrorAction SilentlyContinue)) { $netresult = "Connected" } else { $netresult = "Disconnected" }

                        #Command ONLY works on Windows Server 2012 and forward (gcim vs Get-WmiObject).
                        $upt = Invoke-Command -ComputerName $c -ScriptBlock { ("" + ((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).days) + "-Days " + ((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).hours + "-Hours " + ((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).minutes + "-Mins"}

                        #UpTime Command for Windows Server 2008 and before.
                        #$upt = Get-WinEvent -ProviderName EventLog | Where-Object {$_.Id -eq 6005} | Select-Object -First 1 TimeCreated

                        #Color Text
                        if ( $cpu -lt 9 ) {
                              $Host.UI.RawUI.ForegroundColor = 'White'
                        }
                        if ( $cpu -gt 9 ) {
                              $Host.UI.RawUI.ForegroundColor = 'Green'
                        } 
                        if ( $cpu -gt 29 ) {
                              $Host.UI.RawUI.ForegroundColor = 'Yellow'
                        }
                        if ( $cpu -gt 69 ) {
                              $Host.UI.RawUI.ForegroundColor = 'Red'
                        }
                        if ( $netresult -eq "Disconnected" ) {
                              $Host.UI.RawUI.ForegroundColor = 'Red'
                        }

                        #Organize
                        #new-object psobject -prop  @{ # Work on PowerShell V2 and below
                        [pscustomobject] [ordered] @{ # Only if on PowerShell V3
                              'ComputerName' = $c
                              'AverageCpu'   = $avg
                              'MemoryUsage'  = $mem + '%'
                              'SpaceAvail_C' = $freeC + 'GB'
                              'SpaceAvail_D' = $freeD + 'GB'
                              'Internet'     = $netresult
                              'UpTime'       = $upt
                        }
                  }
                  else {
                        $Host.UI.RawUI.ForegroundColor = 'Red'
                        #Organize
                        #new-object psobject -prop  @{ # Work on PowerShell V2 and below
                        [pscustomobject] [ordered] @{ # Only if on PowerShell V3
                              'ComputerName' = $c
                              'AverageCpu'   = 'OFFLINE'
                              'MemoryUsage'  = 'OFFLINE'
                              'SpaceAvail_C' = 'OFFLINE'
                              'SpaceAvail_D' = 'OFFLINE'
                              'Internet'     = 'OFFLINE'
                              'UpTime'       = 'OFFLINE'
                        }
                  }
            }
      }
}


  

while ($true) {
      type '.\server.txt' | Get-ComputerStats | ft -AutoSize
      start-sleep -s 5
}
