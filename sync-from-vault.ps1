# 지식창고/로봇소프트웨어개발기사 노트를 이 저장소의 content/로 동기화 후 커밋+push

$Source = "D:\ObsidianVault\지식창고\로봇소프트웨어개발기사"
$Dest   = "$PSScriptRoot\content\로봇소프트웨어개발기사"
$ImgSource = "D:\ObsidianVault\images"
$ImgDest   = "$PSScriptRoot\content\attachments"

robocopy $Source $Dest /MIR /XD .space 자료 /XF *.json "조사 - *.md" 자료조사_재작업_체크리스트.md /NFL /NDL /NJH /NJS

# 폴더명과 같은 이름의 .md(폴더 노트)는 동기화하지 않음
@(Get-Item $Dest) + @(Get-ChildItem -Path $Dest -Recurse -Directory) | ForEach-Object {
    $folderNote = Join-Path $_.FullName ($_.Name + ".md")
    if (Test-Path $folderNote) {
        Remove-Item $folderNote -Force
    }
}

# 노트에서 참조하는 이미지(![[...]])만 추려서 attachments/로 복사
New-Item -ItemType Directory -Force -Path $ImgDest | Out-Null
$imgExt = 'png|jpg|jpeg|gif|svg|webp'
$refs = Get-ChildItem -Path $Dest -Recurse -Filter *.md |
    Select-String -Pattern "!\[\[([^\|\]]+\.($imgExt))(\|[^\]]*)?\]\]" -AllMatches |
    ForEach-Object { $_.Matches } |
    ForEach-Object { $_.Groups[1].Value } |
    Sort-Object -Unique

foreach ($name in $refs) {
    $src = Join-Path $ImgSource $name
    if (Test-Path $src) {
        Copy-Item $src -Destination $ImgDest -Force
    } else {
        Write-Warning "이미지 없음: $name"
    }
}

Set-Location $PSScriptRoot
git add content
if (git status --porcelain -- content) {
    git commit -m "Sync notes from vault"
    git push origin main
    Write-Host "Synced and pushed."
} else {
    Write-Host "No changes."
}
