@echo off
call C:\c64\setc64vars.bat
set rootdir=.
set file=ptower_intro
set d_file=d-%file%
set startaddr=$1070

%exomizer% sfx %startaddr% %rootdir%\%file%.prg -o %rootdir%\%d_file%.prg
%c64sc% %rootdir%\%d_file%.prg
