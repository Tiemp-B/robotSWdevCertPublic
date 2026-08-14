# 지식창고/로봇소프트웨어개발기사, 지식창고/Box(용어) 노트를 이 저장소의 content/로 동기화 후 커밋+push

$Pairs = @(
    @{ Source = "D:\ObsidianVault\지식창고\로봇소프트웨어개발기사"; Dest = "$PSScriptRoot\content\로봇소프트웨어개발기사" },
    @{ Source = "D:\ObsidianVault\지식창고\Box"; Dest = "$PSScriptRoot\content\Box" }
)
$ImgSource = "D:\ObsidianVault\images"
$ImgDest   = "$PSScriptRoot\content\attachments"

foreach ($pair in $Pairs) {
    robocopy $pair.Source $pair.Dest /MIR /XD .space 자료 /XF *.json "조사 - *.md" 자료조사_재작업_체크리스트.md /NFL /NDL /NJH /NJS

    # 폴더명과 같은 이름의 .md(폴더 노트)는 동기화하지 않음
    @(Get-Item $pair.Dest) + @(Get-ChildItem -Path $pair.Dest -Recurse -Directory) | ForEach-Object {
        $folderNote = Join-Path $_.FullName ($_.Name + ".md")
        if (Test-Path $folderNote) {
            Remove-Item $folderNote -Force
        }
    }
}

# 노트에서 참조하는 이미지(![[...]])만 추려서 attachments/로 복사
New-Item -ItemType Directory -Force -Path $ImgDest | Out-Null
$imgExt = 'png|jpg|jpeg|gif|svg|webp'
$refs = Get-ChildItem -Path "$PSScriptRoot\content" -Recurse -Filter *.md |
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
