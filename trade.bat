@echo off
setlocal enabledelayedexpansion
(for /f "tokens=*" %%a in (trade_log.txt) do (
    set line=%%a
    if not "!line:~0,4!"=="9453" echo !line!
)) > trade_log_new.txt
move /y trade_log_new.txt trade_log.txt
