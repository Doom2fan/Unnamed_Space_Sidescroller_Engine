@echo off
echo Compiling dsfmlGame [Debug]

IF NOT EXIST .\Debug\ MKDIR Debug
IF NOT EXIST .\Debug\resources MKDIR .\Debug\Resources

XCOPY .\DLLs .\Debug\ /D /S /E
XCOPY .\resources .\Debug\resources\ /D /S /E

dmd @.\dbg_cmdfile.args @.\cmdfile.args

IF %ERRORLEVEL% NEQ 0 GOTO Error
IF NOT EXIST .\Debug\dsfmlGame.exe GOTO Error
    echo Completed! (check Debug directory)
	goto :Finish

:Error
    echo Cannot build dsfmlGame in Debug Mode

:Finish