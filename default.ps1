Framework "4.0x64"

$Here = Split-Path $MyInvocation.MyCommand.Definition

Properties {
        $BuildDir = $Here
        $TmpDir = "$BuildDir\tmp"

        $MsBuild = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe"
        $Squirrel = "$Here\src\packages\squirrel.windows.0.99.1.1\tools\Squirrel.exe"
        $NuGet = "$BuildDir\Configuration\Tools\NuGet.exe"



        $SolutionFilePath = "$Here..\src\WpfFuture.sln"
        $Configuration="Release"
}

FormatTaskName (("-"*25) + "[{0}]" + ("-"*25))

Task Default -Depends Pack

Task Clean {
        Exec { &$MsBuild $SolutionFilePath /t:Clean /p:Configuration=$Configuration } "Failed to clean WpfFuture.sln"
}

Task Build -depends Clean  {
        Exec { &$MsBuild $SolutionFilePath /t:Build /p:Configuration=$Configuration /p:RunOctoPack=true } "Failed to build WpfFuture.sln"
}

Task Pack -Depends Build {
        Copy-Item "$here\src\obj\octopacked\*.nupkg" $TmpDir -Force -Verbose
        $nupkg = gci $TmpDir -filter *.nupkg |sort LastWriteTime | select -last 1
        $nupkg | Write-Host
        Exec {&$Squirrel --releasify "$TmpDir\$nupkg"} "Failed to create squirrel package"
}