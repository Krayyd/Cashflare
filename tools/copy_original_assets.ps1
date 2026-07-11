$src = 'C:\Users\Baks\AppData\Local\Temp\bablomet_decompiled\resources\assets'
$dst = 'C:\Users\Baks\Projects\Cashflare\Cashflare\Resources'
New-Item -ItemType Directory -Force -Path "$dst\Ruble","$dst\Atlas","$dst\Sounds","$dst\Russia","$dst\Localizable" | Out-Null

Copy-Item "$src\2x\atlas0.png" "$dst\Atlas\atlas0.png" -Force
Copy-Item "$src\2x\atlas0.plist" "$dst\Atlas\atlas0.plist" -Force
Copy-Item "$src\Ruble\*" "$dst\Ruble\" -Force
Copy-Item "$src\Russia\shop.plist" "$dst\Russia\shop.plist" -Force
Copy-Item "$src\regions.plist" "$dst\regions.plist" -Force
Copy-Item "$src\moneyEmitter.plist" "$dst\moneyEmitter.plist" -Force
Copy-Item "$src\sounds\money.mp3" "$dst\Sounds\money.mp3" -Force -ErrorAction SilentlyContinue
Copy-Item "$src\sounds\click.mp3" "$dst\Sounds\click.mp3" -Force -ErrorAction SilentlyContinue
Copy-Item "$src\sounds\purchase.mp3" "$dst\Sounds\purchase.mp3" -Force -ErrorAction SilentlyContinue
Copy-Item "$src\sounds\slide.mp3" "$dst\Sounds\slide.mp3" -Force -ErrorAction SilentlyContinue
if (Test-Path "$src\ru\Localizable.json") { Copy-Item "$src\ru\Localizable.json" "$dst\Localizable\ru.json" -Force }
if (Test-Path "$src\en_US\Localizable.json") { Copy-Item "$src\en_US\Localizable.json" "$dst\Localizable\en.json" -Force }

# Dollar for multi-currency later
New-Item -ItemType Directory -Force -Path "$dst\Dollar" | Out-Null
Copy-Item "$src\Dollar\*" "$dst\Dollar\" -Force -ErrorAction SilentlyContinue

Write-Host 'Copied:'
Get-ChildItem $dst -Recurse -File | Select-Object FullName, Length | Format-Table -AutoSize
