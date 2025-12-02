#!/bin/bash
# JobMatch AI - Demo Installation Script
# For Linux and macOS

set -e

clear

echo "================================================"
echo "      JobMatch AI - Demo Installation"
echo "================================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Docker is installed
echo -e "${BLUE}Checking prerequisites...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo ""
    echo "Please install Docker Desktop from:"
    echo "  - macOS: https://docs.docker.com/desktop/install/mac-install/"
    echo "  - Linux: https://docs.docker.com/desktop/install/linux-install/"
    echo ""
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    echo ""
    echo "Please start Docker Desktop and try again."
    echo ""
    exit 1
fi

# Check if docker-compose is available
if ! docker compose version &> /dev/null && ! docker-compose --version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    echo ""
    echo "Please install Docker Compose:"
    echo "https://docs.docker.com/compose/install/"
    echo ""
    exit 1
fi

# Detect docker compose command
DOCKER_COMPOSE="docker compose"
if ! docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
fi

echo -e "${GREEN}✅ Docker is installed and running${NC}"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env configuration file...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ .env file created${NC}"
    echo ""
    echo -e "${YELLOW}ℹ️  Optional: Edit .env to add ANTHROPIC_API_KEY for AI features${NC}"
    echo ""
fi

echo -e "${GREEN}✅ Configuration ready${NC}"
echo ""

# Create necessary directories
echo -e "${BLUE}Creating directories...${NC}"
mkdir -p uploads
echo -e "${GREEN}✅ Directories created${NC}"
echo ""

# Pull images
echo "================================================"
echo "      Pulling Docker Images"
echo "================================================"
echo ""
echo -e "${BLUE}📥 Pulling pre-built images from Docker Hub...${NC}"
echo "This may take a few minutes depending on your internet speed."
echo ""

$DOCKER_COMPOSE pull

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to pull Docker images${NC}"
    echo ""
    echo "Please verify:"
    echo "  1. The images exist on Docker Hub (mvyas7/job-hunt-ai-backend and mvyas7/job-hunt-ai-frontend)"
    echo "  2. Your internet connection is working"
    echo ""
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Images pulled successfully${NC}"
echo ""

# Start services
echo "================================================"
echo "      Starting Services"
echo "================================================"
echo ""
echo -e "${BLUE}🚀 Starting all services...${NC}"
echo ""

$DOCKER_COMPOSE up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to start services${NC}"
    echo ""
    echo "Run 'docker compose logs' to see error details"
    echo ""
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Services started successfully${NC}"
echo ""

# Wait for services to be ready
echo "================================================"
echo "      Waiting for Services to Initialize"
echo "================================================"
echo ""
echo -e "${BLUE}⏳ This may take 2-3 minutes...${NC}"
echo ""

# Function to check service health
check_service() {
    local name=$1
    local url=$2
    local max_attempts=60
    local attempt=0

    echo -n "Checking $name... "

    while [ $attempt -lt $max_attempts ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Ready${NC}"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 2
        echo -n "."
    done

    echo -e "${YELLOW}⚠️  Still starting (may take a bit longer)${NC}"
    return 1
}

# Check each service
check_service "Elasticsearch" "http://localhost:9200/_cluster/health"
check_service "Neo4j" "http://localhost:7474"
check_service "Backend API" "http://localhost:8000/health"

echo ""

# Setup demo data (optional, in background)
echo -e "${BLUE}📊 Setting up demo data in background...${NC}"
echo "(This will continue even if it takes a while)"
docker exec jobmatch_backend python -c "
from app.database.elasticsearch_setup import initialize_elasticsearch
from app.database.neo4j_setup import initialize_neo4j
try:
    initialize_elasticsearch()
    initialize_neo4j()
    print('Demo data initialized')
except Exception as e:
    print(f'Note: {e}')
" 2>/dev/null || echo "Demo data will be created on first use"

echo ""

# Installation complete
echo "================================================"
echo "      🎉 Installation Complete!"
echo "================================================"
echo ""
echo -e "${GREEN}Your JobMatch AI demo is ready!${NC}"
echo ""
echo "Access your application:"
echo -e "  🌐 Frontend:         ${BLUE}http://localhost:3001${NC}"
echo -e "  🔧 Backend API:      ${BLUE}http://localhost:8000${NC}"
echo -e "  📚 API Docs:         ${BLUE}http://localhost:8000/docs${NC}"
echo -e "  🔍 Elasticsearch:    ${BLUE}http://localhost:9200${NC}"
echo -e "  🕸️  Neo4j Browser:    ${BLUE}http://localhost:7474${NC}"
echo ""
echo "Neo4j Login:"
echo "  Username: neo4j"
echo "  Password: password"
echo ""
echo "================================================"
echo "      Quick Commands"
echo "================================================"
echo ""
echo "View logs:       ${DOCKER_COMPOSE} logs -f"
echo "Stop services:   ${DOCKER_COMPOSE} down"
echo "Restart:         ${DOCKER_COMPOSE} restart"
echo "Remove all data: ${DOCKER_COMPOSE} down -v"
echo ""
echo -e "${YELLOW}Tip: Check out the QUICK_START.md guide for usage examples${NC}"
echo ""
