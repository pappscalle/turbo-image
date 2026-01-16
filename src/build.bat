@echo off

REM --- Compile UNITS first ---
echo ============================
echo Compiling UNITS
echo ============================

cd external\src\units
for %%F in (*.pas) do call C:\TP7\BIN\TPC.EXE %%F -B -Q
cd ..\..\..

REM --- Compile PROGRAMS ---
echo ============================
echo Compiling PROGRAMS
echo ============================

for %%F in (*.pas) do call C:\TP7\BIN\TPC.EXE %%F -B -Q -Uexternal\src\units
echo.
echo Build complete.
exit
