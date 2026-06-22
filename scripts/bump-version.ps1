<#
  bump-version.ps1 — set a plugin's version across all manifest files at once,
  so they stay consistent and pass the release CI guard.

  Updates, for the given plugin:
    1. plugins/<id>/.claude-plugin/plugin.json   (CI source of truth)
    2. .claude-plugin/marketplace.json           (CI checks this too)
    3. plugins/<id>/plugin.json                  (custom root manifest)
    4. registry.json                             (entry version, releaseUrl, updated date)

  Usage (from repo root):
    powershell -ExecutionPolicy Bypass -File scripts\bump-version.ps1 -Version 0.3.0

  Then publish:
    powershell -ExecutionPolicy Bypass -File scripts\republish-release.ps1 -Version 0.3.0
#>

param(
  [Parameter(Mandatory = $true)][string]$Version,
  [string]$PluginId = "artisan-es-reader-plugin"
)

$ErrorActionPreference = "Stop"

if ($Version -notmatch '^\d+\.\d+\.\d+$') {
  throw "ERROR: Version '$Version' is not semver (expected e.g. 0.3.0)."
}

$idRegex = [regex]::Escape($PluginId)
$today   = Get-Date -Format 'yyyy-MM-dd'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Edit-File {
  param([string]$Path, [hashtable[]]$Edits)
  if (-not (Test-Path $Path)) { throw "ERROR: $Path not found." }
  $text = [System.IO.File]::ReadAllText($Path)
  foreach ($e in $Edits) {
    $new = [regex]::Replace($text, $e.Pattern, $e.Replacement)
    if ($new -eq $text -and $e.Required) {
      throw "ERROR: pattern not found in $Path (label: $($e.Label))."
    }
    $text = $new
  }
  [System.IO.File]::WriteAllText((Resolve-Path $Path), $text, $utf8NoBom)
  Write-Host ("   updated {0}" -f $Path)
}

$verReplace = '${1}' + $Version + '${2}'

Write-Host ">> Bumping $PluginId to $Version ..."

# 1. .claude-plugin/plugin.json — single version field
Edit-File "plugins/$PluginId/.claude-plugin/plugin.json" @(
  @{ Label='version'; Required=$true; Pattern='("version"\s*:\s*")[^"]*(")'; Replacement=$verReplace }
)

# 2. .claude-plugin/marketplace.json — single plugin entry version
Edit-File ".claude-plugin/marketplace.json" @(
  @{ Label='version'; Required=$true; Pattern='("version"\s*:\s*")[^"]*(")'; Replacement=$verReplace }
)

# 3. root plugins/<id>/plugin.json — single version field
Edit-File "plugins/$PluginId/plugin.json" @(
  @{ Label='version'; Required=$true; Pattern='("version"\s*:\s*")[^"]*(")'; Replacement=$verReplace }
)

# 4. registry.json — entry version (anchored after id), releaseUrl segment, updated date.
#    Do NOT touch the top-level registry "version" (format version).
Edit-File "registry.json" @(
  @{ Label='entry version'; Required=$true;
     Pattern=('("id"\s*:\s*"' + $idRegex + '"[\s\S]*?"version"\s*:\s*")[^"]*(")');
     Replacement=$verReplace }
  @{ Label='releaseUrl'; Required=$false;
     Pattern='("releaseUrl"\s*:\s*"[^"]*?/v)[^/"]+(/)';
     Replacement=$verReplace }
  @{ Label='updated'; Required=$false;
     Pattern='("updated"\s*:\s*")[^"]*(")';
     Replacement=('${1}' + $today + '${2}') }
)

Write-Host ""
Write-Host ">> All manifests set to $Version."

# 5. Commit the manifest changes.
git add "plugins/$PluginId/.claude-plugin/plugin.json" `
        ".claude-plugin/marketplace.json" `
        "plugins/$PluginId/plugin.json" `
        "registry.json"
git commit -m "v$Version"
if ($LASTEXITCODE -ne 0) { Write-Host ">> Nothing new to commit (continuing)." }

Write-Host ""
Write-Host ">> Done. Now publish: powershell -ExecutionPolicy Bypass -File scripts\republish-release.ps1 -Version $Version"
