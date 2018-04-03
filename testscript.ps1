#
# MyCustomScriptExtension.ps1
#
param (
  $vmAdminUsername,
  $vmAdminPassword
)
 
$password =  ConvertTo-SecureString $vmAdminPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("$env:USERDOMAIN\$vmAdminUsername", $password)
 
Write-Verbose -Verbose "Entering Custom Script Extension..."

$Profile = Get-NetConnectionProfile -InterfaceAlias Ethernet
$Profile.NetworkCategory = "Private"
Set-NetConnectionProfile -InputObject $Profile

Enable-PSRemoting -force
 
Invoke-Command -Credential $credential -ComputerName $env:COMPUTERNAME -ArgumentList $PSScriptRoot -ScriptBlock {
  param 
  (
    $workingDir
  )
 
  #################################
  # Elevated custom scripts go here 
  #################################
  Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  choco install python2
}
