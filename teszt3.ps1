# Log fájlok helyei
$startTime = Get-Date
$logFile = "C:\D wannabe\susu\mestint\mestintlogfile1125.txt"
$seedFile = "C:\D wannabe\susu\mestint\seeds.txt"  # Seed fájl
$iii=0

$directory = "C:\D wannabe\susu\mestint"  # A mappa, ahol a .data fájlok találhatók

# Ha még nem létezik a log fájl, létrehozzuk
if (-Not (Test-Path $logFile)) {
    New-Item -Path $logFile -ItemType File
}

# Ha még nem létezik a seed fájl, létrehozzuk (csak akkor ha nincs seed fájl)
if (-Not (Test-Path $seedFile)) {
    New-Item -Path $seedFile -ItemType File
}

# Ha létezik seed fájl, olvassuk be a seedeket
if (Test-Path $seedFile) {
    # Beolvassuk a seedeket a fájlból
    $seeds = Get-Content -Path $seedFile
    Write-Host "Beolvasva a seedek a $seedFile fájlbol."
} else {
    # Ha nincs seed fájl, véletlenszerű seedeket generálunk
    $seeds = @()
    for ($i = 1; $i -le 31; $i++) {
        # Véletlenszerű seed generálása 10 karakter hosszú számkombinációként
        $seed = -join ((48..57) | Get-Random -Count 10 | % { [char]$_ })
        $seeds += $seed
        Write-Host "Generált seed $seed."
    }

    # Elmentjük a generált seedeket a seed fájlba
    $seeds | Out-File -FilePath $seedFile
    Write-Host "A seedek elmentve a $seedFile fájlba."
}

# 100 seed futtatása
foreach ($seed in $seeds) {
    Write-Host $iii
	$iii++
    Write-Host "Running with seed $seed..."

    # A Java parancs kimenetének mentése
    $output = java -jar game_engine.jar 0 game.mario.MarioGame $seed 1000 game.mario.SamplePlayer

    # A kimenet sorainak feldolgozása
    $outputLines = $output -split "`n"

    # Ha van elég sor, kinyerjük a 2. sor 3. értékét
    if ($outputLines.Length -ge 2) {
        $secondLine = $outputLines[1]  # 2. sor (0-alapú index)
        $fields = $secondLine -split "\s+"  # Szóközökkel való felosztás
        if ($fields.Length -ge 3) {
            $thirdValue = $fields[2]  # 3. érték
            
            # Mentés a log fájlba, biztosítva, hogy új sorban írja
            Add-Content -Path $logFile -Value "$thirdValue"
            Write-Host "Logged: $seed $thirdValue"
        }
    }
	# Törlés a .data fájlok után minden futás után
    Get-ChildItem -Path $directory -Filter "*.data" -Recurse | Remove-Item -Force
    Write-Host "Toroltuk a .data fajlokat a $directory konyvtarbol"
}

# Befejező idő rögzítése
$endTime = Get-Date

# Futtatás ideje
$executionTime = $endTime - $startTime
Write-Host "Futas ideje: $($executionTime.TotalSeconds) masodperc"
Read-Host 'Nyomj Entert a kilepeshez...'
