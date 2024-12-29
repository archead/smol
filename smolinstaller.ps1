# Check if winget is installed
try {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "winget is available. Proceeding with FFmpeg installation..." -ForegroundColor Green

        # Install FFmpeg using Gyan.FFmpeg
        try {
            winget install --id=Gyan.FFmpeg -e -h
            Write-Host "FFmpeg installation completed successfully." -ForegroundColor Green
        } catch {
            Write-Host "An error occurred during FFmpeg installation: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "winget is not installed or not available in the PATH. Please ensure winget is installed." -ForegroundColor Red
    }
} catch {
    Write-Host "An unexpected error occurred while checking winget: $_" -ForegroundColor Red
}

Write-Output "Installing smol..."
try {
    Write-Output "Setting Execution Policy to Unrestricted for CurrentUser."
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force

    $Response = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/archead/smol/main/smol.ps1' -UseBasicParsing
    $profilescript = "
function smol {`n"
    $profilescript += $Response
    $profilescript += "`n}"

    if (!(Test-Path -Path $PROFILE)) {
        Write-Output "Creating PowerShell profile."
        New-Item -ItemType File -Path $PROFILE -Force
        Write-Output "Adding smol to profile."
        Add-Content $PROFILE $profilescript
    } else {
        Write-Output "Profile exists. Updating smol function if it exists."
        # Read the existing profile content
        try {
            $profileContent = Get-Content $PROFILE -Raw

            # Remove any existing 'smol' function definitions
            $profileContent = $profileContent -replace '\s*function smol[\s\S]*?Write-Output "Video saved as: \$filename"\s*}\s*', ""
            $profileContent = $profileContent -replace '(?<=^.*\n)#SMOL_START(.|\n)*?(?=#SMOL_STOP)', ""

            # Update the profile content
            Set-Content $PROFILE -Value $profileContent
            Add-Content $PROFILE $profilescript
        } catch {
            Write-Host "An error occurred while updating the profile: $_" -ForegroundColor Red
        }
    }

    Write-Host "Adding smol to context menu." -ForegroundColor Yellow

    try {
        # Add smol to the context menu
        if ((Test-Path -LiteralPath "HKLM:\SOFTWARE\Classes\*\shell\smol") -ne $true) {  
            New-Item "HKLM:\SOFTWARE\Classes\*\shell\smol" -force -ea SilentlyContinue 
        }
        if ((Test-Path -LiteralPath "HKLM:\SOFTWARE\Classes\*\shell\smol\command") -ne $true) {  
            New-Item "HKLM:\SOFTWARE\Classes\*\shell\smol\command" -force -ea SilentlyContinue 
        }
        New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\*\shell\smol' -Name '(default)' -Value 'Compress with smol' -PropertyType String -Force -ea SilentlyContinue
        New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\*\shell\smol\command' -Name '(default)' -Value 'powershell.exe smol \"%1\"' -PropertyType String -Force -ea SilentlyContinue
        Write-Host "smol installed successfully! You can now close this window." -ForegroundColor Green
    } catch {
        Write-Host "An error occurred while adding smol to the context menu: $_" -ForegroundColor Red
    }
} catch {
    Write-Host "An unexpected error occurred during the smol installation process: $_" -ForegroundColor Red
}
