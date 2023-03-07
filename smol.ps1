$dur = ffprobe $args[0] -show_entries format=duration -of compact=p=0:nk=1 -v 0
$filename = $args[0] -replace '.\\',''
$filename = "smol_" + $filename
$dur = [int]$dur
$bitrate = [int](200000 / $dur - 128)
$bitrate = $bitrate.toString()+ "k"
Write-Output "Making the video smol..."
Write-Output "Please Wait."
ffmpeg -hide_banner -loglevel error -y -i $args[0] -vf scale=1280:720 -c:v libx264 -preset superfast -b:v $bitrate -pass 1 -an -f null NUL; `
ffmpeg -hide_banner -loglevel error -i $args[0] -vf scale=1280:720 -c:v libx264 -preset superfast -b:v $bitrate -pass 2 -c:a aac -b:a 128k $filename
rm .\ffmpeg2pass-0.log 
#rm .\ffmpeg2pass-0.log.mbtree
Write-Output "Done."
Write-Output "Video saved as: " $filename