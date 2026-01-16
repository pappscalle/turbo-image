
program Image;

{$G+}

uses
CRT, DOS, Graphics, Logger;

const 
  MaxImageSize = 65536;

type 
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






var 
  header : PCXHeader;
  PCXFile : File;
  pal : Palette;

  ImageData: ^byte;
  DecodedData: ^byte;

  bytevalue: byte;

  bytesRead : integer;

  totalFileSize: longint;
  headerSize: integer;
  paletteSize: integer;
  encodedSize: longint;
  decodedSize: word;

  x,y : integer;
  index: word;


procedure printHeaderInfo(header: PCXHeader);
begin
  writeLogInteger('Manufacturer: ' , header.manufacturer);
  writeLogInteger('Version: ', header.version);
  writeLogInteger('Encoding: ', header.encoding);
  writeLogInteger('Bits per pixel: ', header.bitsPerPixel);
  writeLogInteger('xMin: ', header.xMin);
  writeLogInteger('yMin: ', header.yMin);
  writeLogInteger('xMax: ', header.xMax);
  writeLogInteger('yMax: ', header.yMax);
  writeLogInteger('Horisontal resolution: ', header.horizontalRes);
  writeLogInteger('Vertical resolution: ', header.verticalRes);
  writeLogInteger('Number of planes: ', header.numberOfPlanes);
  writeLogInteger('Bytes per line: ', header.bytesPerLine);
  writeLogInteger('Palette type: ', header.paletteType);
  writeLogInteger('Horizontal size: ', header.horizontalSize);
  writeLogInteger('Vertical size: ', header.verticalSize);
end;

procedure decode(input: Pointer; encodedSize: word; output: Pointer; decodedSize: word);
var 
  i, j, count : longint;
  byteValue : byte;
  src, dest : ^byte;
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

    if j > DecodedSize then
    begin
      writeLogInteger('Error: Decoded data exceeds allocated buffer size.', j);
      Exit;
    end;
  end;

end;

procedure LoadPCX(filename : string);
begin
  Assign(PCXFile, filename);

    {$I-}
  Reset(PCXFile, 1);
    {$I+}

  if IOResult <> 0 then
    begin
      WriteLn('Error: File "', filename, '" does not exist or cannot be opened.'
      );
      Halt(1);
    end;

  headerSize := sizeof(header);


  BlockRead(PCXFile, header, headerSize, bytesRead);

  if (bytesRead <> headerSize) then
    begin
      writeln('Error reading PCX Header');
      Close(PCXFile);
      Halt(1);
    end;

  totalFileSize := fileSize(PCXFile);

  paletteSize := 768;
  encodedSize := totalFileSize - headerSize;
  decodedSize := ((header.xMax - header.xMin + 1) *
                 (header.yMax - header.yMin + 1) *
                 header.numberOfPlanes);

  if (bytesRead = headerSize) then
    begin
      printHeaderInfo(header);
      writeLog('---');
      writeLogInteger('File size: ', totalFileSize);
      writeLogInteger('Header size: ', headerSize);
      writeLogInteger('Palette size: ', paletteSize);
      writeLogInteger('Encoded image size: ', encodedSize);
      writeLogInteger('Decoded image size: ', decodedSize);
    end;


  Seek(PCXFile, 0);

  getMem(ImageData, encodedSize);
  getMem(DecodedData, decodedSize);

  seek(PCXFile, headerSize);
  BlockRead(PCXFile, ImageData^, totalFileSize - headerSize, bytesRead);

  if (header.version = 5) then
    begin
      seek(PCXFile, totalFileSize - paletteSize - 1);
      BlockRead(PCXFile, byteValue, 1, bytesRead);
      if (byteValue = $0C) then
        begin
          BlockRead(PCXFile, pal, 768, bytesRead);
        end;
    end;

  close(PCXFile);

  writeLog('Start decoding PCX');
  decode(ImageData,encodedSize,  DecodedData, decodedSize);
  writeLog('PCX decoded');

end;



begin


  LoadPCX('data\dredd.pcx');

  
    SetMCGA;
for index:= 0 to 255 do
begin
  pal[index].r := pal[index].r shr 2;
  pal[index].g := pal[index].g shr 2;
  pal[index].b := pal[index].b shr 2;
end;


SetPalette(pal);
  Index := 0;
  for y := 0 to 199 do
  begin
    for x := 0 to 319 do
    begin
      SetPixel(x, y, Byte(Pointer(LongInt(DecodedData) + Index)^));
      Inc(Index);
    end;
  end;
  repeat until keypressed;
    SetTextMode;

end.