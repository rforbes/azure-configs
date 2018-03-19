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
 
Invoke-Command -Credential $credential -ComputerName $env:COMPUTERNAME -ArgumentList $PSScriptRoot -ScriptBlock {
  param 
  (
    $workingDir
  )
 
  #################################
  # Elevated custom scripts go here 
  #################################
  Write-Verbose -Verbose "Entering Elevated Custom Script Commands..."
  New-Item $env:userdir AnEmptyFile.txt -ItemType file
}
