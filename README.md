# ServerWatcher

A basic system monitor script written in Powershell to monitor resources and internet connectivity on multiple systems.

###### How To Use:
> - Keep server.txt in the same folder as the Powershell script. (Or put it wherever you want and update the code. Up to you!)
> - Update server.txt with the IP Adress or Computer Name of systems you want to monitor.
> - Load the Powershell script and let it run.

###### What is monitored (in order):
> - If system is reachable. > Text color will change red if OFFLINE.
> - CPU Usage in percents. > Text color will change based on load.
> - Memory Usage in percents.
> - Remaining Free Space on Disk C: in Gigabytes.
> - Remaining Free Space on Disk D: in Gigabytes. (Will register as 'GB' if no drive is found)
> - Internet Connectivity by making system ping google.com. > Text color will change red if disconnected.
> - System UpTime

###### Feel free to edit the code however you see fit!
