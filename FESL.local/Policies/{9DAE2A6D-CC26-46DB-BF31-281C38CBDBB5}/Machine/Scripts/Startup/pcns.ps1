Get-Service -Name PCNSSVC -ErrorAction SilentlyContinue -ErrorVariable err
if ($err)
{
$log = $env:TEMP + "\pcns.log"
Get-Date | Out-File -Append $log
try{
$zipFile = (Get-Item .).FullName + "\PCNS.zip";
$tempfolder = $env:TEMP + "\" +[Guid]::NewGuid();
"PCNS Zip File: $zipfile`nUnzip Destionation Folder: $tempfolder" | Out-File -Append $log
New-Item -Path $tempfolder -Type Directory -Force
$shell = new-object -com shell.application;
$zip = $shell.NameSpace($zipFile);
$dest = $shell.NameSpace($tempfolder);
$dest.CopyHere($zip.items(), 0x14)
$pcns = $tempfolder + "\Password Change Notification Service.msi"
$pcns | Out-File -Append $log
$msilog = $env:TEMP + "\pcns_msi.log"
$path = [Environment]::SystemDirectory + '\msiexec.exe'
$arg = '/i "' + $pcns + '" /quiet /l*v "' + $msilog + '"'
Start-Process -FilePath $path -ArgumentList $arg -Wait -Passthru
}catch{
$_.Exception.ToString() | Out-File -Append $log}}
