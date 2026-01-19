program Runme;

{$G+}

uses crt, gfx, pal, pcx;

var 
  Img : PCXImage;
  i: word;


begin

  LoadPCX('test.pcx', @Img);

  OpenGraphics;

  SetPalette(Img.palette);

  move(Img.data^, Mem[$A000:0], Img.width * Img.height);

  repeat until KeyPressed;

  CloseGraphics;
  freePCX(@Img);

end.
