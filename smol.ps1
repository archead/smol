$dur = ffprobe $args[0] -show_entries format=duration -of compact=p=0:nk=1 -v 0
$filename = $args[0] -replace '.\\',''
$filename = "smol_" + $filename
$dur = [int]$dur
$bitrate = [int]((200000 - $dur * 128) / $dur)
$bitrate = $bitrate.toString()+ "k"

Write-Progress -Activity "Pass 1/2" -Status "0% Complete:" -PercentComplete 0
ffmpeg -hide_banner -loglevel error -y -i $args[0] -vf scale=1280:720 -c:v libx264 -preset superfast -b:v $bitrate -pass 1 -an -f null NUL; `
Write-Progress -Activity "Pass 2/2" -Status "50% Complete:" -PercentComplete 50
ffmpeg -hide_banner -loglevel error -y -i $args[0] -vf scale=1280:720 -c:v libx264 -preset superfast -b:v $bitrate -pass 2 -c:a aac -b:a 128k $filename
Write-Progress -Activity "Done." -Status "100% Complete:" -PercentComplete 100
Start-Sleep -Milliseconds 1000

#ffmpeg -hide_banner -i $args[0] -vf scale=1280:720 -c:v libx264 -preset superfast -b:v $bitrate -c:a aac -b:a 128k $filename
rm .\ffmpeg2pass-0.log 

Write-Output "Done."
Write-Output "Video saved as: $filename" 
