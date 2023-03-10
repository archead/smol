# smol
Smol is a powershell script that quickly converts large video files down to 25mb, which happens to be discord's upload limit ;)
## Requirements
- ffmpeg added to PATH
  - to install you can use either:
    - [this](https://phoenixnap.com/kb/ffmpeg-windows) guide
    - `choco install ffmpeg` via [Chocolatey](https://chocolatey.org/) 
- In case the install script fails for some reason, you must ensure Get-ExecutionPolicy is not Restricted

## Installation:
run `irm https://t.ly/O0P6f | iex` in Admin Powershell
