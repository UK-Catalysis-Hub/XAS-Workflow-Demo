@echo off
REM the first parameter is the string for dir and project files
REM the second parameter is the path where the input files are stored
REM the third parameter is the number of files to process

REM example:
REM task_02.bat rh4co 50
set "baseName=%1"
set "crystalFile=%2"
set /A top_count=%3

set "fit_log=%baseName%_fit\processing.log"


REM create the directory for the results
if exist "%baseName%_fit\" (
  echo %baseName%_fit\ directory exists >> %fit_log%
  ) else (
  mkdir "%baseName%_fit\"
  echo create directory %baseName%_fit\ >> %fit_log%
  )
@echo Started: %date% %time%  >> %fit_log%

setlocal enableextensions enabledelayedexpansion
set /a count = 0
for %%f in (.\%baseName%\*.prj) do (
  set "n=00000!count!"
  echo processing %%~nf 
  echo athena_file: .\%baseName%\%baseName%!n:~-6!.prj >> %fit_log%
  echo crystal file: %crystalFile% >> %fit_log%
  set athena_file=%baseName%!n:~-6!.prj
  perl demeter_task02.pl %%f  %crystalFile% %baseName% Y
  set /a count += 1
  echo processed !count! of %top_count% files >> %fit_log%
  if "!count!"=="%top_count%" goto :next
)

endlocal
:next

@echo Completed: %date% %time%  >> %fit_log%
@echo finished processing
