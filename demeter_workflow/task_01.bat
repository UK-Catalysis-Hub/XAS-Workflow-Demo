@echo off
REM the first parameter is the string for dir and project files
REM the second parameter is the path where the input files are stored
REM the third parameter is the number of files to process

REM example:
REM task_01.bat rh4co ..\nexusdata\rh4co_ox_53\37123_Rh_4_CO_Oxidation_45_7_ascii\*.dat 50
set "baseName=%1"
set "filesPath=%2"
set /A top_count=%3

REM create the directory for the results
if exist "%baseName%\" (
  echo directory exists 
  ) else (
  echo create directory
  mkdir "%baseName%\"
  )

setlocal enableextensions enabledelayedexpansion
set /a count = 0
for %%f in (%filesPath%) do (
  set "n=00000!count!"
  echo new file .\%baseName%\%baseName%!n:~-6!.prj
  set athena_file=%baseName%!n:~-6!.prj
  perl demeter_task01.pl %%f   %baseName%!n:~-6! .\%baseName%\%baseName%!n:~-6!.prj Y
  set /a count += 1
  echo !count!
  if "!count!"=="%top_count%" goto :next
)

endlocal
:next
echo finished processing
