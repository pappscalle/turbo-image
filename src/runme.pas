program Runme;

{$G+}

uses crt, gfx;

begin

  SetVideoMode($13);

  repeat

    SetPixel(random(320), random(200), random (256));

  until KeyPressed;

  SetVideoMode($03);

end.
