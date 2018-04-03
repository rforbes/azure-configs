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
  choco feature enable -n allowGlobalConfirmation
  choco install ssh
  choco install git
  choco install python2
  refreshenv
  
  pip install boto
  pip install credstash
  
  refreshenv
  
  New-Item requirements.txt -ItemType file
  
  Add-Content requirements.txt -value "git+https://github.com/MozillaSecurity/fuzzfetch.git"
  Add-Content requirements.txt -value "git+https://github.com/MozillaSecurity/ffpuppet.git"
  Add-Content requirements.txt -value "git+ssh://git@loki/MozillaSecurity/loki.git"
  Add-Content requirements.txt -value "git+ssh://git@sapphire/MozillaSecurity/sapphire.git"
  Add-Content requirements.txt -value "git+https://github.com/MozillaSecurity/avalanche.git"
  Add-Content requirements.txt -value "git+https://github.com/MozillaSecurity/FuzzManager.git"
  
  if (!(Test-Path "$env:userprofile\.ssh\config"))
  {
    New-Item -path C:\Share -name $env:userprofile\.ssh\config -type "file"
  }
  else
  {
    Add-Content -path $env:userprofile\.ssh\config -value "`r`n"

  }
  Add-Content -path $env:userprofile\.ssh\config -value "HostName github.com"
  Add-Content -path $env:userprofile\.ssh\config -value "IdentitiesOnly yes"
  Add-Content -path $env:userprofile\.ssh\config -value "IdentityFile env:userprofile/.ssh/id_ecdsa.grizzly"
  Add-Content -path $env:userprofile\.ssh\config -value "`r`n"
  Add-Content -path $env:userprofile\.ssh\config -value "Host grizzly-private"
  Add-Content -path $env:userprofile\.ssh\config -value "HostName github.com"
  Add-Content -path $env:userprofile\.ssh\config -value "IdentitiesOnly yes"
  Add-Content -path $env:userprofile\.ssh\config -value "IdentityFile env:userprofile/.ssh/id_ecdsa.grizzly-private"
  Add-Content -path $env:userprofile\.ssh\config -value "`r`n"
  Add-Content -path $env:userprofile\.ssh\config -value "Host sapphire"
  Add-Content -path $env:userprofile\.ssh\config -value "HostName github.com"
  Add-Content -path $env:userprofile\.ssh\config -value "IdentitiesOnly yes"
  Add-Content -path $env:userprofile\.ssh\config -value "IdentityFile env:userprofile/.ssh/id_ecdsa.sapphire"
  Add-Content -path $env:userprofile\.ssh\config -value "`r`n"
  Add-Content -path $env:userprofile\.ssh\config -value "Host domfuzz2"
  Add-Content -path $env:userprofile\.ssh\config -value "HostName github.com"
  Add-Content -path $env:userprofile\.ssh\config -value "IdentitiesOnly yes"
  Add-Content -path $env:userprofile\.ssh\config -value "IdentityFile env:userprofile/.ssh/id_ecdsa.domfuzz2"
  Add-Content -path $env:userprofile\.ssh\config -value "`r`n"
  Add-Content -path $env:userprofile\.ssh\config -value "Host fuzzidl"
  Add-Content -path $env:userprofile\.ssh\config -value "HostName github.com"
  Add-Content -path $env:userprofile\.ssh\config -value "IdentitiesOnly yes"
  Add-Content -path $env:userprofile\.ssh\config -value "IdentityFile env:userprofile/.ssh/id_ecdsa.fuzzidl"
  Add-Content -path $env:userprofile\.ssh\config -value "`r`n"
  
  credstash -r us-east-1 get deploy-grizzly.pem >> $env:userprofile\.ssh\id_ecdsa.grizzly
  credstash -r us-east-1 get deploy-grizzly-private.pem >> $env:userprofile\.ssh\id_ecdsa.grizzly_private
  credstash -r us-east-1 get deploy-sapphire.pem >> $env:userprofile\.ssh\id_ecdsa.sapphire
  credstash -r us-east-1 get deploy-domino.pem >> $env:userprofile\.ssh\id_ecdsa.domfuzz2
  credstash -r us-east-1 get deploy-fuzzidl.pem >> $env:userprofile\.ssh\id_ecdsa.fuzzidl
  
  pip install -U -r config/aws/requirements.txt
}
