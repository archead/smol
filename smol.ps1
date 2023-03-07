$dur = ffprobe $args[0] -show_entries format=duration -of compact=p=0:nk=1 -v 0
$filename = $args[0] -replace '.\\',''
$filename = "smol_" + $filename
$dur = [int]$dur
$bitrate = [int]((200000 - $dur * 128) / $dur)
$bitrate = $bitrate.toString()+ "k"

Write-Progress -Activity "Pass 1/2" -Status "0% Complete:" -PercentComplete 0

ffmpeg -hide_banner -loglevel error -y -i $args[0] -vf scale=1280:720 -c:v libx264 -preset superfast -b:v $bitrate -pass 1 -an -f null NUL; `

for ($i = 1; $i -le 50; $i++ ) {
    Write-Progress -Activity "Pass 2/2" -Status "$i% Complete:" -PercentComplete $i
    Start-Sleep -Milliseconds 1
}

ffmpeg -hide_banner -loglevel error -y -i $args[0] -vf scale=1280:720 -c:v libx264 -preset superfast -b:v $bitrate -pass 2 -c:a aac -b:a 128k $filename

for ($i = 50; $i -le 100; $i++ ) {
    Write-Progress -Activity "Done." -Status "$i% Complete:" -PercentComplete $i
    Start-Sleep -Milliseconds 1
}

Start-Sleep -Milliseconds 1000

#ffmpeg -hide_banner -i $args[0] -vf scale=1280:720 -c:v libx264 -preset superfast -b:v $bitrate -c:a aac -b:a 128k $filename
rm .\ffmpeg2pass-0.log 

Write-Output "Video saved as: $filename" 
