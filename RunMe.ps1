#Check for PowerShell version
if($PSVersionTable.PSVersion.Major -ge 5){
    Write-Output "Machine is using PowerShell 5 or higher"

    #Init check variables
    $ConfigExist = $false
    $ModuleExist = $false
    $ManifestExist = $false
    
    #Check for config template
    if(Test-Path $PSScriptRoot\ConfigTemplate.json){
        Write-Output "Config template found"
        $ConfigExist = $true
    } else {
        Write-Output "Config template not found, cannot configure module"
    }
    
    #Check for template folder
    if(Test-Path $PSScriptRoot\OPSLoggingTemplate){
        #Check for Module template
        if(Test-Path $PSScriptRoot\OPSLoggingTemplate\OPSLoggingTemplate.psm1){
            Write-Output "Module template file found"
            $ModuleExist = $true
        } else {
            Write-Output "Module template file not found"
        }
    
        #Check for Manifest template
        if(Test-Path $PSScriptRoot\OPSLoggingTemplate\OPSLoggingTemplate.psd1){
            Write-Output "Module manifest found"
            $ManifestExist = $true
        } else {
            Write-Output "Module manifest template not found"
        }
    }
    
    #If the files exist gather config data from user
    if($ConfigExist -and $ModuleExist -and $ManifestExist){
        #Validate and gather config settings
        $ConfigPath = (Read-Host -Prompt "Enter UNC path to a folder all sctips can use to read the config file, the folder will be created if missing (Example: \\UNC\Path\To\Folder\Config)").TrimEnd('\')
        While(![bool]([System.Uri]$ConfigPath).IsUnc){
            Write-Error "String is an invalid Format"
            $ConfigPath = (Read-Host -Prompt "Enter UNC path to a folder all sctips can use to read the config file, the folder will be created if missing (Example: \\UNC\Path\To\Folder\Config)").TrimEnd('\')
        }
        $ModuleRoot = (Read-Host -Prompt "Enter UNC path to the root of your modules folder, the folder will be created if missing (Example: \\UNC\Path\To\Folder\Modules)").TrimEnd('\')
        While(![bool]([System.Uri]$ModuleRoot).IsUnc){
            Write-Error "String is an invalid Format"
            $ModuleRoot = (Read-Host -Prompt "Enter UNC path to the root of your modules folder, the folder will be created if missing (Example: \\UNC\Path\To\Folder\Modules)").TrimEnd('\')
        }
        $ScriptRoot = (Read-Host -Prompt "Enter UNC path to the root of your scripts folder, the folder will be created if missing (Example: \\UNC\Path\To\Folder\Scripts)").TrimEnd('\')
        While(![bool]([System.Uri]$ScriptRoot).IsUnc){
            Write-Error "String is an invalid Format"
            $ScriptRoot = (Read-Host -Prompt "Enter UNC path to the root of your scripts folder, the folder will be created if missing (Example: \\UNC\Path\To\Folder\Scripts)").TrimEnd('\')
        }
        $LogRoot = (Read-Host -Prompt "Enter UNC path to the root of the folder you want all logs published to, the folder will be created if missing (Example: \\UNC\Path\To\Folder\Logs)").TrimEnd('\')
        While(![bool]([System.Uri]$LogRoot).IsUnc){
            Write-Error "String is an invalid Format"
            $LogRoot = (Read-Host -Prompt "Enter UNC path to the root of the folder you want all logs published to, the folder will be created if missing (Example: \\UNC\Path\To\Folder\Logs)").TrimEnd('\')
        }
        $ScriptRootName = Read-Host -Prompt "Enter the folder name of the default scripts log folder (Example: ScriptLogs)"
        While(($ScriptRootName -notmatch '^[^\\\\\/\?\%\*\.\:\|\"<>]+$') -or ([bool]([System.Uri]$ScriptRootName).IsUnc -eq $true)){
            Write-Error "String is an invalid Format"
            $ScriptRootName = Read-Host -Prompt "Enter the folder name of the default scripts log folder (Example: ScriptLogs)"
        }
        $ModuleRootName = Read-Host -Prompt "Enter the folder name of the default modules log folder (Example: ModuleLogs)"
        While(($ModuleRootName -notmatch '^[^\\\\\/\?\%\*\.\:\|\"<>]+$') -or ([bool]([System.Uri]$ModuleRootName).IsUnc)){
            Write-Error "String is an invalid Format"
            $ModuleRootName = Read-Host -Prompt "Enter the folder name of the default modules log folder (Example: ModuleLogs)"
        }
        $EmailTo = Read-Host -Prompt "Enter default Email To address (Example: emailaddress@company.com)"
        While(![bool]($EmailTo -as [Net.Mail.MailAddress])){
           Write-Error "String is an invalid Format"
           $EmailTo = Read-Host -Prompt "Enter default Email To address (Example: emailaddress@company.com)"
        }
        $EmailCC = Read-Host -Prompt "Enter default Email CC address (Example: emailaddress@company.com)"
        While(![bool]($EmailCC -as [Net.Mail.MailAddress])){
           Write-Error "String is an invalid Format"
           $EmailCC = Read-Host -Prompt "Enter default Email CC address (Example: emailaddress@company.com)" 
        }
        $SendAs = Read-Host -Prompt "Enter SendAs name (Example: sender@companyname.com)"
        While(![bool]($SendAs -as [Net.Mail.MailAddress])){
           Write-Error "String is an invalid Format"
           $SendAs = Read-Host -Prompt "Enter SendAs name (Example: sender@companyname.com)"
        }
        $SMTP = Read-Host -Prompt "Enter SMTP FQDN (Example: smtp.companyname.com)"
        While($SMTP -notmatch "(?=^.{1,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)"){
            Write-Error "String is an invalid Format"
            $SMTP = Read-Host -Prompt "Enter SMTP FQDN (Example: smtp.companyname.com)"
        }
    
        #Set config settings
        $ConfigTemplate = Get-Content $PSScriptRoot\ConfigTemplate.json -Raw | ConvertFrom-Json
        $ConfigTemplate.Globals.LogRoot = "$LogRoot\"
        $ConfigTemplate.Globals.ModuleRoot = "$ModuleRoot\"
        $ConfigTemplate.Globals.ScriptRoot = "$ScriptRoot\"
        $ConfigTemplate.Globals.ScriptLogRoot = "$ScriptRootName\"
        $ConfigTemplate.Globals.ModuleLogRoot = "$ModuleRootName\"
        $ConfigTemplate.Globals.Email.EmailTo = $EmailTo
        $ConfigTemplate.Globals.Email.EmailCC = $EmailCC
        $ConfigTemplate.Globals.Email.SMTP = $SMTP
        $ConfigTemplate.Globals.Email.SendAs = $SendAs
        $ConfigFile = "$($ConfigPath)\Config.json"
        
        #Check for and save config file
        if(!(Test-Path $ConfigPath)){
            New-Item -ItemType Directory -Path $ConfigPath -Force | Out-Null
        }
        $ConfigTemplate | ConvertTo-Json | Set-Content $ConfigFile -Force
        
        #Check for path and save module
        if(!(Test-Path "$ModuleRoot\OPSLogging")){
            New-Item -ItemType Directory -Path "$ModuleRoot\OPSLogging" -Force | Out-Null
        }
        (Get-Content $PSScriptRoot\OPSLoggingTemplate\OPSLoggingTemplate.psm1).Replace("::CONFIGFILE::",$ConfigFile) | Set-Content "$ModuleRoot\OPSLogging\OPSLogging.psm1"
        (Get-Content $PSScriptRoot\OPSLoggingTemplate\OPSLoggingTemplate.psd1).Replace("::NESTEDMODULES::","$ModuleRoot\OPSLogging\OPSLogging.psm1") | Set-Content "$ModuleRoot\OPSLogging\OPSLogging.psd1"
    
        #Prompt for environmental variable add, loop if wrong answer
        $answer = Read-Host "Would you like to auto load the module path? (y/n)"
        while("y","n" -notcontains $answer){
            Write-Error "Please enter either 'y' or 'n'"
        	$answer = Read-Host "Would you like to auto load the module path? (y/n)"
        }
    
        #If user selects yes, set env variable
        if($answer -contains "y"){
            #Save the current value in the $p variable.
            Write-Output "Assigning environmental path to variable"
            $p = [Environment]::GetEnvironmentVariable("PSModulePath")
    
            #Add the new path to the $p variable. Begin with a semi-colon separator.
            Write-Output "Injecting modules path into environmental variable"
            $p += ";$ModuleRoot"
    
            #Add the paths in $p to the PSModulePath value.
            Write-Output "Saving updated environmental path"
            [Environment]::SetEnvironmentVariable("PSModulePath",$p, "Machine")
    
            Write-Output "Powershell instance must be restared before changes apply" -ForegroundColor Yellow
        }
    } else {
        Write-Error "Could not find all templates needed to perform configuration, please run RunMe.ps1 form within the same folder as template files"
    }
} else {
    Write-Error "Module was written on PowerShell version 5. Install version 5 or higher and run this script again"
}