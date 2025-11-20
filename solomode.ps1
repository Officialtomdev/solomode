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


function Install-Tool {
    param(
        [Parameter(Mandatory=$true)][string]$ToolName,
        [Parameter(Mandatory=$true)][string]$Url,
        [string]$ZipName = $null,
        [string]$ExeName = $null,
        [string[]]$Commands = $null,      
        [switch]$NestedFolder,            
        [switch]$IsExe,                   
        [string]$BaseFolder = "C:\Solomode",
        [switch]$Cleanup                 
    )

    $null = New-Item -ItemType Directory -Path $BaseFolder -Force

    $ToolFolder = Join-Path $BaseFolder $ToolName
    New-Item -ItemType Directory -Path $ToolFolder -Force | Out-Null

    if ($ExeName) {
        $DownloadFile = Join-Path $ToolFolder $ExeName
    } elseif ($ZipName) {
        $DownloadFile = Join-Path $ToolFolder $ZipName
    } else {
        $DownloadFile = Join-Path $ToolFolder (Split-Path $Url -Leaf)
    }

    Write-Host "[=] Getting $ToolName from $Url"

    try {
        Invoke-WebRequest -Uri $Url -OutFile $DownloadFile -UseBasicParsing -ErrorAction Stop
        Write-Host "[+] Downloaded: $ToolName -> $DownloadFile" -ForegroundColor Green
    }
    catch {
        Write-Warning "[!] Failed to download $ToolName : $_"
        return @{
            Name = $ToolName
            Success = $false
            Error = $_.Exception.Message
        }
    }

    if ($ZipName -and -not $IsExe) {
        try {
            Write-Host "[=] Extracting $DownloadFile to $ToolFolder"
            Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
            [System.IO.Compression.ZipFile]::ExtractToDirectory($DownloadFile, $ToolFolder)

            if ($NestedFolder) {
                $ExtractedFolderName = [IO.Path]::GetFileNameWithoutExtension($ZipName)
                $ExeDir = Join-Path $ToolFolder $ExtractedFolderName
            } else {
                $ExeDir = $ToolFolder
            }

            if ($Commands) {
                foreach ($cmd in $Commands) {
                    $processedCmd = $cmd.Replace("{folder}", $ToolFolder)
                    Write-Host "[CMD] Running: $processedCmd"

                    $parts = $processedCmd -split ' '
                    $exe = Join-Path $ExeDir $parts[0]
                    $args = @()
                    if ($parts.Count -gt 1) { $args = $parts[1..($parts.Count - 1)] }

                    try {
                        Start-Process -FilePath $exe -ArgumentList $args -WorkingDirectory $ExeDir -NoNewWindow -Wait -ErrorAction Stop
                    } catch {
                        Write-Warning "[!] Command failed for $ToolName : $_"
                    }
                }
            }

            if ($Cleanup) {
                Remove-Item -LiteralPath $DownloadFile -Force -ErrorAction SilentlyContinue
                Write-Host "[X] Removed archive: $DownloadFile"
            }

            return @{
                Name = $ToolName
                Success = $true
                Path = $ToolFolder
            }
        }
        catch {
            Write-Warning "[!] Failed to extract $ToolName : $_"
            return @{
                Name = $ToolName
                Success = $false
                Error = $_.Exception.Message
            }
        }
    }
    elseif ($IsExe) {
        try {
            if ($Commands) {
                foreach ($cmd in $Commands) {
                    $processedCmd = $cmd.Replace("{folder}", $ToolFolder)
                    Write-Host "[CMD] Running: $processedCmd"

                    $parts = $processedCmd -split ' '
                    $exe = $DownloadFile   
                    $args = @()
                    if ($parts.Count -gt 1) { $args = $parts[1..($parts.Count - 1)] }

                    try {
                        Start-Process -FilePath $exe -ArgumentList $args -WorkingDirectory $ToolFolder -NoNewWindow -Wait -ErrorAction Stop
                    } catch {
                        Write-Warning "[!] Command failed for $ToolName : $_"
                    }
                }
            }

            if ($Cleanup) {
                Remove-Item -LiteralPath $DownloadFile -Force -ErrorAction SilentlyContinue
                Write-Host "[X] Removed exe: $DownloadFile"
            }

            return @{
                Name = $ToolName
                Success = $true
                Path = $ToolFolder
            }
        } catch {
            Write-Warning "[!] Error processing EXE for $ToolName : $_"
            return @{
                Name = $ToolName
                Success = $false
                Error = $_.Exception.Message
            }
        }
    }
    else {
        Write-Host "[+] $ToolName saved as $DownloadFile (no extraction requested)"
        return @{
            Name = $ToolName
            Success = $true
            Path = $ToolFolder
        }
    }
}


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

    $hostname = (systeminfo | findstr /C:"Host Name").Trim()
    $installDate = (systeminfo | findstr /C:"Original Install Date").Trim()

    $serviceNames = @(
        "pcasvc","DPS","Diagtrack","sysmain","eventlog","sgrmbroker","cdpusersvc"
    )

    $services = foreach ($svc in $serviceNames) {
        try {
            $s = Get-Service -Name $svc -ErrorAction Stop
            [PSCustomObject]@{ Name = $s.Name; Status = $s.Status }
        } catch {
            [PSCustomObject]@{ Name = $svc; Status = "Not Found" }
        }
    }

    Write-Host "`nSystem Information:" -ForegroundColor Cyan
    Write-Host $hostname
    Write-Host $installDate

    Write-Host "`nService State:" -ForegroundColor Cyan
    $services | ForEach-Object { Write-Host "$($_.Name): $($_.Status)" }

    if ($webhook -ne "n" -and $webhook.Trim() -ne "") {
        $payload = @{
            embeds = @(
                @{
                    title = "Solo Mode Report"
                    color = 5814783
                    fields = @(
                        @{ name = "Hostname"; value = $hostname },
                        @{ name = "Install Date"; value = $installDate },
                        @{
                            name = "Service Status"
                            value = ($services | ForEach-Object { "$($_.Name): $($_.Status)" }) -join "`n"
                        }
                    )
                }
            )
        } | ConvertTo-Json -Depth 5

        try {
            Invoke-RestMethod -Uri $webhook -Method Post -ContentType "application/json" -Body $payload -ErrorAction Stop
            Write-Host "`nWebhook sent successfully!" -ForegroundColor Green
        } catch {
            Write-Host "`nFailed to send webhook: $_" -ForegroundColor Red
        }
    }

    Write-Host "`nReturning to Main Menu..." -ForegroundColor Cyan
    Start-Sleep 3
}

function Run-ToolsInstaller {
    Clear-Host
    Write-Host $soloArt -ForegroundColor Cyan
    Write-Host "[Tools Installer Running...]" -ForegroundColor Cyan
    Write-Host ""

    $BaseDir = "C:\Solomode"
    $LogFile = Join-Path $BaseDir "download-log.txt"
    New-Item -ItemType Directory -Path $BaseDir -Force | Out-Null
    $ProgressPreference = 'SilentlyContinue'

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Write-Host "All tools will be saved in: $BaseDir`n"

    $results = @()

    $results += Install-Tool -ToolName "AmcacheParser" `
                             -Url "https://download.ericzimmermanstools.com/net9/AmcacheParser.zip" `
                             -ZipName "AmcacheParser.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "ShimCacheParser" `
                             -Url "https://download.ericzimmermanstools.com/AppCompatCacheParser.zip" `
                             -ZipName "AppCompatCacheParser.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "HxD" `
                             -Url "https://mh-nexus.de/downloads/HxDSetup.zip" `
                             -ZipName "HxDSetup.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "Hayabusa" `
                             -Url "https://github.com/Yamato-Security/hayabusa/releases/download/v3.1.1/hayabusa-3.1.1-win-x64.zip" `
                             -ZipName "hayabusa-3.1.1-win-x64.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "Everything" `
                             -Url "https://www.voidtools.com/Everything-1.4.1.1026.x64-Setup.exe" `
                             -ExeName "Everything-1.4.1.1026.x64-Setup.exe" `
                             -IsExe

    $results += Install-Tool -ToolName "SystemInformerCanary" `
                             -Url "https://github.com/winsiderss/si-builds/releases/download/3.2.25078.1756/systeminformer-3.2.25078.1756-canary-setup.exe" `
                             -ExeName "systeminformer-3.2.25078.1756-canary-setup.exe" `
                             -IsExe

    $results += Install-Tool -ToolName "bstrings" `
                             -Url "https://download.ericzimmermanstools.com/net9/bstrings.zip" `
                             -ZipName "bstrings.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "DetectItEasy" `
                             -Url "https://github.com/horsicq/DIE-engine/releases/download/3.10/die_win64_portable_3.10_x64.zip" `
                             -ZipName "die_win64_portable_3.10_x64.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "JumpListExplorer" `
                             -Url "https://download.ericzimmermanstools.com/net6/JumpListExplorer.zip" `
                             -ZipName "JumpListExplorer.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "MFTECmd" `
                             -Url "https://download.ericzimmermanstools.com/MFTECmd.zip" `
                             -ZipName "MFTECmd.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "usnhelper" `
                             -Url "https://raw.githubusercontent.com/txchnology/test/main/usnjrnl_rewind.exe" `
                             -ExeName "usnhelper.exe" `
                             -IsExe

    $results += Install-Tool -ToolName "PECmd" `
                             -Url "https://download.ericzimmermanstools.com/net9/PECmd.zip" `
                             -ZipName "PECmd.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "RegistryExplorer" `
                             -Url "https://download.ericzimmermanstools.com/net9/RegistryExplorer.zip" `
                             -ZipName "RegistryExplorer.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "SrumECmd" `
                             -Url "https://download.ericzimmermanstools.com/net9/SrumECmd.zip" `
                             -ZipName "SrumECmd.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "TimelineExplorer" `
                             -Url "https://download.ericzimmermanstools.com/net9/TimelineExplorer.zip" `
                             -ZipName "TimelineExplorer.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "WxTCmd" `
                             -Url "https://download.ericzimmermanstools.com/net9/WxTCmd.zip" `
                             -ZipName "WxTCmd.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "RamDumpExplorer" `
                             -Url "https://github.com/bacanoicua/RAMDumpExplorer/releases/download/1.0/RAMDumpExplorer.exe" `
                             -ExeName "RAMDumpExplorer.exe" `
                             -IsExe

    $results += Install-Tool -ToolName "UsbDeview" `
                             -Url "https://www.nirsoft.net/utils/usbdeview-x64.zip" `
                             -ZipName "usbdeview-x64.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "AlternateStreamView" `
                             -Url "https://www.nirsoft.net/utils/alternatestreamview-x64.zip" `
                             -ZipName "alternatestreamview-x64.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "WinPrefetchView" `
                             -Url "https://www.nirsoft.net/utils/winprefetchview-x64.zip" `
                             -ZipName "winprefetchview-x64.zip" `
                             -Cleanup

    $results += Install-Tool -ToolName "PathsParser" `
                             -Url "https://github.com/spokwn/PathsParser/releases/download/v1.0.11/PathsParser.exe" `
                             -ExeName "PathsParser.exe" `
                             -IsExe

    $results += Install-Tool -ToolName "PrefetchParser" `
                             -Url "https://github.com/spokwn/prefetch-parser/releases/download/v1.5.4/PrefetchParser.exe" `
                             -ExeName "PrefetchParser.exe" `
                             -IsExe

    $results += Install-Tool -ToolName "ProcessParser" `
                             -Url "https://github.com/spokwn/process-parser/releases/download/v0.5.4/ProcessParser.exe" `
                             -ExeName "ProcessParser.exe" `
                             -IsExe

    $results += Install-Tool -ToolName "PcaSvcExecuted" `
                             -Url "https://github.com/spokwn/pcasvc-executed/releases/download/v0.8.6/PcaSvcExecuted.exe" `
                             -ExeName "PcaSvcExecuted.exe" `
                             -IsExe

    $results += Install-Tool -ToolName "BAMParser" `
                             -Url "https://github.com/spokwn/BAM-parser/releases/download/v1.2.7/BAMParser.exe" `
                             -ExeName "BAMParser.exe" `
                             -IsExe

    $results += Install-Tool -ToolName "JournalTrace" `
                             -Url "https://github.com/spokwn/JournalTrace/releases/download/1.2/JournalTrace.exe" `
                             -ExeName "JournalTrace.exe" `
                             -IsExe

    $results += Install-Tool -ToolName "ReplaceParser" `
                             -Url "https://github.com/spokwn/Replaceparser/releases/download/v1.1-recode/ReplaceParser.exe" `
                             -ExeName "ReplaceParser.exe" `
                             -IsExe

    $results += Install-Tool -ToolName "RECmd" `
                             -Url "https://download.ericzimmermanstools.com/net9/RECmd.zip" `
                             -ZipName "RECmd.zip" `
                             -NestedFolder `
                             -Cleanup

    $results += Install-Tool -ToolName "Velociraptor" `
                             -Url "https://github.com/Velocidex/velociraptor/releases/download/v0.73/velociraptor-v0.73.4-windows-amd64.exe" `
                             -ExeName "velociraptor.exe" `
                             -IsExe

    $results += Install-Tool -ToolName "WinLiveInfo" `
                             -Url "https://github.com/kacos2000/Win10LiveInfo/releases/download/v.1.0.23.0/WinLiveInfo.exe" `
                             -ExeName "WinLiveInfo.exe" `
                             -IsExe


     $results += Install-Tool -ToolName "MagnetProcessCapture" `
                             -Url "https://go.magnetforensics.com/e/52162/MagnetProcessCapture/kpt99v/1596068034/h/W_fAl_pThcDb-QN7ecFXAw8szOQU2dFtF_t_N383OvM" `
                             -ZipName "MagnetProcessCaptureV13.zip" `
                             -NestedFolder `
                             -Cleanup
                    
     $results += Install-Tool -ToolName "lastactivityview" `
                             -Url "https://www.nirsoft.net/utils/lastactivityview.zip" `
                             -ZipName "lastacitivityview.zip" `
                             -NestedFolder `
                             -Cleanup


     $results += Install-Tool -ToolName "OSForensics" `
                             -Url "https://osforensics.com/downloads/OSForensics.exe" `
                             -ExeName "OSForensics.exe" `
                             -IsExe


                             

 

    foreach ($r in $results) {
        if ($r -is [hashtable] -and $r.Success) {
            Add-Content -Path $LogFile -Value "$(Get-Date -Format 'u') - Installed: $($r.Name) -> $($r.Path)"
        } elseif ($r -is [hashtable]) {
            Add-Content -Path $LogFile -Value "$(Get-Date -Format 'u') - FAILED: $($r.Name) -> $($r.Error)"
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

    Write-Host "Are you sure you want to delete this folder?" -ForegroundColor Yellow
    Write-Host $path -ForegroundColor Cyan
    $confirm = Read-Host "Type Y to confirm"

    if ($confirm -eq "Y") {
        try {
            Remove-Item -LiteralPath $path -Recurse -Force
            Write-Host "`nFolder deleted successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "`nFailed to delete folder! $_" -ForegroundColor Red
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
