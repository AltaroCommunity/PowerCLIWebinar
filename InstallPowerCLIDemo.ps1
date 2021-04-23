# This was put together by Andy Syrewicze - Technical Evangelist for Altaro Software. Reach out to Andy with questions using the below if desired
# Twitter: https://www.twitter.com/asyrewicze
# Github: https://github.com/asyrewicze

# This "script" was used to demonstrate the Installation of PowerCLI on a Linux OS during an Altaro Webinar focused on PowerCLI and Automation. A recording of the webinar can be found below:
# https://www.altaro.com/webinars/powercli.php

# While this isn't officially a "script" Following from top to bottom and reading the commented sections, you will learn how to install PowerCLI on Linux.

# Note: This demo was conducted using Debian Stable 10.9 in April of 2021

# Escalate to root (if not using sudo)
# Note that depending on your distribution you can either escalate directly to root context using su as shown below, or you can also use sudo. 

su

# Let's Install PowerShell!
# This is done via a Snap Image provided by Microsoft
# Most Modern Linux distros come with Snap Pre-Installed, however if you don't have it run the below in a root context or via sudo:

apt-get install snapd
snap install core

# NOTE: you may have to restart your BASH session for PATH variables to work correctly after install. This includes situations where you may be SSHd into a remote system. 

# Grab PowerShell with Snap!

snap install powershell --classic

# Now we can run PowerShell from BASH with either of the below options

powershell
pwsh

# You can run PowerShell cmdlets to our heart's content just like any other system! For example:

Get-Command

# Notice that the below cmdlet returns the output of the running Linux processes on the system

Get-Process

# Now for the PowerCLI portion of the installation. The below grabs and installs PowerCLI for the current user

Install-Module VMware.PowerCLI -Scope CurrentUser

# Once installed the below command will list all PowerCLI commands now available in the shell

Get-Command -Module *VMware*

# PowerCLI Commands can be used as normal now!
# For Example: The below will show the help file for the vSphere Update-Tools Command

Get-Help Update-Tools

# End of Demo