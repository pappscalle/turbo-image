program UnitsBuf;

{$G+}

uses crt, gfx, gfxbuf, box;

const
  NUM_BOXES = 5;

var
  i : integer;
  boxes : array[1..NUM_BOXES] of TBox;

begin
  Randomize;
  OpenGraphics;
  InitBuffer;             
  for i := 1 to NUM_BOXES do
    boxes[i].Init;

  repeat
    for i := 1 to NUM_BOXES do boxes[i].Move;

    for i := 1 to NUM_BOXES do boxes[i].Erase;
    for i := 1 to NUM_BOXES do boxes[i].Draw;

    WaitRetrace;
    FlipBuffer;            
  until KeyPressed;

  DoneBuffer;             
  CloseGraphics;
end.
