program USSFEdit;

uses
  Forms,
  SysUtils,
  SSFEdit in 'SSFEdit.pas' {Form1},
  UTLKFile in 'UTLKFile.pas',
  UEntryForm in 'UEntryForm.pas' {EntryForm},
  USSFFile in 'USSFFile.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'SSFEditor';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TEntryForm, EntryForm);
  if (ParamCount() > 0) then begin
      if (SysUtils.FileExists(ParamStr(1))
          and (lowercase(copy(ParamStr(1), Length(ParamStr(1)) - 3, 4)) = '.ssf'))
      then begin
          Form1.LoadFile(ParamStr(1));
      end;
  end;
  // -------------------------------------------------------


  Application.Run;
end.
