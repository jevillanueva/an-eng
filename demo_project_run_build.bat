REM Go to the dbt project directory
cd /d "D:/2026/an-eng/demo_project"

echo ====== Running dbt build ======
echo Starting dbt build...
echo Project: D:/2026/an-eng/demo_project
echo ============================

REM Run the dbt build command (models + tests + snapshots)
dbt build

echo ====== dbt build completed ======
echo Finished dbt build for project: D:/2026/an-eng/demo_project
echo Exit code: %ERRORLEVEL%
echo ============================

pause
endlocal