[string]$Directory = 'C:\test\sample'
[string]$BaseDatabaseName = "test" #end with an _ if you want one between this and the filename
[string]$RestoreServer = 'AVIONTEDEV02'



$ErrorActionPreference = "Stop";
. "$((get-item $PSScriptRoot).Parent.FullName)\functions\Restore-SqlDbDiffMove.ps1"
#."..\functions\Restore-SqlDbDiffMove.ps1"
Push-Location
Import-Module SQLPS | out-null
Pop-Location

Get-ChildItem -Path $Directory -Filter *.bak | ForEach-Object {

    $DatabaseName = $BaseDatabaseName + $_.BaseName

    Restore-SqlDbDiffMove -RestoreServer $RestoreServer -DatabaseName $DatabaseName -BackupFileFull $_.FullName -Verbose
    
}