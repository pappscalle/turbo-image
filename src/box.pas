unit Box;

{$G+}       

interface

uses gfx;

type
  TBox = object
    x, y     : integer;
    oldx, oldy : integer;
    dx, dy   : integer;
    color    : byte;
    procedure Init;
    procedure Move;
    procedure Draw;
    procedure Erase;
  end;

implementation

procedure TBox.Init;
begin
  x := random(SCREEN_WIDTH - 16);
  y := random(SCREEN_HEIGHT - 16);
  oldx := x;
  oldy := y;
  dx := random(3) + 1;
  dy := random(3) + 1;
  color := random(15) + 1;
end;

procedure TBox.Move;
begin
  oldx := x;
  oldy := y;
  inc(x, dx);
  inc(y, dy);

  if (x < 0) or (x > SCREEN_WIDTH - 16) then
    dx := -dx;
  if (y < 0) or (y > SCREEN_HEIGHT - 16) then
    dy := -dy;
end;

procedure TBox.Draw; assembler;
asm
  push ds
  push es
  push bp

  lds  si, Self
  mov  bx, [si]            { x }
  mov  dx, [si+2]          { y }
  mov  al, [si+12]         { color }
  mov  ah, al

  les  di, ScreenTarget

  mov  bp, dx
  shl  bp, 6
  mov  cx, dx
  shl  cx, 8
  add  bp, cx
  add  bp, bx
  add  di, bp

  mov  cx, 16
@row:
  push cx
  mov  cx, 8
  rep  stosw
  add  di, SCREEN_WIDTH - 16
  pop  cx
  loop @row

  pop bp
  pop es
  pop ds
end;

procedure TBox.Erase; assembler;
asm
  push ds
  push es

  les  di, ScreenTarget
  lds  si, Self
  mov  bx, [si+4]          { oldx }
  mov  dx, [si+6]          { oldy }
  xor  ax, ax              { color = 0 }

  mov  di, dx
  shl  di, 6
  mov  cx, dx
  shl  cx, 8
  add  di, cx
  add  di, bx

  mov  cx, 16
@row:
  push cx
  mov  cx, 8
  rep  stosw
  add  di, SCREEN_WIDTH - 16
  pop  cx
  loop @row

  pop es
  pop ds
end;

end.