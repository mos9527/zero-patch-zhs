if ($args -notcontains '--no-update') {
    Write-Host "Updating dependencies"
    
    Remove-Item -Path ".bin" -Recurse -ErrorAction Ignore | Out-Null
    New-Item -ErrorAction Ignore -ItemType Directory -Path ".bin" | Out-Null
    # sc3tools
    Invoke-WebRequest -Uri "https://github.com/mos9527/sc3tools/releases/download/0.0.2/Release.zip" -OutFile .\.bin\sc3tools.zip
    Expand-Archive -Path .\.bin\sc3tools.zip -DestinationPath .\.bin\sc3tools    
    # mpk
    Invoke-WebRequest -Uri "https://github.com/mos9527/sg0-tools/releases/download/latest/mpk.exe" -OutFile .\.bin\mpk.exe
    # LanguageBarrier
    Invoke-WebRequest -Uri "https://github.com/mos9527/LanguageBarrier/releases/download/latest/dinput8.dll" -OutFile .\.bin\dinput8.dll
    Invoke-WebRequest -Uri "https://github.com/mos9527/LanguageBarrier/releases/download/latest/VSFilter.dll" -OutFile .\.bin\VSFilter.dll
}

Remove-Item -Path ".temp" -Recurse -ErrorAction Ignore | Out-Null
New-Item -ErrorAction Ignore -ItemType Directory -Path ".temp" | Out-Null
New-Item -ErrorAction Ignore -ItemType Directory -Path ".temp\script\" | Out-Null

Write-Host "Preparing scripts"
Copy-Item -Path ".\scripts\script_scx\*" -Destination ".\.temp\script\" -Force
.\.bin\sc3tools\sc3tools.exe replace-text .\.temp\script\*.scx .\scripts\script\*.txt sg0zhs

Write-Host "Preparing c0data"
Remove-Item -Path ".temp\c0data" -Recurse -ErrorAction Ignore | Out-Null
New-Item -ErrorAction Ignore -ItemType Directory -Path ".temp\c0data" | Out-Null
# feature : Custom font
Copy-Item -Path ".\textures\0x0_FONT_A.dds" -Destination ".\.temp\c0data\" -Container:$false -recurse -Force
# feature : Controller prompt customization
# XXX: There's only one for now
Write-Host "- Button Prompt : PlayStation (Dualshock/Dualsense) button prompts"
Copy-Item -Path ".\textures\ps\*.dds" -Destination ".\.temp\c0data\" -Container:$false -Force

Write-Host "Packing data"
Set-Location .\.temp
Write-Host "Packing cnscript.mpk"
..\.bin\mpk.exe -o .\script\ -r cnscript.mpk

Write-Host "Packing c0data.mpk"
..\.bin\mpk.exe -o .\c0data\ -r c0data.mpk
Set-Location .\..\

Write-Host "Preparing distribution"
Remove-Item -Path "dist" -Recurse -ErrorAction Ignore | Out-Null
New-Item -ErrorAction Ignore -ItemType Directory -Path "dist\GATE 0" | Out-Null
New-Item -ErrorAction Ignore -ItemType Directory -Path "dist\LanguageBarrier" | Out-Null

Copy-Item -Path ".\.temp\*.mpk" -Destination ".\dist\LanguageBarrier\" -Container:$false -Force
Copy-Item -Path ".\textures\font-outline*" -Destination ".\dist\LanguageBarrier\" -Container:$false -Force
Copy-Item -Path ".\config\*" -Destination ".\dist\LanguageBarrier\" -Container:$false -Force

Copy-Item -Path ".\.bin\dinput8.dll" -Destination ".\dist\GATE 0\" -Container:$false -Force
Copy-Item -Path ".\.bin\VSFilter.dll" -Destination ".\dist\GATE 0\" -Container:$false -Force

Write-Host "Packing distribution"
Remove-Item -Path "Release.zip" -ErrorAction Ignore | Out-Null
Compress-Archive -Path .\dist\* -Destination Release.zip

Write-Host "All done. Going home."
