program ControleTarefas;

uses
  Vcl.Forms,
  untTarefas in 'View\untTarefas.pas' {frmControleTarefas},
  untDM in 'DAO\untDM.pas' {DM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmControleTarefas, frmControleTarefas);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
