# Initialize repository settings for local development
# This script prevents git from tracking local changes to CSV data files

Write-Host "Setting up git skip-worktree for data CSV files..." -ForegroundColor Green

# Mark all CSV files in data/ to skip worktree tracking
# This keeps the files in the repository but prevents git from tracking local changes
$csvFiles = Get-ChildItem -Path "data\*.csv" -File

foreach ($file in $csvFiles) {
    $relativePath = $file.FullName.Replace("$PWD\", "").Replace("\", "/")
    git update-index --skip-worktree $relativePath
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Configured: $relativePath" -ForegroundColor Gray
    } else {
        Write-Host "  Failed: $relativePath" -ForegroundColor Red
    }
}

Write-Host "`nSuccessfully configured git to skip tracking changes to CSV files" -ForegroundColor Green

Write-Host "`nTo undo this setting for a specific file, run:" -ForegroundColor Yellow
Write-Host "  git update-index --no-skip-worktree data/filename.csv" -ForegroundColor Gray
