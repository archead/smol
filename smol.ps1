#SMOL_START
# SMOL INSTALLER HEADER ABOVE DONT REMOVE 
param (

    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string]$argPath,

    [Parameter(Mandatory=$false)]
    [switch]$d
)

$ErrorActionPreference = 'Stop'

function CleanupTempFiles {
    try {
        Remove-Item .\log.txt, .\ffmpeg2pass-0.log, .\ffmpeg2pass-0.log.mbtree.temp, .\ffmpeg2pass-0.log.mbtree -ErrorAction SilentlyContinue
    } catch {
        Write-Warning "Failed to clean up temporary files: $_"
    }
}

# Helper Function that displays encode progress
# Removing its calls from the main script will break the script 
# since the ffmpeg call has the -Wait flag which blocks execution
function Show-Progress {
    param (
        $passnum
    )

    # Wait for the log.txt file to be created
    while (!(Test-Path "log.txt")) { Start-Sleep 1 }

    # Initialize last write time and offset
    $lastwrite = Get-Item log.txt
    $offset, $progress = 0

    # Continue until the progress reaches 100%
    While ($progress -lt 100) {
        $currentwrite = Get-Item log.txt

        # Update progress if the log file has been updated or if progress=end is reached
        if(($lastwrite.LastWriteTime) -lt ($currentwrite.LastWriteTime) -or (Get-Content log.txt -tail 1) -eq "progress=end") {
            try {
                # Extract the last frame number using regex
                $frames = Get-Content log.txt | Select-String -Pattern '^frame=(\d+)'
                $currframe = [Int]($frames | Select-Object -Last 1).Matches.Groups[1].Value
                $percent = [math]::Ceiling(($currframe / $totalframes) * 100)
                $progress = $percent
                Write-Progress -Activity "Pass $passnum/2" -Status "$progress% Complete:" -PercentComplete $progress
            } catch {
                Write-Error "Error reading progress from log file: $_"
            }
        }

        # Check if the progress has ended
        if((Get-Content log.txt -tail 1) -eq "progress=end"){
            $progress = 100
        }
    }
}

# SCRIPT START ----------------------------------------------------------------------------------------

# Prevents blocking the output text by moving all debug text down the same number of rows as the progress bar
Write-Output "`n`n`n`n`n`n"

if ($d) {
    $DebugPreference = 'Continue'
    Write-Host "[DEBUG MODE]" -ForegroundColor "Yellow"
}

# Get the total frame count of the video
try {
    $totalframes = [int](ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 $argPath)
    Write-Output "Framecount: `t`t$totalframes"
} catch {
    Write-Error "Failed to calculate total frames using ffprobe. Ensure the input file is valid. Error: $_"
    exit 1
}

# Get the video duration using ffprobe
$dur = ffprobe $argPath -show_entries format=duration -of compact=p=0:nk=1 -v 0
$dur = [float]$dur
Write-Output "Video Duration: `t$dur `bs"

# Prepare output filename
$filename = Get-Item $argPath
$filename = "smol_" + $filename.Basename + ".mp4"

$audiobitrate = 128

# Calculate the target bitrate
$bitrate = [int](((9.5 * 8388.608) - ($dur * $audiobitrate)) / $dur)  # https://trac.ffmpeg.org/wiki/Encode/H.264#twopass

# Adjust bitrate if it is too low
if ($bitrate -lt 100){
    Write-Output "WARNING: Audio bitrate too high! Attempting to adjust automatically..."
    Write-Output "STATUS: Dropping audio bitrate to 64kbps"
    $audiobitrate = 64
    $bitrate = [int](((9.5 * 8388.608) - ($dur * $audiobitrate)) / $dur)  # https://trac.ffmpeg.org/wiki/Encode/H.264#twopass
    Write-Output "Adjusted Target bitrate: $bitrate `bKbps"
}

# Abort if the bitrate is still too low after adjustments
if ($bitrate -lt 100){
    Write-Output "WARNING: Video bitrate has dropped below 100kbps... this will have VERY undesirable results... cancelling operation"
    exit 1
}

# Convert bitrate to string with "k" suffix
$bitrate = $bitrate.ToString() + "k"
$audiobitrate = $audiobitrate.ToString() + "k"

# Remove existing log files from previous runs
Remove-Item .\log.txt, .\ffmpeg2pass-0.log, .\ffmpeg2pass-0.log.mbtree.temp, .\ffmpeg2pass-0.log.mbtree -ErrorAction SilentlyContinue

# Ensure the specified file exists
if (-not (Test-Path $argPath)) {
    Write-Error "The specified file does not exist: $($argPath)"
    exit 1
}

# Resolve the path of the video file
$filepath = (Resolve-Path $argPath).Path

# Output codec information
Write-Output "Target filesize: `t<10MB"
Write-Output "Video Codec: `t`tlibx264 @ $bitrate`bKbps"
Write-Output "Audio Codec: `t`tlibopus @ $audiobitrate`bKbps"
Write-Output "Beginning Transcode..."

try {
# Run FFmpeg for the first pass
$ffmpegArgsPass1 = "-progress log.txt -hide_banner -loglevel error -y -i `"$filepath`" -vf `"scale=1280:-2`" -c:v libx264 -preset slow -b:v $bitrate -pass 1 -fps_mode passthrough -f null NUL; ` "
Write-Debug("ffmpeg " + $ffmpegArgsPass1)
Start-Process -FilePath "ffmpeg" -ArgumentList $ffmpegArgsPass1 -NoNewWindow
Show-Progress 1

# Remove log file after the first pass
Remove-Item .\log.txt -ErrorAction SilentlyContinue

# Run FFmpeg for the second pass
$ffmpegArgsPass2 = "-progress log.txt -hide_banner -loglevel error -y -i `"$filepath`" -vf `"scale=1280:-2`" -c:v libx264 -preset slow -b:v $bitrate -pass 2 -c:a libopus -b:a $audiobitrate -ac 2 `"$filename`""
Write-Debug("ffmpeg " + $ffmpegArgsPass2)
Start-Process -FilePath "ffmpeg" -ArgumentList $ffmpegArgsPass2 -NoNewWindow
Show-Progress 2

# Clean up temporary log files after transcoding
Remove-Item .\log.txt, .\ffmpeg2pass-0.log, .\ffmpeg2pass-0.log.mbtree.temp, .\ffmpeg2pass-0.log.mbtree -ErrorAction SilentlyContinue

# Final output message
Write-Output "Video saved as: $filename"

} catch {
    Write-Warning "An error occurred during the process: $_"
    
    # Attempt cleanup even in case of an error
    CleanupTempFiles
}
# SMOL INSTALLER FOOTER DO NOT REMOVE
#SMOL_STOP