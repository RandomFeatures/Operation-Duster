unit Main;

interface

uses
  Windows, SysUtils, Graphics, Forms,
  DXClass, DXSprite, DXDraws, DXSounds, DirectX,
  DIB, Controls, ExtCtrls, Classes, DXInput;

type
  TMainForm = class(TDXForm)
    DXTimer: TDXTimer;
    DXDraw: TDXDraw;
    DXSpriteEngine: TDXSpriteEngine;
    ImageList: TDXImageList;
    Clock: TTimer;
    DXSound1: TDXSound;
    DXWaveList1: TDXWaveList;
    DXInput: TDXInput;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DXDrawFinalize(Sender: TObject);
    procedure DXDrawInitialize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DXTimerTimer(Sender: TObject; LagCount: Integer);
    procedure DXTimerActivate(Sender: TObject);
    procedure DXTimerDeactivate(Sender: TObject);
    procedure DXDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DXDrawMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DXDrawMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ClockTimer(Sender: TObject);
    procedure letsBegin;

  private
    FAngle: Integer;
   // FMoveMode: Boolean;
      FSurface: TDirectDrawSurface;
  end;


var
  MainForm: TMainForm;
  mousex: integer;
  mousey: integer;
  mousecontrol: boolean;
  count : integer;
  GameNow: Boolean;
  GameOver:Boolean;
 implementation

{$R *.DFM}

type
  {Mail boxes, Stop Signs, Fire Hydrants(sp)}
  TStuffSprite = class(TImageSprite)
  private
    FCounter: Double;
    FS: Integer;
    procedure Hit;
  public
    procedure DoMove(MoveCount: Integer); override;
  end;

  {Car}
  TCarSprite = class(TImageSprite)
  protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
  end;


procedure TStuffSprite.DoMove(MoveCount: Integer);
begin
  //TStuffSprite doenst actually move but the even makes a good time
  //so why not reuse rather than makeing another timer :)

  if Gameover then dead;
  inherited DoMove(MoveCount);

  if not Collisioned then
  begin
    Inc(FS, MoveCount);
    if FS>2000 then Dead;
  end;
end;

procedure TStuffSprite.Hit;
begin
     {Was Hit}
     Collisioned := False;
      //play wave file
     MainForm.DXWaveList1.Items.Find('bonk').Play(False);
     //Put up the right damaged image
     if Image  = MainForm.ImageList.Items.Find('mail') then
        Image := MainForm.ImageList.Items.Find('mailbroke');
     if Image  = MainForm.ImageList.Items.Find('stop') then
        Image := MainForm.ImageList.Items.Find('stopbroke');
     if Image  = MainForm.ImageList.Items.Find('fire') then
        Image := MainForm.ImageList.Items.Find('firebroke');

end;

procedure TCarSprite.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  //Hit something with the car
  if Sprite is TStuffSprite then
    TStuffSprite(Sprite).Hit;
  Done := False;
end;

procedure TCarSprite.DoMove(MoveCount: Integer);
var
  MsgSize     :  Integer;
  mouseright  :  string;
  test        :  boolean;
  xpos        :  boolean;
  ypos        :  boolean;
  xneg        :  boolean;
  yneg        :  boolean;
begin
     Test := false;
     xpos := false;
     ypos := false;
     xneg := false;
     yneg := false;

  inherited DoMove(MoveCount);
  if Gameover then
  begin
       dead;
  end;
  //using the mouse to move
  if mousecontrol = true then
  begin
        if mousex  > 340 then
             begin
                  xpos:=true;
                  if mousex > 475 then
                     X := X + (500/1000)*MoveCount
                  else
                     X := X + (300/1000)*MoveCount;
             end;
          if mousex < 300 then
             begin
               xneg:=true;
               if mousex < 156 then
                  X := X - (500/1000)*MoveCount
               else
                  X := X - (300/1000)*MoveCount;
             end;

          if mousey > 260 then
             begin
                 ypos := true;
                  if mousey > 395 then
                     Y := Y + (500/1000)*MoveCount
                  else
                      Y := Y + (300/1000)*MoveCount;
             end;
          if mousey < 220 then
           begin
               yneg := true;
                if mousey < 85 then
                   Y := Y - (500/1000)*MoveCount
                else
                    Y := Y - (300/1000)*MoveCount;
           end;
  end;

  //Using Joystick or keyboard to move
  if isUp in MainForm.DXInput.States then
     begin
          ypos := false;
          yneg := true;
          Y := Y - (500/1000)*MoveCount;
     end;

  if isDown in MainForm.DXInput.States then
     begin
          ypos := true;
          yneg := false;
          Y := Y + (500/1000)*MoveCount;
     end;

  if isLeft in MainForm.DXInput.States then
     begin
          xpos := false;
          xneg := true;
          X := X - (500/1000)*MoveCount;
     end;

  if isRight in MainForm.DXInput.States then
     begin
          xpos := true;
          xneg := false;
          X := X + (500/1000)*MoveCount;
     end;

 //Pick the right car image
 if (xpos = true) and (ypos = false) and (yneg = false)then
    Image := MainForm.ImageList.Items.Find('right');

 if (xpos = true) and (ypos = true) and (yneg = false)then
    Image := MainForm.ImageList.Items.Find('rightdown');

 if (xpos = true) and (ypos = false) and (yneg = true)then
    Image := MainForm.ImageList.Items.Find('rightup');

 if (xneg = true) and (ypos = false) and (yneg = false)then
    Image := MainForm.ImageList.Items.Find('left');

 if (xneg = true) and (ypos = true) and (yneg = false)then
    Image := MainForm.ImageList.Items.Find('leftdown');

 if (xneg = true) and (ypos = false) and (yneg = true)then
    Image := MainForm.ImageList.Items.Find('leftup');

 if (ypos = true) and (xpos = false) and (xneg = false)then
    Image := MainForm.ImageList.Items.Find('down');

if (yneg = true) and (xpos = false) and (xneg = false)then
    Image := MainForm.ImageList.Items.Find('up');

  Collision; //check for a collision with the TStuffSprite


  if mousecontrol = true then mouseright := '1' else mouseright := '0';
  //Move the view screen
  Engine.X := -X+Engine.Width div 2-Width div 2;
  Engine.Y := -Y+Engine.Height div 2-Height div 2;



end;



procedure TMainForm.DXTimerActivate(Sender: TObject);
begin
  Caption := Application.Title;
end;

procedure TMainForm.DXTimerDeactivate(Sender: TObject);
begin
  //took the pause out
  Caption := Application.Title + ' [Pause]';
end;

procedure TMainForm.DXTimerTimer(Sender: TObject; LagCount: Integer);
var
i: integer;
begin
  //Rapper Event for the Application.onIdle
  //Makes a damn fast timer but has a down side
  //this method restrices you to one times and
  //pocessor speed will affect the game speed
  if not DXDraw.CanDraw then exit;  //make sure everything is Ok
  if (count = 0) or (DXSpriteEngine.Engine.AllCount -2 = 0) then
     gameover := True; //were done

  DXInput.Update;// watch for stuff from a joystick and/or keyboard

     if Not GameNow then
        begin //Intro Screen
             DXDraw.Surface.Fill(0);
             ImageList.Items[9].DrawAdd(DXDraw.Surface, Bounds(7, 20, 623, 421),0, Trunc(Cos256(FAngle)*126+127));
             with DXDraw.Surface.Canvas do
             begin
                 Brush.Style := bsClear;
                 Font.Color := clWhite;
                 Font.Size := 12;
                 Font.Style := [];
                 Textout(5,0, 'Press F2 to play');
                 if GameOver then //End screen
                    begin
                         Clock.enabled := false;
                         if DXSpriteEngine.Engine.AllCount -2 = 0 then
                         Textout(5,24, 'Good Job!  You ran over everything')
                         else
                          Textout(5,24, 'Sorry! You ran out of time! Better luck next time.');
                         Font.Color := clRed;
                         Font.Size := 24;
                         Font.Style := [fsBold];
                         Textout(5,400, 'GAME OVER');
                    end;
                 Release;
            end;

            Inc(FAngle);
        end
     else
         begin //playing the game
              DXSpriteEngine.Move(LagCount);
              DXSpriteEngine.Dead;

              {  Description  }
              DXDraw.Surface.Fill(0);
              DXSpriteEngine.Draw;

              with DXDraw.Surface.Canvas do
              begin
                   Brush.Style := bsClear;
                   Font.Color := clWhite;
                   Font.Size := 12;
                   Font.Style := [];

                   if DXSpriteEngine.Engine.AllCount -52 = 0 then
                      Textout(5,0, 'Good Job!  You smashed everything')
                   else
                       Textout(5, 0, 'Obsticles Left to smash: '+inttostr(DXSpriteEngine.Engine.AllCount -2));

                   Font.Style := [fsBold];
                   Font.Color := clBlue;
                   Textout(5, 24, 'Time Remaining: '+IntToStr(count));
                   Release;
              end;
         end;
     //Keep of with score or whatever
     if (count = 0) or (DXSpriteEngine.Engine.AllCount -2 = 0) then
        gamenow := false;

     DXDraw.Surface.Draw(mouseX-FSurface.Width div 2, mousey-FSurface.Height div 2, FSurface.ClientRect, FSurface, True);
     DXDraw.Flip; //from the back buffer to the screen

end;

procedure TMainForm.DXDrawFinalize(Sender: TObject);
begin //clean up
     DXTimer.Enabled := False;
     FSurface.Free;  FSurface := nil;
end;

procedure TMainForm.DXDrawInitialize(Sender: TObject);
begin //setup
     DXTimer.Enabled := True;
     FSurface := TDirectDrawSurface.Create(DXDraw.DDraw);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Randomize;
  ImageList.Items.MakeColorTable;

  DXDraw.ColorTable := ImageList.Items.ColorTable;
  DXDraw.DefColorTable := ImageList.Items.ColorTable;
  DXDraw.UpdatePalette;

  with TBackgroundSprite.Create(DXSpriteEngine.Engine) do
  begin
       SetMapSize(1, 1);
       Image := ImageList.Items.Find('background');
       Z := -2;
       Tile := True;
  end;

  Count:= 600;
  GameNow := False;
  GameOver:= False;

end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {  Application end  }
  if Key=VK_ESCAPE then
    Close;

  if Key=VK_RETURN then
  begin
    key := 0;
  end;
  if Key=VK_F2 then
  begin
    if not GameNow then
    letsbegin;
  end;

  {  Screen mode change  }
  if Key=VK_F4 then
  begin
    DXDraw.Finalize;

    if doFullScreen in DXDraw.Options then
    begin
      RestoreWindow;

      DXDraw.Cursor := crCross;
      BorderStyle := bsSizeable;
      DXDraw.Options := DXDraw.Options - [doFullScreen];
    end else
    begin
      StoreWindow;

//     DXDraw.Cursor := crCross;
      BorderStyle := bsNone;
      DXDraw.Options := DXDraw.Options + [doFullScreen];
    end;
    DXDraw.Initialize;

  end;
end;

procedure TMainForm.DXDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
    mousex:= x;
    mousey:= y;
end;

procedure TMainForm.DXDrawMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
  rd: integer;
begin
  Randomize;
     //Beep the horn
     if button = mbRight then
        mousecontrol := true;
     If button = mbLeft then
     begin
          rd := random(2);
          if rd = 0 then
             MainForm.DXWaveList1.Items.Find('horn').Play(False)
          else
          MainForm.DXWaveList1.Items.Find('horn2').Play(False);
     end;
     if GameNow then
end;

procedure TMainForm.DXDrawMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     //Stop moving when mouse is released
     if button = mbRight then
        mousecontrol := false;
end;


procedure TMainForm.ClockTimer(Sender: TObject);
begin
     if count > 0 then
        dec(count);
end;

procedure TMainForm.letsBegin;
var
  i  : Integer;
  rd : Integer;
begin
  Gamenow  := true;
  Count    := 600;
  GameOver := false;
  Clock.enabled := true;
  Randomize;


  for i:=0 to 199 do
    with TStuffSprite.Create(DXSpriteEngine.Engine) do
    begin
      rd := Random(3);

      If rd = 0 then
         Image := ImageList.Items.Find('stop');
      If rd = 1 then
         Image := ImageList.Items.Find('fire');
      If rd = 2 then
         Image := ImageList.Items.Find('mail');

      X := Random(5000)-2500;
      Y := Random(5000)-2500;
      Z := 2;
      Width := Image.Width;
      Height := Image.Height;
      FCounter := Random(MaxInt);

    end;
  //Create our car
  with TCarSprite.Create(DXSpriteEngine.Engine) do
  begin
    Image := ImageList.Items.Find('up');
    Z := 3;
    Width := Image.Width;
    Height := Image.Height;
  end;


end;

end.

