@echo off
echo Compiling dsfmlGame [Release]

IF NOT EXIST .\Release\ MKDIR Release
IF NOT EXIST .\Release\resources MKDIR .\Release\Resources

XCOPY .\DLLs .\Release\ /D /S /E
XCOPY .\resources .\Release\resources\ /D /S /E

dmd @.\rel_cmdfile.args @.\cmdfile.args

IF %ERRORLEVEL% NEQ 0 GOTO Error
IF NOT EXIST .\Release\dsfmlGame.exe GOTO Error
    echo Completed! (check Release directory)
    goto :Finish

:Error
    echo Cannot build dsfmlGame in Release Mode

:Finish