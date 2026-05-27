unit UST_Common;

interface

function ShowAlertBox(sMessage : string) : word;
function ShowInfoBox(sMessage : string) : word;
function ShowConfirmBox(sMessage : string) : word;

function GetIsNumber(sStr : string) : boolean;
function GetIsNumberSigned(sStr : string) : boolean;
function OpenFolderDialog(const sTitle: string; const iFlags: integer): string;

function SafeStrToDouble(sStr : string) : Double;
function SafeStrToFloat(sStr : string) : Single;
function GetIsFloat(sStr : string) : boolean;

function ReplaceInString(sSource, sFind, sReplace : string ) : string;

function RunShellGetOutput(sExecutable : String; sParameters : string = '') : string;

procedure RunAndWaitShell(Executable, Parameter: string; ShowParameter: integer);
procedure MakeFileWritable(sFilename : string);
procedure BackupFile(const sFilename, sNewfile: string);

implementation

uses Classes, Dialogs, Forms, SysUtils, Windows, ShellAPI, ShlObj;

// -----------------------------------------------------------------------------
//
// -----------------------------------------------------------------------------
function ShowAlertBox(sMessage : string) : word;
begin
     result := MessageDlg(sMessage, mtWarning, [mbOK], 0);
end;


// -----------------------------------------------------------------------------
//
// -----------------------------------------------------------------------------
function ShowInfoBox(sMessage : string) : word;
begin
     result := MessageDlg(sMessage, mtInformation, [mbOK], 0);
end;


// -----------------------------------------------------------------------------
//
// -----------------------------------------------------------------------------
function ShowConfirmBox(sMessage : string) : word;
begin
     result := MessageDlg(sMessage, mtConfirmation, [mbYes, mbNo], 0);
end;


// -----------------------------------------------------------------------------
// UTILITY: Check if the string can be converted to an Unsigned Integer.
// -----------------------------------------------------------------------------
function GetIsNumber(sStr : string) : boolean;
var
   i       : integer;
begin
     for i := 1 to Length(sStr) do begin
         if not (sStr[i] in ['0'..'9']) then begin
            result := false;
            exit;
         end;
     end;

     if (Length(sStr) > 0) then
        result := true
     else
        result := false;
end;


// -----------------------------------------------------------------------------
// UTILITY: Check if the string can be converted to a Signed Integer.
// -----------------------------------------------------------------------------
function GetIsNumberSigned(sStr : string) : boolean;
var
   i       : integer;
begin
     if (Length(sStr) <= 0) then begin
         result := false;
         exit;
     end;

     if not (sStr[1] in ['0'..'9', '-']) then begin
         result := false;
         exit;
     end;

     for i := 2 to Length(sStr) do begin
         if not (sStr[i] in ['0'..'9']) then begin
            result := false;
            exit;
         end;
     end;

     result := true;
end;


// -----------------------------------------------------------------------------
// UTILITY: Make the file with the specified name Writable if it is flagged
//          as ReadOnly in Windows.
// -----------------------------------------------------------------------------
procedure MakeFileWritable(sFilename : string);
var   nFlags : Word;begin     if (SysUtils.FileExists(sFileName)) then begin        nFlags := FileGetAttr(sFilename);        if((nFlags and faReadOnly) = faReadOnly) then begin            nFlags := nFlags and not faReadOnly;            FileSetAttr(sFilename, nFlags);        end;     end;end;


// -----------------------------------------------------------------------------
// UTILITY: Make a backup copy of the specified file and save it at the path
//          and with the name specified by the second parameter.
// -----------------------------------------------------------------------------
procedure BackupFile(const sFilename, sNewfile: string);
var
  inFile  : TFileStream;
  outFile : TFileStream;
begin
    inFile := TFileStream.Create(sFilename, fmOpenRead or fmShareDenyNone);
    try
        outFile := TFileStream.Create(sNewfile, fmCreate);
        try
            outFile.CopyFrom(inFile, 0);
        finally
            outFile.Free;
        end;
    finally
        inFile.Free;
    end;
end;


// -----------------------------------------------------------------------------
// CALLBACK FUNCTION for OpenFolderDialog(). Do NOT call directly.
// -----------------------------------------------------------------------------
function OpenFolderSetup(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): integer stdcall;
var
   oArea  : TRect;
   oRect  : TRect;
   oDlgPt : TPoint;
begin
    // Center the Dialog box on the desktop...
    if (uMsg = BFFM_INITIALIZED) then begin
        oArea.top    := Screen.DesktopTop;
        oArea.left   := Screen.DesktopLeft;
        oArea.bottom := Screen.DesktopTop + Screen.DesktopHeight;
        oArea.right  := Screen.DesktopLeft + Screen.DesktopWidth;

        GetWindowRect(Wnd, oRect);

        oDlgPt.X := ((oArea.Right-oArea.Left) div 2) - ((oRect.Right-oRect.Left) div 2);
        oDlgPt.Y := ((oArea.Bottom-oArea.Top) div 2) - ((oRect.Bottom-oRect.Top) div 2);

        MoveWindow(Wnd, oDlgPt.X, oDlgPt.Y, oRect.Right - oRect.Left, oRect.Bottom - oRect.Top, True);
    end;

    Result := 0;
end;



// -----------------------------------------------------------------------------
// Wrapper for Win32API OpenFolder dialog box, since no Delphi component seems
// to exist for it in this version of Delphi.
// -----------------------------------------------------------------------------
function OpenFolderDialog(const sTitle: string; const iFlags: integer): string;
var
   lpItemID   : PItemIDList;
   BrowseInfo : TBrowseInfo;
   sName      : array[0..MAX_PATH] of char;
   sPath      : array[0..MAX_PATH] of char;
begin
    FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);

    with BrowseInfo do begin
        hwndOwner      := Application.Handle;
        pszDisplayName := @sName;
        lpszTitle      := PChar(sTitle);
        ulFlags        := iFlags;
        lpfn           := OpenFolderSetup;
    end;

    lpItemID := SHBrowseForFolder(BrowseInfo);

    if (lpItemId <> nil) then begin
        SHGetPathFromIDList(lpItemID, sPath);
        GlobalFreePtr(lpItemID);
        Result := sPath;
    end
    else begin
        Result:='';
    end;
end;


// -----------------------------------------------------------------------------
// Wrapper for Win32API functionality for running an external application and
// waiting for it to finish before proceeding, since no TCL functions seems
// to exist for this purpose.
// Executable = path&name of application to run
// Parameter = Commandline parameters to send to the application when calling it.
// ShowParameter = If SW_HIDE, the console window will not be shown when the app runs.
// -----------------------------------------------------------------------------
procedure RunAndWaitShell(Executable, Parameter: string; ShowParameter: integer);
var
   Info:  TShellExecuteInfo;
   pInfo: PShellExecuteInfo;
   exitCode: DWORD;
begin
    // Make a pointer to the struct...
    pInfo := @Info;

  // Fill the struct with the necessary parameters.
    with Info do begin
        cbSize       := SizeOf(Info);
        fMask        := SEE_MASK_NOCLOSEPROCESS;
        wnd          := application.Handle;
        lpVerb       := nil;
        lpFile       := PChar(Executable);             // Application to run
        lpParameters := PChar(Parameter + #0);         // Cmdline params to application
        lpDirectory  := nil;
        nShow        := ShowParameter;                 // If SW_HIDE, don't show console window.
        hInstApp     := 0;
    end;

  // Run the external application...
    if (not ShellExecuteEx(pInfo)) then begin
        raise EFOpenError.Create('Unable to start external application "' + Executable + '"! (' + SysErrorMessage(GetLastError) + ')');
    end;

  // Wait for the external application to finish...
    repeat
        exitCode := WaitForSingleObject(Info.hProcess, 500);
        Application.ProcessMessages;
    until (exitcode <> STILL_ACTIVE) and (exitCode <> WAIT_TIMEOUT);
end;


// -----------------------------------------------------------------------------
// Wrapper for Win32API functionality for running an external console
// application, capture its StdOut output and wait for it to finish before
// proceeding, returning any output as function value.
// Executable = path&name of application to run
// Parameter = Commandline parameters to send to the application when calling it.
// -----------------------------------------------------------------------------
function RunShellGetOutput(sExecutable : String; sParameters : string = '') : string;
const
    ReadBuffer = 2400;   
var
    oSecurity       : TSecurityAttributes;
    oReadPipe       : THandle;
    oWritePipe      : THandle;
    oStartInfo      : TStartUpInfo;
    oProcessInfo    : TProcessInformation;
    sBuffer         : Pchar;
    iBytesRead      : DWord;
    iApprunning     : DWord;
    sResult         : string;
    sCmdLine        : String;
begin
    result := '';
    sResult := '';

    // If name is shorter than x.exe its not a valid EXE name, no point in continuing.
    if (Length(sExecutable) < 5) then
       exit;

    // The commandline consists of at least the ExeName&path....
    sCmdLine := sExecutable;

    // If parameters are specified, append them to the commandline...
    if (Length(sParameters) > 0) then
        sCmdLine := sExecutable + ' ' + sParameters;

    // Fill arcane Struct needed for Win32API calls with necessary info... :/
    with oSecurity do begin
        nLength                 := sizeof(TSecurityAttributes);
        bInheritHandle          := true;
        lpSecurityDescriptor    := nil;
    end;
   
    if Createpipe(oReadPipe, oWritePipe, @oSecurity, 0) then begin
        sBuffer := AllocMem(ReadBuffer + 1);
        FillChar(oStartInfo, sizeof(oStartInfo), #0);

        try
            // Fill arcane Struct needed for Win32API calls with necessary info... :/
            with oStartInfo do begin
                cb          := SizeOf(oStartInfo);
                hStdOutput  := oWritePipe;
                hStdInput   := oReadPipe;
                dwFlags     := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
                wShowWindow := SW_HIDE;
            end;

            // ADDED(2006-02-05) Set the current folder to the folder the
            // application is run from...
            ChDir(ExtractFilePath(sExecutable));

            // Start the application...
            if CreateProcess(nil, PChar(sCmdLine), @oSecurity, @oSecurity, true, NORMAL_PRIORITY_CLASS, nil, nil, oStartInfo, oProcessInfo) then begin
                // Wait for the application to finish....
                repeat
                    iApprunning := WaitForSingleObject(oProcessInfo.hProcess, 100);
                    Application.ProcessMessages;
                until (iApprunning <> WAIT_TIMEOUT) and (iApprunning <> STILL_ACTIVE);

                // Read the output from the pipe and put in the result string...
                repeat
                    iBytesRead := 0;
                    ReadFile(oReadPipe, sBuffer[0], ReadBuffer,iBytesRead, nil);
                    sBuffer[iBytesRead]:= #0;
                    OemToAnsi(sBuffer, sBuffer);
                    sResult := sResult + String(sBuffer);
                until (iBytesRead < ReadBuffer);

                // Clean set functio result and clean up...
                result := sResult;
                CloseHandle(oProcessInfo.hProcess);
                CloseHandle(oProcessInfo.hThread);
            end
            else begin
                raise EFOpenError.CreateHelp('Unable to start program ' + sExecutable + '!' , 1);
            end;
        finally
            // Free used resources...
            FreeMem(sBuffer);
            CloseHandle(oReadPipe);
            CloseHandle(oWritePipe);
        end;
    end;
end;



// -----------------------------------------------------------------------------
// UTILITY: Check if the supplied string can be converted to a decimal number.
// -----------------------------------------------------------------------------
function GetIsFloat(sStr : string) : boolean;
var
   i       : integer;
begin
     if (Length(sStr) <= 0) then begin
         result := false;
         exit;
     end;

     if not (sStr[1] in ['0'..'9', '-']) then begin
         result := false;
         exit;
     end;

     for i := 2 to (Length(sStr) - 1) do begin
         if not (sStr[i] in ['0'..'9', '.', ',']) then begin
            result := false;
            exit;
         end;
     end;

     if not (sStr[Length(sStr)] in ['0'..'9']) then begin
         result := false;
         exit;
     end;

     result := true;
end;


// -----------------------------------------------------------------------------
// UTILITY: Convert string to a Float if possible, accepting both comma and
//          period as valid decimal separators.
// -----------------------------------------------------------------------------
function SafeStrToFloat(sStr : string) : Single;
begin
    if not GetIsFloat(sStr) then begin
        result := 0.0;
        exit;
    end;

    if (DecimalSeparator = ',') then begin
        if (Pos('.', sStr) > 0) then
            sStr[Pos('.', sStr)] := ',';
    end
    else if (DecimalSeparator = '.') then begin
        if (Pos(',', sStr) > 0) then
            sStr[Pos(',', sStr)] := '.';
    end;

    result := StrToFloat(sStr);
end;


// -----------------------------------------------------------------------------
// UTILITY: Convert string to a Float if possible, accepting both comma and
//          period as valid decimal separators.
// -----------------------------------------------------------------------------
function SafeStrToDouble(sStr : string) : Double;
begin
    if not GetIsFloat(sStr) then begin
        result := 0.0;
        exit;
    end;

    if (DecimalSeparator = ',') then begin
        if (Pos('.', sStr) > 0) then
            sStr[Pos('.', sStr)] := ',';
    end
    else if (DecimalSeparator = '.') then begin
        if (Pos(',', sStr) > 0) then
            sStr[Pos(',', sStr)] := '.';
    end;

    result := StrToFloat(sStr);
end;


// -----------------------------------------------------------------------------
// Utility function for replacing substrings within a string with another
// string.
// sSource = The original string to operate on.
// sFind   = The substring that should be replaced.
// sReplace = The new string that will be inserted in place of sFind.
//
// Returns: The modified string.
// -----------------------------------------------------------------------------
function ReplaceInString(sSource, sFind, sReplace : string ) : string;
var
   iPos, lPos : integer;
   
	function EgenPos( substr, str : string; startval : integer ) : integer;
	var temp : string;
	    iPos : integer;
	begin
	     startval := startval + 1;
	     if (Length(str)-startval > 0) then
	     begin
	          temp := Copy(str, startval, (Length(str)-startval)+1 );
	          iPos := pos(substr, temp);
	          if iPos > 0 then
	             result := startval + (iPos-1)
	          else
	              result := 0;
	     end
	     else
	         result := 0;
	end;
begin
     lPos := 1;
     repeat
       iPos := EgenPos(sFind, sSource, lPos);
       lPos := iPos;
       if iPos > 0 then
          sSource := copy(sSource, 1, iPos-1) + sReplace +
                    copy(sSource, iPos+Length(sFind), Length(sSource)-(iPos-1+Length(sFind)))
     until iPos = 0;
     result := sSource;
end;


end.
 