#Mandatory:
[string]$RestoreServer='your_RestoreServer'
[string]$DatabaseName='your_databasename'
[string]$BackupFileFull='your_filepathandname'

#Optional:
[string]$BackupFileDiff=''
[string]$DataFileDirectory=''
[string]$LogFileDirectory=''



$ErrorActionPreference = "Stop";
#. "$((get-item $PSScriptRoot).Parent.FullName)\functions\Restore-SqlDbDiffMove.ps1"
."..\functions\Restore-SqlDbDiffMove.ps1"
Push-Location
Import-Module SQLPS | out-null
Pop-Location

$parms = @{
    'RestoreServer'=$RestoreServer;
    'DatabaseName'=$DatabaseName;
    'BackupFileFull'=$BackupFileFull;
    'BackupFileDiff'=$BackupFileDiff;
    'DataFileDirectory'=$DataFileDirectory;
    'LogFileDirectory'=$LogFileDirectory;
    'Verbose'=$True;
}

Restore-SqlDbDiffMove @parms