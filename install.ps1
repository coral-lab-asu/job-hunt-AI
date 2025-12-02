# JobMatch AI - Demo Installation Script
# For Windows PowerShell

$ErrorActionPreference = "Stop"

Clear-Host

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "      JobMatch AI - Demo Installation" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
Write-Host "Checking prerequisites..." -ForegroundColor Blue

try {
    docker --version | Out-Null
} catch {
    Write-Host "❌ Docker is not installed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Docker Desktop from:"
    Write-Host "https://docs.docker.com/desktop/install/windows-install/" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Check if Docker is running
try {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not running"
    }
} catch {
    Write-Host "❌ Docker is not running" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Check docker compose
try {
    docker compose version 2>&1 | Out-Null
    $DockerCompose = "docker compose"
} catch {
    try {
        docker-compose --version 2>&1 | Out-Null
        $DockerCompose = "docker-compose"
    } catch {
        Write-Host "❌ Docker Compose is not installed" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please install Docker Compose:" -ForegroundColor Yellow
        Write-Host "https://docs.docker.com/compose/install/"
        Write-Host ""
        exit 1
    }
}

Write-Host "✅ Docker is installed and running" -ForegroundColor Green
Write-Host ""

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "Creating .env configuration file..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✅ .env file created" -ForegroundColor Green
    Write-Host ""
    Write-Host "ℹ️  Optional: Edit .env to add ANTHROPIC_API_KEY for AI features" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "✅ Configuration ready" -ForegroundColor Green
Write-Host ""

# Create directories
Write-Host "Creating directories..." -ForegroundColor Blue
New-Item -ItemType Directory -Force -Path "uploads" | Out-Null
Write-Host "✅ Directories created" -ForegroundColor Green
Write-Host ""

# Pull images
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "      Pulling Docker Images" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📥 Pulling pre-built images from Docker Hub..." -ForegroundColor Blue
Write-Host "This may take a few minutes depending on your internet speed."
Write-Host ""

& $DockerCompose pull

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to pull Docker images" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please verify:"
    Write-Host "  1. The images exist on Docker Hub (mvyas7/job-hunt-ai-backend and mvyas7/job-hunt-ai-frontend)"
    Write-Host "  2. Your internet connection is working"
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "✅ Images pulled successfully" -ForegroundColor Green
Write-Host ""

# Start services
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "      Starting Services" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Starting all services..." -ForegroundColor Blue
Write-Host ""

& $DockerCompose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to start services" -ForegroundColor Red
    Write-Host ""
    Write-Host "Run 'docker compose logs' to see error details"
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "✅ Services started successfully" -ForegroundColor Green
Write-Host ""

# Wait for services
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "      Waiting for Services to Initialize" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏳ This may take 2-3 minutes..." -ForegroundColor Blue
Write-Host ""

Start-Sleep -Seconds 30

# Check services
function Test-ServiceHealth {
    param($Name, $Url)

    Write-Host "Checking $Name... " -NoNewline

    $maxAttempts = 60
    $attempt = 0

    while ($attempt -lt $maxAttempts) {
        try {
            $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Host "✅ Ready" -ForegroundColor Green
                return $true
            }
        } catch {
            # Continue trying
        }

        $attempt++
        Start-Sleep -Seconds 2
        Write-Host "." -NoNewline
    }

    Write-Host ""
    Write-Host "⚠️  Still starting (may take a bit longer)" -ForegroundColor Yellow
    return $false
}

Test-ServiceHealth "Elasticsearch" "http://localhost:9200/_cluster/health"
Test-ServiceHealth "Neo4j" "http://localhost:7474"
Test-ServiceHealth "Backend API" "http://localhost:8000/health"

Write-Host ""

# Installation complete
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "      🎉 Installation Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your JobMatch AI demo is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "Access your application:" -ForegroundColor White
Write-Host "  🌐 Frontend:         " -NoNewline
Write-Host "http://localhost:3001" -ForegroundColor Blue
Write-Host "  🔧 Backend API:      " -NoNewline
Write-Host "http://localhost:8000" -ForegroundColor Blue
Write-Host "  📚 API Docs:         " -NoNewline
Write-Host "http://localhost:8000/docs" -ForegroundColor Blue
Write-Host "  🔍 Elasticsearch:    " -NoNewline
Write-Host "http://localhost:9200" -ForegroundColor Blue
Write-Host "  🕸️  Neo4j Browser:    " -NoNewline
Write-Host "http://localhost:7474" -ForegroundColor Blue
Write-Host ""
Write-Host "Neo4j Login:" -ForegroundColor White
Write-Host "  Username: neo4j"
Write-Host "  Password: password"
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "      Quick Commands" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "View logs:       $DockerCompose logs -f"
Write-Host "Stop services:   $DockerCompose down"
Write-Host "Restart:         $DockerCompose restart"
Write-Host "Remove all data: $DockerCompose down -v"
Write-Host ""
Write-Host "Tip: Check out the QUICK_START.md guide for usage examples" -ForegroundColor Yellow
Write-Host ""
