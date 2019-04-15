
@echo off
echo.

set Region=%1%
set Environment=%2%

@REM Choose appropriate endpoints based on the region provided
if %Region% EQU devush (
	set LoginURL=https://api.devsysush.inbcu.com
)
if %Region% EQU devash (
	set LoginURL=https://api.devsysash.inbcu.com
)
if %Region% EQU ash (
	set LoginURL=https://api.sysash.inbcu.com
)

@REM call cf login --skip-ssl-validation -a %LoginURL% -o TVE-Programming -s COMPASS-%Environment%

@REM call deploy.bat %Region% %Environment% eureka infra develop
call deploy.bat %Region% %Environment% admin backend develop
