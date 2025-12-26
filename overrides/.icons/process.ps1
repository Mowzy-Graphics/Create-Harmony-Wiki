# --- Category name ---
$category = "backpacks"

# --- Create output folder ---
$outputFolder = "gameitem/$category"
if (-not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null
}

Add-Type -AssemblyName System.Drawing

# --- Set upscale factor ---
$scale = 8   # 32x8 = 256 pixels

# --- Get all PNG files ---
$inputFolder = "to-process/$category"
$pngFiles = Get-ChildItem $inputFolder -Filter *.png -File

$total = $pngFiles.Count
$count = 0

foreach ($file in $pngFiles) {
    $count++

    # Remove everything before the "__" and keep the rest
    $fname = $file.BaseName -replace ".*?__", ""

    # Build output path
    $outFile = Join-Path $outputFolder ($fname + ".svg")

    try {
        # Read PNG as bytes and convert to base64
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        $base64 = [System.Convert]::ToBase64String($bytes)

        # Get original image dimensions
        $image = [System.Drawing.Image]::FromFile($file.FullName)
        $origWidth = $image.Width
        $origHeight = $image.Height
        $image.Dispose()

        # Calculate scaled dimensions
        $width = $origWidth * $scale
        $height = $origHeight * $scale

        # Create SVG content with pixelated scaling
        $svgContent = @"
<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height">
  <image href="data:image/png;base64,$base64" width="$width" height="$height" style="image-rendering: pixelated;"/>
</svg>
"@

        # Write to SVG file
        $svgContent | Out-File -FilePath $outFile -Encoding UTF8

        Write-Host "[$count/$total] Upscaled $($file.Name) -> $($fname).svg"
    } catch {
        Write-Warning "Failed: $($file.Name) - $_"
    }
}


Write-Host "All files wrapped in SVG with pixelated upscale successfully!"
