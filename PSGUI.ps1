<#

PSGUI
-----
 * Written by Xavier Avrillier for Altaro Software.
 * Date: 2021/04/15
 * Altaro Software : www.altaro.com
 * Xavier's blog   : www.vxav.fr

-----

This script is purely educational and aims at providing understanding on the use of 
PowerShell Forms with the example of a simple VM deployment.

This script is not production-ready as it includes almost no checks of any kind.
A proper script should verify that the set parameters allow for a safe deployment.

#>

########################################
#  Utility functions.
########################################

Function Invoke-vCenterButton {

    <# 
        This function is invoked when the connect vcenter button is pushed.
        When the vCenter is connected, it populates and enable certain fields.
    #>

    $VIServer = Connect-VIServer -Server $vcenterTextBox.Text

    

    if ($VIServer.IsConnected) {
        
        # Disable vCenter fields
        $vcenterButton.Enabled  = $false
        $vcenterButton.Text     = "Connected"
        $vcenterTextBox.Enabled = $false

        # Enable fields
        $deployButton.Enabled       = $true
        $VmName_textbox.Enabled     = $true
        $vmhComboBox.Enabled        = $true
        $templateComboBox.Enabled   = $true
        $cpuComboBox.enabled        = $true

        # Add hosts to vmhost ComboBox
        $vmhost = Get-VMHost -Server $VIServer | where connectionstate -eq connected
        $vmhComboBox.Items.Clear()
        $vmhost.Name | Sort  | ForEach-Object {[void] $vmhComboBox.Items.Add($_)}

        # Add templates to template ComboBox
        $Templates = Get-Template
        $templateComboBox.Items.Clear()
        $Templates.Name | Sort  | ForEach-Object {[void] $templateComboBox.Items.Add($_)}

    } else {
        
        # If vCenter not connected, change button text to "Retry"

        Invoke-WarningPopup -WarningTitle "Connection failed" -WarningBody $error[0].exception.message

        $vcenterButton.text = "Retry"

    }

}

Function Invoke-DatastoreButton {

    <# 
        This function is invoked when the datastore button is pushed.
        It will pop up a list of available datastores on the host.
    #>

    $datastoreLabel.text = Get-VMHost $vmhComboBox.Text | Get-Datastore -Server $VIServer | where state -eq available | Out-GridView -PassThru | select -ExpandProperty Name

}

Function Invoke-DeployButton {
    
    # Checking all parameters are set and building NEW-VM parameter object.

    $deployparams = @{Server = $VIServer}

    if (!$templateComboBox.Text) {$WarningBody += "Template not set`n"} else {$deployparams.Add('Template',$templateComboBox.Text)}
    if (!$vmhComboBox.Text)      {$WarningBody += "Host not set`n"} else {$deployparams.Add('VMHost',$vmhComboBox.Text)}
    if (!$datastoreLabel.Text)   {$WarningBody += "Datastore not set`n"} else {$deployparams.Add('Datastore',$datastoreLabel.Text)}
    if (!$cpuComboBox.Text)      {$WarningBody += "CPU not set`n"}
    if (!$VmName_textbox.Text)   {$WarningBody += "VM name not set`n"} 
    elseif (Get-VM $VmName_textbox.Text) {$WarningBody += "$($VmName_textbox.Text) already used`n"}
    else {$deployparams.Add('Name',$VmName_textbox.Text)}

    # If a parameter is not set, a warning pops up and prevents deployment attempt.

    if ($WarningBody) {

        $WarningBody = @("Issues:`n$WarningBody")

        Invoke-WarningPopup -WarningTitle "Missing fields" -WarningBody $WarningBody

    } else {

        # New-VM deployment tasks. This could be a separate function.

        $deployButton.Text    = "Deploying"
        $deployButton.enabled = $False

        $NewVM = New-VM @deployparams

        # Cpu count has to be changed after deployment when working with templates.

        if ($NewVM.NumCpu -ne $cpuComboBox.Text) {Set-VM -VM $NewVM -NumCpu $cpuComboBox.Text -confirm:$false}

        # Start VM if Power on checkbox enabled.

        if ($PwrCheckbox.Checked) {Start-VM -VM $NewVM}

        $deployButton.enabled = $True
        $deployButton.Text    = "Deploy"

    }
}

Function Invoke-WarningPopup {

param([string]$WarningTitle,[string]$WarningBody)

    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $WarningButton = [System.Windows.MessageBoxButton]::OK
    $WarningIcon = [System.Windows.MessageBoxImage]::Warning

    [System.Windows.MessageBox]::Show($WarningBody,$WarningTitle,$WarningButton,$WarningIcon)

}


########################################
# Form Creation.
########################################

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,400'
$Form.text                       = "My First GUI Tool"
$Form.TopMost                    = $false
$Form.MaximizeBox                = $false
$Form.FormBorderStyle            = 'Fixed3D'
$Form.Font                       = 'Microsoft Sans Serif,10'

# Here is an image that acts as a button. The picture must be in the same folder as the script.

$LogoButton                      = New-Object system.Windows.Forms.Button
$LogoButton.width                = 140
$LogoButton.height               = 30
$LogoButton.location             = New-Object System.Drawing.Point(250,265)
$LogoButton.Image = [System.Drawing.Image]::FromFile("$PSScriptRoot\PSGUI.png")

########################################
# Form content.
########################################

# vCENTER.

$vcenterLabel                    = New-Object system.Windows.Forms.Label
$vcenterLabel.text               = "vCenter"
$vcenterLabel.AutoSize           = $true
$vcenterLabel.width              = 25
$vcenterLabel.height             = 10
$vcenterLabel.location           = New-Object System.Drawing.Point(17,18)

$vcentertextbox                  = New-Object system.Windows.Forms.TextBox
$vcentertextbox.multiline        = $false
$vcentertextbox.width            = 200
$vcentertextbox.height           = 20
$vcentertextbox.location         = New-Object System.Drawing.Point(105,14)

$vcenterButton                   = New-Object system.Windows.Forms.Button
$vcenterButton.text              = "Connect"
$vcenterButton.width             = 75
$vcenterButton.height            = 20
$vcenterButton.location          = New-Object System.Drawing.Point(314,14)
$vcenterButton.Font              = 'Microsoft Sans Serif,9'

# New VM name.

$VmName_Label                    = New-Object system.Windows.Forms.Label
$VmName_Label.text               = "VM name"
$VmName_Label.AutoSize           = $true
$VmName_Label.width              = 25
$VmName_Label.height             = 10
$VmName_Label.location           = New-Object System.Drawing.Point(17,54)

$VmName_textbox                  = New-Object system.Windows.Forms.TextBox
$VmName_textbox.multiline        = $false
$VmName_textbox.width            = 200
$VmName_textbox.height           = 20
$VmName_textbox.location         = New-Object System.Drawing.Point(105,54)
$VmName_textbox.enabled          = $false

# New VM CPU count.

$cpucnt_Label                    = New-Object system.Windows.Forms.Label
$cpucnt_Label.text               = "CPU count"
$cpucnt_Label.AutoSize           = $true
$cpucnt_Label.width              = 25
$cpucnt_Label.height             = 10
$cpucnt_Label.location           = New-Object System.Drawing.Point(17,94)
$cpucnt_Label.Font               = 'Microsoft Sans Serif,10'

$cpuComboBox                     = New-Object system.Windows.Forms.ComboBox
$cpuComboBox.width               = 200
$cpuComboBox.height              = 20
$cpuComboBox.location            = New-Object System.Drawing.Point(105,94)
$cpuComboBox.DropDownStyle       = "DropDownList"
$cpuComboBox.SelectedItem        = $cpuComboBox.Items[2]
@(1,2,4,8,12) | ForEach-Object {[void] $cpuComboBox.Items.Add($_)}
$cpuComboBox.enabled             = $false


# ESXi host to deploy to.

$vmhost_Label                    = New-Object system.Windows.Forms.Label
$vmhost_Label.text               = "ESXi host"
$vmhost_Label.AutoSize           = $true
$vmhost_Label.width              = 25
$vmhost_Label.height             = 10
$vmhost_Label.location           = New-Object System.Drawing.Point(17,134)

$vmhComboBox                     = New-Object system.Windows.Forms.ComboBox
$vmhComboBox.width               = 200
$vmhComboBox.height              = 20
$vmhComboBox.location            = New-Object System.Drawing.Point(105,134)
$vmhComboBox.DropDownStyle       = "DropDownList"
$vmhComboBox.enabled             = $false
$vmhComboBox.add_SelectedIndexChanged({# Datastore field cleared and enabled when a host is selected.
    $datastoreLabel.text         = ""
    $DatastoreButton.enabled = $True
}) 

# Template.

$template_Label                  = New-Object system.Windows.Forms.Label
$template_Label.text             = "Template"
$template_Label.AutoSize         = $true
$template_Label.width            = 25
$template_Label.height           = 10
$template_Label.location         = New-Object System.Drawing.Point(17,174)

$templateComboBox                = New-Object system.Windows.Forms.ComboBox
$templateComboBox.text           = "comboBox"
$templateComboBox.width          = 200
$templateComboBox.height         = 20
$templateComboBox.location       = New-Object System.Drawing.Point(105,174)
$templateComboBox.DropDownStyle  = "DropDownList"
$templateComboBox.enabled        = $false

# Datastore Button.

$DatastoreButton                 = New-Object system.Windows.Forms.Button
$DatastoreButton.text            = "Datastore"
$DatastoreButton.width           = 164
$DatastoreButton.height          = 30
$DatastoreButton.location        = New-Object System.Drawing.Point(17,214)
$DatastoreButton.enabled         = $false

$datastoreLabel                  = New-Object system.Windows.Forms.Label
$datastoreLabel.AutoSize         = $true
$datastoreLabel.width            = 25
$datastoreLabel.height           = 10
$datastoreLabel.location         = New-Object System.Drawing.Point(200,214)

# Power on Checkbox
 
$PwrCheckbox                     = new-object System.Windows.Forms.checkbox
$PwrCheckbox.Location            = new-object System.Drawing.Size(17,254)
$PwrCheckbox.Size                = new-object System.Drawing.Size(250,50)
$PwrCheckbox.Text                = "Power on new VM"
$PwrCheckbox.Checked             = $false

# Deploy Button.

$deployButton                    = New-Object system.Windows.Forms.Button
$deployButton.text               = "Deploy"
$deployButton.width              = 164
$deployButton.height             = 30
$deployButton.location           = New-Object System.Drawing.Point(120,360)
$deployButton.enabled            = $false

$Form.controls.AddRange(@($LogoButton,$deployButton,$vcenterButton,$vcentertextbox,$vcenterLabel,$VmName_Label,$VmName_textbox,$cpucnt_Label,$cpuComboBox,$deployButton,$templateComboBox,$template_Label,$vmhost_Label,$vmhComboBox,$DatastoreButton,$datastoreLabel,$PwrCheckbox))

########################################
# Buttons actions
########################################

$LogoButton.Add_Click({start-process "www.altaro.com"})

$vCenterButton.Add_Click({Invoke-vCenterButton})

$DatastoreButton.Add_Click({Invoke-DatastoreButton})

$DeployButton.Add_Click({Invoke-DeployButton})

########################################
# Main GUI form
########################################

# Press Enter to click the "Connect" button.
$form.AcceptButton = $vcenterButton 

# Disconnect vCenter when closing the form.
$Form.add_FormClosing({if ($VIServer.IsConnected) {Disconnect-VIServer $VIServer -Confirm:$false}})

# Display main form.
$Form.ShowDialog()
