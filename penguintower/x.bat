@echo off
call C:\c64\setc64vars.bat
set rootdir=.
set file=penguintower
set d_file=d-%file%
set startaddr=$4500

%exomizer% sfx %startaddr% %rootdir%\%file%.prg -o %rootdir%\%d_file%.prg
%c64sc% %rootdir%\%d_file%.prg
