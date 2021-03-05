@ECHO OFF
setlocal enableextensions enabledelayedexpansion
set /a count = 0
for %%f in (..\nexusdata\rh4co_ox_53\37123_Rh_4_CO_Oxidation_45_7_ascii\*.dat) do (
  set /a count += 1
  set text_file=%%~nf  
  set val=<%%f
  echo fullname: %%f
  echo path: %%~pf
  echo extension is: %%~xf
rem  echo "name: %%~nf"
  echo file name is: !text_file:~0,46!"
  echo short name is: !text_file:~29,17!"
rem   echo "contents: !val!"
  echo !count!
  if "!count!"=="3" goto :next
)
endlocal 
:next
echo ---------------------------------------------
set baseName=%1
for /l %%X in (1 1 5) do (
	echo %%X
	set "ni=00000%%X"
	echo %ni%
	SET "dname=%baseName%!ni:~-6!"
	echo %dname%
)
echo ---------------------------------------------
FOR /l %%G in (100006,1,100010) DO echo %1%%%G.txt
REM SET  a=Hello 
REM SET  b=World 
REM SET /A d = 50 
REM SET c=%a% and %b% %d%
REM echo %a%
REM echo %b%
REM echo %c%
rem perl demeter_task01.pl ..\nexusdata\rh4co_ox_53\37123_Rh_4_CO_Oxidation_45_7_ascii\37123_Rh_4_CO_Oxidation_45_7_rh4co_ox_47_00300.dat  rh4co_ox_47_00300 rh4co_ox_47_00300.prj Y

echo ---------------------------------------------
set "baseName=rh4co_ox_47_"
set "extension=.txt"
set a=0
for /l %%G in (995 1 1000) do (
	SET /A a += 1
    set "n=00000%%G"
    echo %baseName%!n:~-6!%extension%
	echo !baseName:~-6!
)

echo ---------------------------------------------
setlocal enableextensions enabledelayedexpansion
set /a count = 0
for /l %%G in (100001,1,100010) do (
  set /a count += 1
  echo !count!
  if "!count!"=="3" goto :continue
)
endlocal
:continue
SET TEXT=Hello World
SET SUBSTRING=!TEXT:~0,5!
ECHO !SUBSTRING!
