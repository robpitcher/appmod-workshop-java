#!/bin/bash

set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

if ! docker info > /dev/null 2>&1; then
    echo "Docker is not available. Start Docker and try again." >&2
    exit 1
fi

echo "Preparing both modules and Maven plugins..."
if ! (cd "$PROJECT_ROOT" && ./mvnw -B test-compile spring-boot:help); then
    echo "Maven preparation failed. Check that JDK 25 is configured in JAVA_HOME or PATH." >&2
    exit 1
fi

echo "Starting PostgreSQL container..."
if docker inspect --type container assets-postgres > /dev/null 2>&1; then
    docker start assets-postgres
else
    docker run -d --name assets-postgres \
        -e POSTGRES_DB=assets_manager \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=postgres \
        -p 5432:5432 postgres:latest
fi

echo "Starting RabbitMQ container..."
if docker inspect --type container assets-rabbitmq > /dev/null 2>&1; then
    docker start assets-rabbitmq
else
    docker run -d --name assets-rabbitmq \
        -p 5672:5672 \
        -p 15672:15672 \
        rabbitmq:management
fi

echo "Waiting for services to start..."
wait_for_service() {
    for _ in {1..30}; do
        if docker exec "$@" > /dev/null 2>&1; then
            return 0
        fi
        sleep 2
    done
    echo "$1 did not become ready." >&2
    return 1
}
wait_for_service assets-postgres pg_isready -U postgres -d assets_manager
wait_for_service assets-rabbitmq rabbitmq-diagnostics -q ping

# Create logs directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/logs"

# Create pids directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/pids"

echo "Starting web module..."
cd "$PROJECT_ROOT/web" && "$PROJECT_ROOT/mvnw" spring-boot:run -Dspring-boot.run.jvmArguments="-Dspring.pid.file=$PROJECT_ROOT/pids/web.pid" -Dspring-boot.run.profiles=dev > "$PROJECT_ROOT/logs/web.log" 2>&1 &

echo "Starting worker module..."
cd "$PROJECT_ROOT/worker" && "$PROJECT_ROOT/mvnw" spring-boot:run -Dspring-boot.run.jvmArguments="-Dspring.pid.file=$PROJECT_ROOT/pids/worker.pid" -Dspring-boot.run.profiles=dev > "$PROJECT_ROOT/logs/worker.log" 2>&1 &

echo "Modules are starting. Check logs directory for output."
echo "Web application: http://localhost:8080"
echo "RabbitMQ Management: http://localhost:15672 (guest/guest)"