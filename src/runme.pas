program Runme;

{$G+}

uses crt, gfx, pal, pcx;

var 
  Img : PCXImage;
  i: word;

procedure paintImage(DataPtr: Pointer; size: word); assembler;
asm
    push ds
    lds  si, DataPtr
    les  di, ScreenTarget
    mov  cx, size
    rep  movsb
    pop  ds
end;


begin

  LoadPCX('test.pcx', @Img);



  {move(Img.data^, Mem[$A000:0], Img.width * Img.height);}

  OpenGraphics;

  SetPalette(Img.palette);

  paintImage(Img.data, Img.size); 

  repeat until KeyPressed;

  CloseGraphics;
  freePCX(@Img);

end.
