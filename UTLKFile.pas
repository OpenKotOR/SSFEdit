unit UTLKFile;

interface

uses SysUtils, Windows, Classes;

// STRING FLAG CONSTANTS
const TEXT_PRESENT      = $0001;
const SND_PRESENT       = $0002;
const SNDLENGTH_PRESENT = $0004;

type
// CUSTOM TYPE DEFINITIONS
float   = single;
TResRef = array[0..15] of Char;
T4Char  = array[0..3] of Char;

// EXCEPTION FOR PASSING ERROR MESSAGES
EHell = Class(Exception);

// TTLKString ==================================================================
TTLKString = Class(TObject)
     private
            Flags          : dword;
            SoundResref    : TResRef;
            VolumeVariance : dword;
            PitchVariance  : dword;
            OffsetToString : dword;
            StringSize     : dword;
            SoundLength    : float;

            StringStrRef   : dword;
            StringEntry    : string;
            CustomEntry    : boolean;
     public
           function GetFlags() : dword;
           procedure SetFlags(nFlags : dword);

           function GetSound() : TResRef;
           procedure SetSound(resref : TResRef);

           function GetVolume() : dword;
           procedure SetVolume(nVolume : dword);

           function GetPitch() : dword;
           procedure SetPitch(nPitch : dword);

           function GetOffset() : dword;
           procedure SetOffset(nOffset : dword);

           function GetSize() : dword;
           procedure SetSize(nSize : dword);

           function GetSndLength() : float;
           procedure SetSndLength(fLength : float);

           function GetText() : string;
           procedure SetText(sText : string);

           function GetStrRef() : dword;
           procedure SetStrRef(iStrRef : dword);

           function GetCustom() : boolean;
           procedure SetCustom(bCustom : boolean);

           procedure Clone(oClone : TTLKString);

           constructor Create(); overload;
           constructor Create(oClone : TTLKString); overload;
           destructor Destroy(); override;

           property strflags      : dword      read GetFlags     write SetFlags;
           property strsound      : TResRef    read GetSound     write SetSound;
           property sndvolume     : dword      read GetVolume    write SetVolume;
           property sndpitch      : dword      read GetPitch     write SetPitch;
           property stroffset     : dword      read GetOffset    write SetOffset;
           property strsize       : dword      read GetSize      write SetSize;
           property sndlength     : float      read GetSndLength write SetSndLength;
           property strtext       : string     read GetText      write SetText;
           property strref        : dword      read GetStrRef    write SetStrRef;
           property iscustom      : boolean    read GetCustom    write SetCustom;
end;

// TStringData =================================================================
TStringData = Class(TObject)
     private
            next : TStringData;
            prev : TStringData;
            data : TTLKString;
     public
           function GetData() : TTLKString;
           procedure SetData(oData : TTLKString);

           function GetNext() : TStringData;
           procedure SetNext(oData : TStringData);

           function GetPrev() : TStringData;
           procedure SetPrev(oData : TStringData);

           constructor Create();
           destructor Destroy(); override;

           property stringdata : TTLKString read GetData write SetData;
           property listnext : TStringData read GetNext write SetNext;
           property listprev : TStringData read GetPrev write SetPrev;           
end;

// TStringDataList =============================================================
TStringDataList = Class(TObject)
     private
            p_oFirst            : TStringData;
            p_oLast             : TStringData;
            p_oCurrent          : TStringData;
            p_iCount            : integer;
     public
           function first() : TTLKString;
           function next() : TTLKString;
           function isempty(): boolean;
           function eol(): boolean;

           procedure Insert(oData : TTLKString);
           procedure Delete(bDelete : boolean = false);

           constructor Create;
           destructor Destroy; override;         

end;

// TTLKFileHandler ============================================================
TTLKFileHandler = Class(TObject)
     private
            // Header information
            FileType : T4Char;
            FileVersion : T4Char;
            LanguageId : dword;
            StringCount : dword;
            StringEntriesOffset : dword;

            // The string entries
            StringList : TStringDataList;

            // Keep track of if data has been written properly.
            bDirty : boolean;
            bFileOpen : boolean;
     public
           property strings     : TStringDataList read StringList;
           property count       : dword           read StringCount;
           property fileid      : T4Char          read FileType;
           property version     : T4Char          read FileVersion;
           property fileexists  : boolean         read bFileOpen;
           property language    : dword           read LanguageId  write LanguageId;

           procedure AddEntry(oEntry : TTLKString);
           procedure ReplaceEntry(oEntry : TTLKString);
           procedure NewTlkFile();
           procedure LoadTlkFile(sFilename : string);
           procedure SaveTlkFile(sFilename : string);
           procedure Reset();

           constructor Create(); overload;
           constructor Create(sFilename : string); overload;
           destructor Destroy(); override;
end;


implementation

procedure MakeFileWritable(sFilename : string);
var  nFlags  : Word;begin     if (SysUtils.FileExists(sFilename)) then begin        nFlags := FileGetAttr(sFilename);        if ((nFlags and faReadOnly) = faReadOnly) then begin           nFlags := nFlags and not faReadOnly;           FileSetAttr(sFilename, nFlags);        end;     end;end;
// TSTRINGDATA =================================================================
// Class defining an individual node in the String Entry linked list.
// Keeps track of the previous and next nodes in the list in relation to it.
// =============================================================================

// -----------------------------------------------------------------------------
// Constructor - create a new node for the string data list.
// -----------------------------------------------------------------------------
constructor TStringData.Create();
begin
     inherited Create;
end;


// -----------------------------------------------------------------------------
// Destructor - Destroy this node.
// -----------------------------------------------------------------------------
destructor TStringData.Destroy();
begin
     inherited Destroy;
     // ST: Remember - don't destroy the data here. Just because you want to
     // remove it from the list doesn't mean you no longer want the data.
end;


// -----------------------------------------------------------------------------
// Data control function - store data in this node.
// -----------------------------------------------------------------------------
procedure TStringData.SetData(oData : TTLKString);
begin
     data := oData;
end;


// -----------------------------------------------------------------------------
// Data control function - get the data stored in this node.
// -----------------------------------------------------------------------------
function TStringData.GetData() : TTLKString;
begin
     Result := data;
end;


// -----------------------------------------------------------------------------
// Data control function - return the next node in the linked list related
// to this node.
// -----------------------------------------------------------------------------
function TStringData.GetNext() : TStringData;
begin
     result := next;
end;


// -----------------------------------------------------------------------------
// Data control function - Set the next node in the linked list related to
// this node.
// -----------------------------------------------------------------------------
procedure TStringData.SetNext(oData : TStringData);
begin
     next := oData;
end;


// -----------------------------------------------------------------------------
// Data control function - return the previous node in the linked list related
// to this node.
// -----------------------------------------------------------------------------
function TStringData.GetPrev() : TStringData;
begin
     result := prev;
end;


// -----------------------------------------------------------------------------
// Data control function - Set the previous node in the linked list related to
// this node.
// -----------------------------------------------------------------------------
procedure TStringData.SetPrev(oData : TStringData);
begin
     prev := oData;
end;

// TSTRINGDATALIST =============================================================
// Linked list containing all of the string entries from the dialog.tlk file.
// =============================================================================

// -----------------------------------------------------------------------------
// Constructor - initialize a new linked list.
// -----------------------------------------------------------------------------
constructor TStringDataList.Create();
begin
     inherited Create;
     p_iCount := 0;
     p_oFirst := nil;
end;


// -----------------------------------------------------------------------------
// Destructor - Destroy the list and all content kept within it.
// -----------------------------------------------------------------------------
destructor TStringDataList.Destroy();
var
   oTmp : TStringData;
   oTmpData : TTLKString;
begin
     // Destroy all nodes in the linked list before destroying the
     // list object itself.
     p_oCurrent := p_oFirst;
     while (p_oCurrent <> nil) do
     begin
          oTmp := p_oCurrent;
          oTmpData := p_oCurrent.stringdata;
          p_oCurrent := p_oCurrent.listnext;
          oTmpData.free();
          oTmp.free();
          p_iCount := p_iCount - 1; // TODO: Throw exception if this ends up
                                    //     bigger than 0 at the end of the loop?
     end;
     
     inherited Destroy;
end;


// -----------------------------------------------------------------------------
// Move the list pointer to the first position and return the object stored
// there, if any.
// -----------------------------------------------------------------------------
function TStringDataList.first() : TTLKString;
begin
     p_oCurrent := p_oFirst;

     if (p_oFirst <> nil) then
          result := p_oCurrent.stringdata
     else
         result := nil;
end;


// -----------------------------------------------------------------------------
// Move the list pointer to the next position and return the object stored
// there, if any.
// -----------------------------------------------------------------------------
function TStringDataList.next() : TTLKString;
begin
     if ((p_oCurrent <> p_oLast) and (p_oCurrent.listnext <> nil)) then
     begin
        p_oCurrent := p_oCurrent.listnext;
        result := p_oCurrent.stringdata;
     end
     else
         result := nil;
end;


// -----------------------------------------------------------------------------
// Returns TRUE if the list is empty and FALSE if it is not.
// -----------------------------------------------------------------------------
function TStringDataList.isempty(): boolean;
begin
     if (p_oFirst = nil) then
       result := true
     else
         result := false;
end;


// -----------------------------------------------------------------------------
// Returns TRUE if the list pointer has reached the end of the list.
// -----------------------------------------------------------------------------
function TStringDataList.eol(): boolean;
begin
     if (p_oCurrent = nil) then
       result := true
     else
         result := false;
end;


// -----------------------------------------------------------------------------
// Inserts a new entry at the end of the linked list.
// -----------------------------------------------------------------------------
procedure TStringDataList.Insert(oData : TTLKString);
var
   oTmp : TStringData;
begin
     oTmp := TStringData.Create();
     oTmp.stringdata := oData;

     // ST: List is empty, insert at first position
     if (p_oFirst = nil) then
     begin
          p_oFirst := oTmp;
          p_oFirst.listnext := nil;
          p_oFirst.listprev := nil;
          p_oCurrent := p_oFirst;
          p_oLast := p_oFirst;
     end
     else
     begin
          // ST: Insert at the end of the list...
          p_oLast.listnext := oTmp;
          oTmp.listnext := nil;
          oTmp.listprev := p_oLast;
          p_oLast := oTmp;
          p_oCurrent := p_oLast;
     end;
     p_iCount := p_iCount + 1;

end;

// -----------------------------------------------------------------------------
// Delete an entry from the linked list. Be VERY cautious about using this since
// Dialog TLK is indexed by position. Removing one entry that's not at the end
// of the list will mess up the indexing for all following entries.
// The list pointer will be set to the next entry in the list following the
// currently deleted one.
// -----------------------------------------------------------------------------
procedure TStringDataList.Delete(bDelete : boolean);
var
   oPrev : TStringData;
   oNext : TStringData;
   oData : TTLKString;
begin
     oPrev := p_oCurrent.listprev;
     oNext := p_oCurrent.listnext;

     oNext.listprev := oPrev;
     oPrev.listnext := oNext;

     if (bDelete) then
     begin
          oData := p_oCurrent.stringdata;
          oData.free();
     end;
     p_oCurrent.free();
     p_oCurrent := oNext;
end;

// TTLKSTRING ==================================================================
// A data holding class that stores the data belonging to a dialog.tlk entry.
// =============================================================================

// -----------------------------------------------------------------------------
// Standard constructor, create a new talkstring object.
// -----------------------------------------------------------------------------
constructor TTLKString.Create();
begin
     inherited Create;
end;


// -----------------------------------------------------------------------------
// Copy Constructor - create a copy of an existing talkstring object.
// -----------------------------------------------------------------------------
constructor TTLKString.Create(oClone : TTLKString);
begin
     inherited Create();

     Flags            := oClone.strflags;
     SoundResref      := oClone.strsound;
     VolumeVariance   := oClone.sndvolume;
     PitchVariance    := oClone.sndpitch;
     OffsetToString   := oClone.stroffset;
     StringSize       := oClone.strsize;
     SoundLength      := oClone.sndlength;

     StringStrRef     := oClone.strref;
     StringEntry      := oClone.strtext;
     CustomEntry      := oClone.iscustom;
end;


// -----------------------------------------------------------------------------
// Destructor - destroy this talkstring object.
// -----------------------------------------------------------------------------
destructor TTLKString.Destroy();
begin
     inherited Destroy();
end;

// -----------------------------------------------------------------------------
// Make this object hold data identical to that of the specified object.
// -----------------------------------------------------------------------------
procedure TTLKString.Clone(oClone : TTLKString);
begin
     Flags            := oClone.strflags;
     SoundResref      := oClone.strsound;
     VolumeVariance   := oClone.sndvolume;
     PitchVariance    := oClone.sndpitch;
     OffsetToString   := oClone.stroffset;
     StringSize       := oClone.strsize;
     SoundLength      := oClone.sndlength;

     StringStrRef     := oClone.strref;
     StringEntry      := oClone.strtext;
     CustomEntry      := oClone.iscustom;
end;


// -----------------------------------------------------------------------------
// Get any bitfield flags set for this string, use bit-and with above constants
// to check if a specific flag is set..
// -----------------------------------------------------------------------------
function TTLKString.GetFlags() : dword;
begin
     result := Flags;
end;


// -----------------------------------------------------------------------------
// Set bitfield flags for this string, use bit-or to set multiple flags.
// -----------------------------------------------------------------------------
procedure TTLKString.SetFlags(nFlags : dword);
begin
     Flags := nFlags;
end;


// -----------------------------------------------------------------------------
// Get the StrRef for the sound associated with this string, if any.
// -----------------------------------------------------------------------------
function TTLKString.GetSound() : TResRef;
begin
     result := SoundResref;
end;


// -----------------------------------------------------------------------------
// Set the StrRef of the sound associated with this string.
// -----------------------------------------------------------------------------
procedure TTLKString.SetSound(resref : TResRef);
begin
     SoundResref := resref;
end;


// -----------------------------------------------------------------------------
// Get the volume variance for the sound associated with this string.
// -----------------------------------------------------------------------------
function TTLKString.GetVolume() : dword;
begin
     result := VolumeVariance;
end;


// -----------------------------------------------------------------------------
// Set the volume variance for the sound associated with this string.
// -----------------------------------------------------------------------------
procedure TTLKString.SetVolume(nVolume : dword);
begin
     VolumeVariance := nVolume;
end;


// -----------------------------------------------------------------------------
// Get the sound pitch variance for the sound associated with this string.
// -----------------------------------------------------------------------------
function TTLKString.GetPitch() : dword;
begin
     result := PitchVariance;
end;


// -----------------------------------------------------------------------------
// Set the sound pitch variance for the sound associated with this string.
// -----------------------------------------------------------------------------
procedure TTLKString.SetPitch(nPitch : dword);
begin
     PitchVariance := nPitch;
end;


// -----------------------------------------------------------------------------
// Get the offset for the string within the current dialog.tlk file.
// Don't write this when rebuilding a tlk file, it's only used for reading.
// -----------------------------------------------------------------------------
function TTLKString.GetOffset() : dword;
begin
     result := OffsetToString;
end;


// -----------------------------------------------------------------------------
// Set the offset for the string within the current dialog.tlk file.
// -----------------------------------------------------------------------------
procedure TTLKString.SetOffset(nOffset : dword);
begin
     OffsetToString := nOffset;
end;


// -----------------------------------------------------------------------------
// Get the length of the current string, to be read from the offset. This is
// only used for reading dialog.tlk, it's probably better to re-calculate string
// length from what we have when writing.
// -----------------------------------------------------------------------------
function TTLKString.GetSize() : dword;
begin
    result := StringSize;
end;


// -----------------------------------------------------------------------------
// Get the size of the string in dialog.tlk. Used with offset for reading in
// data from an existing dialog.tlk file.
// -----------------------------------------------------------------------------
procedure TTLKString.SetSize(nSize : dword);
begin
     StringSize := nSize;
end;


// -----------------------------------------------------------------------------
// Get the duration of the sound associated with this string.
// -----------------------------------------------------------------------------
function TTLKString.GetSndLength() : float;
begin
     result := SoundLength;
end;


// -----------------------------------------------------------------------------
// Set the duration of the sound associated with this string.
// -----------------------------------------------------------------------------
procedure TTLKString.SetSndLength(fLength : float);
begin
     SoundLength := fLength;
end;


// -----------------------------------------------------------------------------
// Get the text string for this entry.
// -----------------------------------------------------------------------------
function TTLKString.GetText() : string;
begin
     result := StringEntry;
end;


// -----------------------------------------------------------------------------
// Set the text string for this entry.
// -----------------------------------------------------------------------------
procedure TTLKString.SetText(sText : string);
begin
     // IMPORTANT!!!! MAKE SURE THAT THE LENGTH OF THE NEW STRING IS SET WITH
     //               THE SETSIZE PROPERTY AS WELL WHEN THIS IS MODIFIED
     //               MANUALLY! CAN'T DO IT HERE SINCE IT'D OVERRIDE THE VALUE
     //               READ FROM FILE WHEN LOADING A TLK FILE!
     StringEntry := sText;
     // StringSize := length(StringEntry);
end;


// -----------------------------------------------------------------------------
// Get the Dialog.tlk index for this particular string.
// -----------------------------------------------------------------------------
function TTLKString.GetStrRef() : dword;
begin
     result := StringStrRef;
end;


// -----------------------------------------------------------------------------
// Store the Dialog.tlk index for this particular string.
// -----------------------------------------------------------------------------
procedure TTLKString.SetStrRef(iStrRef : dword);
begin
     StringStrRef := iStrRef;
end;


// -----------------------------------------------------------------------------
// Get the status of the Custom flag. This is set for entries that have not been
// read from dialog.tlk but added by this program. This should not be written.
// -----------------------------------------------------------------------------
function TTLKString.GetCustom() : boolean;
begin
     result := CustomEntry;
end;


// -----------------------------------------------------------------------------
// Set the custom flag for this entry. This should be set for new entries that
// have not been read from a dialog.tlk file.
// -----------------------------------------------------------------------------
procedure TTLKString.SetCustom(bCustom : boolean);
begin
     CustomEntry := bCustom;
end;


// TTLKFILEHANDLER =============================================================
// Class that handles reading in data from a dialog.tlk file and writing out
// data to a new dialog.tlk file.
// =============================================================================

// -----------------------------------------------------------------------------
// Standard constructor, create a new TLK file handler.
// -----------------------------------------------------------------------------
constructor TTLKFileHandler.Create();
begin
     inherited Create();
     Reset();
end;


// -----------------------------------------------------------------------------
// Shortcut constructor, create a new TLK file handler and load the TLK file
// specified as a parameter.
// -----------------------------------------------------------------------------
constructor TTLKFileHandler.Create(sFilename : string);
begin
     inherited Create();
     Reset();
     LoadTlkFile(sFileName);
end;


// -----------------------------------------------------------------------------
// Destructor, destroy the TLK file handler.
// -----------------------------------------------------------------------------
destructor TTLKFileHandler.Destroy();
begin
     StringList.free();
     inherited Destroy();
end;


// -----------------------------------------------------------------------------
//
// -----------------------------------------------------------------------------
procedure TTLKFileHandler.AddEntry(oEntry : TTLKString);
begin
     if (bFileOpen = False) then
        raise EHell.Create('Unable to add new entry. No TLK file is open!');

     // ADD a new entry AT THE END of the TLK data...
     // CHECK THIS CAREFULLY IF LENGTH() CAN BE USED TO GET THE PROPER LENGTH
     // OF THE STRING THAT IS NEEDED FOR STRINGSIZE.
     oEntry.strsize := Length(oEntry.strtext);
     oEntry.iscustom := True;
     oEntry.strref := StringCount;
     StringList.Insert(oEntry);
     StringCount := StringCount + 1;
end;


// -----------------------------------------------------------------------------
// REPLACE the entry with the specified STRREF with the provided entry.
// Just a wrapper setting some fields in the entry...
// -----------------------------------------------------------------------------
procedure TTLKFileHandler.ReplaceEntry(oEntry : TTLKString);
begin
     if (bFileOpen = False) then
        raise EHell.Create('Unable to modify entry. No TLK file is currently open!');

     oEntry.iscustom := true;
     oEntry.strsize := Length(oEntry.strtext);
end;


// -----------------------------------------------------------------------------
// Initialize the handler as if a blank TLK file has been loaded.
// -----------------------------------------------------------------------------
procedure TTLKFileHandler.NewTlkFile();
begin
     Reset();
     bFileOpen := True;

     FileType := 'TLK ';
     FileVersion := 'V3.0';
end;


// -----------------------------------------------------------------------------
// [?] Load the TLK file specified by the parameter.
// -----------------------------------------------------------------------------
procedure TTLKFileHandler.LoadTlkFile(sFilename : string);
var
   inFile     : TFileStream;
   oData      : TTLKString;
   iCount     : integer;
   iIdx       : integer;
   nTemp      : dword;
   tmpfloat   : float;
   tmpResref  : TResRef;
   stringBuf  : array[0..4095] of Char;
   nOffset    : dword;
begin
     Reset();

     inFile := TFileStream.Create(sFilename, fmOpenRead or fmShareDenyWrite);
     try
        // Read in file header information...
        inFile.Read(FileType, sizeof(FileType));
        inFile.Read(FileVersion, sizeof(FileVersion));

        if not (FileType = 'TLK ') then
           raise EHell.Create('Type mismatch. Specified file is not a valid TLK file!');

        if  not (FileVersion = 'V3.0') then
           raise EHell.Create('Version mismatch. File is not a valid v3.0 TLK file!');

        // Read the rest of the TLK header info...
        inFile.Read(LanguageId, sizeof(LanguageId));
        inFile.Read(StringCount, sizeof(StringCount));
        inFile.Read(StringEntriesOffset, sizeof(StringEntriesOffset));

        if (StringCount < 1) then
           raise EHell.Create('No entries found in the specified TLK file!');

        // Read in all the entries in the String Data Table...
        for iCount := 0 to (StringCount-1) do
        begin
             if (longword(inFile.Position) >= StringEntriesOffset) then
                raise EHell.Create('Error reading string data table. Overflow into entry data table!');

             // Read a string data entry and store in an object...
             oData := TTLKString.Create();
             inFile.Read(nTemp, sizeof(nTemp));
             oData.strflags := nTemp;

             inFile.Read(tmpResref, sizeof(tmpResref));
             oData.strsound := tmpResref;

             inFile.Read(nTemp, sizeof(nTemp));
             oData.sndvolume := nTemp;

             inFile.Read(nTemp, sizeof(nTemp));
             oData.sndpitch := nTemp;

             inFile.Read(nTemp, sizeof(nTemp));
             oData.stroffset := nTemp;

             inFile.Read(nTemp, sizeof(nTemp));
             oData.strsize := nTemp;

             inFile.Read(tmpfloat, sizeof(tmpfloat));
             oData.sndlength := tmpfloat;

             oData.strref := iCount;

             // Clear the buffer of any leftover characters....
             for iIdx := 0 to 4095 do
                 stringBuf[iIdx] := #0;

             // Read the text string from the entry table...
             nOffset := longword(inFile.Position);
             inFile.Seek(StringEntriesOffset + oData.stroffset, soFromBeginning);
             inFile.Read(stringBuf, oData.strsize);
             oData.strtext := stringBuf;
             inFile.Seek(nOffset, soFromBeginning);

             StringList.Insert(oData);
        end;

        bFileOpen := True;

     finally
        inFile.free();
     end;
end;

// -----------------------------------------------------------------------------
// [?] Save a new TLK file with the name and path specified by the parameter.
// -----------------------------------------------------------------------------
procedure TTLKFileHandler.SaveTlkFile(sFilename : string);
var
   stringBuf      : array[0..4095] of Char;
   outFile        : TFileStream;
   oData          : TTLKString;
   iOffsetEntry   : dword;
   iTmpOffset     : dword;
   iCount         : integer;
   iIdx           : integer;
   nTmpInt        : dword;
   sTmpResRef     : TResRef;
   fTmpFloat      : float;
   sTmpString     : AnsiString;
   iSize          : longint;
begin
     if (bFileOpen = False) then
        raise EHell.Create('There is no open file to save!');

     // Remove the ReadOnly flag if the file already exists, before writing.
     if SysUtils.FileExists(sFileName) then
        MakeFileWritable(sFilename);

     outFile := TFileStream.Create(sFilename, fmCreate or fmShareDenyWrite);
     try
        if not (FileType = 'TLK ') then
           raise EHell.Create('There is no valid TLK file currently open to save!');

        if (StringList.isempty) then
           raise EHell.Create('There is no current data in the TLK file to write!');

        // Mark that we've begun to write data...
        bDirty := True;

        // Write file header - file format: TLK
        outFile.write(FileType, sizeof(FileType));

        // Write file header - file format version: 3.0
        outFile.write(FileVersion, sizeof(FileVersion));

        // Write the LanguageId of the TLK.
        outFile.write(LanguageId, sizeof(LanguageId));

        // Write the number of string entries in the TLK.
        outFile.write(StringCount, sizeof(StringCount));

        // Make room for the StringEntryTable offset. It'll get its value
        // set below when it is known.
        iOffsetEntry := longword(outFile.Position);
        outFile.write(StringEntriesOffset, sizeof(StringEntriesOffset));

        // Write the String Data Table...
        oData := StringList.First();
        for iCount := 0 to (StringCount-1) do
        begin
             // Write the Flags value
             nTmpInt := oData.strflags;
             outFile.Write(nTmpInt, sizeof(nTmpInt));

             // Write the sound ResRef
             sTmpResRef := oData.strsound;
             outFile.Write(sTmpResRef, sizeof(sTmpResRef));

             // Write the SoundVariance value
             nTmpInt := oData.sndvolume;
             outFile.Write(nTmpInt, sizeof(nTmpInt));

             // Write the PitchVariance value
             nTmpInt := oData.sndpitch;
             outFile.Write(nTmpInt, sizeof(nTmpInt));

             // Allocate space for the OffsetToString value
             // Re-use the offset value to temporarily store the offset
             // of the offset that need to be adjusted later. :)
             oData.stroffset := longword(outFile.Position);
             nTmpInt := 0;
             outFile.Write(nTmpInt, sizeof(nTmpInt));

             // Write the StringSize (length) value
             nTmpInt := oData.strsize;
             outFile.Write(nTmpInt, sizeof(nTmpInt));

             // Write the SoundLength (duration) value.
             fTmpFloat := oData.sndlength;
             outFile.Write(fTmpFloat, sizeof(fTmpFloat));

             // Move on to the next entry...
             oData := StringList.Next();
        end;

        // Update the header with the offset where the Entry Table starts...
        iTmpOffset := longword(outFile.Position);
        outFile.seek(iOffsetEntry, soFromBeginning);
        StringEntriesOffset := iTmpOffset;
        outFile.write(StringEntriesOffset, sizeof(StringEntriesOffset));
        outFile.seek(iTmpOffset, soFromBeginning);

        // Write the String Entry Table
        oData := StringList.First();
        for iCount := 0 to (StringCount-1) do
        begin
             // Update the offset in the String Data Table for this entry...
             iTmpOffset := longword(outFile.Position);
             outFile.seek(oData.stroffset, soFromBeginning);
             iOffsetEntry := (iTmpOffset - StringEntriesOffset);
             // Apparently there should be no offset if there's no string...
             if (oData.strsize < 1) then
                iOffsetEntry := 0;
             outFile.write(iOffsetEntry, sizeof(iOffsetEntry));
             outFile.seek(iTmpOffset, soFromBeginning);

             // Clear the buffer of any leftover characters....
             for iIdx := 0 to 4095 do
                 stringBuf[iIdx] := #0;

             // Fetch the string that should be written to the Entry Table.
             sTmpString := oData.strtext;

             // First make sure we're not exceeding the sting buffer size...
             iSize := Length(sTmpString);
             if (iSize > 4096) then
                iSize := 4096;

             // Write the string itself into the String Entry Table...
             for iIdx := 1 to iSize do
                  stringBuf[iIdx - 1] := sTmpString[iIdx];

             outFile.write(stringBuf, oData.strsize);

             // Move on to next entry to write...
             oData := StringList.Next();
        end;

        // Mark that all data (hopefully) has been written successfully.
        bDirty := False;
     finally
            outFile.free();
     end;
end;

// -----------------------------------------------------------------------------
// Reset all data stored within this object, readying it for reading a TLK file.
// -----------------------------------------------------------------------------
procedure TTLKFileHandler.Reset();
var
   i : integer;
begin
     for i := 0 to 3 do
         FileType[i] := #0;

     for i := 0 to 3 do
         FileVersion := #0;

     LanguageId := 0;
     StringCount := 0;
     StringEntriesOffset := 0;

     StringList.free();
     StringList := TStringDataList.Create();
     
     bDirty := False;
     bFileOpen := False;
end;

end.
 