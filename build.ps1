param (
    [string]$Version = "0.0.0.0",
    [string]$Configuration = "Release"
)

Write-Host $Version
$Here = Split-Path $MyInvocation.MyCommand.Definition
$env:EnableNuGetPackageRestore = 'false'
$NuGetExe = 'NuGet.exe'

if ((Test-Path $NuGetExe) -eq $false) {(New-Object System.Net.WebClient).DownloadFile('http://nuget.org/nuget.exe', $NuGetExe)}

& $NuGetExe install squirrel.windows -OutputDirectory src\packages
& $NuGetExe install psake -OutputDirectory src\packages -Version 4.2.0.1
& $NuGetExe restore src\WpfFuture.sln

if((Get-Module psake) -eq $null)
{
    Import-Module $Here\src\packages\psake.4.2.0.1\tools\psake.psm1
}

$TmpPath = $Here+'\tmp'
New-Item -Type Directory $TmpPath -Force

$psake.use_exit_on_error = $true
Invoke-psake -buildFile $Here'.\Default.ps1' -parameters @{"Version"=$Version;"Configuration"=$Configuration;"NuGetPack"="true"}

#rm $TmpPath -force -recurse

if ($psake.build_success -eq $false) { exit 1 } else { exit 0 }