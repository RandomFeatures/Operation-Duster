program Duster;

uses
  Windows,
  Forms,
  Main in 'Main.pas' {MainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Operation Duster';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
