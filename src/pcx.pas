unit PCX;

interface   

uses
  Dos, gfx, pal;

type 

    PByte = ^Byte;

    PCXImage = record
       width: word;
       height: word;
       data: PByte;
       palette: Palette;
    end;   

    PPCXImage = ^PCXImage;

    PCXHeader = record
      manufacturer : byte;
      version : byte;
      encoding : byte;
      bitsPerPixel : byte;
      xMin : word;
      yMin : word;
      xMax : word;
      yMax : word;
      horizontalRes : word;
      verticalRes : word;
      palette : array[0..47] of byte;
      reserved0 : byte;
      numberOfPlanes: byte;
      bytesPerLine : word;
      paletteType: word;
      horizontalSize : word;
      verticalSize : word;
      reserved1 : array[0..53] of byte;
    end;

procedure LoadPCX(filename: string; pcx: PPCXImage);  
procedure freePCX(pcx: PPCXImage);

implementation

procedure decode(input: PByte; encodedSize: word; output: PByte; decodedSize: word);
var 
  i, j, count : word;
  byteValue : byte;
  src, dest : PByte;
begin
  i:= 0;
  j:= 0;
  src := input;
  dest := output;
  while (i < encodedSize) do 
  begin
    byteValue := src^;
    inc(src);
    inc(i);
    if (byteValue and $C0) = $C0 then
    begin
      count := byteValue and $3F;
      byteValue := src^;
      inc(src);
      inc(i);
    end else 
    begin
      count := 1;
    end;
    while (count > 0) and (j < decodedSize) do
    begin
      dest^ := byteValue;
      inc(dest);
      inc(j);
      dec(count);
    end;

    if j > decodedSize then
    begin
      writeLn('Error: Decoded data exceeds allocated buffer size.', j);
      Exit;
    end;
  end;

end;

procedure LoadPCX(filename: string; pcx: PPCXImage);  
var 
    header : PCXHeader;
    f : File;
    bytevalue: byte;
    bytesRead : integer;
    
    totalFileSize: longint;
    headerSize: integer;
    paletteSize: integer;
    encodedSize: longint;
    decodedSize: word;

    encodedData: PByte;    
    decodedData: PByte;

    pall: Palette;
    i : integer;

begin

    Assign(f, filename);
    {$I-}
    reset(f, 1);
    {$I+}
    if IOResult <> 0 then
    begin
        writeln('Error: Could not open PCX file: ' + filename);
        Halt(1);
    end;

    { Read header }

    headerSize := SizeOf(PCXHeader);
    BlockRead(f, header, headerSize, bytesRead);
    if bytesRead <> headerSize then
    begin
        writeln('Error: Could not read PCX header from file: ' + filename);
        Close(f);
        Halt(1);        
    end;

    { Validate header }

    if (header.version <> 5) or 
        (header.manufacturer <> 10) or
        (header.encoding <> 1) or
        (header.bitsPerPixel <> 8) or
        (header.numberOfPlanes <> 1) then
    begin
        writeln('Unsupported PCX format');
        Close(f);
        Halt(1);
    end;

    { Calculate sizes }

    totalFileSize := FileSize(f);
    encodedSize := totalFileSize - headerSize;
    decodedSize := header.bytesPerLine * (header.yMax - header.yMin + 1) * header.numberOfPlanes;
    paletteSize := 768;

    { Allocate memory for encoded and decoded data }
    getMem(encodedData, encodedSize);
    getMem(decodedData, decodedSize);

    { Read encoded data }
    seek(f, headerSize);
    BlockRead(f, encodedData^, encodedSize, bytesRead);

    if bytesRead <> encodedSize then
    begin
        writeln('Error: Could not read PCX data from file: ' + filename);
        Close(f);
        Halt(1);
    end;

    { Read palette }
    if (header.version = 5) then 
    begin
        seek(f, totalFileSize - paletteSize - 1);
        BlockRead(f, byteValue, 1, bytesRead);
        if (byteValue = $0C) then
        begin
            BlockRead(f, pall, paletteSize, bytesRead);            
        end;

        for i:= 0 to 255 do
        begin
            pall[i].r := pall[i].r shr 2;
            pall[i].g := pall[i].g shr 2;
            pall[i].b := pall[i].b shr 2;
        end;  

    end;


    close(f);

    { Decode PCX data }
    decode(encodedData, encodedSize, decodedData, decodedSize);

    { Fill PCXImage record }
    pcx^.width := header.xMax - header.xMin + 1;
    pcx^.height := header.yMax - header.yMin + 1;
    pcx^.data := decodedData;
    pcx^.palette := pall;

    freeMem(encodedData, encodedSize);

end;

procedure freePCX(pcx: PPCXImage);
begin
    if pcx^.data <> nil then
    begin
        freeMem(pcx^.data, pcx^.width * pcx^.height);
        pcx^.data := nil;
        pcx^.width := 0;
        pcx^.height := 0;
    end;
end;


end.