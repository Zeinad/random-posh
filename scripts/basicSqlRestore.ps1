#Mandatory:
[string]$RestoreServer='AVIONTEDEV02'
[string]$DatabaseName='test'
[string]$BackupFileFull='C:\TEMP\TX3560_DC_20170515.bak'

#Optional:
[string]$BackupFileDiff=''
[string]$DataFileDirectory=''
[string]$LogFileDirectory=''


$ErrorActionPreference = "Stop";
. "$((get-item $PSScriptRoot).Parent.FullName)\functions\Restore-SqlDbDiffMove.ps1"

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