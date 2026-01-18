program Units;

{$G+}

uses crt, gfx, box;

const 
  NUM_BOXES = 5;

var
  i : integer;
  boxes : array[1..NUM_BOXES] of TBox;

begin
  Randomize;
  OpenGraphics;
  
  for i := 1 to NUM_BOXES do
    boxes[i].Init;

  repeat
    for i := 1 to NUM_BOXES do boxes[i].Move;

    WaitRetrace;
    for i := 1 to NUM_BOXES do boxes[i].Erase;
    for i := 1 to NUM_BOXES do boxes[i].Draw;

  until KeyPressed;

  CloseGraphics;

end.
