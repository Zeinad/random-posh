[string]$RestoreServer='your_RestoreServer'
[string]$DatabaseName='your_databasename'
[string]$BackupFileFull='your_filepathandname'

#Optional:
[string]$BackupFileDiff=''
[string]$DataFileDirectory=''
[string]$LogFileDirectory=''


    function Restore-SqlDbDiffMove {
    <#

    .SYNOPSIS
    Restore a database, with support for file renaming and relocating.

    .DESCRIPTION
    Restore-SqlDbDiffMove will restore a full backup, with or without a provided differential, including dynamic renaming of the data and log files to match the new database name. Optinal support for non-default data and log file directories as well.

    .PARAMETER RestoreServer
    This is the server your backup files will be restored to.

    .PARAMETER DatabaseName
    This is the name your database will have upon being restored.

    .PARAMETER BackupFileFull
    This is the directory and file name of the full backup to be restored.

    .PARAMETER BackupFileDiff
    Optional. This is the directory and file name of the differential backup to be restored. If provided the full backup will be restored WITH NORECOVERY and the differential will be restored to it WITH RECOVERY to complete the restore.

    .PARAMETER DataFileDirectory
    Optional. Specify this to control the directory for the restored databases data files (if different than the server default). If not provided server default is used.

    .PARAMETER LogFileDirectory
    Optional. Specify this to control the directory for the restored databases log files (if different than the server default). If not provided server default is used.

    #>
    [cmdletbinding()]
        param(
          [Parameter(Mandatory=$true)]
          [string]$RestoreServer,
          [Parameter(Mandatory=$true)]
          [string]$DatabaseName,
          [Parameter(Mandatory=$true)]
          [string]$BackupFileFull,
          [string]$BackupFileDiff,
          [string]$DataFileDirectory,
          [string]$LogFileDirectory        
        )
        $server = new-object Microsoft.SqlServer.Management.Smo.Server $RestoreServer;

        if($DataFileDirectory -and !$LogFileDirectory){
          $LogFileDirectory = $DataFileDirectory;
        }

        if(!$DataFileDirectory)
        {
          $DataFileDirectory = $server.Settings.DefaultFile;
        }
        if(!$LogFileDirectory){
          $LogFileDirectory = $server.Settings.DefaultLog;
        }
        $backupDeviceItem = new-object Microsoft.SqlServer.Management.Smo.BackupDeviceItem "$BackupFileFull", 'File';
        $restore = new-object 'Microsoft.SqlServer.Management.Smo.Restore';
        $restore.Database = $DatabaseName;
        $restore.Devices.Add($backupDeviceItem);

        $dataFileNumber = 0; #data files, mdf
        $ftFileNumber = 0; #full text files, ndf
        $logFileNumber = 0; #log files, ldf
        $fsFileNumber = 0; #filstream

        foreach ($file in $restore.ReadFileList($server))
        {
            $relocateFile = new-object 'Microsoft.SqlServer.Management.Smo.RelocateFile';
            $relocateFile.LogicalFileName = $file.LogicalName;

            if ($file.Type -eq 'D' -and $file.PhysicalName -like '*.mdf' ){
                if($dataFileNumber) {
                    $suffix = "_$dataFileNumber";
                }
                else{
                    $suffix = $null;
                }

                $relocateFile.PhysicalFileName = Join-Path -Path "$DataFileDirectory" -ChildPath "$DatabaseName$suffix.mdf" ;
                
                $dataFileNumber ++;
            }
            elseif ($file.Type -eq 'D' -and $file.PhysicalName -like '*.ndf' ){
                if($ftFileNumber) {
                    $suffix = "_$ftFileNumber";
                }
                else{
                    $suffix = $null;
                }

                $relocateFile.PhysicalFileName = Join-Path -Path "$DataFileDirectory" -ChildPath "$DatabaseName$suffix.ndf";
                
                $ftFileNumber ++;
            }
            elseif ($file.Type -eq 'L') {
                if($logFileNumber) {
                    $suffix = "_$logFileNumber";
                }
                else{
                    $suffix = $null;
                }
              $relocateFile.PhysicalFileName = Join-Path -Path "$LogFileDirectory" -ChildPath "$DatabaseName.ldf";
            }
            elseif ($file.Type -eq 'S') {
                if($fsFileNumber) {
                    $suffix = "_$fsFileNumber";
                }
                else{
                    $suffix = $null;
                }
              $relocateFile.PhysicalFileName = Join-Path -Path "$DataFileDirectory" -ChildPath "$DatabaseName";
            }
            else {
              Write-Error 'file of type not D,L, or S, or currently has a weird extention; what kind of file is this?'
            }

            $restore.RelocateFiles.Add($relocateFile) | out-null;
        }    
        
        if($BackupFileDiff) {
            Restore-SqlDatabase -ServerInstance $RestoreServer -Database $DatabaseName -BackupFile "$BackupFileFull" -RelocateFile $restore.RelocateFiles -NoRecovery -ConnectionTimeout 0
        }
        else {
            Restore-SqlDatabase -ServerInstance $RestoreServer -Database $DatabaseName -BackupFile "$BackupFileFull" -RelocateFile $restore.RelocateFiles -ConnectionTimeout 0
        }
        
        $restore.Devices.Remove($backupDeviceItem);
        
        if($BackupFileDiff)
        {
            Restore-SqlDatabase -ServerInstance $RestoreServer -Database $DatabaseName -BackupFile "$BackupFileDiff" -ConnectionTimeout 0
        }
    }


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