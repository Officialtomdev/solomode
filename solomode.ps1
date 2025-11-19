Clear-Host

# ASCII Art Banner
$soloArt = @"
 ________  ________  ___       ________          _____ ______   ________  ________  _______      
|\   ____\|\   __  \|\  \     |\   __  \        |\   _ \  _   \|\   __  \|\   ___ \|\  ___ \     
\ \  \___|\ \  \|\  \ \  \    \ \  \|\  \       \ \  \\\__\ \  \ \  \|\  \ \  \_|\ \ \   __/|    
 \ \_____  \ \  \\\  \ \  \    \ \  \\\  \       \ \  \\|__| \  \ \  \\\  \ \  \ \\ \ \  \_|/__  
  \|____|\  \ \  \\\  \ \  \____\ \  \\\  \       \ \  \    \ \  \ \  \\\  \ \  \_\\ \ \  \_|\ \ 
    ____\_\  \ \_______\ \_______\ \_______\       \ \__\    \ \__\ \_______\ \_______\ \_______\
   |\_________\|_______|\|_______|\|_______|        \|__|     \|__|\|_______|\|_______|\|_______|
   \|_________|                                                                                  

Made by Tomdevw
"@


function Show-MainMenu {
    Clear-Host
    Write-Host $soloArt -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1) Solo Mode"
    Write-Host "2) Tools Installer"
    Write-Host "3) Delete C:\Solomode Folder"
    Write-Host "4) Exit"
    Write-Host ""
}


function Run-SoloMode {
    Clear-Host
    Write-Host $soloArt -ForegroundColor Cyan
    Write-Host "[Solo Mode]" -ForegroundColor Cyan
    Write-Host ""

    $webhook = Read-Host -Prompt "Enter webhook URL (or type 'n' for none)"

    $hostname = systeminfo | findstr /C:"Host Name"
    $installDate = systeminfo | findstr /C:"Original Install Date"

    $services = @(
        "pcasvc","DPS","Diagtrack","sysmain","eventlog","sgrmbroker","cdpusersvc", "BAM"
    ) | ForEach-Object {
        Get-Service | Where-Object { $_.Name -match $_ }
    }

    Write-Host "`nSystem Information:" -ForegroundColor Cyan
    Write-Host $hostname
    Write-Host $installDate

    Write-Host "`nService State:" -ForegroundColor Cyan
    $services | ForEach-Object { Write-Host "$($_.Name): $($_.Status)" }

    if ($webhook -ne "n" -and $webhook.Trim() -ne "") {
        Write-Host "`n[Webhook Enabled — Insert your authorized webhook code here]" -ForegroundColor Yellow
    }

    Write-Host "`nReturning to Main Menu..." -ForegroundColor Cyan
    Start-Sleep 3
}


function Run-ToolsInstaller {
    Clear-Host
    Write-Host $soloArt -ForegroundColor Cyan
    Write-Host "[Tools Installer Running...]" -ForegroundColor Cyan

    $BaseDir = "C:\Solomode"
    $LogFile = "$BaseDir\download-log.txt"
    New-Item -ItemType Directory -Path $BaseDir -Force | Out-Null
    $ProgressPreference = 'SilentlyContinue'

    Write-Host "All tools will be saved in: $BaseDir`n"

    $Tools = @(
    @{ Name="Amcache Parser"; Url="https://download.ericzimmermanstools.com/net9/AmcacheParser.zip"; File="AmcacheParser.exe" },
    @{ Name="ShimCache Parser"; Url="https://download.ericzimmermanstools.com/AppCompatCacheParser.zip"; File="AppCompatCacheParser.exe" },
    @{ Name="HxD"; Url="https://mh-nexus.de/downloads/HxDSetup.zip"; File="HxDSetup.exe" },
    @{ Name="HayaBusa"; Url="https://github.com/Yamato-Security/hayabusa/releases/download/v3.1.1/hayabusa-3.1.1-win-x64.zip"; File="hayabusa-3.1.1-win-x64.exe" },
    @{ Name="Everything Tool"; Url="https://www.voidtools.com/Everything-1.4.1.1026.x64-Setup.exe"; File="Everything-1.4.1.1026.x64-Setup.exe" },
    @{ Name="System Informer Canary"; Url="https://github.com/winsiderss/si-builds/releases/download/3.2.25078.1756/systeminformer-3.2.25078.1756-canary-setup.exe"; File="systeminformer-3.2.25078.1756-canary-setup.exe" },
    @{ Name="bstrings"; Url="https://download.ericzimmermanstools.com/net9/bstrings.zip"; File="bstrings.exe" },
    @{ Name="Detect It Easy"; Url="https://github.com/horsicq/DIE-engine/releases/download/3.10/die_win64_portable_3.10_x64.zip"; File="die_win64_portable_3.10_x64.exe" },
    @{ Name="JumpList Explorer"; Url="https://download.ericzimmermanstools.com/net6/JumpListExplorer.zip"; File="JumpListExplorer.exe" },
    @{ Name="MFTECmd"; Url="https://download.ericzimmermanstools.com/MFTECmd.zip"; File="MFTECmd.exe" },
    @{ Name="usnhelper"; Url="https://raw.githubusercontent.com/txchnology/test/main/usnjrnl_rewind.exe"; File="usnhelper.exe" },
    @{ Name="PECmd"; Url="https://download.ericzimmermanstools.com/net9/PECmd.zip"; File="PECmd.exe" },
    @{ Name="Registry Explorer"; Url="https://download.ericzimmermanstools.com/net9/RegistryExplorer.zip"; File="RegistryExplorer.exe" },
    @{ Name="SrumECmd"; Url="https://download.ericzimmermanstools.com/net9/SrumECmd.zip"; File="SrumECmd.exe" },
    @{ Name="Timeline Explorer"; Url="https://download.ericzimmermanstools.com/net9/TimelineExplorer.zip"; File="TimelineExplorer.exe" },
    @{ Name="WxTCmd"; Url="https://download.ericzimmermanstools.com/net9/WxTCmd.zip"; File="WxTCmd.exe" },
    @{ Name="RamDump Explorer"; Url="https://github.com/bacanoicua/RAMDumpExplorer/releases/download/1.0/RAMDumpExplorer.exe"; File="RAMDumpExplorer.exe" },
    @{ Name="UsbDeview"; Url="https://www.nirsoft.net/utils/usbdeview-x64.zip"; File="usbdeview-x64.exe" },
    @{ Name="AlternateStreamView"; Url="https://www.nirsoft.net/utils/alternatestreamview-x64.zip"; File="alternatestreamview-x64.exe" },
    @{ Name="WinPrefetchView"; Url="https://www.nirsoft.net/utils/winprefetchview-x64.zip"; File="winprefetchview-x64.exe" },
    @{ Name="Paths Parser"; Url="https://github.com/spokwn/PathsParser/releases/download/v1.0.11/PathsParser.exe"; File="PathsParser.exe" },
    @{ Name="Prefetch Parser"; Url="https://github.com/spokwn/prefetch-parser/releases/download/v1.5.4/PrefetchParser.exe"; File="PrefetchParser.exe" },
    @{ Name="Process Parser"; Url="https://github.com/spokwn/process-parser/releases/download/v0.5.4/ProcessParser.exe"; File="ProcessParser.exe" },
    @{ Name="PcaSvc Executed"; Url="https://github.com/spokwn/pcasvc-executed/releases/download/v0.8.6/PcaSvcExecuted.exe"; File="PcaSvcExecuted.exe" },
    @{ Name="BAM Parser"; Url="https://github.com/spokwn/BAM-parser/releases/download/v1.2.7/BAMParser.exe"; File="BAMParser.exe" },
    @{ Name="JournalTrace"; Url="https://github.com/spokwn/JournalTrace/releases/download/1.2/JournalTrace.exe"; File="JournalTrace.exe" },
    @{ Name="ReplaceParser"; Url="https://github.com/spokwn/Replaceparser/releases/download/v1.1-recode/ReplaceParser.exe"; File="ReplaceParser.exe" },
    @{ Name="RECmd"; Url="https://download.ericzimmermanstools.com/net9/RECmd.zip"; File="RECmd.exe" },
    @{ Name="Velociraptor"; Url="https://github.com/Velocidex/velociraptor/releases/download/v0.73/velociraptor-v0.73.4-windows-amd64.exe"; File="velociraptor.exe" },
    @{ Name="WinLiveInfo"; Url="https://github.com/kacos2000/Win10LiveInfo/releases/download/v.1.0.23.0/WinLiveInfo.exe"; File="WinLiveInfo.exe" },
    @{ Name="ExeInfoPe"; Url="https://cdn.discordapp.com/attachments/1280238836626231379/1280238836814712983/exeinfope.zip?ex=682d7814&is=682c2694&hm=3152a4be175e0a18ea93c84618c21b587d9a4237ec2cb0e519a830690c1cec99&"; File="exeinfope.exe" }
)


    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    foreach ($tool in $Tools) {
        try {
            $start = Get-Date
            Invoke-WebRequest -Uri $tool.Url -OutFile (Join-Path $BaseDir $tool.File) -ErrorAction Stop
            $elapsed = [math]::Round((New-TimeSpan $start (Get-Date)).TotalSeconds, 1)
            Add-Content $LogFile "$(Get-Date -Format 'u') - Downloaded: $($tool.Name) ($elapsed s)"
            Write-Host "[+] $($tool.Name) downloaded successfully ($elapsed s)" -ForegroundColor Green
        }
        catch {
            Add-Content $LogFile "$(Get-Date -Format 'u') - FAILED: $($tool.Name) ($($tool.Url))"
            Write-Warning "Failed to download $($tool.Name)"
        }
    }

    Write-Host "`nInstaller Finished." -ForegroundColor Cyan
    Write-Host "Location: $BaseDir"
    Write-Host "Log: $LogFile"

    Start-Sleep 3
}


function Delete-SolomodeFolder {
    Clear-Host
    Write-Host $soloArt -ForegroundColor Cyan
    Write-Host "[Delete Solomode Folder]" -ForegroundColor Yellow
    Write-Host ""

    $path = "C:\Solomode"

    if (-not (Test-Path $path)) {
        Write-Host "Folder does not exist: $path" -ForegroundColor Red
        Start-Sleep 2
        return
    }

    Write-Host "Are you sure you want to delete the folder:" -ForegroundColor Yellow
    Write-Host $path -ForegroundColor Cyan
    $confirm = Read-Host "Type Y to confirm"

    if ($confirm -eq "Y") {
        try {
            Remove-Item -LiteralPath $path -Recurse -Force
            Write-Host "`nFolder deleted successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "`nFailed to delete folder!" -ForegroundColor Red
        }
    }
    else {
        Write-Host "`nCancelled." -ForegroundColor Yellow
    }

    Start-Sleep 2
}

while ($true) {
    Show-MainMenu
    $choice = Read-Host "Choose an option"

    switch ($choice) {
        "1" { Run-SoloMode }
        "2" { Run-ToolsInstaller }
        "3" { Delete-SolomodeFolder }
        "4" { break }
        default {
            Write-Host "Invalid option." -ForegroundColor Red
            Start-Sleep 1
        }
    }
}
