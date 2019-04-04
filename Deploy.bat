@REM =====================================================================================

@REM This script can deploy specified Microservice/Application to the specified Env's .

@REM Execute this script without any parameters to see usage

@REM Author Mattaparthi Mohan

@REM Last update - 03-04-2019

@REM =====================================================================================



@echo off



set _exitStatus=0

set _argcActual=0

set _argcExpected=4



echo.



for %%i in (%*) do set /A _argcActual+=1



if %_argcActual% LSS %_argcExpected% (

   call :_ShowUsage %0%, "Bad arguments"

   set _exitStatus=1

   goto:_EOF

)



@REM Set variables

set Region=%1%

set Environment=%2%

set ApplicationName=%3%

set RepositoryType=%4%

if "%_argcActual%"=="5" (

	set BranchName=%5%

)



@REM Choose appropriate endpoints based on the region provided

if %Region% EQU devush (

	set LoginURL=https://api.devsysush.inbcu.com

	set Domain=%2%.compass.devush.inbcu.com

)

if %Region% EQU devash (

	set LoginURL=https://api.devsysash.inbcu.com

	set Domain=%2%.compass.devash.inbcu.com

)

if %Region% EQU ash (

	set LoginURL=https://api.sysash.inbcu.com

	set Domain=%2%.compass.ash.inbcu.com

)

if %Region% EQU ush (

	set LoginURL=https://api.sysush.inbcu.com

	set Domain=%2%.compass.ush.inbcu.com

)



if %_argcActual% EQU 5 (

	@REM Checkout code from specified branch; Compile and Build

	set OLDDIR=%CD%

	cd %TEMP% 

	mkdir checkout1

	cd checkout1

	set HTTP_PROXY=http://proxy.inbcu.com:80

	set HTTPS_PROXY=http://proxy.inbcu.com:80

	git clone --branch=%BranchName% https://github.inbcu.com/%ApplicationName%.git 

	set HTTP_PROXY=

	set HTTPS_PROXY=

	cd %ApplicationName%

)



@REM Compile and Build

call mvn clean install -Dmaven.test.skip=true





@REM Login into Cloud Foundry

call cf login --skip-ssl-validation -a %LoginURL% -o TVE-Programming -s COMPASS-%Environment% -u mattaparthi -p devops 



@REM Setup routes based on the type of repository

if "%RepositoryType%"=="backend" (

	echo "The Repository Type is backend"

	if "%Environment%"=="staging" (

		call cf push %ApplicationName% -d %Domain% --no-hostname --no-start --route-path %ApplicationName% -p target\%ApplicationName%.jar -i ${p:environment/numberofinstances} -k ${p:environment/harddisk} -m ${p:environment/memory}

		call cf set-env %ApplicationName% JAVA_OPTS "-Dappdynamics.http.proxyHost=173.213.212.20 -Dappdynamics.http.proxyPort=80 -Dappdynamics.agent.applicationName=\"COMPASS Ash Stg\" -Dappdynamics.agent.tierName=%ApplicationName%"

		call cf bind-service %ApplicationName% appdynamics

	) else if "%Environment%"=="prod" (

		call cf push %ApplicationName% -d %Domain% --no-hostname --no-start --route-path %ApplicationName% -p target\%ApplicationName%.jar -i ${p:environment/numberofinstances} -k ${p:environment/harddisk} -m ${p:environment/memory}

		call cf set-env %ApplicationName% JAVA_OPTS "-Dappdynamics.http.proxyHost=173.213.212.20 -Dappdynamics.http.proxyPort=80 -Dappdynamics.agent.applicationName=\"COMPASS RePlatform Prod\" -Dappdynamics.agent.tierName=%ApplicationName%"

		call cf bind-service %ApplicationName% appdynamics

	) else if "%Environment%"=="staging1" (

		call cf push %ApplicationName% -d %Domain% --no-hostname --no-start --route-path %ApplicationName% -p target\%ApplicationName%.jar -i ${p:environment/numberofinstances} -k ${p:environment/harddisk} -m ${p:environment/memory}

		call cf set-env %ApplicationName% JAVA_OPTS "-Dappdynamics.http.proxyHost=173.213.212.20 -Dappdynamics.http.proxyPort=80 -Dappdynamics.agent.applicationName=\"COMPASS Ash Stg\" -Dappdynamics.agent.tierName=%ApplicationName%"

		call cf bind-service %ApplicationName% appdynamics

	) else if "%Environment%"=="Rel2Dev" (

		call cf push %ApplicationName% -d %Domain% -b https://github.com/cloudfoundry/java-buildpack#v4.5 --no-hostname --no-start --route-path %ApplicationName% -p target\%ApplicationName%.jar

	) else if "%Environment%"=="DevIntg" (

		call cf push %ApplicationName% -d %Domain% -b https://github.com/cloudfoundry/java-buildpack#v4.5 --no-hostname --no-start --route-path %ApplicationName% -p target\%ApplicationName%.jar

	) else (

		call cf push %ApplicationName% -d %Domain% --no-hostname --no-start --route-path %ApplicationName% -p target\%ApplicationName%.jar

	)

) 

if "%RepositoryType%"=="frontend" (

	call cf push %ApplicationName% -d %Domain% --no-hostname --no-start -p target\webapp.war

)

if "%RepositoryType%"=="infra" (

	if "%ApplicationName%"=="eureka" (

		call cf push eureka1 -d %Domain% --hostname=%ApplicationName% --no-start -p target\%ApplicationName%.jar

		cf set-env eureka1 SPRING_PROFILES_ACTIVE sr1

		cf bind-service eureka1 sr2

		cf start eureka1

		call cf push eureka2 -d %Domain% --hostname=%ApplicationName% --no-start -p target\%ApplicationName%.jar

		cf set-env eureka2 SPRING_PROFILES_ACTIVE sr2

		cf bind-service eureka2 sr1

		cf start eureka2

	)

	if "%ApplicationName%"=="config" (

		call cf push %ApplicationName% -d %Domain% --hostname=%ApplicationName% --no-start -p target\%ApplicationName%.jar

	)

)

call cf set-env %ApplicationName% HTTPS_PROXY "http://proxy.inbcu.com:80"

call cf set-env %ApplicationName% HTTP_PROXY "http://proxy.inbcu.com:80"

call cf set-env %ApplicationName% TZ "America/New_York"	

call cf start %ApplicationName%



if %_argcActual% EQU 5 (

	@REM Perform cleanup and move back to directory from where the script was executed

	cd ..\..

	rmdir /Q /S checkout1

	chdir /d %OLDDIR%

)



goto:_EOF



:_ShowUsage

  

  echo ===============================================================================================

  echo [USAGE]:

  echo.

  echo If you want to checkout code from repository, execute the command below:

  echo.

  echo [USAGE]: %~1 ^<Region^> ^<Environment^> ^<Application Name^> ^<Repository Type^> ^<Branch Name^>

  echo.

  echo If you want to deploy from current directory, execute the command below:

  echo.

  echo [USAGE]: %~1 ^<Region^> ^<Environment^> ^<Application Name^> ^<Repository Type^>

  echo ===============================================================================================

  echo.

  echo Prerequsities:

  echo ====================================================================================

  echo Git bash utility is installed

  echo CF CLI is installed

  echo Required privileges  and access to the target CF region

  echo Write permissions to Windows Temp directory

  echo Required privileges and access to the target GitHub repository

  echo ====================================================================================

  echo.

  echo Parameter details (Possible values):

  echo ====================================================================================

  echo Region: devush, devash, ash

  echo Environment: dev, qa, integration, performance, preuat, backlog-release, staging

  echo Application Name: Name of GitHub Repository. E.g. users, networks, authorization

  echo Repository Type: backend, frontend, infra. E.g. Specify frontend for webcomponent, infra for eureka, backend for others

  echo Branch Name: Name of branch from which code is checked out. E.g. develop, master

  echo ====================================================================================

  echo.

  if NOT "%~3" == "" (

    echo %~3

    echo.

  )

  

goto:eof



:_EOF

 

echo The exit status is %_exitStatus%.

echo.

cmd /c exit %_exitStatus%
