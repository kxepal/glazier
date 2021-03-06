@echo off
title Time to Relax.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set CYGWIN=nontsec nodosfilewarning
if not exist c:\tmp mkdir c:\tmp
set TEMP=c:\tmp
set TMP=c:\tmp

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: following settings allow Erlang build to locate openssl correctly
:: and CouchDB to find ICU, Curl, and SSL if required
set USE_SSLEAY=1
set USE_OPENSSL=1
if not defined SSL_PATH  set SSL_PATH=%RELAX%\openssl
if not defined ICU_PATH  set ICU_PATH=%RELAX%\icu
if not defined CURL_PATH set CURL_PATH=%RELAX%\curl
if not defined ZLIB_PATH set ZLIB_PATH=%RELAX%\zlib

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: haul in MSVC compiler configuration
:: TODO remove dependency on x86 flag
call "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /x86 /release

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: LIB and INCLUDE are preset by Windows SDK and/or Visual C++ shells
:: however VC++ uses LIB & INCLUDE and SDK uses Lib & Include. In Cygwin
:: these are *NOT* the same but when we shell out to CL.exe and LINK.exe
:: all is well again

:: relax for couchdb
:: werldir for building erlang

if not defined RELAX set RELAX=c:\relax
if not defined WERL_DIR set WERL_DIR=c:\werl
setx WERL_DIR %WERL_DIR% > NUL:
setx RELAX %RELAX% > NUL:

set LIB=%RELAX%\VC\VC\lib;%RELAX%\SDK\lib;%LIB%
SET INCLUDE=%RELAX%\VC\VC\Include;%RELAX%\SDK\Include;%RELAX%\SDK\Include\gl;%INCLUDE%

set INCLUDE=%INCLUDE%;%SSL_PATH%\include\openssl;%SSL_PATH%\include;%CURL_PATH%\include\curl;%ICU_PATH%\include;
set LIBPATH=%LIBPATH%;%SSL_PATH%\lib;%CURL_PATH%\lib;%ICU_PATH%\lib;
set LIB=%LIB%;%SSL_PATH%\lib;%CURL_PATH%\lib;%ICU_PATH%\lib;

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: check which version of erlang setup we want
:: pick up from jenkins if required
if not defined BUILD_WITH_JENKINS goto select
if not defined OTP_REL goto select
goto %OTP_REL%
:: no default, so let's ask the user instead!
:: choice.exe exists on all windows platforms since MSDOS but not on XP
:select
echo select:
echo       3 for R15b03-1
echo       4 for R14b04
::echo       A for R16A
echo       B for R16B
echo       1 for R16B01
set /p choice=or 0 to exit to the shell.
:: then get to unix goodness as fast as possible
if /i "%choice%"=="0" goto win_shell
::::if /i "%choice%"=="2" goto R......
if /i "%choice%"=="3" goto R15B03-1
if /i "%choice%"=="4" goto R14B04
if /i "%choice%"=="A" goto R16A
if /i "%choice%"=="B" goto R16B
if /i "%choice%"=="1" goto R16B01
:: else
goto eof

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:R15B03-1
set ERTS_VSN=5.9.3.1
set OTP_REL=R15B03-1
goto unix_shell

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:R16B01
set ERTS_VSN=5.10.2
set OTP_REL=R16B01
goto unix_shell

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:R14B04
set ERTS_VSN=5.8.5
set OTP_REL=R14B04
goto unix_shell


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:R16B
set ERTS_VSN=5.10.1
set OTP_REL=R16B
goto unix_shell

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:unix_shell
color
title Building in %ERL_TOP% with OTP %OTP_REL% and Erlang v%ERTS_VSN%
for /f "usebackq" %%i in (`c:\cygwin\bin\cygpath.exe %WERL_DIR%`) do @set WERL_PATH=%%i
set ERL_TOP=%WERL_PATH%/otp_src_%OTP_REL%
c:\cygwin\bin\bash %relax%\bin\shell.sh
goto eof

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:win_shell
echo type exit to stop relaxing.
cmd.exe /k

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
