@echo off
echo === Building Frontend ===
cd /d "%~dp0ClothNCareFrontend\cloth-n-care-ui"
call npm install
call npm run build
if errorlevel 1 (
    echo Frontend build failed!
    exit /b 1
)
echo Frontend build successful!

echo.
echo === Building Backend ===
cd /d "%~dp0ClothNCare\ClothNCare"
call mvnw.cmd clean package -DskipTests
if errorlevel 1 (
    echo Backend build failed!
    exit /b 1
)
echo Backend build successful!

echo.
echo === Build Complete ===
echo JAR location: %~dp0ClothNCare\ClothNCare\target\ClothNCare-0.0.1-SNAPSHOT.jar
