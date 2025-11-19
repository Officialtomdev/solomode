Clear-Host

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
        "pcasvc","DPS","Diagtrack","sysmain","eventlog","sgrmbroker","cdpusersvc"
    ) | ForEach-Object {
        Get-Service | findstr -i $_
    }

    Write-Host "`nSystem Information:" -ForegroundColor Cyan
    Write-Host $hostname
    Write-Host $installDate

    Write-Host "`nService State:" -ForegroundColor Cyan
    $services | ForEach-Object { Write-Host $_ }

    if ($webhook -ne "n" -and $webhook.Trim() -ne "") {
        Write-Host "`n[Webhook Enabled — Insert your authorized webhook code here]" -ForegroundColor Yellow
        
        <#
            PLACE YOUR WEBHOOK CODE HERE
        #>
    }

    Write-Host "`nReturning to Main Menu..." -ForegroundColor Cyan
    Start-Sleep 2
}



function Run-ToolsInstaller {
    Clear-Host
    Write-Host $soloArt -ForegroundColor Cyan
    Write-Host "[Tools Installer Running...]" -ForegroundColor Cyan

    $BaseDir = "C:\Screenshare"
    $LogFile = "$BaseDir\download-log.txt"
    New-Item -ItemType Directory -Path $BaseDir -Force | Out-Null
    $ProgressPreference = 'SilentlyContinue'

    Write-Host "All tools will be saved in: $BaseDir`n"

    $Tools = @(
        @{ Name="Kernel Live Dump Analyzer Parser"; Url="https://github.com/spokwn/KernelLiveDumpTool/releases/download/v1.1/KernelLiveDumpTool.exe"; File="KernelLiveDumpTool.exe" },
        @{ Name="BAM Parser"; Url="https://github.com/spokwn/BAM-parser/releases/download/v1.2.9/BAMParser.exe"; File="BAMParser.exe" },
        @{ Name="Paths Parser"; Url="https://github.com/spokwn/PathsParser/releases/download/v1.2/PathsParser.exe"; File="PathsParser.exe" },
        @{ Name="JournalTrace"; Url="https://github.com/spokwn/JournalTrace/releases/download/1.2/JournalTrace.exe"; File="JournalTrace.exe" },
        @{ Name="Tool"; Url="https://github.com/spokwn/Tool/releases/download/v1.1.3/espouken.exe"; File="espouken.exe" },
        @{ Name="PcaSvc Executed"; Url="https://github.com/spokwn/pcasvc-executed/releases/download/v0.8.7/PcaSvcExecuted.exe"; File="PcaSvcExecuted.exe" },
        @{ Name="BAM Deleted Keys"; Url="https://github.com/spokwn/BamDeletedKeys/releases/download/v1.0/BamDeletedKeys.exe"; File="BamDeletedKeys.exe" },
        @{ Name="Prefetch Parser"; Url="https://github.com/spokwn/prefetch-parser/releases/download/v1.5.5/PrefetchParser.exe"; File="PrefetchParser.exe" },
        @{ Name="Activities Cache Parser"; Url="https://github.com/spokwn/ActivitiesCache-execution/releases/download/v0.6.5/ActivitiesCacheParser.exe"; File="ActivitiesCacheParser.exe" }
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    foreach ($tool in $Tools) {
        try {
            $start = Get-Date
            Invoke-WebRequest -Uri $tool.Url -OutFile (Join-Path $BaseDir $tool.File) -ErrorAction Stop
            $elapsed = [math]::Round((New-TimeSpan $start (Get-Date)).TotalSeconds, 1)
            Add-Content $LogFile "$(Get-Date -Format 'u') - Downloaded: $tool.Name ($elapsed s)"
            Write-Host "[+] $tool.Name downloaded successfully ($elapsed s)"
        }
        catch {
            Add-Content $LogFile "$(Get-Date -Format 'u') - FAILED: $tool.Name ($tool.Url)"
            Write-Warning "Failed to download $tool.Name"
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
        default {
            Write-Host "Invalid option." -ForegroundColor Red
            Start-Sleep 1
        }
    }
}
