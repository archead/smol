# smol
Smol is a powershell script that quickly* converts large video files down to 10mb, which happens to be discord's upload limit ;)

<sub>*depends on file size and length<sub>

## Requirements
### NOTE: ffmpeg is installed automatically with the script via winget
- ffmpeg added to PATH
  - to install you can use:
    1. `winget install ffmpeg` Provided by [Gyan](https://www.gyan.dev/ffmpeg/builds/)
    2. [this](https://phoenixnap.com/kb/ffmpeg-windows) guide
    3. `choco install ffmpeg` via [Chocolatey](https://chocolatey.org/) 
- In case the install script fails for some reason, you must ensure Get-ExecutionPolicy is not Restricted

## Installation:
Run the command below in Admin Powershell:

    irm https://raw.githubusercontent.com/archead/smol/refs/heads/main/smolinstaller.ps1 | iex



![ezgif com-video-to-gif](https://user-images.githubusercontent.com/55419973/224908409-9c4a41e2-0b47-42f1-8ec1-b720ebb731b5.gif)

## Usage:

1. Right-click on any video
2. Select `Compress with smol`
3. Wait for the process to finish
4. A new video file prefixed with `smol_` will appear

![ezgif com-video-to-gif](https://user-images.githubusercontent.com/55419973/224909234-f550152d-56ee-4dc1-83d4-f4bf6bcd1280.gif)

## Size Comparisson
![image](https://user-images.githubusercontent.com/55419973/224909634-dbf02788-6c52-4ef9-92e5-ee4293eeff16.png)

![image](https://user-images.githubusercontent.com/55419973/224909384-a54cc959-1992-4cb3-b4ec-b8def133d8f6.png)

## Removal
1. run `delete_smol.reg`
2. Delete the `smol()` function out of your `$PROFILE` file (more info [here](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.3))

## Warning
This is ideal for video files with a duration below 5 minutes

Although this script will transcode anything as long as the final birate is not below 100Kbps this will most likely result in extremely undesirable results
