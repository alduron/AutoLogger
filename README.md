# Powershell Logging Module
## Features

* Uniform logging of functions and scripts to configurable .log files
* Automatic log file selection based on configuration file
* Log file parsing based on configuration file
* Optional console output
* Optional email alerting

## Installation
### GitHub
#### Clone Repo

```terminal
> git clone https://github.com/alduron/AutoLogger.git
> Run RunMe.ps1

```

#### Download Repo

* Download [the zip](https://github.com/alduron/AutoLogger/archive/master.zip)
* Unzip the content of Logger to any folder
* Run RunMe.ps1 and follow prompts

## TL;DR - The module

```powershell
New-LogEntry "Message to be logged" -JobType "Test" -Console
Add-ToLog "Message to be logged" -Type ERR -ErrorMessage $_.Exception.Message -Console
Close-LogEntry -Result "Failure" -Console -SendEmail
Get-LogEntry -LogFile <Name of log files auto populated> -Type ERR -Contains "Word or phrase" - Exclude "Word of phrase"

```

## TL;DR - The config file

```json

"Modules": [
	{
		"Name": "Name of the module that will be logged",
		"Location": "Location of the logging module. This is for future use and is not currently used",
		"LogDefault": "Default logging folder name followed by \\",
		"Functions": [
			{
				"Name": "Example-Function name that will be caught by the file selector",
				"Log": "Redirect folder name and path to the log file within the logging root folder"
			}
		]
	}
],

```

## NOTES

* The configuration JSON file needs to be in the exact format supplied in the template. The auto configuration script will populate the initial data, but all additions need to follow the same format
* The module is designed to be used in situations where multiple techs are running the same module and require uniform logged responses
* The Get-LogEntry is a temporary function and will be expanded upon at a later date
