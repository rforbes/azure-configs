#
# MyCustomScriptExtension.ps1
#
param (
  $vmAdminUsername,
  $vmAdminPassword,
  $aws_key_id,
  $aws_secret
)
 
$password =  ConvertTo-SecureString $vmAdminPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("$env:USERDOMAIN\$vmAdminUsername", $password)

$Profile = Get-NetConnectionProfile -InterfaceAlias Ethernet
$Profile.NetworkCategory = "Private"
Set-NetConnectionProfile -InputObject $Profile

Enable-PSRemoting -force
 
Invoke-Command -Credential $credential -ComputerName $env:COMPUTERNAME -ArgumentList $aws_key_id, $aws_secret -ScriptBlock {
    param 
    (
        $aws_key_id,
        $aws_secret
    )
    
    #################################
    # Elevated custom scripts go here 
    #################################
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco feature enable -n allowGlobalConfirmation
    choco install openssh
    choco install git
    choco install python2

    # Create support files
    New-Item -Path $env:userprofile\.aws\credentials -force
    Add-Content -path $env:userprofile\.aws\credentials -Value "[default]"
    Add-Content -path $env:userprofile\.aws\credentials -Value "aws_secret_key_id = $aws_key_id"
    Add-Content -path $env:userprofile\.aws\credentials -Value "aws_secret_access_key = $aws_secret"
    
    New-Item -path $env:userprofile\requirements.txt -ItemType file
    Add-Content -path $env:userprofile\requirements.txt -value "git+https://github.com/MozillaSecurity/fuzzfetch.git"
    Add-Content -path $env:userprofile\requirements.txt -value "git+https://github.com/MozillaSecurity/ffpuppet.git"
    Add-Content -path $env:userprofile\requirements.txt -value "git+ssh://git@loki/MozillaSecurity/loki.git"
    Add-Content -path $env:userprofile\requirements.txt -value "git+ssh://git@sapphire/MozillaSecurity/sapphire.git"
    Add-Content -path $env:userprofile\requirements.txt -value "git+https://github.com/MozillaSecurity/avalanche.git"
    Add-Content -path $env:userprofile\requirements.txt -value "git+https://github.com/MozillaSecurity/FuzzManager.git"

    if (!(Test-Path "$env:userprofile\.ssh\config"))
    {
        New-Item -path $env:userprofile\.ssh\config -type "file" -force
    }
    else
    {
        Add-Content -path $env:userprofile\.ssh\config -value "`r`n"
    }
    Add-Content -path $env:userprofile\.ssh\config -value "HostName github.com"
    Add-Content -path $env:userprofile\.ssh\config -value "IdentitiesOnly yes"
    Add-Content -path $env:userprofile\.ssh\config -value "IdentityFile $env:userprofile\.ssh\id_ecdsa.grizzly"
    StrictHostKeyChecking no
    Add-Content -path $env:userprofile\.ssh\config -value "`r`n"
    Add-Content -path $env:userprofile\.ssh\config -value "Host grizzly-private"
    Add-Content -path $env:userprofile\.ssh\config -value "HostName github.com"
    Add-Content -path $env:userprofile\.ssh\config -value "IdentitiesOnly yes"
    Add-Content -path $env:userprofile\.ssh\config -value "IdentityFile $env:userprofile\.ssh\id_ecdsa.grizzly-private"
    StrictHostKeyChecking no
    Add-Content -path $env:userprofile\.ssh\config -value "`r`n"
    Add-Content -path $env:userprofile\.ssh\config -value "Host sapphire"
    Add-Content -path $env:userprofile\.ssh\config -value "HostName github.com"
    Add-Content -path $env:userprofile\.ssh\config -value "IdentitiesOnly yes"
    Add-Content -path $env:userprofile\.ssh\config -value "IdentityFile $env:userprofile\.ssh\id_ecdsa.sapphire"
    StrictHostKeyChecking no
    Add-Content -path $env:userprofile\.ssh\config -value "`r`n"
    Add-Content -path $env:userprofile\.ssh\config -value "Host domfuzz2"
    Add-Content -path $env:userprofile\.ssh\config -value "HostName github.com"
    Add-Content -path $env:userprofile\.ssh\config -value "IdentitiesOnly yes"
    Add-Content -path $env:userprofile\.ssh\config -value "IdentityFile $env:userprofile\.ssh\id_ecdsa.domfuzz2"
    StrictHostKeyChecking no
    Add-Content -path $env:userprofile\.ssh\config -value "`r`n"
    Add-Content -path $env:userprofile\.ssh\config -value "Host fuzzidl"
    Add-Content -path $env:userprofile\.ssh\config -value "HostName github.com"
    Add-Content -path $env:userprofile\.ssh\config -value "IdentitiesOnly yes"
    Add-Content -path $env:userprofile\.ssh\config -value "IdentityFile $env:userprofile\.ssh\id_ecdsa.fuzzidl"
    StrictHostKeyChecking no
    Add-Content -path $env:userprofile\.ssh\config -value "`r`n"
}

Invoke-Command -Credential $credential -ComputerName $env:COMPUTERNAME -ArgumentList $aws_key_id, $aws_secret -ScriptBlock {
    param 
    (
        $aws_key_id,
        $aws_secret
    )
    
    python -m pip install --upgrade pip
    
    pip install boto
    pip install credstash
    
    refreshenv

    $env:aws_access_key_id = $aws_key_id
    $env:aws_secret_access_key = $aws_secret
    
    credstash -r us-east-1 get deploy-grizzly.pem >> $env:userprofile\.ssh\id_ecdsa.grizzly
    credstash -r us-east-1 get deploy-grizzly-private.pem >> $env:userprofile\.ssh\id_ecdsa.grizzly_private
    credstash -r us-east-1 get deploy-sapphire.pem >> $env:userprofile\.ssh\id_ecdsa.sapphire
    credstash -r us-east-1 get deploy-domino.pem >> $env:userprofile\.ssh\id_ecdsa.domfuzz2
    credstash -r us-east-1 get deploy-fuzzidl.pem >> $env:userprofile\.ssh\id_ecdsa.fuzzidl
    
    pip install -U -r $env:userprofile\requirements.txt
}
