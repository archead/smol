Write-Output "Installing smol..."
Write-Output "Setting Execution Policty to Unrestricted for CurrentUser."
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force

$Response = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/archead/smol/main/smol.ps1' -UseBasicParsing 
$profilescript = "
function smol `n 
{`n"
$profilescript += $Response
$profilescript += "`n}"

if (!(Test-Path -Path $PROFILE)) {
	Write-Output "Creating powershell profile."
	New-Item -ItemType File -Path $PROFILE -Force
	Write-Output "adding smol to profile."
	Add-Content $PROFILE $profilescript
}
else {
	Write-Output "adding smol to profile."
	Add-Content $PROFILE $profilescript
}

Write-Output "adding smol to context menu."

# Reg2CI (c) 2022 by Roger Zander
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Classes\*\shell\smol") -ne $true) {  New-Item "HKLM:\SOFTWARE\Classes\*\shell\smol" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Classes\*\shell\smol\command") -ne $true) {  New-Item "HKLM:\SOFTWARE\Classes\*\shell\smol\command" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\*\shell\smol' -Name '(default)' -Value 'Compress with smol' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\*\shell\smol\command' -Name '(default)' -Value 'powershell.exe smol \"%1\"' -PropertyType String -Force -ea SilentlyContinue;

Write-Output "smol installed successfully! You can now close this window."
