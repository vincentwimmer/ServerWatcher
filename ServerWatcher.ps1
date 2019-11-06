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
                        $avg = "" + (gcim win32_processor -computername $c | Measure-Object -property LoadPercentage -Average | Foreach { $_.Average }) + "%"

                        $mem = gcim win32_operatingsystem -ComputerName $c |
                        Foreach { "{0:N2}" -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) * 100) / $_.TotalVisibleMemorySize) }

                        $freeC = gcim Win32_Volume -ComputerName $c -Filter "DriveLetter = 'C:'" |
                        Foreach { "{0:N2}" -f ($_.FreeSpace / 1GB) }

                        $freeD = gcim Win32_Volume -ComputerName $c -Filter "DriveLetter = 'D:'" |
                        Foreach { "{0:N2}" -f ($_.FreeSpace / 1GB) }

                        $net = if ([bool](Test-Connection -ComputerName google.com -Source $c -Count 1 -ErrorAction SilentlyContinue)) { $netresult = "Connected" } else { $netresult = "Disconnected" }

                        $upt = Invoke-Command -ComputerName $c -ScriptBlock { ("" + ((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).days) + "-Days " + ((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).hours + "-Hours " + ((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).minutes + "-Mins"}

                        #Color Text
                        if ( $avg -lt 9 ) {
                              $Host.UI.RawUI.ForegroundColor = 'White'
                        }
                        if ( $avg -gt 9 ) {
                              $Host.UI.RawUI.ForegroundColor = 'Green'
                        } 
                        if ( $avg -gt 29 ) {
                              $Host.UI.RawUI.ForegroundColor = 'Yellow'
                        }
                        if ( $avg -gt 69 -or $net -eq $False ) {
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
      type '.\server1.txt' | Get-ComputerStats | ft -AutoSize
      start-sleep -s 5
}
