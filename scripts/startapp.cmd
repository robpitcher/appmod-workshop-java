@echo off
setlocal

rem Get the directory where the script is located
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..

docker info >nul 2>&1
if errorlevel 1 (
    echo Docker is not available. Start Docker and try again.
    exit /b 1
)

echo Preparing both modules and Maven plugins...
cd /d "%PROJECT_ROOT%"
call "%PROJECT_ROOT%\mvnw.cmd" -B test-compile spring-boot:help
if errorlevel 1 (
    echo Maven preparation failed. Check that JDK 25 is configured in JAVA_HOME or PATH.
    exit /b 1
)

echo Starting PostgreSQL container...
docker inspect --type container assets-postgres >nul 2>&1
if errorlevel 1 (
    docker run -d --name assets-postgres -e POSTGRES_DB=assets_manager -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:latest
) else (
    docker start assets-postgres
)
if errorlevel 1 exit /b 1

echo Starting RabbitMQ container...
docker inspect --type container assets-rabbitmq >nul 2>&1
if errorlevel 1 (
    docker run -d --name assets-rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:management
) else (
    docker start assets-rabbitmq
)
if errorlevel 1 exit /b 1

echo Waiting for services to start...
call :wait_for_postgres
if errorlevel 1 (
    echo PostgreSQL did not become ready.
    exit /b 1
)
call :wait_for_rabbitmq
if errorlevel 1 (
    echo RabbitMQ did not become ready.
    exit /b 1
)

rem Create logs directory if it doesn't exist
if not exist "%PROJECT_ROOT%\logs" mkdir "%PROJECT_ROOT%\logs"

rem Create pids directory if it doesn't exist
if not exist "%PROJECT_ROOT%\pids" mkdir "%PROJECT_ROOT%\pids"

echo Starting web module...
cd /d "%PROJECT_ROOT%\web"
start "Web Module" cmd /k "%PROJECT_ROOT%\mvnw.cmd spring-boot:run -Dspring-boot.run.jvmArguments=-Dspring.pid.file=%PROJECT_ROOT%\pids\web.pid -Dspring-boot.run.profiles=dev"

echo Starting worker module...
cd /d "%PROJECT_ROOT%\worker"
start "Worker Module" cmd /k "%PROJECT_ROOT%\mvnw.cmd spring-boot:run -Dspring-boot.run.jvmArguments=-Dspring.pid.file=%PROJECT_ROOT%\pids\worker.pid -Dspring-boot.run.profiles=dev"

echo Modules are starting in separate windows.
echo Web application: http://localhost:8080
echo RabbitMQ Management: http://localhost:15672 (guest/guest)
exit /b 0

:wait_for_postgres
for /l %%i in (1,1,30) do (
    docker exec assets-postgres pg_isready -U postgres -d assets_manager >nul 2>&1
    if not errorlevel 1 exit /b 0
    timeout /t 2 /nobreak >nul
)
exit /b 1

:wait_for_rabbitmq
for /l %%i in (1,1,30) do (
    docker exec assets-rabbitmq rabbitmq-diagnostics -q ping >nul 2>&1
    if not errorlevel 1 exit /b 0
    timeout /t 2 /nobreak >nul
)
exit /b 1
