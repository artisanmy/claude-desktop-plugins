<#
  republish-release.ps1 — cleanly (re)publish a plugin release so Claude Desktop
  detects the new version. Run from the repo root in PowerShell, where you have
  GitHub push access.

      powershell -ExecutionPolicy Bypass -File scripts\republish-release.ps1 -Version 0.5.0
      powershell -ExecutionPolicy Bypass -File scripts\republish-release.ps1 -PluginId artisan-es-reader-plugin -Version 0.5.0
#>

param(
  [string]$PluginId                           = "artisan-es-reader-plugin",
  [Parameter(Mandatory = $true)][string]$Version
)

$ErrorActionPreference = "Stop"
$Tag      = "$PluginId/v$Version"
$Manifest = "plugins/$PluginId/.claude-plugin/plugin.json"

Write-Host ">> Plugin: $PluginId   Version: $Version   Tag: $Tag"

# 0. Clear any stale git locks left by a crashed/interrupted git process.
foreach ($lock in @(".git/index.lock", ".git/packed-refs.lock", ".git/refs/tags/$Tag.lock")) {
  if (Test-Path $lock) { Remove-Item $lock -Force -ErrorAction SilentlyContinue }
}

# 1. Sanity check: the manifest version must equal the version we are tagging.
if (-not (Test-Path $Manifest)) { throw "ERROR: $Manifest not found." }
$ManVer = (Get-Content $Manifest -Raw | ConvertFrom-Json).version
if ($ManVer -ne $Version) {
  throw "ERROR: $Manifest says version $ManVer but you are publishing $Version. Bump the manifest first, then re-run."
}
Write-Host ">> Manifest version OK ($ManVer)."

# 2. Commit the workflow guard (and anything else staged). Skips if nothing to commit.
git add .github/workflows/release.yml
git commit -m "ci: fail release if tag version mismatches manifests"
if ($LASTEXITCODE -ne 0) { Write-Host ">> Nothing new to commit (continuing)." }

# 3. Push the branch so the remote has the correct content.
git push origin HEAD
if ($LASTEXITCODE -ne 0) { throw "git push origin HEAD failed." }

# 4. Recreate the tag at the current commit and re-fire the release workflow.
Write-Host ">> Removing old tag (local + remote) if present..."
try { git tag -d $Tag 2>$null } catch {}
try { git push origin ":refs/tags/$Tag" 2>$null } catch {}

Write-Host ">> Creating and pushing fresh tag..."
git tag $Tag
git push origin $Tag
if ($LASTEXITCODE -ne 0) { throw "Pushing tag $Tag failed." }

# 5. If the GitHub CLI is available, clear any stale release so the asset rebuilds clean.
if (Get-Command gh -ErrorAction SilentlyContinue) {
  gh release delete $Tag --yes --cleanup-tag 2>$null
  git push origin $Tag 2>$null   # re-push in case --cleanup-tag removed it
}

Write-Host ""
Write-Host ">> Done. GitHub Actions is now rebuilding & uploading $PluginId.plugin."
Write-Host ">> Then in Claude Desktop run:  /plugin marketplace update artisan-plugins"
