# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# pe-req.ps1 - Request privilege escalation
#
# Detail - Using a Syncro task tray option, a user choose a privilege escalation request which will create a Syncro 
#          alert and give the user a popup notification indicating the request has been submitted.  Syncro automated
#          remediation will then close the alert and run pe.ps1 on the asset which will determine the logged in users,
#          add that user to the local Administrators group, create a ticket and notify the user that the request has
#          been completed.  The ticket will be used to track privegele escalation requests as well as remove user from
#          local Administrators group after the end of the business day.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Date     Notes
# -------- ------------------------------------------------------------------------------------------------------------
# 20200107 Inital version (software@tsmidwest.com)
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


###
### Definitions
###


###
### PowerShell runtime options
###
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference     = "SilentlyContinue"


###
### Modules
###
Import-Module C:\ProgramData\Syncro\bin\module.psm1


###
### Determine user name of currently logged in user
###
$cs = (Get-WmiObject -Class Win32_ComputerSystem)


###
### Create RMM Alert
###
Rmm-Alert -Category "Privilege Escalation" -Body "Privilege escalation request for user $($cs.UserName)"


###
### Display message popup indicating request has been submitted
###
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("Privilege escalation request for user $($cs.UserName) submitted.", 0, "Privilege Escalation", 0) | Out-Null


###
### Wait for existance of file pec.txt (complete), pea.txt (already admin) or pef.txt (failed) in c:\xxxxxxxxx and
### message user appropriately
###
$flag = 0
while ($flag -eq 0) {

    ###
    ### Privilege escalation completed
    ###
    if (Test-Path "c:\xxxxxxxxx\pec.txt" -PathType Leaf) {
        $flag = 1
        Remove-Item "c:\xxxxxxxxx\pec.txt"
        $wshell.Popup("Privilege escalation request for user $($cs.UserName) completed`r`n`nSign out and back in for new privileges to take affect.", 0, "Privilege Escalation", 0) | Out-Null
    }

    ###
    ### User already has administrative privilieges
    ###
    if (Test-Path "c:\xxxxxxxxx\pea.txt" -PathType Leaf) {
        $flag = 1
        Remove-Item "c:\xxxxxxxxx\pea.txt"
        $wshell.Popup("User $($cs.UserName) already has administrative privileges.", 0, "Privilege Escalation", 0) | Out-Null
    }
    
    ###
    ### Privilege escalation failed - not currently implemented; however, if a timeout is desired, or some other
	### failure scenario is desired, it should be inserted here.
    ###

    ###
    ### Don't kill the computer
    ###
    Start-Sleep -Seconds 5
}

    
###
### End script
###
Exit 0
