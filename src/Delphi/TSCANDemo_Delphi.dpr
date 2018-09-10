program TSCANDemo_Delphi;

uses
  Vcl.Forms,
  fDemo in 'fDemo.pas' {frmTSCANDemo},
  uTSCAN in 'uTSCAN.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTSCANDemo, frmTSCANDemo);
  Application.Run;
end.
