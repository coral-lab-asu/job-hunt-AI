#!/bin/bash
# JobMatch AI - Uninstall Script
# For Linux and macOS

set -e

echo "================================================"
echo "      JobMatch AI - Uninstall"
echo "================================================"
echo ""

# Detect docker compose command
DOCKER_COMPOSE="docker compose"
if ! docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
fi

echo "This will:"
echo "  1. Stop all running containers"
echo "  2. Remove containers"
echo "  3. Remove Docker networks"
echo ""
echo "Do you want to also remove all data (volumes)?"
echo "  - Choose 'y' to delete all data (cannot be undone)"
echo "  - Choose 'n' to keep data for next time"
echo ""
read -p "Remove data volumes? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Stopping and removing everything (including data)..."
    $DOCKER_COMPOSE down -v
    echo ""
    echo "All services and data removed."
else
    echo "Stopping and removing containers (keeping data)..."
    $DOCKER_COMPOSE down
    echo ""
    echo "Services stopped. Data volumes preserved."
fi

echo ""
echo "Uninstall complete!"
echo ""
echo "To reinstall, run: ./install.sh"
echo ""
