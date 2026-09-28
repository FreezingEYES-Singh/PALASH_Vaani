<#
.SYNOPSIS
    Runs PALASH-Vaani on your PC and keeps it up to date with GitHub.

.DESCRIPTION
    Start it by double-clicking run-windows.bat in the project folder.

    1. Checks that Git and Flutter are installed. If Flutter is missing, it
       offers to download it into C:\src\flutter (or <drive>\src\flutter on
       the drive with the most free space, if C: is low) and add it to PATH.
    2. Downloads the latest changes from GitHub and starts the app in your
       browser (Microsoft Edge by default).
    3. Checks GitHub for new changes every 30 seconds. When it finds some, it
       downloads them and restarts the app, so the browser shows the new
       version without you doing anything.

    While it runs, you can press these keys in its window:
        R  restart the app          r  reload the app
        u  check GitHub now         q  quit

.PARAMETER Browser
    Browser to run the app in: edge (default), chrome or brave.
    Edge and Chrome include Hindi voices, so the speaker buttons work there.

.PARAMETER IntervalSeconds
    How often to check GitHub for new changes, in seconds. Default: 30.

.PARAMETER FlutterDir
    Where to install Flutter if it is missing, for example D:\src\flutter.
    The path must not contain spaces.

.PARAMETER FlutterArgs
    Extra arguments for "flutter run", for example "--web-port 8080".

.EXAMPLE
    run-windows.bat -Browser chrome

.EXAMPLE
    run-windows.bat -FlutterDir D:\src\flutter
#>
param(
    [ValidateSet('edge', 'chrome', 'brave')]
    [string]$Browser = 'edge',

    [ValidateRange(10, 3600)]
    [int]$IntervalSeconds = 30,

    [string]$FlutterDir = '',

    [string]$FlutterArgs = ''
)

$ErrorActionPreference = 'Stop'

$FlutterVersion = '3.47.2'
$FlutterZipSha256 = '37934f2128a55d77a38baba12fd611157ed23a47bf7d2b7d17e9e84da118409d'
$MinFlutterVersion = [version]'3.47.0'
# Installing needs room for the 1.9 GB download plus the unpacked SDK and packages.
$InstallNeedsGB = 6
# Below this much free space, prefer another drive for Flutter.
$SystemDriveComfortGB = 10
# "flutter run" must finish compiling and connect to the browser before it can
# restart the app, so updates wait until the app has been up this long.
$StartupGraceSeconds = 120

$OnWindows = ($env:OS -eq 'Windows_NT')
$ProjectDir = Split-Path -Parent $PSScriptRoot
$App = $null
$AppStartedAt = [datetime]::MinValue
$Device = $null
$Warned = @{}

function Write-Status([string]$Message, [string]$Color = 'Cyan') {
    Write-Host ('[{0}] {1}' -f (Get-Date -Format 'HH:mm:ss'), $Message) -ForegroundColor $Color
}

function Write-WarningOnce([string]$Key, [string]$Message) {
    if (-not $script:Warned.ContainsKey($Key)) {
        Write-Status $Message 'Yellow'
        $script:Warned[$Key] = $true
    }
}

# Runs a program and returns its exit code and output, without PowerShell
# treating the program's error output as a script error.
function Invoke-Native {
    $exe = $args[0]
    $rest = @($args | Select-Object -Skip 1)
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $lines = & $exe @rest 2>&1
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previous
    }
    $text = (@($lines) | ForEach-Object { "$_" }) -join "`n"
    return [pscustomobject]@{ Code = $code; Output = $text.Trim() }
}

function Add-UserPath([string]$Dir) {
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $parts = @()
    if ($userPath) { $parts = @($userPath -split ';' | Where-Object { $_ }) }
    if ($parts -notcontains $Dir) {
        [Environment]::SetEnvironmentVariable('Path', (@($parts + $Dir) -join ';'), 'User')
    }
    if (($env:Path -split ';') -notcontains $Dir) { $env:Path = "$Dir;$env:Path" }
}

# Suggests where to install Flutter: an existing <drive>\src\flutter if there
# is one, else C:\src\flutter, or the drive with the most free space when C:
# is low. (Flutter breaks when its path has spaces, which user folders often
# have, so it never goes under the user folder.)
function Get-DefaultFlutterDir {
    param($Drives = @([System.IO.DriveInfo]::GetDrives() | Where-Object { $_.DriveType -eq 'Fixed' -and $_.IsReady }))
    foreach ($drive in $Drives) {
        $dir = $drive.Name.TrimEnd('\') + '\src\flutter'
        if (Test-Path "$dir\bin\flutter.bat") { return $dir }
    }
    $system = $Drives | Where-Object { $_.Name.TrimEnd('\') -eq $env:SystemDrive } | Select-Object -First 1
    if ($system -and $system.AvailableFreeSpace -ge $SystemDriveComfortGB * 1GB) {
        return "$env:SystemDrive\src\flutter"
    }
    $roomiest = $Drives | Sort-Object AvailableFreeSpace -Descending | Select-Object -First 1
    if ($roomiest) { return $roomiest.Name.TrimEnd('\') + '\src\flutter' }
    return "$env:SystemDrive\src\flutter"
}

function Install-Flutter([string]$Root) {
    # The download unpacks into a folder named "flutter", and Flutter's own .bat
    # scripts break on paths with spaces or "!".
    if ($Root -match '[\s!]' -or (Split-Path -Leaf $Root) -ne 'flutter') {
        throw "Flutter can't be installed in '$Root'. Use a folder named flutter with no spaces or ! in its path, for example D:\src\flutter."
    }
    $parent = Split-Path -Parent $Root
    $bin = Join-Path $Root 'bin'
    if (-not (Test-Path (Join-Path $bin 'flutter.bat'))) {
        if (Test-Path $Root) {
            throw "The folder $Root already exists but has no Flutter in it. Rename or delete it, then run this again."
        }
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
        $drive = New-Object System.IO.DriveInfo ([System.IO.Path]::GetPathRoot((Resolve-Path $parent).Path))
        $freeGB = [math]::Round($drive.AvailableFreeSpace / 1GB, 1)
        if ($freeGB -lt $InstallNeedsGB) {
            throw "Installing Flutter needs about $InstallNeedsGB GB of free space, but $($drive.Name) has $freeGB GB. Free up space or choose another drive, for example: run-windows.bat -FlutterDir D:\src\flutter"
        }
        # Download next to the install rather than to the (often fuller) system drive.
        $zip = Join-Path $parent "flutter_windows_$FlutterVersion-stable.zip"
        $url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_$FlutterVersion-stable.zip"
        if (Test-Path $zip) { Remove-Item $zip -Force }

        Write-Status "Downloading Flutter $FlutterVersion (about 1.9 GB). This can take a while..."
        if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
            & curl.exe --location --fail --retry 3 --output $zip $url
            if ($LASTEXITCODE -ne 0) { throw 'Downloading Flutter failed. Check your internet connection and try again.' }
        } else {
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
        }

        Write-Status 'Checking the download...'
        if ((Get-FileHash -Algorithm SHA256 $zip).Hash -ne $FlutterZipSha256) {
            Remove-Item $zip -Force
            throw 'The Flutter download is damaged. Run this again to download it again.'
        }

        Write-Status "Unpacking Flutter into $Root (this takes a few minutes)..."
        if (Get-Command tar.exe -ErrorAction SilentlyContinue) {
            & tar.exe -xf $zip -C $parent
        } else {
            Expand-Archive -Path $zip -DestinationPath $parent
        }
        if (-not (Test-Path (Join-Path $bin 'flutter.bat'))) {
            throw "Unpacking Flutter failed. Delete the folder $Root if it exists, then run this again."
        }
        Remove-Item $zip -Force
    }
    Add-UserPath $bin
    # When Flutter is not on the system drive, keep downloaded packages next to it too.
    $onSystemDrive = [System.IO.Path]::GetPathRoot($Root) -eq [System.IO.Path]::GetPathRoot("$env:SystemDrive\")
    if (-not $onSystemDrive -and -not $env:PUB_CACHE) {
        $pubCache = Join-Path $parent 'pub-cache'
        [Environment]::SetEnvironmentVariable('PUB_CACHE', $pubCache, 'User')
        $env:PUB_CACHE = $pubCache
        Write-Status "Packages will be stored in $pubCache."
    }
    Write-Status "Flutter is installed in $Root and added to your PATH." 'Green'
}

function Get-FlutterVersion {
    $result = Invoke-Native flutter --version --machine
    if ($result.Code -ne 0 -or $result.Output.IndexOf('{') -lt 0) { return $null }
    try {
        $json = $result.Output.Substring($result.Output.IndexOf('{'))
        return [version](ConvertFrom-Json $json).frameworkVersion
    } catch {
        return $null
    }
}

# Maps the -Browser choice to a "flutter run -d" device.
function Get-FlutterDevice {
    if ($Browser -ne 'brave') { return $Browser }
    foreach ($base in @($env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:LOCALAPPDATA)) {
        if (-not $base) { continue }
        $exe = Join-Path $base 'BraveSoftware\Brave-Browser\Application\brave.exe'
        if (Test-Path $exe) {
            # Flutter runs Chromium-based browsers through its "chrome" device.
            $env:CHROME_EXECUTABLE = $exe
            return 'chrome'
        }
    }
    throw 'Brave was not found. Run with -Browser edge or -Browser chrome instead.'
}

function Start-App {
    Write-Status "Starting the app in $Browser. The first start takes a minute or two..."
    $runArgs = "run -d $script:Device $FlutterArgs".Trim()
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    if ($OnWindows) {
        $psi.FileName = $env:ComSpec
        $psi.Arguments = "/c flutter $runArgs"
    } else {
        $psi.FileName = (Get-Command flutter).Source
        $psi.Arguments = $runArgs
    }
    $psi.WorkingDirectory = $ProjectDir
    $psi.UseShellExecute = $false
    # Commands such as R (restart) are typed into "flutter run" through this pipe.
    $psi.RedirectStandardInput = $true
    $script:App = [System.Diagnostics.Process]::Start($psi)
    $script:App.StandardInput.AutoFlush = $true
    $script:AppStartedAt = Get-Date
}

function Send-AppKey([string]$Key) {
    if ($script:App -and -not $script:App.HasExited) {
        try { $script:App.StandardInput.WriteLine($Key) } catch { <# The app is already exiting. #> }
    }
}

function Stop-App {
    if (-not $script:App) { return }
    if (-not $script:App.HasExited) {
        Send-AppKey 'q'
        if (-not $script:App.WaitForExit(30000)) {
            if ($OnWindows) {
                & taskkill.exe /PID $script:App.Id /T /F | Out-Null
            } else {
                try { $script:App.Kill($true) } catch { $script:App.Kill() }
            }
            $null = $script:App.WaitForExit(10000)
        }
    }
    $script:App = $null
}

# Downloads new commits from GitHub, if any. Returns what the app needs:
# 'none' (nothing new), 'other' (new commits that don't touch the app),
# 'hot' (restart the running app) or 'full' (stop it and start again).
function Sync-FromGitHub {
    $fetch = Invoke-Native git fetch --quiet
    if ($fetch.Code -ne 0) {
        Write-WarningOnce 'fetch' "Could not reach GitHub. Will keep trying. ($($fetch.Output))"
        return 'none'
    }
    $script:Warned.Remove('fetch')

    $local = (Invoke-Native git rev-parse HEAD).Output
    $remote = (Invoke-Native git rev-parse '@{u}').Output
    if ($local -eq $remote) { return 'none' }

    if ((Invoke-Native git merge-base --is-ancestor HEAD '@{u}').Code -ne 0) {
        Write-WarningOnce 'diverged' 'This copy has its own commits, so updates from GitHub cannot be applied automatically.'
        return 'none'
    }
    if ((Invoke-Native git status --porcelain --untracked-files=no).Output) {
        Write-WarningOnce 'dirty' 'Some project files were changed on this PC, so updates are paused. To receive updates, undo the changes with: git checkout -- .'
        return 'none'
    }

    $files = @((Invoke-Native git diff --name-only HEAD '@{u}').Output -split "`n" | Where-Object { $_ })
    $commits = (Invoke-Native git log --oneline --no-decorate 'HEAD..@{u}').Output
    $merge = Invoke-Native git merge --ff-only --quiet '@{u}'
    if ($merge.Code -ne 0) {
        Write-WarningOnce 'merge' "Could not apply the update: $($merge.Output)"
        return 'none'
    }
    $script:Warned.Remove('dirty')
    $script:Warned.Remove('diverged')
    $script:Warned.Remove('merge')

    Write-Status 'Downloaded an update from GitHub:' 'Green'
    foreach ($line in ($commits -split "`n")) { Write-Host "           $line" -ForegroundColor Green }
    if (@($files -match '^(run-windows\.bat|tools/run-windows\.ps1)$').Count -gt 0) {
        Write-Status 'This update also changes this launcher. To use the new version, press q and start run-windows.bat again.' 'Yellow'
    }

    if (@($files -match '^(pubspec\.(yaml|lock)$|web/)').Count -gt 0) { return 'full' }
    if (@($files -match '^(lib|assets)/').Count -gt 0) { return 'hot' }
    return 'other'
}

try {
    # Lets Hindi text and emoji in Flutter's output display correctly; optional.
    try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { <# Keep the default encoding. #> }
    Write-Host ''
    Write-Host 'PALASH-Vaani: run on this PC and keep it updated from GitHub' -ForegroundColor Green
    Write-Host ''
    Set-Location $ProjectDir

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw 'Git is not installed. Install it from https://git-scm.com/download/win, then run this again.'
    }
    if ((Invoke-Native git rev-parse --is-inside-work-tree).Output -ne 'true') {
        throw 'This folder is not a Git copy of the project. Get one with: git clone https://github.com/FreezingEYES-Singh/PALASH_Vaani.git'
    }
    $upstream = Invoke-Native git rev-parse --abbrev-ref --symbolic-full-name '@{u}'
    if ($upstream.Code -ne 0) {
        throw 'This branch is not connected to a branch on GitHub, so updates cannot be downloaded.'
    }

    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        if (-not $OnWindows) { throw 'Flutter is not installed.' }
        if (-not $FlutterDir) { $FlutterDir = Get-DefaultFlutterDir }
        if (-not (Test-Path "$FlutterDir\bin\flutter.bat")) {
            $answer = Read-Host "Flutter is not installed. Download Flutter $FlutterVersion (1.9 GB) and install it in ${FlutterDir}? (Y/n)"
            if ($answer -and $answer -notmatch '^[Yy]') {
                throw 'Flutter is needed to run the app. To install it somewhere else, run: run-windows.bat -FlutterDir D:\src\flutter'
            }
        }
        Install-Flutter $FlutterDir
    }
    # Shows the version. On first use, Flutter also finishes setting itself up here.
    & flutter --version
    $version = Get-FlutterVersion
    if ($version -and $version -lt $MinFlutterVersion) {
        throw "This project needs Flutter $MinFlutterVersion or newer, but you have $version. Run 'flutter upgrade', then run this again."
    }
    $Device = Get-FlutterDevice

    Write-Status "Getting the latest version from GitHub ($($upstream.Output))..."
    $null = Sync-FromGitHub
    Write-Status 'Getting packages...'
    $pub = Invoke-Native flutter pub get
    if ($pub.Code -ne 0) {
        Write-Host $pub.Output
        throw 'flutter pub get failed.'
    }

    Start-App
    Write-Host ''
    Write-Host "Checking GitHub for updates every $IntervalSeconds seconds." -ForegroundColor Green
    Write-Host 'Keys: R restart app, r reload app, u check GitHub now, q quit.' -ForegroundColor Green
    Write-Host ''

    $canReadKeys = $true
    try { $null = [Console]::KeyAvailable } catch { $canReadKeys = $false }
    $nextCheck = (Get-Date).AddSeconds($IntervalSeconds)

    while ($true) {
        if ($App -and $App.HasExited) {
            $exitCode = $App.ExitCode
            $App = $null
            if ($exitCode -eq 0) {
                Write-Status 'The app was closed.' 'Yellow'
                break
            }
            Write-Status "The app stopped with an error (exit code $exitCode). It will start again with the next update from GitHub, or press R to try now." 'Yellow'
        }

        $key = $null
        if ($canReadKeys) {
            try {
                if ([Console]::KeyAvailable) {
                    $char = [Console]::ReadKey($true).KeyChar
                    if ([int]$char -ge 32) { $key = [string]$char }
                }
            } catch {
                $canReadKeys = $false
            }
        }
        if ($key) {
            if ($key -ceq 'q') {
                Write-Status 'Quitting...'
                break
            } elseif ($key -ceq 'u') {
                $nextCheck = Get-Date
            } elseif ($App) {
                Send-AppKey $key
            } elseif ($key -ceq 'R') {
                Start-App
            }
        }

        if ((Get-Date) -ge $nextCheck) {
            $nextCheck = (Get-Date).AddSeconds($IntervalSeconds)
            $appAge = ((Get-Date) - $AppStartedAt).TotalSeconds
            if ($App -and $appAge -lt $StartupGraceSeconds) {
                # Still starting up; check again once it has had time to connect.
                $nextCheck = $AppStartedAt.AddSeconds($StartupGraceSeconds)
            } else {
                $action = Sync-FromGitHub
                if ($action -eq 'full') {
                    Write-Status 'The update changes packages or web files, so the app will start again.'
                    Stop-App
                    $pub = Invoke-Native flutter pub get
                    if ($pub.Code -eq 0) {
                        Start-App
                    } else {
                        Write-Host $pub.Output
                        Write-Status 'flutter pub get failed. Will try again with the next update.' 'Yellow'
                    }
                } elseif ($action -eq 'hot') {
                    if ($App) {
                        Write-Status 'Restarting the app with the new code...'
                        Send-AppKey 'R'
                    } else {
                        Start-App
                    }
                } elseif ($action -eq 'other') {
                    Write-Status 'The update does not change the app, so it keeps running as is.'
                }
            }
        }
        Start-Sleep -Milliseconds 200
    }
} catch {
    Write-Host ''
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Stop-App
}
