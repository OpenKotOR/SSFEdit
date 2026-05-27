unit SSFEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, UTLKFile, ExtCtrls, Grids, Buttons, StoffeUtils;

type
  TResEntry = record
     text  : string;
     sound : string;
  end;
  T4Char  = array[0..3] of Char;
  TForm1 = class(TForm)
    Panel1: TPanel;
    gridSnd: TStringGrid;
    Bevel1: TBevel;
    lblType: TLabel;
    edStrRef: TEdit;
    btnModify: TButton;
    lblText: TLabel;
    Panel2: TPanel;
    edTLKfile: TEdit;
    edSSFfile: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    btnSave: TBitBtn;
    BitBtn2: TBitBtn;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    btnNew: TBitBtn;
    btnAddTlk: TButton;
    Bevel2: TBevel;
    procedure Button1Click(Sender: TObject);
    function GetTlkString(iStrRef : DWORD) : TResEntry;
    function ShowAlertBox(sMessage : string) : word;
    function ShowInfoBox(sMessage : string) : word;
    function ShowConfirmBox(sMessage : string) : word;
    procedure SetupLabels;
    procedure ResetGrid;
    procedure RefreshGrid;
    procedure edField1KeyPress(Sender: TObject; var Key: Char);
    procedure edStrRefKeyPress(Sender: TObject; var Key: Char);
    procedure gridSndClick(Sender: TObject);
    procedure btnModifyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnAddTlkClick(Sender: TObject);
  private
    { Private declarations }
    tlkdata : TTLKFileHandler;
    l_labels : array [1..40] of string;
    l_entries : array [1..40] of DWORD;

    l_tlkfile : string;
    l_ssffile : string;
    l_tlkloaded : boolean;
    l_tlkmodified : boolean;
  public
    { Public declarations }
    procedure LoadFile(sFilename : string);
  end;

var
  Form1: TForm1;

implementation

uses UEntryForm;

{$R *.DFM}

function TForm1.ShowAlertBox(sMessage : string) : word;
begin
     result := MessageDlgPos(sMessage, mtWarning, [mbOK], 0, Left + 64, Top + 128);
end;

function TForm1.ShowInfoBox(sMessage : string) : word;
begin
     result := MessageDlgPos(sMessage, mtInformation, [mbOK], 0, Left + 64, Top + 128);
end;

function TForm1.ShowConfirmBox(sMessage : string) : word;
begin
     result := MessageDlgPos(sMessage, mtConfirmation, [mbYes, mbNo], 0, Left + 64, Top + 128);
end;

function TForm1.GetTlkString(iStrRef : DWORD) : TResEntry;
var
   tlkentry : TTLKString;
   sTemp    : string;
   rResult  : TResEntry;
begin
     if (tlkdata = nil) then begin
        rResult.text := 'ERROR';
        rResult.sound := 'ERROR';
        result := rResult;
        exit;
     end;

     tlkentry := tlkdata.strings.first();
     while ((tlkentry <> nil) and (tlkentry.strref <= (tlkdata.count-1))) do
     begin
          if (tlkentry.strref = iStrRef) then
          begin
               sTemp :=  ReplaceInString(tlkentry.strtext, #13, '');
               rResult.text := ReplaceInString(sTemp, #10, ' ');
               rResult.sound := tlkentry.strsound;
               result := rResult;
               exit;
          end;

          tlkentry := tlkdata.strings.next();
     end;

        rResult.text := 'NOT FOUND';
        rResult.sound := 'N/A';
        result := rResult;
end;

procedure TForm1.ResetGrid();
var
   i : integer;
begin
    gridSnd.cols[0].clear();
    gridSnd.cols[1].clear();
    gridSnd.cols[2].clear();
    gridSnd.cols[3].clear();
    gridSnd.rowcount := 41;
    gridSnd.colwidths[0] := 82;
    gridSnd.colwidths[1] := 64;
    gridSnd.colwidths[2] := 88;
    gridSnd.colwidths[3] := gridSnd.width - (gridSnd.colwidths[0] + gridSnd.colwidths[1] + gridSnd.colwidths[2] + 24);

    gridSnd.cells[0, 0] := 'Sound Type';
    gridSnd.cells[1, 0] := 'StrRef';
    gridSnd.cells[2, 0] := 'Sound (dialog.tlk)';
    gridSnd.cells[3, 0] := 'Text (dialog.tlk)';

    SetupLabels();

    for i:= 1 to 40 do begin
        gridSnd.cells[0, i] := l_labels[i];
    end;
end;

procedure TForm1.RefreshGrid();
var
   i : integer;
   rRes : TResEntry;
begin
    ResetGrid();

    for i := 1 to 40 do begin
        if (l_entries[i] = $FFFFFFFF) then begin
            gridSnd.cells[1, i] := '-1';
            gridSnd.cells[2, i] := 'None';
            gridSnd.cells[3, i] := 'None';
        end
        else begin
            rRes := GetTlkString(l_entries[i]);
            gridSnd.cells[1, i] := IntToStr(l_entries[i]);
            gridSnd.cells[2, i] := rRes.sound;
            gridSnd.cells[3, i] := rRes.text;
        end;
    end;
end;

procedure TForm1.SetupLabels();
begin
    l_labels[1] := 'Battlecry 1';
    l_labels[2] := 'Battlecry 2';
    l_labels[3] := 'Battlecry 3';
    l_labels[4] := 'Battlecry 4';
    l_labels[5] := 'Battlecry 5';
    l_labels[6] := 'Battlecry 6';
    l_labels[7] := 'Selected 1';
    l_labels[8] := 'Selected 2';
    l_labels[9] := 'Selected 3';
    l_labels[10] := 'Attack 1';
    l_labels[11] := 'Attack 2';
    l_labels[12] := 'Attack 3';
    l_labels[13] := 'Pain 1';
    l_labels[14] := 'Pain 2';
    l_labels[15] := 'Low health';
    l_labels[16] := 'Death';
    l_labels[17] := 'Critical hit';
    l_labels[18] := 'Target immune';
    l_labels[19] := 'Place mine';
    l_labels[20] := 'Disarm mine';
    l_labels[21] := 'Stealth on';
    l_labels[22] := 'Search';
    l_labels[23] := 'Pick lock start';
    l_labels[24] := 'Pick lock fail';
    l_labels[25] := 'Pick lock done';
    l_labels[26] := 'Leave party';
    l_labels[27] := 'Rejoin party';
    l_labels[28] := 'Poisoned';
    l_labels[29] := 'Unknown(29)';
    l_labels[30] := 'Unknown(30)';
    l_labels[31] := 'Unknown(31)';
    l_labels[32] := 'Unknown(32)';
    l_labels[33] := 'Unknown(33)';
    l_labels[34] := 'Unknown(34)';
    l_labels[35] := 'Unknown(35)';
    l_labels[36] := 'Unknown(36)';
    l_labels[37] := 'Unknown(37)';
    l_labels[38] := 'Unknown(38)';
    l_labels[39] := 'Unknown(39)';
    l_labels[40] := 'Unknown(40)';
end;

procedure TForm1.LoadFile(sFilename : string);
var
   inFile     : TFileStream;
   FileType   : T4Char;
   FileVersion: T4Char;
   StartOffset: DWORD;
   intBuff    : DWORD;
   i          : integer;
begin
     if not l_tlkloaded then begin
         dlgOpen.FileName := 'dialog.tlk';
         dlgOpen.DefaultExt := 'tlk';
         dlgOpen.Filter := 'TLK table file (*.tlk)|*.tlk';
         dlgOpen.Title := 'Please select your dialog.tlk file:';

         if dlgOpen.execute then begin
            l_tlkloaded := True;
            l_tlkmodified := False;
            l_tlkfile := dlgOpen.filename;
         end;
     end;

     if not l_tlkloaded then begin
        ShowAlertBox('No tlk file loaded! Aborting...');
        exit;
     end;

     if not SysUtils.FileExists(sFilename) then begin
        ShowAlertBox('No valid file specified to load! Aborting...');
        exit;
     end;

     for i := 1 to 40 do
         l_entries[i] := $FFFFFFFF;

     l_ssffile := sFilename;
     tlkdata.LoadTlkFile(l_tlkfile);
     try
         inFile := TFileStream.Create(l_ssffile, fmOpenRead or fmShareDenyWrite);
         try
            inFile.Read(FileType, sizeof(FileType));
            inFile.Read(FileVersion, sizeof(FileVersion));
            inFile.Read(StartOffset, sizeof(StartOffset));

            if (FileType <> 'SSF ') or (FileVersion <> 'V1.1') then begin
               ShowAlertBox('Meep! Selected file is not a valid SSF v1.1 file!');
               exit;
            end;

            inFile.Seek(StartOffset, soFromBeginning);

            for i := 1 to 40 do begin
                inFile.Read(intBuff, sizeof(intBuff));
                l_entries[i] := intBuff;
            end;

            RefreshGrid();
            edTLKfile.text := l_tlkfile;
            edSSFfile.text := l_ssffile;
            btnSave.enabled := True;
            gridSnd.enabled := True;

         finally
            inFile.free();
         end;
     except
         on e : Exception do ShowAlertBox('An error occured! ' + e.Message);
     end;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
   inFile     : TFileStream;
   FileType   : T4Char;
   FileVersion: T4Char;
   StartOffset: DWORD;
   intBuff    : DWORD;
   i          : integer;
begin
     if (l_ssffile <> '') and (ShowConfirmBox('Opening a new file will cause all unsaved changes to ' + ExtractFileName(l_ssffile) + ' to be lost. Continue to open a new file anyway?') <> mrYes) then
        exit;

     if not l_tlkloaded then begin
         dlgOpen.FileName := 'dialog.tlk';
         dlgOpen.DefaultExt := 'tlk';
         dlgOpen.Filter := 'TLK table file (*.tlk)|*.tlk';
         dlgOpen.Title := 'Please select your dialog.tlk file:';

         if dlgOpen.execute then begin
            l_tlkloaded := True;
            l_tlkmodified := False;
            l_tlkfile := dlgOpen.filename;
         end;
     end;

     if not l_tlkloaded then begin
        ShowAlertBox('No tlk file loaded! Aborting...');
        exit;
     end;

     dlgOpen.FileName := '';
     dlgOpen.DefaultExt := 'ssf';
     dlgOpen.Filter := 'Soundset file (*.ssf)|*.ssf';
     dlgOpen.Title := 'Please open a Soundset file to edit:';

     if not dlgOpen.execute then
         exit;

     for i := 1 to 40 do
         l_entries[i] := $FFFFFFFF;

     l_ssffile := dlgOpen.filename;
     tlkdata.LoadTlkFile(l_tlkfile);
     try
         inFile := TFileStream.Create(l_ssffile, fmOpenRead or fmShareDenyWrite);
         try
            inFile.Read(FileType, sizeof(FileType));
            inFile.Read(FileVersion, sizeof(FileVersion));
            inFile.Read(StartOffset, sizeof(StartOffset));

            if (FileType <> 'SSF ') or (FileVersion <> 'V1.1') then begin
               ShowAlertBox('Meep! Selected file is not a valid SSF v1.1 file!');
               exit;
            end;

            inFile.Seek(StartOffset, soFromBeginning);

            for i := 1 to 40 do begin
                inFile.Read(intBuff, sizeof(intBuff));
                l_entries[i] := intBuff;
            end;

            RefreshGrid();
            edTLKfile.text := l_tlkfile;
            edSSFfile.text := l_ssffile;
            btnSave.enabled := True;
            gridSnd.enabled := True;
            gridSnd.setfocus();

         finally
            inFile.free();
         end;
     except
         on e : Exception do ShowAlertBox('An error occured! ' + e.Message);
     end;
end;

procedure TForm1.edField1KeyPress(Sender: TObject; var Key: Char);
begin
    if not (Key in ['0'..'9']) then begin
        Key := #0;
        beep();
    end;
end;

// #3 is Copy, #8 is Backspace, #22 is Paste, #24 is Cut
procedure TForm1.edStrRefKeyPress(Sender: TObject; var Key: Char);
begin
    if not (Key in [^C, #8, ^V, ^X, ^Z, '0'..'9']) then begin
        Key := #0;
        beep();
    end;
end;

procedure TForm1.gridSndClick(Sender: TObject);
begin
     if not btnModify.enabled then
        btnModify.enabled := True;

     if not btnAddTlk.enabled then
        btnAddTlk.enabled := True;

     if not edStrRef.enabled then
        edStrRef.enabled := True;

     lblType.caption := gridSnd.cells[0, gridSnd.row] + ':';
     edStrRef.text := gridSnd.cells[1, gridSnd.row];
     lblText.caption := '[' + gridSnd.cells[2, gridSnd.row] + '] ' + gridSnd.cells[3, gridSnd.row];
end;

procedure TForm1.btnModifyClick(Sender: TObject);
var
   iSave : DWORD;
begin
     if (edStrRef.text = '') or (edStrRef.text = '-1') then
         iSave := $FFFFFFFF
     else
         iSave := StrToInt(edStrRef.text);

     l_entries[gridSnd.row] := iSave;
     RefreshGrid();
     lblType.caption := gridSnd.cells[0, gridSnd.row] + ':';
     edStrRef.text := gridSnd.cells[1, gridSnd.row];
     lblText.caption := '[' + gridSnd.cells[2, gridSnd.row] + '] ' + gridSnd.cells[3, gridSnd.row];
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     tlkdata := TTLKFileHandler.Create();
     l_tlkloaded := False;
     ResetGrid();
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     if (tlkdata <> nil) then
        tlkdata.free();
end;

procedure TForm1.btnSaveClick(Sender: TObject);
var
   outFile : TFileStream;
   intBuf  : DWORD;
   i       : integer;
begin
     try
         if l_tlkmodified and l_tlkloaded then begin
             dlgSave.FileName := ExtractFileName(l_tlkfile);
             dlgSave.Title := 'Please save your modified dialog.tlk file.';
             dlgSave.Filter := 'TLK table file (*.tlk)|*.tlk';
             dlgSave.DefaultExt := 'tlk';

             if not dlgSave.execute then
                exit;

             l_tlkfile := dlgSave.FileName;
             tlkdata.SaveTlkFile(l_tlkfile);
             l_tlkmodified := False;
             edTLKfile.text := l_tlkfile;
         end;

         dlgSave.FileName := ExtractFileName(l_ssffile);
         dlgSave.Title := 'Please save your modified Soundset file.';
         dlgSave.Filter := 'Soundset file (*.ssf)|*.ssf';
         dlgSave.DefaultExt := 'ssf';

         if dlgSave.Execute then begin
            l_ssffile := dlgSave.FileName;
            edSSFfile.text := l_ssffile;

            outFile := TFileStream.Create(dlgSave.FileName, fmCreate or fmShareDenyWrite);
            try
                outFile.write('SSF ', 4);
                outFile.write('V1.1', 4);

                intBuf := 12;
                outFile.write(intBuf, sizeof(intBuf));

                for i := 1 to 40 do begin
                    intBuf := l_entries[i];
                    outFile.write(intBuf, sizeof(intBuf));
                end;

                ShowInfoBox('Done saving modified data to ' + dlgSave.FileName + '!');
            finally
                outFile.free();
            end;
         end;
    except
        on e : Exception do ShowAlertBox('An error occured! ' + e.Message);
    end;
end;

procedure TForm1.btnNewClick(Sender: TObject);
var
   i : integer;
begin
     if (l_ssffile <> '') and (ShowConfirmBox('Creating a new file will cause all unsaved changes to ' + ExtractFileName(l_ssffile) + ' to be lost. Make a new file anyway?') <> mrYes) then
        exit;

     if not l_tlkloaded then begin
         dlgOpen.FileName := 'dialog.tlk';
         dlgOpen.DefaultExt := 'tlk';
         dlgOpen.Filter := 'TLK table file (*.tlk)|*.tlk';
         dlgOpen.Title := 'Please select your dialog.tlk file:';

         if dlgOpen.execute then begin
            l_tlkloaded := True;
            l_tlkmodified := False;
            l_tlkfile := dlgOpen.filename;
         end;
     end;

     if not l_tlkloaded then begin
        ShowAlertBox('No tlk file loaded! Aborting...');
        exit;
     end;

     try
         tlkdata.LoadTlkFile(l_tlkfile);

         if (tlkdata.fileexists) then begin
             l_ssffile := 'new.ssf';

             for i := 1 to 40 do
                 l_entries[i] := $FFFFFFFF;

             RefreshGrid();
             edTLKfile.text := l_tlkfile;
             edSSFfile.text := l_ssffile;
             btnSave.enabled := True;
             gridSnd.enabled := True;
             gridSnd.setfocus();
         end;
     except
         on e : Exception do ShowAlertBox('An error occured! ' + e.Message);
     end;

end;

procedure TForm1.btnAddTlkClick(Sender: TObject);
var
   tlkentry    : TTLKString;
   sResref     : TResRef;
   i           : integer;
   iSave       : integer;
   sTempString : string;
begin
     if not l_tlkloaded then
        exit;

     EntryForm.Reset();
     EntryForm.Reposition(Left + 32, Top + 64);
     EntryForm.Caption := 'Add entry to ' + l_tlkfile;
     EntryForm.entrycount := tlkdata.count;

     if (EntryForm.ShowModal <> mrOk) then
     	exit;

     try
         iSave := tlkdata.count;

         // Transform the Resref from a string into a TResRef so it can be stored.
         for i := 0 to 15 do begin
             if (Length(EntryForm.edResref.text) > i) then
                sResRef[i] := EntryForm.edResref.text[i+1]
             else
                 sResRef[i] := #0;
         end;

         // Create a new String Entry and store the info from the input boxes.
         tlkentry           := TTLKString.Create();
         tlkentry.strflags  := TEXT_PRESENT or SND_PRESENT or SNDLENGTH_PRESENT;
         tlkentry.sndvolume := 0;
         tlkentry.sndpitch  := 0;
         tlkentry.sndlength := 0;
         tlkentry.strsound  := sResRef;

         // Remove carriage returns from the text, since the Text property
         // returns both LF and CR for changing rows.
         sTempString := EntryForm.txtString.text;
         sTempString := ReplaceInString(sTempString, #13, '');
         tlkentry.strtext := sTempString;

         // Add the new entry to the list of entries...
         tlkdata.AddEntry(tlkentry);


         l_tlkmodified := True;
         l_entries[gridSnd.row] := iSave;
         RefreshGrid();

         edStrRef.text := IntToStr(iSave);
         edStrRef.text := IntToStr(iSave);
         lblType.caption := l_labels[gridSnd.row] + ':';
         lblText.caption := '[' + gridSnd.cells[2, gridSnd.row] + '] ' + gridSnd.cells[3, gridSnd.row];


     except
           on e : EHell do ShowAlertBox('ERROR! ' + e.Message);
     end;
end;

end.
