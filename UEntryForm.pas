unit UEntryForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TEntryForm = class(TForm)
    boxText: TGroupBox;
    txtString: TMemo;
    boxResref: TGroupBox;
    edResref: TEdit;
    btnSave: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    entrycount : DWORD;

    procedure Reposition(x, y : word);
    procedure Reset();
  end;

var
  EntryForm: TEntryForm;

implementation

{$R *.DFM}

procedure TEntryForm.Reset();
begin
     txtString.clear();
     edResref.text := '';
end;

procedure TEntryForm.Reposition(x, y : word);
begin
     Top := y;
     Left := x;
end;

procedure TEntryForm.FormShow(Sender: TObject);
begin
     boxText.caption := ' Entry Text (' + IntToStr(entrycount) + ') ';
     txtString.setfocus;
end;


end.
