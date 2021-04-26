#############################################################
### Demo step 1 : REPORT CONTENT
### Gather information on the virtual disks in a variable
#############################################################

$htmlfile = "vdisks.html"

$Table = @()

foreach ($VM in (get-vm)){
        
        # Gather list of hard disks of the current VM.
        $Disks = $vm | Get-HardDisk

        # Process each disk as follows:
        foreach ($disk in $Disks) {
            
            # Gathers Disk bus (0:1  1:1  ...).
            $Controller = $VM.extensiondata.config.hardware.device | Where Key -eq $Disk.ExtensionData.ControllerKey
            $DiskBus = "$($Controller.BusNumber):$($Disk.ExtensionData.UnitNumber)"

            $Naa = $CompatibilityMode = $StorageFormat = "N/A"

            # Process RDM vs vDisk.
            if ($Disk.DiskType -like "Raw*") {
                $Naa = $Disk.scsicanonicalname
                $CompatibilityMode = $Disk.ExtensionData.Backing.CompatibilityMode
            } else {
                $StorageFormat = $Disk.StorageFormat
            }

            # Populate table with current disk record.
            $Table += [pscustomobject]@{

                VM = $VM.name
                Name = $Disk.name
                CapacityGB = $Disk.capacitygb
                Naa = $Naa
                Node = "$DiskBus"
                File = $Disk.filename
                Persistence = $Disk.Persistence
                DiskType = $Disk.disktype
                CompatibilityMode = $CompatibilityMode
                StorageFormat = $StorageFormat
                DiskMode = $Disk.ExtensionData.Backing.DiskMode
                Sharing = $Disk.ExtensionData.Backing.Sharing
                Controller = $Controller.deviceinfo.summary
                ControllerSharedBus = $Controller.SharedBus

            }

        }

}


#############################################################
### Demo step 2 : CONVERT TO HTML AND STORE IN FILE
### Open vdisk.html in a browser
#############################################################


$table | ConvertTo-Html | Out-File $htmlfile


#############################################################
### Demo step 3 : ADD CSS
### Add borders to the html table via CSS. Refresh browser
#############################################################


$Style = @'
<img src="https://www.altaro.com/images/altaro-hornetsecurity-logo.svg">
<style>table, th, td {border: 1px solid;}</style>
'@

$table | ConvertTo-Html -Head $Style | Out-File $htmlfile


#############################################################
### Demo step 4 : ADD REPORT DATE AND TIME
### Add execution time at top of report. Refresh browser
#############################################################


$table | ConvertTo-Html -Head $Style -PreContent "<h2>Execution time: $(get-date -Format u)</h2>" | Out-File $htmlfile


#############################################################
### Demo step 5 : COLOR CONDITION
### Highlight RDM disks in cyan (light blue)
#############################################################


$Table = @()

foreach ($VM in (get-vm)){

        $Disks = $vm | Get-HardDisk

        foreach ($disk in $Disks) {
            
            # Disk bus (0:1  1:1  ...)
            $Controller = $VM.extensiondata.config.hardware.device | Where Key -eq $Disk.ExtensionData.ControllerKey
            $DiskBus = "$($Controller.BusNumber):$($Disk.ExtensionData.UnitNumber)"

            $Naa = $CompatibilityMode = $StorageFormat = "N/A"

            if ($Disk.DiskType -like "Raw*") {
                $Naa = $Disk.scsicanonicalname
                $CompatibilityMode = $Disk.ExtensionData.Backing.CompatibilityMode
                $color = "cyan"
            } else {
                $StorageFormat = $Disk.StorageFormat
                $color = "white"
            }

            ### ADDED A COLOR CONDITION

            $Table += [pscustomobject]@{

                VM = "REPLACEME1$color REPLACEME2$($VM.name)"
                Name = $Disk.name
                CapacityGB = $Disk.capacitygb
                Naa = $Naa
                Node = "$DiskBus"
                File = $Disk.filename
                Persistence = $Disk.Persistence
                DiskType = $Disk.disktype
                CompatibilityMode = $CompatibilityMode
                StorageFormat = $StorageFormat
                DiskMode = $Disk.ExtensionData.Backing.DiskMode
                Sharing = $Disk.ExtensionData.Backing.Sharing
                Controller = $Controller.deviceinfo.summary
                ControllerSharedBus = $Controller.SharedBus

            }

        }

}


#############################################################
### Demo step 6 : CONVERT TO HTML WITH PATTERN REPLACEMENT
### REPLACE THE 2 STRINGS TO MAKE <td bgcolor="cyan">xxxxxx</td>
#############################################################


$htmlTable = $Table | ConvertTo-Html -Head $Style -PreContent "<h2>Execution time: $(get-date)</h2>"
$htmlTable -replace "><td>REPLACEME1"," bgcolor=" -replace "REPLACEME2","><td>" | Out-File $htmlfile


#############################################################
### Demo step 7 : Send report via email
### Configure your own SMTP settings to send in an email
#############################################################


$BODY = $htmlTable -replace "><td>REPLACEME1"," bgcolor=" -replace "REPLACEME2","><td>"

$Email = @{
    Subject = "VM disks inventory"
    From = "FromAddress@provider.com"
    To = "ToAddress@provider.com"
    SmtpServer = "smtp.provider.com"
    Body = [string]$BODY
    BodyAsHtml = $True
    port=587
    credential=Get-Credential "FromAddress@provider.com"
}

Send-MailMessage @Email