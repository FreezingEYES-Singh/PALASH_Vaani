# Handoff: test the Windows launcher on real hardware

For the Claude session on the user's Windows PC. The cloud session that wrote
the launcher can't message you back, so its side of the conversation is this
file and its pushes to the branch below. Send results to it as a message.

## Repo

- URL: https://github.com/FreezingEYES-Singh/PALASH_Vaani
- Branch: `claude/compassionate-franklin-9w8iwk` (currently also the default
  branch, so a plain clone checks it out)

## Flutter

- Version: **3.47.2 stable** (Dart 3.13.2). Any 3.47.x works; the project
  needs Dart >= 3.13.2.
- No manual install needed. If `flutter` isn't on PATH, the launcher offers to
  install 3.47.2 and checks the download's SHA-256 before unpacking.
- Location: `C:\src\flutter` only when C: has at least 10 GB free, otherwise
  `<drive>\src\flutter` on the fixed drive with the most free space. With
  about 5 GB free on C:, this PC should get `D:\src\flutter`. Force it with
  `-FlutterDir D:\src\flutter`.
- When Flutter isn't on the system drive, the launcher also sets the user
  variable `PUB_CACHE` to `<drive>\src\pub-cache` (unless it's already set).
- The SDK path can't contain spaces or `!` (Flutter's own .bat scripts break),
  and the launcher refuses such paths. The project path with `!!` should be
  fine for web builds; please confirm.

## Start it

In PowerShell:

```powershell
git clone https://github.com/FreezingEYES-Singh/PALASH_Vaani.git "D:\!!Pendrive\Coding\SIH\PALASH"
cd "D:\!!Pendrive\Coding\SIH\PALASH"
.\run-windows.bat -FlutterDir D:\src\flutter
```

`run-windows.bat` runs `tools\run-windows.ps1` with Windows PowerShell and
`-ExecutionPolicy Bypass`. Options: `-Browser edge|chrome|brave` (default
edge), `-IntervalSeconds <n>` (default 30). Keys in its window: `R` restart the
app, `r` reload, `u` check GitHub now, `q` quit.

## Already tested (Linux, PowerShell 7.6, headless Chromium)

- Against a local stand-in for GitHub: a README-only update left the app
  running; a `lib/` change hot-restarted it in about 0.6 s and the new text
  rendered; a `pubspec.yaml` change quit the app, ran `flutter pub get` and
  relaunched it.
- Keys `R` and `q` through a pseudo-terminal; no processes left after `q`.
- The installer with the real Windows zip: URL, checksum, unpacking, PATH.
- Unit tests: choice of install drive, path validation, low-space refusal,
  the "launcher updated" notice.

Not tested: anything that needs Windows itself (cmd.exe, launching Edge or
Chrome, Windows PowerShell 5.1, taskkill, writing PATH and PUB_CACHE to the
user environment). The last installer changes (zip saved next to the install
instead of %TEMP%, PUB_CACHE) have not been run with the real download.

## Please verify on the PC

1. **Install.** Accept the prompt. Flutter should land in `D:\src\flutter`,
   `flutter --version` should say 3.47.2, and C: free space should barely
   change. In a new terminal, `flutter` should be on PATH and `PUB_CACHE`
   should be `D:\src\pub-cache`.
2. **Launch.** Edge opens the app and the dashboard shows Hindi and Ol Chiki
   text correctly. Also try `-Browser chrome`.
3. **Sound.** A speaker button speaks in Edge. If it's silent, report the
   result of `speechSynthesis.getVoices().filter(v => v.lang.startsWith('hi'))`
   from the DevTools console.
4. **Update without app changes.** About 2 minutes after launch, run
   `git reset --hard HEAD~1` in another terminal. Within 30 s the launcher
   should download the update, say the app keeps running, and say the
   launcher itself changed.
5. **Update with app changes.** Message the cloud session "ready for update
   test". It will push a one-line visible change to `lib/` (the dashboard
   heading gains " - auto-update test") and revert it after you confirm. The
   app should show each change within about 30 s with no input from you.
6. **Keys.** `R` restarts the app; `q` quits and closes the browser. Closing
   the browser window instead should end the launcher with "The app was
   closed."
7. **Cleanup.** After quitting, `tasklist | findstr /i "dart flutter"` should
   show nothing.
8. **Report** `$PSVersionTable.PSVersion`, the launcher window text for
   anything that failed, and screenshots of anything that looks wrong.
