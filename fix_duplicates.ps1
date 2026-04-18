# PowerShell script to remove duplicate string entries from strings.xml
$filePath = "app\src\main\res\values\strings.xml"
$content = Get-Content $filePath

# Track seen string names
$seenNames = @{}
$filteredContent = @()
$inStringTag = $false

foreach ($line in $content) {
    if ($line -match '<string name="([^"]+)"') {
        $stringName = $matches[1]
        if (-not $seenNames.ContainsKey($stringName)) {
            $seenNames[$stringName] = $true
            $filteredContent += $line
        } else {
            Write-Host "Removing duplicate: $stringName"
        }
    } else {
        $filteredContent += $line
    }
}

# Write the filtered content back to the file
$filteredContent | Set-Content $filePath -Encoding UTF8
Write-Host "Duplicates removed successfully!"