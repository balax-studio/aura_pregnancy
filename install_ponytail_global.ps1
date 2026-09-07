# Ponytail Global Kurulum Scripti (Antigravity IDE / Gemini IDE)
$ErrorActionPreference = "Stop"

$globalConfigDir = "$env:USERPROFILE\.gemini\config"
$globalRulesDir = "$globalConfigDir\rules"
$globalSkillsDir = "$globalConfigDir\skills"

Write-Host "Ponytail Global Kurulumu Baslatiliyor..." -ForegroundColor Cyan

# Klasorleri olustur
if (-not (Test-Path $globalRulesDir)) {
    New-Item -ItemType Directory -Path $globalRulesDir -Force | Out-Null
}
if (-not (Test-Path $globalSkillsDir)) {
    New-Item -ItemType Directory -Path $globalSkillsDir -Force | Out-Null
}

$sourceRules = "$PSScriptRoot\.agents\rules\ponytail.md"
$sourceSkills = "$PSScriptRoot\.agents\skills"

# 1. Kurali kopyala
if (Test-Path $sourceRules) {
    Copy-Item -Path $sourceRules -Destination "$globalRulesDir\ponytail.md" -Force
    Write-Host "[OK] Global Kural Eklendi: $globalRulesDir\ponytail.md" -ForegroundColor Green
}

# 2. Becerileri (skills) kopyala
$ponytailSkills = @(
    "ponytail",
    "ponytail-audit",
    "ponytail-debt",
    "ponytail-gain",
    "ponytail-help",
    "ponytail-review"
)

foreach ($skill in $ponytailSkills) {
    $src = "$sourceSkills\$skill"
    $dst = "$globalSkillsDir\$skill"
    if (Test-Path $src) {
        if (-not (Test-Path $dst)) {
            New-Item -ItemType Directory -Path $dst -Force | Out-Null
        }
        Copy-Item -Path "$src\*" -Destination $dst -Recurse -Force
        Write-Host "[OK] Global Beceri Eklendi: $dst" -ForegroundColor Green
    }
}

Write-Host "`nPonytail basariyla GLOBAL olarak kuruldu! Artik tum projelerinizde varsayilan olarak aktif olacaktir." -ForegroundColor Cyan
