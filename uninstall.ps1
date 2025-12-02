# JobMatch AI - Uninstall Script
# For Windows PowerShell

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "      JobMatch AI - Uninstall" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Detect docker compose
try {
    docker compose version 2>&1 | Out-Null
    $DockerCompose = "docker compose"
} catch {
    $DockerCompose = "docker-compose"
}

Write-Host "This will:" -ForegroundColor White
Write-Host "  1. Stop all running containers"
Write-Host "  2. Remove containers"
Write-Host "  3. Remove Docker networks"
Write-Host ""
Write-Host "Do you want to also remove all data (volumes)?" -ForegroundColor Yellow
Write-Host "  - Choose 'y' to delete all data (cannot be undone)"
Write-Host "  - Choose 'n' to keep data for next time"
Write-Host ""

$response = Read-Host "Remove data volumes? (y/N)"

if ($response -eq 'y' -or $response -eq 'Y') {
    Write-Host "Stopping and removing everything (including data)..." -ForegroundColor Yellow
    & $DockerCompose down -v
    Write-Host ""
    Write-Host "All services and data removed." -ForegroundColor Green
} else {
    Write-Host "Stopping and removing containers (keeping data)..." -ForegroundColor Yellow
    & $DockerCompose down
    Write-Host ""
    Write-Host "Services stopped. Data volumes preserved." -ForegroundColor Green
}

Write-Host ""
Write-Host "Uninstall complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "To reinstall, run: .\install.ps1"
Write-Host ""
