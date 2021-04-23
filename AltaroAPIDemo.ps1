# This was put together by Andy Syrewicze - Technical Evangelist for Altaro Software. Reach out to Andy with questions using the below if desired
# Twitter: https://www.twitter.com/asyrewicze
# Github: https://github.com/asyrewicze

# This "script" was used to demonstrate the Altaro VM Backup rest API in a demo during an Altaro Webinar focused on PowerCLI and Automation. A recording of the webinar can be found below:
# https://www.altaro.com/webinars/powercli.php

# While this isn't officially a "script" Following from top to bottom and reading the commented sections, you will learn the basics of using the Altaro VM Backup Rest API.

# For detailed inforamation on the Altaro VM Backup Rest API please visit https://www.altaro.com/api.

# Let's First Get the status of the Altaro Rest API Service
# Note: by default the Altaro Rest API is in a disabled state and only reachable locally. 

Get-Service -Name Altaro.RestService.exe

# Change to the Directory hosting the starting cmdlets
# The below is the default path, update your path based on your installation directory

$AltaroScriptDir = 'C:\Program Files\Altaro\Altaro Backup\Cmdlets'
cd $AltaroScriptDir
dir

# These cmdlets are pre-canned and conduct some of the basic API operations. The -help switch can be passed As well for detailed syntax

.\StartSessionPasswordShown.ps1 -help

# Let's authenticate to the API and open a session
# Replace the username and Password below with those needed in your environment
# Alternatively there is a pre-built script that calls the API with the password hidden. 
# If scripting this for long term automation, it's highly recommended you read Luke's article on encrypting passwords in powershell below
# https://www.altaro.com/msp-dojo/encrypt-password-powershell/

.\StartSessionPasswordShown.ps1 administrator Password01! localhost

# Save the Session token to a variable for future use
# NOTE: Unique for each session!
# Example Session Token: 6e52ac6a-d3ba-4d09-a552-df1047578ba5

$SessionToken='paste-session-token-here'

# Now let's return some information from the API starting with a list of VMs in the backup console!

.\GetVirtualMachines.ps1 $SessionToken

# What about details of the last backup?
# The below needs the Altaro Virtual Machine Ref ID that can be found by using the above GetVirtualMachines.ps1 script. Capture the RefID in a variable as shown below
# Example RefID: dd62dacb-73b9-4fbc-a370-fc9b021b017d

$VMRefID='paste-vmrefid-here'
.\GetLastBackupDetails.ps1 $SessionToken $VMRefID

# What about details of our backup storage?

.\GetBackupLocations.ps1 $SessionToken

# Note: Many other functions can be done with the pre-built scripts in this directory, simply look throught the using dir and calling the -help switch for the cmdlet in question.

# When done we need to close the session

.\EndAllSessions.ps1

# End of Demo