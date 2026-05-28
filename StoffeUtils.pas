unit StoffeUtils;   // Av Kristoffer - ia98kbe@student.hk-r.se
(*
 ______________________________________________________________________
 INNEHÅLLSFÖRTECKNING - ÅTERANVÄNDBARA GENERELLA FUNKTIONER (V3.0)

 SCRATCH THAT - Nåt är fuckat med denna filen, rensar bort allt fluff
 och behåller bara det som behövs för TLK readers i denna kopian.
 ______________________________________________________________________
 senast ändrad: 2005-05-11 *)
 
interface

function EgenPos( substr, str : string; startval : integer ) : integer;
function ReplaceInString( temp, dummy, newtext : string ) : string;

//procedure RestrictInput( var editbx : TEdit );
//procedure GiveFocus( var editbx : TEdit );

implementation

// -----------------------------------------------------------------------

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


// -----------------------------------------------------------------------
(*
procedure RestrictInput( var editbx : TEdit );
var
   i : integer;
   numstr : string;
begin
     numstr := editbx.text;
     for i := 1 to Length(numstr) do
         if not (numstr[i] in ['0'..'9', DecimalSeparator]) then
         begin
              numstr := copy(numstr, 1, i-1) + copy(numstr, i+1, Length(numstr) );
              editbx.text := numstr;
              editbx.selstart := i-1;
              Exit;
         end;
end;

// -----------------------------------------------------------------------

procedure GiveFocus( var editbx : TEdit );
begin
     editbx.setfocus;
     editbx.SelStart := 0;
     editbx.SelLength := Length(editbx.text);
end;
   *)
// -----------------------------------------------------------------------

function ReplaceInString( temp, dummy, newtext : string ) : string;
var
   iPos, lPos : integer;
begin
     lPos := 1;
     repeat
       iPos := EgenPos(dummy, temp, lPos);
       lPos := iPos;
       if iPos > 0 then
          temp := copy(temp, 1, iPos-1) + newtext +
                    copy(temp, iPos+Length(dummy), Length(temp)-(iPos-1+Length(dummy)))
     until iPos = 0;
     result := temp;
end;

// -----------------------------------------------------------------------



end.
