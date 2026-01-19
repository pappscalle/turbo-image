(*
  gfx.pas

  Graphics routines for Mode 13h (320x200x256 colors)
*)
unit Gfx;

{$G+}

interface

uses Dos;

const
  SCREEN = $A000;
  SCREEN_WIDTH = 320;
  SCREEN_HEIGHT = 200;
  SCREEN_SIZE = SCREEN_WIDTH * SCREEN_HEIGHT;

var 
  ScreenTarget: Pointer;  

procedure SetScreenTarget(prt: Pointer); 
procedure UseHardwareScreen;
procedure OpenGraphics;
procedure CloseGraphics;
procedure SetPixel(x, y: integer; color: byte);
procedure ClearScreen(color : byte);
procedure WaitRetrace;

implementation

procedure SetScreenTarget(prt: Pointer);
begin
  ScreenTarget := prt;
end;

procedure UseHardwareScreen;
begin
  ScreenTarget := Ptr(SCREEN, 0);
end;

procedure SetVideoMode(mode: word); Assembler;
asm
  mov   ax, mode
  int   10h
end;

procedure OpenGraphics;
begin
  SetVideoMode($13);
  UseHardwareScreen;
end;

procedure CloseGraphics;
begin
  SetVideoMode($03);
end;

procedure SetPixel(x, y: integer; color: byte); assembler;
asm
  les   di, ScreenTarget
  mov   ax, y
  mov   dx, ax
  shl   ax, 2
  add   ax, dx
  shl   ax, 6
  add   ax, x
  add   di, ax
  mov   al, color
  stosb
end;

procedure ClearScreen(color : byte); assembler;
asm
  les   di, ScreenTarget
  mov   al, color
  mov   ah, al
  mov   cx, SCREEN_SIZE / 2
  rep   stosw
end;

procedure WaitRetrace; assembler;
asm
  mov   dx,3DAh
 @l1:
  in    al,dx
  and   al,08h
  jnz   @l1
 @l2:
  in    al,dx
  and   al,08h
  jz    @l2
end;

end.