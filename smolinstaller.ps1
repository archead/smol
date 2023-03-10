Write-Output "Installing smol..."
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
$profilescript = '
function smol 
{
	function Show-Progress 
	{
		param (
			$passnum
		)

		while (!(Test-Path "log.txt")) { Start-Sleep 1 }
		$lastwrite = Get-Item log.txt
		$offset, $progress = 0

		While ($progress -lt 100) 
		{
			$currentwrite = Get-Item log.txt
			if(($lastwrite.LastWriteTime) -lt ($currentwrite.LastWriteTime) -or (Get-Content log.txt -tail 1) -eq "progress=end")
			{
				$frame = Get-Content log.txt | Select -Index $offset
				$currframe = [int]($frame.substring(6))
				$offset += 12
				$percent = [int]($currframe / $totalframes * 100)
				$progress = $percent
				Write-Progress -Activity "Pass $passnum/2" -Status "$progress% Complete:" -PercentComplete $progress
				$lastwrite = $currentwrite
			}
		}
	}

	$totalframes = ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 $args[0]

	$dur = ffprobe $args[0] -show_entries format=duration -of compact=p=0:nk=1 -v 0
	$filename = Get-Item $args[0]
	$filename = "smol_" + $filename.Basename + ".mp4"
	$dur = [int]$dur
	$bitrate = [int]((200000 - $dur * 128) / $dur)
	$bitrate = $bitrate.toString()+"k"

	if (Test-Path "ffmpeg2pass-0.log") { rm .\ffmpeg2pass-0.log }
	if (Test-Path "log.txt") { rm .\log.txt }
	$filepath = $args[0]
	Start-Process -FilePath "ffmpeg" -ArgumentList "-progress log.txt -hide_banner -loglevel error -y -i `"$filepath`" -vf scale=1280:720 -c:v libx264 -preset superfast -b:v $bitrate -pass 1 -an -f null NUL; ` " -NoNewWindow
	Show-Progress 1

	rm .\log.txt
	Start-Process -FilePath "ffmpeg"  -ArgumentList "-progress log.txt -hide_banner -loglevel error -y -i `"$filepath`" -vf scale=1280:720 -c:v libx264 -preset superfast -b:v $bitrate -pass 2 -c:a aac -b:a 128k `"$filename`"" -NoNewWindow
	Show-Progress 2

	rm .\ffmpeg2pass-0.log .\log.txt 

	Write-Output "Video saved as: $filename"
}'



if (!(Test-Path -Path $PROFILE)) {
	Write-Output "Creating powershell profile..."
	New-Item -ItemType File -Path $PROFILE -Force
	Write-Output "adding smol to profile..."
	Add-Content $PROFILE $profilescript
}
else {
	Write-Output "adding smol to profile..."
	Add-Content $PROFILE $profilescript
}

Write-Output "adding smol to context menu..."

# Reg2CI (c) 2022 by Roger Zander
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Classes\*\shell\smol") -ne $true) {  New-Item "HKLM:\SOFTWARE\Classes\*\shell\smol" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Classes\*\shell\smol\command") -ne $true) {  New-Item "HKLM:\SOFTWARE\Classes\*\shell\smol\command" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\*\shell\smol' -Name '(default)' -Value 'Compress with smol' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\*\shell\smol\command' -Name '(default)' -Value 'powershell.exe smol \"%1\"' -PropertyType String -Force -ea SilentlyContinue;

Write-Output "smol installed successfully! You can now close this window."
