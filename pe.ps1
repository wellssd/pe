# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# pe.ps1 - Escalate current users priviliges to Administrator by adding user to Administrators local group
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Date     Notes
# -------- ------------------------------------------------------------------------------------------------------------
# 20200106 Inital version (software@xxxxxxxxx.com)
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


###
### Definitions
###
$ISSUETYPE = "MSA Support"
$SUBDOMAIN = "xxxxxxxxx"
$SUBJECT   = "Privilege Escalation"


###
### PowerShell Runtime Options
###
#$ErrorActionPreference = "SilentlyContinue"
#$WarningPreference     = "SilentlyContinue"


###
### Modules
###
Import-Module $env:SyncroModule


###
### Determine user name of currently logged in user
###
$cs = (Get-WmiObject -Class Win32_ComputerSystem)


###
### Insert a pause to allow the user to acknowledge the popup message that the request has been submitted before firing
### off a new popup window indicating the task is complete. - Not implemented
###


###
### Get list of users currently in Administrators group
###
$localadmin = Get-LocalGroupMember -Group Administrators | Where-Object { $_.Name -in $cs.UserName }


###
### If the logged in users isn't already in the local Administrators group, add them
###
if ($cs.UserName -in $localadmin.Name) { 

    ###
    ### Display popup message
    ###
    $cs.UserName | Out-File "c:\xxxxxxxxx\pea.txt"

} else {

    ###
    ### Add user to local Administrators group
    ###
    Add-LocalGroupMember -Group Administrators -Member $cs.UserName


    ###
    ### Create Syncro ticket and add comment
    ###
    $SyncroTkt = Create-Syncro-Ticket -Subdomain $SUBDOMAIN -Subject $SUBJECT -IssueType $ISSUETYPE -Status "New"
    Create-Syncro-Ticket-Comment -Subdomain $SUBDOMAIN -TicketIdOrNumber $SyncroTkt.ticket.id -Subject "Privilege Escalation Detail" -Body "Privilege escalation for user $($cs.UserName) completed." -DoNotEmail $True | Out-Null


    ###
    ### Display popup message
    ###
    #$wshell.Popup("Privilege escalation for user $($cs.UserName) completed.`r`n`nLog out and log back in for privileges to become effective.", 0, "Privilege Escalation", 0) | Out-Null
    $cs.UserName | Out-File "c:\xxxxxxxxx\pec.txt"

}
